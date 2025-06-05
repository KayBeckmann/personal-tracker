// src/components/tasks/CreateTaskForm.vue
<template>
  <div class="task-form">
    <h3>{{ isEditMode ? 'Task bearbeiten' : 'Neuen Task erstellen' }}</h3>
    <form @submit.prevent="handleSubmit">
      <div>
        <label for="task-title">Titel:</label>
        <input type="text" id="task-title" v-model="editableTask.title" required />
      </div>
      <div>
        <label for="task-description">Beschreibung (optional):</label>
        <textarea id="task-description" v-model="editableTask.description"></textarea>
      </div>
      <div>
        <label for="task-priority">Priorität:</label>
        <select id="task-priority" v-model="editableTask.priority">
          <option value="low">Niedrig</option>
          <option value="medium">Mittel</option>
          <option value="high">Hoch</option>
        </select>
      </div>
      <div>
        <label for="task-dueDate">Fällig bis (optional):</label>
        <input type="date" id="task-dueDate" v-model="editableTask.dueDate" />
      </div>
      <div class="form-actions">
        <button type="submit">{{ isEditMode ? 'Task aktualisieren' : 'Task hinzufügen' }}</button>
        <button type="button" @click="handleCancel" class="cancel-button">Abbrechen</button>
      </div>
      <div v-if="formError" class="error-message">{{ formError }}</div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed, defineProps, defineEmits, onMounted } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import type { Task } from '@/services/db';

const props = defineProps<{
  taskToEdit?: Task | null; // Optional prop for editing
}>();

const emit = defineEmits(['formSubmitted', 'cancelEdit']);

const taskStore = useTaskStore();

// Use a local reactive object for form data
const editableTask = ref<Partial<Task>>({
  title: '',
  description: '',
  priority: 'medium',
  dueDate: null,
});

const formError = ref<string | null>(null);

const isEditMode = computed(() => !!props.taskToEdit);

// Populate form when taskToEdit prop changes or on mount if in edit mode
watch(
  () => props.taskToEdit,
  (newTask) => {
    if (newTask && isEditMode.value) {
      editableTask.value = { 
        ...newTask,
        // Ensure dueDate is a string in YYYY-MM-DD format for the input type="date"
        // or null if not set. The input expects an empty string for no date,
        // or a valid date string.
        dueDate: newTask.dueDate || null 
      };
    } else {
      // Reset for create mode
      editableTask.value = {
        title: '',
        description: '',
        priority: 'medium',
        dueDate: null,
      };
    }
  },
  { immediate: true, deep: true } // immediate to run on mount, deep for object changes
);


const handleSubmit = async () => {
  if (!editableTask.value.title || !editableTask.value.title.trim()) {
    formError.value = 'Titel darf nicht leer sein.';
    return;
  }
  formError.value = null;

  try {
    if (isEditMode.value && props.taskToEdit?.id) {
      const taskToUpdate: Task = {
        ...props.taskToEdit, // Includes original id and createdAt
        ...editableTask.value,
        title: editableTask.value.title.trim(),
        description: editableTask.value.description || undefined,
        priority: editableTask.value.priority as 'low' | 'medium' | 'high', // Cast because editableTask is Partial
        dueDate: editableTask.value.dueDate || null, // Ensure null if empty
      };
      await taskStore.updateTask(taskToUpdate);
    } else {
      const newTaskPayload: Omit<Task, 'id' | 'createdAt' | 'completed'> = {
        title: editableTask.value.title.trim(),
        description: editableTask.value.description || undefined,
        priority: editableTask.value.priority as 'low' | 'medium' | 'high',
        dueDate: editableTask.value.dueDate || null,
      };
      await taskStore.addTask(newTaskPayload);
    }
    emit('formSubmitted');
    resetForm();
  } catch (error) {
    console.error("Fehler beim Verarbeiten des Tasks:", error);
    formError.value = `Task konnte nicht ${isEditMode.value ? 'aktualisiert' : 'hinzugefügt'} werden.`;
  }
};

const handleCancel = () => {
  emit('cancelEdit');
  resetForm();
};

const resetForm = () => {
  if (!isEditMode.value) { // Only reset fully if in create mode
    editableTask.value = {
      title: '',
      description: '',
      priority: 'medium',
      dueDate: null,
    };
  }
  formError.value = null;
};

</script>

<style scoped>
.task-form {
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.task-form h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #333;
}

.task-form div:not(.form-actions) { /* Style all direct div children except form-actions */
  margin-bottom: 10px;
}

.task-form label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
}

.task-form input[type="text"],
.task-form textarea,
.task-form select,
.task-form input[type="date"] {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
}

.task-form textarea {
  min-height: 80px;
  resize: vertical;
}

.form-actions {
  margin-top: 15px;
  display: flex;
  gap: 10px; /* Abstand zwischen den Buttons */
}

.task-form button[type="submit"] {
  background-color: #4DBA87; /* Vue Grün */
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1em;
  transition: background-color 0.3s ease;
}

.task-form button[type="submit"]:hover {
  background-color: #368a67;
}

.task-form .cancel-button {
  background-color: #ccc;
  color: #333;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1em;
  transition: background-color 0.3s ease;
}
.task-form .cancel-button:hover {
  background-color: #bbb;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>