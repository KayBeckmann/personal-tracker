<template>
  <div class="habits-view">
    <h1>Gewohnheiten Verwalten</h1>

    <section class="habit-form-section">
      <h2>{{ editingHabit ? 'Gewohnheit Bearbeiten' : 'Neue Gewohnheit Erstellen' }}</h2>
      <HabitForm :habit-to-edit="editingHabit" @submit-habit="saveHabit" @cancel-edit="cancelEdit" />
    </section>

    <section class="habits-list-section">
      <h2>Meine Gewohnheiten</h2>
      <div v-if="habitStore.isLoading && habitStore.habits.length === 0" class="loading-message">Lade Gewohnheiten...</div>
      <div v-if="habitStore.error" class="error-message">{{ habitStore.error }}</div>
      <div v-if="!habitStore.isLoading && habitStore.habits.length === 0 && !habitStore.error" class="empty-state">
        Noch keine Gewohnheiten erstellt.
      </div>
      <div v-if="habitStore.habits.length > 0" class="habits-list">
        <HabitListItem
          v-for="habit in displayableHabits"
          :key="habit.id"
          :habit="habit"
          :show-details-button="false" 
          :show-delete-button="true"
          @delete-habit="confirmDeleteHabit"
          @completion-toggled="handleCompletionToggleInList(habit.id!)"
        />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useHabitStore } from '@/stores/habitStore';
import HabitForm from '@/components/habits/HabitForm.vue';
import HabitListItem from '@/components/habits/HabitListItem.vue';
import type { Habit, HabitEntry } from '@/services/db';

interface HabitForDisplay extends Habit {
  completedToday: boolean;
  isDue: boolean; // We might not use 'isDue' as strictly here as on dashboard
}

const habitStore = useHabitStore();
const editingHabit = ref<Habit | null>(null);

onMounted(() => {
  // Data is fetched by the store on its own onMounted
});

const displayableHabits = computed<HabitForDisplay[]>(() => {
  const todayStr = habitStore.getTodayDateString();
  return habitStore.habits.map(h => ({
    ...h,
    completedToday: habitStore.isHabitCompletedOnDate(h.id!, todayStr),
    isDue: true // For the habits list, all are "due" for management
  })).sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
});

const saveHabit = async (habitData: Omit<Habit, 'createdAt' | 'streak' | 'lastCompleted'> | Habit) => {
  if ('id' in habitData && habitData.id !== undefined) { // Update existing habit
    // Ensure all fields of Habit are present for update
    const fullHabitData: Habit = {
        id: habitData.id,
        name: habitData.name,
        description: habitData.description || '',
        frequency: habitData.frequency,
        streak: (props.habitToEdit || habitStore.getHabitById(habitData.id))?.streak || 0,
        createdAt: (props.habitToEdit || habitStore.getHabitById(habitData.id))?.createdAt || new Date(),
        lastCompleted: (props.habitToEdit || habitStore.getHabitById(habitData.id))?.lastCompleted,
    };
    await habitStore.updateHabit(fullHabitData);
  } else { // Add new habit
    // Explicitly cast to the type expected by addHabit
    const newHabitData: Omit<Habit, 'id' | 'createdAt' | 'streak' | 'lastCompleted'| 'description'> & { description?: string } = {
        name: habitData.name,
        frequency: habitData.frequency,
        description: habitData.description
    };
    await habitStore.addHabit(newHabitData);
  }
  editingHabit.value = null; // Reset form state
};

const handleEditHabit = (habit: Habit) => {
  editingHabit.value = { ...habit }; // Clone to avoid direct mutation if form is cancelled
};

const cancelEdit = () => {
  editingHabit.value = null;
}

const confirmDeleteHabit = (id: number) => {
  if (window.confirm('Bist du sicher, dass du diese Gewohnheit und alle zugehörigen Einträge löschen möchtest?')) {
    habitStore.deleteHabit(id);
  }
};

const handleCompletionToggleInList = (habitId: number) => {
  // This is mostly for display consistency if we show completion status in the main list.
  // The actual logic is handled by HabitListItem and the store.
  console.log(`Completion toggled for habit ${habitId} in the list view.`);
  // Potentially force a re-fetch or rely on live queries
  // habitStore.fetchAllData(); // Could be too aggressive
};

</script>

<style scoped>
.habits-view {
  padding: 20px;
  text-align: left;
}
.habits-view h1 {
  color: var(--color-heading);
  margin-bottom: 30px;
  text-align: center;
}
.habits-view h2 {
  color: var(--color-text-soft);
  border-bottom: 1px solid var(--color-border-soft);
  padding-bottom: 8px;
  margin-top: 30px;
  margin-bottom: 20px;
  font-size: 1.4em;
}

.habit-form-section, .habits-list-section {
  margin-bottom: 40px;
  padding: 20px;
  background-color: var(--color-background-soft);
  border-radius: 8px;
  box-shadow: 0 1px 5px rgba(0,0,0,0.03);
}

.loading-message, .error-message, .empty-state {
  padding: 15px;
  margin-top: 10px;
  border-radius: 4px;
  text-align: center;
}

.loading-message {
  background-color: var(--color-info-background);
  color: var(--color-info-text);
  border: 1px solid var(--color-info-border);
}

.error-message {
  background-color: var(--color-warning-background);
  color: var(--color-warning-text);
  border: 1px solid var(--color-warning-border);
}
.empty-state {
  color: var(--color-text-light);
  padding: 20px;
}

.habits-list {
  display: grid;
  gap: 10px;
}
</style>