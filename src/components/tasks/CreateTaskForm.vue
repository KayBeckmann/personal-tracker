// src/components/tasks/CreateTaskForm.vue
<template>
  <div class="create-task-form">
    <h3>Neuen Task erstellen</h3>
    <form @submit.prevent="handleSubmit">
      <div>
        <label for="task-title">Titel:</label>
        <input type="text" id="task-title" v-model="title" required />
      </div>
      <div>
        <label for="task-description">Beschreibung (optional):</label>
        <textarea id="task-description" v-model="description"></textarea>
      </div>
      <div>
        <label for="task-priority">Priorität:</label>
        <select id="task-priority" v-model="priority">
          <option value="low">Niedrig</option>
          <option value="medium">Mittel</option>
          <option value="high">Hoch</option>
        </select>
      </div>
      <div>
        <label for="task-dueDate">Fällig bis (optional):</label>
        <input type="date" id="task-dueDate" v-model="dueDate" />
      </div>
      <button type="submit">Task hinzufügen</button>
      <div v-if="formError" class="error-message">{{ formError }}</div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import type { Task } from '@/services/db';

const taskStore = useTaskStore();

const title = ref('');
const description = ref('');
const priority = ref<'low' | 'medium' | 'high'>('medium');
const dueDate = ref<string | null>(null); // Wird als String 'YYYY-MM-DD' vom Input geliefert
const formError = ref<string | null>(null);

const handleSubmit = async () => {
  if (!title.value.trim()) {
    formError.value = 'Titel darf nicht leer sein.';
    return;
  }
  formError.value = null;

  const newTask: Omit<Task, 'id' | 'createdAt' | 'completed'> = {
    title: title.value,
    description: description.value || undefined, // Setze undefined wenn leer, damit Dexie es nicht als leeren String speichert
    priority: priority.value,
    dueDate: dueDate.value || null, // Wichtig: null wenn kein Datum
  };

  try {
    await taskStore.addTask(newTask);
    // Formular zurücksetzen
    title.value = '';
    description.value = '';
    priority.value = 'medium';
    dueDate.value = null;
  } catch (error) {
    console.error("Fehler beim Hinzufügen des Tasks:", error);
    formError.value = 'Task konnte nicht hinzugefügt werden.';
  }
};
</script>

<style scoped>
.create-task-form {
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.create-task-form h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #333;
}

.create-task-form div {
  margin-bottom: 10px;
}

.create-task-form label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
}

.create-task-form input[type="text"],
.create-task-form textarea,
.create-task-form select,
.create-task-form input[type="date"] {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box; /* Wichtig damit padding nicht die Breite erhöht */
}

.create-task-form textarea {
  min-height: 80px;
  resize: vertical;
}

.create-task-form button[type="submit"] {
  background-color: #4DBA87; /* Vue Grün */
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1em;
  transition: background-color 0.3s ease;
}

.create-task-form button[type="submit"]:hover {
  background-color: #368a67;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>