// src/components/tasks/CreateTaskForm.vue

<script setup lang="ts">
import { ref, watch, computed, defineProps, defineEmits } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import type { Task } from '@/services/db';

const props = defineProps({
  taskToEdit: {
    type: Object as () => Task | null,
    default: null
  }
});

const emit = defineEmits(['close']);

const taskStore = useTaskStore();

// Use a local state for the form
const editableTask = ref<Partial<Task>>({
  title: '',
  description: '',
  priority: 'medium',
  dueDate: undefined, // Use undefined instead of null
});

const isEditMode = computed(() => !!props.taskToEdit);

// Watch for changes in the prop and update the local state
watch(() => props.taskToEdit, (newTask) => {
  if (newTask) {
    editableTask.value = { ...newTask };
  } else {
    // Reset for new task creation
    editableTask.value = {
      title: '',
      description: '',
      priority: 'medium',
      dueDate: undefined, // Use undefined instead of null
    };
  }
}, { immediate: true });


const handleSubmit = async () => {
  if (!editableTask.value.title) {
    alert('Please enter a title for the task.');
    return;
  }

  try {
    if (isEditMode.value && editableTask.value.id !== undefined) {
       // Make sure to pass a full Task object to updateTask
      await taskStore.updateTask({
        id: editableTask.value.id,
        title: editableTask.value.title,
        description: editableTask.value.description,
        priority: editableTask.value.priority || 'medium',
        dueDate: editableTask.value.dueDate || undefined, // Ensure undefined if empty
        completed: editableTask.value.completed || false,
        createdAt: editableTask.value.createdAt || new Date(),
      });
    } else {
      await taskStore.addTask({
        title: editableTask.value.title,
        description: editableTask.value.description,
        priority: editableTask.value.priority || 'medium',
        dueDate: editableTask.value.dueDate || undefined,
      });
    }
    
    // Reset form state
    editableTask.value = {
        title: '',
        description: '',
        priority: 'medium',
        dueDate: undefined, // Use undefined instead of null
    };
    emit('close');
  } catch (error) {
    console.error('Failed to save the task:', error);
    // Optionally: show an error message to the user
  }
};
</script>

<template>
  <form @submit.prevent="handleSubmit" class="task-form">
    <div class="form-group">
      <label for="title">Title</label>
      <input type="text" id="title" v-model="editableTask.title" required>
    </div>
    <div class="form-group">
      <label for="description">Description</label>
      <textarea id="description" v-model="editableTask.description"></textarea>
    </div>
    <div class="form-group">
      <label for="priority">Priority</label>
      <select id="priority" v-model="editableTask.priority">
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
      </select>
    </div>
    <div class="form-group">
      <label for="dueDate">Due Date</label>
      <input type="date" id="dueDate" v-model="editableTask.dueDate">
    </div>
    <div class="form-actions">
      <button type="submit" class="btn btn-primary">{{ isEditMode ? 'Update Task' : 'Add Task' }}</button>
      <button type="button" @click="$emit('close')" class="btn btn-secondary">Cancel</button>
    </div>
  </form>
</template>

<style scoped>
.task-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.form-group {
  display: flex;
  flex-direction: column;
}
.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}
</style>