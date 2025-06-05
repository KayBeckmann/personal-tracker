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
  const habitEntries = ref<HabitEntry[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveHabitsQuerySubscription: ZenObservable.Subscription | null = null;
  let liveHabitEntriesQuerySubscription: ZenObservable.Subscription | null = null;

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
      habits.value.forEach(habit => {
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

  const isHabitCompletedOnDate = (habitId: number, date: string): boolean => {
    return habitEntries.value.some(entry => entry.habitId === habitId && entry.date === date && entry.completed);
  }

  const updateHabitStreak = async (habitId: number) => {
    const habit = habits.value.find(h => h.id === habitId);
    if (!habit) return;

    const entriesForHabit = habitEntries.value
      .filter(e => e.habitId === habitId && e.completed)
      .sort((a, b) => b.date.localeCompare(a.date));

    let currentStreak = 0;
    let lastCompletionDateObj: Date | null = null; // Store as Date object

    if (entriesForHabit.length === 0) {
      await updateHabit({ ...habit, streak: 0, lastCompleted: undefined }); // Use undefined for db
      return;
    }

    const today = new Date(getTodayDateString()); // Normalized today
    let expectedDate = new Date(today); // Start expecting today or earlier

    // Set initial lastCompletionDateObj from the most recent completed entry
    if (entriesForHabit.length > 0) {
        lastCompletionDateObj = new Date(entriesForHabit[0].date);
    }


    if (habit.frequency === 'daily') {
      // If the most recent completion is not today or yesterday (for daily habits), streak is 0 unless it's today.
      const mostRecentEntryDate = new Date(entriesForHabit[0].date);
      const diffDaysWithToday = (today.getTime() - mostRecentEntryDate.getTime()) / (1000 * 3600 * 24);

      if (diffDaysWithToday > 1) {
         currentStreak = 0;
         // lastCompletionDateObj remains the actual last completed date
      } else {
        for (const entry of entriesForHabit) {
          const entryDate = new Date(entry.date);
          if (entryDate.toISOString().split('T')[0] === expectedDate.toISOString().split('T')[0]) {
            currentStreak++;
            expectedDate.setDate(expectedDate.getDate() - 1);
          } else if (entryDate < expectedDate) {
            // Streak broken before this entry
            break;
          }
        }
      }
    } else {
      // Simplified for weekly/monthly:
      // If completed today, streak increases by 1 (or starts at 1).
      // This is a placeholder for more complex logic (e.g., weekly means "completed this calendar week")
      // The current logic doesn't really build a "streak" in the traditional sense for non-daily.
      // It more reflects "consecutive periods of completion".
      // For now, if the latest entry is today, we consider it part of "a" streak.
      if (entriesForHabit.length > 0 && entriesForHabit[0].date === getTodayDateString()) {
         // A very simple approach: count how many recent entries match the frequency pattern.
         // This is still not a true "streak" for weekly/monthly in a calendar sense.
         // The original logic was: if completed today, streak = 1.
         // We can improve this slightly by at least checking the last completion.
         currentStreak = habit.streak; // Keep existing streak
         if(isHabitCompletedOnDate(habitId, getTodayDateString())){
            // If it wasn't completed yesterday (for daily) or this period (for others)
            // and now it is, the logic to increment is tricky without better period definition.
            // The original code for daily already handles incrementing,
            // The "else" branch here is for non-daily.
            // Let's assume for non-daily: if completed, it's at least 1.
            // If previous lastCompleted was for the current period, increment. This is still complex.
            // Sticking to a simpler interpretation: if you did it, your streak related to that completion.
            currentStreak = entriesForHabit.length > 0 ? 1 : 0; // Reset/start for simplicity for non-daily for now
            // A true weekly/monthly streak needs to check against calendar weeks/months.
         }
      } else if (entriesForHabit.length > 0) {
        currentStreak = 0; // If not completed today, break non-daily streak by this simple rule
      }
    }

    await updateHabit({ ...habit, streak: currentStreak, lastCompleted: lastCompletionDateObj || undefined });
  };

  const getHabitById = (id: number): Habit | undefined => { // No async needed if just filtering ref
    return habits.value.find(h => h.id === id);
  }

  const getEntriesForHabit = (habitId: number): HabitEntry[] => {
    return habitEntries.value.filter(entry => entry.habitId === habitId);
  }

  // Computed property for habits to display on the dashboard
  const habitsForTodayDashboard = computed(() => {
    const todayStr = getTodayDateString();
    return habits.value.map(habit => {
      const completedToday = isHabitCompletedOnDate(habit.id!, todayStr);
      // For weekly/monthly, "due today" is loosely interpreted as "can be done today".
      // A more precise system would involve specific due dates or day-of-week/month.
      let isDue = false;
      if (habit.frequency === 'daily') {
        isDue = true;
      } else if (habit.frequency === 'weekly') {
        // Placeholder: consider weekly habits always "potentially due"
        // Or, logic to check if it's the designated day of the week
        isDue = true; // Simplification: show all weekly
      } else if (habit.frequency === 'monthly') {
        // Placeholder: consider monthly habits always "potentially due"
        // Or, logic to check if it's the designated day/date of the month
        isDue = true; // Simplification: show all monthly
      }
      return {
        ...habit,
        completedToday,
        isDue // Indicates if it should be shown on a "today" list
      };
    }).filter(h => h.isDue); // Filter based on the isDue logic above
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
    isHabitCompletedOnDate,
    updateHabitStreak,
    getHabitById,
    getEntriesForHabit,
    fetchAllData,
    habitsForTodayDashboard, // Expose the new getter
    getTodayDateString // Expose for components if needed
  };
});