// src/stores/habitStore.ts
import { defineStore } from 'pinia';
import { db, type Habit, type HabitEntry } from '@/services/db';
import { liveQuery, type Subscription } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

function getTodayDateString(): string {
  return new Date().toISOString().split('T')[0]; // YYYY-MM-DD
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
    error.value = null; // Reset error on new fetch
    Promise.all([
      new Promise<void>((resolve, reject) => { // Added reject
        if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();
        const obs = liveQuery(() => db.habits.orderBy('createdAt').toArray());
        liveHabitsQuerySubscription = obs.subscribe({
          next: res => { habits.value = res; resolve(); },
          error: err => {
            console.error('Dexie liveQuery error (habits):', err);
            error.value = "Failed to load habits";
            reject(err); // Propagate error
          }
        });
      }),
      new Promise<void>((resolve, reject) => { // Added reject
        if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();
        const obs = liveQuery(() => db.habitEntries.orderBy('date').toArray());
        liveHabitEntriesQuerySubscription = obs.subscribe({
          next: res => { habitEntries.value = res; resolve(); },
          error: err => {
            console.error('Dexie liveQuery error (habitEntries):', err);
            error.value = "Failed to load habit entries";
            reject(err); // Propagate error
          }
        });
      })
    ]).then(() => {
      // Refresh streaks for all habits after data is fetched
      habits.value.forEach((habit: Habit) => {
        if (habit.id !== undefined) {
          updateHabitStreak(habit.id);
        }
      });
    }).catch(err => {
        // isLoading is set to false in finally, but we can log aggregated error
        console.error("Error fetching all habit data:", err);
        if (!error.value) { // Set a general error if specific one wasn't set
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
        description: habitData.description || '', // Ensure description is always a string
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
      await updateHabitStreak(habitId); // Streak aktualisieren
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
    return habitEntries.value.some((entry: HabitEntry) => entry.habitId === habitId && entry.date === date && entry.completed);
  }

  const updateHabitStreak = async (habitId: number) => {
    const habit = habits.value.find((h: Habit) => h.id === habitId);
    if (!habit) return;

    // KORREKTUR: Lies die Einträge direkt aus der DB, um eine Race Condition 
    // mit dem reaktiven 'habitEntries' Ref zu vermeiden.
    const allEntriesForHabit = await db.habitEntries.where('habitId').equals(habitId).toArray();
    const entriesForHabit = allEntriesForHabit
        .filter((e: HabitEntry) => e.completed)
        .sort((a: HabitEntry, b: HabitEntry) => b.date.localeCompare(a.date));

    let currentStreak = 0;
    let lastCompletionDateObj: Date | null = null;

    if (entriesForHabit.length === 0) {
      await updateHabit({ ...habit, streak: 0, lastCompleted: undefined });
      return;
    }

    const today = new Date(getTodayDateString());
    let expectedDate = new Date(today);

    if (entriesForHabit.length > 0) {
        lastCompletionDateObj = new Date(entriesForHabit[0].date);
    }

    if (habit.frequency === 'daily') {
      const mostRecentEntryDate = new Date(entriesForHabit[0].date);
      const diffDaysWithToday = (today.getTime() - mostRecentEntryDate.getTime()) / (1000 * 3600 * 24);

      if (diffDaysWithToday > 1) {
         currentStreak = 0;
      } else {
        for (const entry of entriesForHabit) {
          const entryDate = new Date(entry.date);
          if (entryDate.toISOString().split('T')[0] === expectedDate.toISOString().split('T')[0]) {
            currentStreak++;
            expectedDate.setDate(expectedDate.getDate() - 1);
          } else if (entryDate < expectedDate) {
            break;
          }
        }
      }
    } else {
      if (entriesForHabit.length > 0 && entriesForHabit[0].date === getTodayDateString()) {
         currentStreak = entriesForHabit.length > 0 ? 1 : 0;
      } else if (entriesForHabit.length > 0) {
        currentStreak = 0;
      }
    }

    await updateHabit({ ...habit, streak: currentStreak, lastCompleted: lastCompletionDateObj || undefined });
  };

  const getHabitById = (id: number): Habit | undefined => {
    return habits.value.find((h: Habit) => h.id === id);
  }

  const getEntriesForHabit = (habitId: number): HabitEntry[] => {
    return habitEntries.value.filter((entry: HabitEntry) => entry.habitId === habitId);
  }

  const habitsForTodayDashboard = computed(() => {
    const todayStr = getTodayDateString();
    return habits.value.map((habit: Habit) => {
      const completedToday = isHabitCompletedOnDate(habit.id!, todayStr);
      let isDue = false;
      if (habit.frequency === 'daily') {
        isDue = true;
      } else if (habit.frequency === 'weekly') {
        isDue = true; 
      } else if (habit.frequency === 'monthly') {
        isDue = true;
      }
      return {
        ...habit,
        completedToday,
        isDue
      };
    }).filter((h: any) => h.isDue);
  });

  onMounted(() => {
    fetchAllData();
  });

  onUnmounted(() => {
    if (liveHabitsQuerySubscription) liveHabitsQuerySubscription.unsubscribe();
    if (liveHabitEntriesQuerySubscription) liveHabitEntriesQuerySubscription.unsubscribe();
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