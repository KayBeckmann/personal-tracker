// src/stores/habitStore.ts
import { defineStore } from 'pinia';
import { db, type Habit, type HabitEntry } from '@/services/db';
import { liveQuery } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

function getTodayDateString(): string {
  return new Date().toISOString().split('T')[0]; // YYYY-MM-DD
}

export const useHabitStore = defineStore('habits', () => {
  const habits = ref<Habit[]>([]);
  const habitEntries = ref<HabitEntry[]>([]); // Alle Einträge laden für Flexibilität
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveHabitsQuerySubscription: ZenObservable.Subscription | null = null;
  let liveHabitEntriesQuerySubscription: ZenObservable.Subscription | null = null;

  const fetchHabits = () => {
    isLoading.value = true;
    error.value = null;
    if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();

    const observable = liveQuery(() => db.habits.orderBy('createdAt').toArray());
    liveHabitsQuerySubscription = observable.subscribe({
      next: (result) => {
        habits.value = result;
        // isLoading.value = false; // Wird durch fetchAllData gesteuert
      },
      error: (err) => {
        console.error('Dexie liveQuery error (habits):', err);
        error.value = 'Failed to load habits.';
        isLoading.value = false;
      },
    });
  };

  const fetchHabitEntries = () => {
    // isLoading.value = true; // Wird durch fetchAllData gesteuert
    error.value = null;
    if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();

    const observable = liveQuery(() => db.habitEntries.orderBy('date').toArray());
    liveHabitEntriesQuerySubscription = observable.subscribe({
      next: (result) => {
        habitEntries.value = result;
        // isLoading.value = false; // Wird durch fetchAllData gesteuert
      },
      error: (err) => {
        console.error('Dexie liveQuery error (habitEntries):', err);
        error.value = 'Failed to load habit entries.';
        isLoading.value = false;
      },
    });
  };

  const fetchAllData = () => {
    isLoading.value = true;
    Promise.all([
        new Promise<void>(resolve => {
            if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();
            const obs = liveQuery(() => db.habits.orderBy('createdAt').toArray());
            liveHabitsQuerySubscription = obs.subscribe({
                next: res => { habits.value = res; resolve(); },
                error: err => { console.error(err); error.value = "Failed to load habits"; resolve(); }
            });
        }),
        new Promise<void>(resolve => {
            if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();
            const obs = liveQuery(() => db.habitEntries.orderBy('date').toArray());
            liveHabitEntriesQuerySubscription = obs.subscribe({
                next: res => { habitEntries.value = res; resolve(); },
                error: err => { console.error(err); error.value = "Failed to load habit entries"; resolve(); }
            });
        })
    ]).finally(() => {
        isLoading.value = false;
    });
  };


  const addHabit = async (habit: Omit<Habit, 'id' | 'createdAt' | 'streak' | 'lastCompleted'>) => {
    try {
      await db.habits.add({
        ...habit,
        streak: 0,
        createdAt: new Date(),
      });
    } catch (e) {
      console.error('Failed to add habit:', e);
      error.value = 'Failed to add habit.';
    }
  };

  const updateHabit = async (habit: Habit) => {
    if (habit.id === undefined) return;
    try {
      await db.habits.update(habit.id, habit);
    } catch (e) {
      console.error('Failed to update habit:', e);
      error.value = 'Failed to update habit.';
    }
  };

  const deleteHabit = async (id: number) => {
    try {
      await db.transaction('rw', db.habits, db.habitEntries, async () => {
        await db.habits.delete(id);
        await db.habitEntries.where('habitId').equals(id).delete();
      });
    } catch (e) {
      console.error('Failed to delete habit and its entries:', e);
      error.value = 'Failed to delete habit.';
    }
  };

  const logHabitDate = async (habitId: number, date: string, completed: boolean) => {
    try {
      const existingEntry = await db.habitEntries.where({ habitId, date }).first();
      if (existingEntry) {
        await db.habitEntries.update(existingEntry.id!, { completed });
      } else {
        await db.habitEntries.add({ habitId, date, completed });
      }
      await updateHabitStreak(habitId); // Streak aktualisieren
    } catch (e) {
      console.error('Failed to log habit date:', e);
      error.value = 'Failed to log habit completion.';
    }
  };

  const isHabitCompletedOnDate = (habitId: number, date: string): boolean => {
    return habitEntries.value.some(entry => entry.habitId === habitId && entry.date === date && entry.completed);
  }

  const updateHabitStreak = async (habitId: number) => {
    const habit = habits.value.find(h => h.id === habitId);
    if (!habit) return;

    const entriesForHabit = habitEntries.value
        .filter(e => e.habitId === habitId && e.completed)
        .sort((a, b) => b.date.localeCompare(a.date)); // Neueste zuerst

    let currentStreak = 0;
    let lastCompletionDate: string | null = null;

    if (entriesForHabit.length === 0) {
        await updateHabit({ ...habit, streak: 0, lastCompleted: null });
        return;
    }

    const todayStr = getTodayDateString();
    let expectedDate = new Date(todayStr);

    for (const entry of entriesForHabit) {
        const entryDate = new Date(entry.date);
        // Logik hängt stark von der "frequency" ab. Hier vereinfacht für 'daily'.
        // Für 'weekly' oder spezifische Tage müsste die Logik erweitert werden,
        // um zu prüfen, ob der Eintrag dem erwarteten Muster entspricht.

        if (habit.frequency === 'daily') {
            if (entry.date === expectedDate.toISOString().split('T')[0]) {
                currentStreak++;
                if (!lastCompletionDate) lastCompletionDate = entry.date;
                expectedDate.setDate(expectedDate.getDate() - 1); // Erwarte den vorherigen Tag
            } else if (entry.date < expectedDate.toISOString().split('T')[0]) {
                // Lücke im Streak gefunden, wenn der Eintrag älter ist als der erwartete Tag
                break;
            }
        } else {
            // TODO: Implementiere komplexere Streak-Logik für andere Frequenzen
            // Fürs Erste: wenn der letzte Eintrag heute ist, Streak = 1, sonst 0
            // Dies ist eine sehr grobe Vereinfachung
            if (entry.date === todayStr) {
                currentStreak = 1; // Minimaler Streak, wenn heute erledigt
                lastCompletionDate = entry.date;
            }
            break; // Für nicht-tägliche Habits, diese einfache Logik erstmal beibehalten
        }
    }
    await updateHabit({ ...habit, streak: currentStreak, lastCompleted: lastCompletionDate });
  };


  const getHabitById = async (id: number): Promise<Habit | undefined> => {
    return habits.value.find(h => h.id === id); // Aus dem ref nehmen für Live-Updates
  }

  const getEntriesForHabit = (habitId: number): HabitEntry[] => {
    return habitEntries.value.filter(entry => entry.habitId === habitId);
  }

  onMounted(() => {
    fetchAllData();
  });

  onUnmounted(() => {
    if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();
    if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();
  });

  return {
    habits,
    habitEntries, // Falls direkter Zugriff benötigt wird
    isLoading,
    error,
    addHabit,
    updateHabit,
    deleteHabit,
    logHabitDate,
    isHabitCompletedOnDate,
    updateHabitStreak, // manuell aufrufen nach Log-Änderungen
    getHabitById,
    getEntriesForHabit,
    fetchAllData
  };
});