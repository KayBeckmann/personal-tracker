<template>
    <form @submit.prevent="handleSubmit" class="habit-form">
      <div class="form-group">
        <label for="habit-name">Habit Name:</label>
        <input type="text" id="habit-name" v-model="name" required />
      </div>
      <div class="form-group">
        <label for="habit-description">Description (Optional):</label>
        <textarea id="habit-description" v-model="description"></textarea>
      </div>
      <div class="form-group">
        <label for="habit-frequency">Frequency:</label>
        <select id="habit-frequency" v-model="frequency" required>
          <option value="daily">Daily</option>
          <option value="weekly">Weekly</option>
          <option value="monthly">Monthly</option>
          </select>
      </div>
      <button type="submit" class="btn-submit">{{ isEditing ? 'Update' : 'Add' }} Habit</button>
      <button type="button" @click="handleCancel" v-if="isEditing" class="btn-cancel">Cancel</button>
    </form>
  </template>
  
  <script setup lang="ts">
  import { ref, watch, onMounted } from 'vue';
  import { type Habit } from '@/services/db';
  
  const props = defineProps<{
    habitToEdit?: Habit | null;
  }>();
  
  const emit = defineEmits(['submit-habit', 'cancel-edit']);
  
  const name = ref('');
  const description = ref('');
  const frequency = ref<'daily' | 'weekly' | 'monthly'>('daily');
  const isEditing = ref(false);
  
  onMounted(() => {
    if (props.habitToEdit) {
      populateForm(props.habitToEdit);
    }
  });
  
  watch(() => props.habitToEdit, (newHabit) => {
    if (newHabit) {
      populateForm(newHabit);
    } else {
      resetForm();
    }
  });
  
  function populateForm(habit: Habit) {
    name.value = habit.name;
    description.value = habit.description || '';
    frequency.value = habit.frequency;
    isEditing.value = true;
  }
  
  function resetForm() {
    name.value = '';
    description.value = '';
    frequency.value = 'daily';
    isEditing.value = false;
  }
  
  const handleSubmit = () => {
    const habitData = {
      name: name.value,
      description: description.value,
      frequency: frequency.value,
    };
    if (isEditing.value && props.habitToEdit?.id !== undefined) {
      emit('submit-habit', { ...habitData, id: props.habitToEdit.id, streak: props.habitToEdit.streak, createdAt: props.habitToEdit.createdAt, lastCompleted: props.habitToEdit.lastCompleted });
    } else {
      emit('submit-habit', habitData);
    }
    resetForm(); // Reset form after submission for adding, or rely on parent to clear for editing
  };
  
  const handleCancel = () => {
    resetForm();
    emit('cancel-edit');
  }
  </script>
  
  <style scoped>
  .habit-form {
    display: flex;
    flex-direction: column;
    gap: 15px;
    padding: 20px;
    border: 1px solid var(--color-border);
    border-radius: 8px;
    background-color: var(--color-background);
    max-width: 500px;
    margin: 20px auto;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  }
  
  .form-group {
    display: flex;
    flex-direction: column;
    text-align: left;
  }
  
  .form-group label {
    margin-bottom: 5px;
    font-weight: 500;
    color: var(--color-text-soft);
  }
  
  .form-group input[type="text"],
  .form-group textarea,
  .form-group select {
    padding: 10px;
    border: 1px solid var(--color-border-soft);
    border-radius: 4px;
    font-size: 1em;
    background-color: var(--color-background-soft);
    color: var(--color-text);
  }
  .form-group input[type="text"]:focus,
  .form-group textarea:focus,
  .form-group select:focus {
    outline: none;
    border-color: var(--color-primary);
    box-shadow: 0 0 0 2px var(--color-primary-light);
  }
  
  .form-group textarea {
    min-height: 80px;
    resize: vertical;
  }
  
  .btn-submit, .btn-cancel {
    padding: 10px 15px;
    font-size: 1em;
    border-radius: 4px;
    cursor: pointer;
    border: none;
    transition: background-color 0.2s ease;
  }
  
  .btn-submit {
    background-color: var(--color-primary);
    color: white;
  }
  .btn-submit:hover {
    background-color: var(--color-primary-dark);
  }
  
  .btn-cancel {
    background-color: var(--color-secondary);
    color: white;
  }
  .btn-cancel:hover {
    background-color: var(--color-secondary-dark);
  }
  </style>