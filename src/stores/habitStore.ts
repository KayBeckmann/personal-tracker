// src/stores/habitStore.ts
import { defineStore } from 'pinia';
import { db, type Habit, type HabitEntry } from '@/services/db';
import { liveQuery, type Subscription } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';
import type { HabitForDisplay } from '@/types';

function getTodayDateString(): string {
  return new Date().toISOString().split('T')[0]; // YYYY-MM-DD
}

// Hilfsfunktion: Gibt den Montag der Woche für ein gegebenes Datum zurück.
function getStartOfWeek(date: Date): Date {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Passe an, sodass Montag der erste Tag ist
  return new Date(d.setDate(diff));
}

// Hilfsfunktion: Gibt den ersten Tag des Monats für ein gegebenes Datum zurück.
function getStartOfMonth(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), 1);
}

export const useHabitStore = defineStore('habits', () => {
  const habits = ref<Habit[]>([]);
  const habitEntries = ref<HabitEntry[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveHabitsQuerySubscription: Subscription | null = null;
  let liveHabitEntriesQuerySubscription: Subscription | null = null;

  const fetchAllData = () => {
    isLoading.value = true;
    error.value = null;
    Promise.all([
      new Promise<void>((resolve, reject) => {
        if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();
        const obs = liveQuery(() => db.habits.orderBy('createdAt').toArray());
        liveHabitsQuerySubscription = obs.subscribe({
          next: res => { habits.value = res; resolve(); },
          error: err => {
            console.error('Dexie liveQuery error (habits):', err);
            error.value = "Failed to load habits";
            reject(err);
          }
        });
      }),
      new Promise<void>((resolve, reject) => {
        if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();
        const obs = liveQuery(() => db.habitEntries.orderBy('date').toArray());
        liveHabitEntriesQuerySubscription = obs.subscribe({
          next: res => { habitEntries.value = res; resolve(); },
          error: err => {
            console.error('Dexie liveQuery error (habitEntries):', err);
            error.value = "Failed to load habit entries";
            reject(err);
          }
        });
      })
    ]).then(() => {
      habits.value.forEach((habit: Habit) => {
        if (habit.id !== undefined) {
          updateHabitStreak(habit.id);
        }
      });
    }).catch(err => {
        console.error("Error fetching all habit data:", err);
        if (!error.value) {
            error.value = "Failed to load all habit data.";
        }
    }).finally(() => {
      isLoading.value = false;
    });
  };

  const addHabit = async (habitData: Omit<Habit, 'id' | 'createdAt' | 'streak' | 'lastCompleted' | 'description'> & { description?: string }) => {
    try {
      await db.habits.add({
        name: habitData.name,
        frequency: habitData.frequency,
        description: habitData.description || '',
        streak: 0,
        createdAt: new Date(),
      });
      error.value = null;
    } catch (e) {
      console.error('Failed to add habit:', e);
      error.value = 'Failed to add habit.';
    }
  };

  const updateHabit = async (habit: Habit) => {
    if (habit.id === undefined) {
      error.value = 'Habit ID is undefined, cannot update.';
      return;
    }
    try {
      await db.habits.update(habit.id, habit);
      error.value = null;
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
      error.value = null;
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
      await updateHabitStreak(habitId);
      error.value = null;
    } catch (e) {
      console.error('Failed to log habit date:', e);
      error.value = 'Failed to log habit completion.';
    }
  };
  
  const toggleHabitCompletionForToday = async (habitId: number) => {
    const todayStr = getTodayDateString();
    const habit = habits.value.find((h: Habit) => h.id === habitId);
    if (!habit || habit.id === undefined) {
        error.value = 'Habit not found.';
        return;
    }
    const isCompleted = isHabitCompletedOnDate(habit.id, todayStr);
    await logHabitDate(habit.id, todayStr, !isCompleted);
  };

  const isHabitCompletedOnDate = (habitId: number, date: string): boolean => {
    return habitEntries.value.some(entry => entry.habitId === habitId && entry.date === date && entry.completed);
  }

  const updateHabitStreak = async (habitId: number) => {
    const habit = habits.value.find(h => h.id === habitId);
    if (!habit) return;

    const allEntriesForHabit = await db.habitEntries.where('habitId').equals(habitId).toArray();
    const completedEntries = allEntriesForHabit
        .filter(e => e.completed)
        .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    if (completedEntries.length === 0) {
      await updateHabit({ ...habit, streak: 0, lastCompleted: undefined });
      return;
    }

    const lastCompletionDate = new Date(completedEntries[0].date);
    const today = new Date(getTodayDateString());
    let currentStreak = habit.streak;
    let isBroken = false;

    switch (habit.frequency) {
        case 'daily':
            const diffDays = (today.getTime() - lastCompletionDate.getTime()) / (1000 * 3600 * 24);
            if (diffDays > 1) {
                isBroken = true;
            }
            break;
        case 'weekly':
            const startOfThisWeek = getStartOfWeek(today);
            if (lastCompletionDate < startOfThisWeek) {
                isBroken = true;
            }
            break;
        case 'monthly':
            const startOfThisMonth = getStartOfMonth(today);
            if (lastCompletionDate < startOfThisMonth) {
                isBroken = true;
            }
            break;
    }

    if (isBroken) {
        currentStreak = 0;
    } else {
        // Neuberechnung des Streaks basierend auf den Einträgen
        // Diese Logik kann komplex sein, hier eine vereinfachte Version:
        // Ein einfacher Ansatz ist, nur den letzten Eintrag zu prüfen.
        // Bei täglichen Gewohnheiten könnte man eine Kette prüfen.
        // Für wöchentlich/monatlich ist ein einfacher "gemacht in diesem Zeitraum" Ansatz oft ausreichend.
        currentStreak = completedEntries.length > 0 ? 1 : 0; // Simple "done" flag für wöchentlich/monatlich
        if (habit.frequency === 'daily' && !isBroken) {
            // Eine genauere tägliche Streak-Berechnung...
            let streak = 0;
            let expectedDate = new Date(today);
            if((today.getTime() - lastCompletionDate.getTime()) / (1000 * 3600 * 24) > 1){
                // streak stays 0
            } else {
                 if((today.getTime() - lastCompletionDate.getTime()) / (1000 * 3600 * 24) <= 1){
                     expectedDate = new Date(lastCompletionDate);
                 }

                for (const entry of completedEntries) {
                    const entryDate = new Date(entry.date);
                    if (entryDate.toISOString().split('T')[0] === expectedDate.toISOString().split('T')[0]) {
                        streak++;
                        expectedDate.setDate(expectedDate.getDate() - 1);
                    } else {
                        break;
                    }
                }
            }
            currentStreak = streak;
        }
    }

    await updateHabit({ ...habit, streak: currentStreak, lastCompleted: lastCompletionDate });
  };


  const getHabitById = (id: number): Habit | undefined => {
    return habits.value.find(h => h.id === id);
  }

  const getEntriesForHabit = (habitId: number): HabitEntry[] => {
    return habitEntries.value.filter(entry => entry.habitId === habitId);
  }

  const habitsForTodayDashboard = computed((): HabitForDisplay[] => {
    const todayStr = getTodayDateString();
    return habits.value.map((habit) => {
      const completedToday = isHabitCompletedOnDate(habit.id!, todayStr);
      return {
        ...habit,
        completedToday,
        isDue: true,
      };
    });
  });

  onMounted(fetchAllData);

  onUnmounted(() => {
    liveHabitsQuerySubscription?.unsubscribe();
    liveHabitEntriesQuerySubscription?.unsubscribe();
  });

  return {
    habits,
    habitEntries,
    isLoading,
    error,
    addHabit,
    updateHabit,
    deleteHabit,
    logHabitDate,
    toggleHabitCompletionForToday,
    isHabitCompletedOnDate,
    updateHabitStreak,
    getHabitById,
    getEntriesForHabit,
    fetchAllData,
    habitsForTodayDashboard,
    getTodayDateString
  };
});