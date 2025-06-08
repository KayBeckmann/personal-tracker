<script setup lang="ts">
import { useHabitStore } from '@/stores/habitStore';
import HabitListItem from '@/components/habits/HabitListItem.vue';
import { storeToRefs } from 'pinia';
import { ref } from 'vue';
import type { Habit } from '@/services/db';

const habitStore = useHabitStore();
// FIX: Use the computed property that returns the correct HabitForDisplay type.
const { habitsForTodayDashboard, isLoading, error } = storeToRefs(habitStore);

const showAddForm = ref(false);
const newHabit = ref<Omit<Habit, 'id' | 'createdAt' | 'streak'>>({
  name: '',
  description: '',
  frequency: 'daily',
});

const addHabit = async () => {
  if (newHabit.value.name.trim()) {
    await habitStore.addHabit(newHabit.value);
    newHabit.value.name = '';
    newHabit.value.description = '';
    showAddForm.value = false;
  }
};
</script>

<template>
  <div class="habits-view">
    <div class="card">
      <div class="card-header">
        <h2>Habit Tracker</h2>
        <button @click="showAddForm = !showAddForm" class="btn btn-primary">
          {{ showAddForm ? 'Cancel' : 'Add Habit' }}
        </button>
      </div>

      <div v-if="showAddForm" class="add-habit-form card-body">
        <form @submit.prevent="addHabit">
          <div class="form-group">
            <label for="habit-name">Habit Name</label>
            <input type="text" id="habit-name" class="form-control" v-model="newHabit.name" required>
          </div>
          <div class="form-group">
            <label for="habit-desc">Description (Optional)</label>
            <input type="text" id="habit-desc" class="form-control" v-model="newHabit.description">
          </div>
          <div class="form-group">
            <label for="habit-freq">Frequency</label>
            <select id="habit-freq" class="form-control" v-model="newHabit.frequency">
              <option value="daily">Daily</option>
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
            </select>
          </div>
          <button type="submit" class="btn btn-success">Save Habit</button>
        </form>
      </div>

      <div v-if="isLoading" class="card-body">Loading habits...</div>
      <div v-if="error" class="card-body alert alert-danger">{{ error }}</div>

      <div v-if="!isLoading && !error" class="habit-list">
        <HabitListItem
          v-for="habit in habitsForTodayDashboard"
          :key="habit.id"
          :habit="habit"
          @completion-toggled="habitStore.toggleHabitCompletionForToday(habit.id!)"
          @delete-habit="habitStore.deleteHabit(habit.id!)"
        />
        <p v-if="habitsForTodayDashboard.length === 0">No habits found. Add one to get started!</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.alert-danger {
    color: var(--color-danger);
}
</style>