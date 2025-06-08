<template>
    <div class="habit-list-item" :class="{ completed: habit.completedToday }">
      <div class="habit-info">
        <span class="habit-name">{{ habit.name }}</span>
        <span v-if="habit.description" class="habit-description">{{ habit.description }}</span>
        <span class="habit-streak">Streak: {{ habit.streak || 0 }}</span>
        <span class="habit-frequency">({{ habit.frequency }})</span>
      </div>
      <div class="habit-actions">
        <input
          type="checkbox"
          :id="'habit-checkbox-' + habit.id"
          :checked="habit.completedToday"
          @change="toggleCompletion"
          class="habit-checkbox"
        />
        <label :for="'habit-checkbox-' + habit.id" class="checkbox-label">
          {{ habit.completedToday ? 'Done' : 'Mark Done' }}
        </label>
        <button v-if="showDetailsButton" @click="$emit('view-details', habit.id)" class="btn-details">Details</button>
        <button v-if="showDeleteButton" @click="$emit('delete-habit', habit.id)" class="btn-delete">×</button>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { type Habit } from '@/services/db';
  import { useHabitStore } from '@/stores/habitStore';
  
  interface HabitForDisplay extends Habit {
    completedToday: boolean;
    isDue: boolean;
  }
  
  const props = defineProps<{
  habit: HabitForDisplay;
  showDetailsButton?: boolean;
  showDeleteButton?: boolean;
}>();
  
  const emit = defineEmits(['view-details', 'delete-habit', 'completion-toggled']);
  
  const habitStore = useHabitStore();
  
  const toggleCompletion = async () => {
    if (props.habit.id === undefined) return;
    const today = habitStore.getTodayDateString();
    await habitStore.logHabitDate(props.habit.id, today, !props.habit.completedToday);
    // The store's live query will update the `completedToday` status reactively through `habitsForTodayDashboard`
    // and subsequently `updateHabitStreak` will be called internally by logHabitDate.
    emit('completion-toggled');
  };
  </script>
  
  <style scoped>
  .habit-list-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 15px;
    border: 1px solid var(--color-border-soft);
    border-radius: 6px;
    margin-bottom: 10px;
    background-color: var(--color-background);
    transition: background-color 0.2s ease-in-out;
    text-align: left;
  }
  
  .habit-list-item.completed {
    background-color: var(--color-primary-light); /* Light green or similar */
    border-color: var(--color-primary-dark);
  }
  
  .habit-list-item.completed .habit-name {
    text-decoration: line-through;
    color: var(--color-text-light);
  }
  
  .habit-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  
  .habit-name {
    font-weight: 600;
    font-size: 1.1em;
    color: var(--color-heading);
  }
  
  .habit-description {
    font-size: 0.9em;
    color: var(--color-text-soft);
    margin-left: 5px;
  }
  
  .habit-streak, .habit-frequency {
    font-size: 0.85em;
    color: var(--color-text-light);
  }
  
  .habit-actions {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .habit-checkbox {
    width: 20px;
    height: 20px;
    cursor: pointer;
    accent-color: var(--color-primary);
  }
  .checkbox-label {
    cursor: pointer;
    font-size: 0.9em;
    color: var(--color-primary-dark);
  }
  .habit-list-item.completed .checkbox-label {
      color: var(--color-text-light);
  }
  
  
  .btn-details, .btn-delete {
    padding: 6px 10px;
    font-size: 0.9em;
    border-radius: 4px;
    cursor: pointer;
    border: 1px solid transparent;
  }
  
  .btn-details {
    background-color: var(--color-info);
    color: white;
  }
  .btn-details:hover {
    background-color: var(--color-info-dark, #0a99b8);
  }
  
  .btn-delete {
    background-color: transparent;
    color: var(--color-danger);
    border: 1px solid var(--color-danger);
    font-weight: bold;
  }
  .btn-delete:hover {
    background-color: var(--color-danger);
    color: white;
  }
  </style>