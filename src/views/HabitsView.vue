// src/views/HabitsView.vue

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useHabitStore } from '@/stores/habitStore';
import HabitForm from '@/components/habits/HabitForm.vue';
import HabitListItem from '@/components/habits/HabitListItem.vue';
import type { Habit } from '@/services/db';

const habitStore = useHabitStore();
const showForm = ref(false);
const habitToEdit = ref<Habit | null>(null);

const todayStr = habitStore.getTodayDateString;

interface HabitForDisplay extends Habit {
  completedToday: boolean;
}

const habitsForDisplay = computed<HabitForDisplay[]>(() => {
    return habitStore.habits
        .map((h: Habit) => ({
            ...h,
            completedToday: habitStore.isHabitCompletedOnDate(h.id!, todayStr()),
        }))
        .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
});


const handleSaveHabit = async (habitData: Omit<Habit, 'id' | 'createdAt' | 'streak'>) => {
    if (habitToEdit.value && habitToEdit.value.id !== undefined) {
        // This is an update
        const habitToUpdate: Habit = {
            id: habitToEdit.value.id,
            name: habitData.name,
            description: habitData.description,
            frequency: habitData.frequency,
            // Keep existing values from the item being edited
            streak: habitToEdit.value.streak || 0,
            createdAt: habitToEdit.value.createdAt || new Date(),
            lastCompleted: habitToEdit.value.lastCompleted,
        };
        await habitStore.updateHabit(habitToUpdate);
    } else {
        // This is a new habit
        await habitStore.addHabit(habitData);
    }
    closeForm();
};

const openEditForm = (habit: Habit) => {
    habitToEdit.value = { ...habit };
    showForm.value = true;
};

const closeForm = () => {
    showForm.value = false;
    habitToEdit.value = null;
};

const handleDeleteHabit = async (habitId: number) => {
    if (confirm('Are you sure you want to delete this habit and all its history?')) {
        await habitStore.deleteHabit(habitId);
    }
};

const handleCompletionToggleInList = async (habitId: number) => {
    await habitStore.toggleHabitCompletionForToday(habitId);
};
</script>

<template>
    <div class="habits-view">
        <h1>Habit Tracker</h1>
        <button @click="showForm = !showForm; habitToEdit = null" class="btn btn-primary mb-4">
            {{ showForm ? 'Cancel' : 'Add New Habit' }}
        </button>

        <HabitForm v-if="showForm" @save-habit="handleSaveHabit" @close="closeForm" :habit-to-edit="habitToEdit" />

        <div class="habit-list">
             <HabitListItem 
                v-for="habit in habitsForDisplay" 
                :key="habit.id" 
                :habit="habit"
                :show-details-button="false"
                :show-delete-button="true"
                @completion-toggled="handleCompletionToggleInList(habit.id!)"
                @delete-habit="handleDeleteHabit(habit.id!)"
                @edit-habit="openEditForm(habit)"
            />
        </div>
    </div>
</template>