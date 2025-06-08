<template>
  <div class="tasks-view">
    <h1>Aufgabenplaner</h1>

    <div class="card add-task-form">
       <div class="card-header">
        <h3>Neue Aufgabe erstellen</h3>
      </div>
      <form @submit.prevent="handleAddTask">
        <div class="form-group">
          <label for="task-title">Titel</label>
          <input type="text" v-model="newTask.title" id="task-title" class="form-control" placeholder="Was gibt es zu tun?" required>
        </div>
         <div class="form-group">
          <label for="task-priority">Priorität</label>
          <select v-model="newTask.priority" id="task-priority" class="form-control">
            <option value="low">Niedrig</option>
            <option value="medium">Mittel</option>
            <option value="high">Hoch</option>
          </select>
        </div>
         <div class="form-group">
          <label for="task-dueDate">Fällig bis</label>
          <input type="date" v-model="newTask.dueDate" id="task-dueDate" class="form-control">
        </div>
        <button type="submit" class="btn btn-primary">Aufgabe hinzufügen</button>
      </form>
    </div>

    <div v-if="isLoading" class="loading">Lade Aufgaben...</div>
    <div v-if="error" class="error-message">{{ error }}</div>

    <div v-if="!isLoading && tasks.length" class="task-list">
      <h2>Offene Aufgaben</h2>
      <div v-for="task in tasks.filter(t => !t.completed)" :key="task.id" class="card task-item" :class="`priority-${task.priority}`">
        <div class="task-item-content">
          <input type="checkbox" :checked="task.completed" @change="taskStore.toggleTaskCompletion(task.id!)" class="task-checkbox"/>
          <div>
            <h3 :class="{ 'completed': task.completed }">{{ task.title }}</h3>
            <p v-if="task.dueDate" class="due-date">Fällig: {{ new Date(task.dueDate).toLocaleDateString('de-DE') }}</p>
          </div>
        </div>
        <button @click="taskStore.deleteTask(task.id!)" class="btn btn-danger btn-sm">
          <i class="fas fa-trash"></i>
        </button>
      </div>
       <h2>Erledigte Aufgaben</h2>
       <div v-for="task in tasks.filter(t => t.completed)" :key="task.id" class="card task-item completed-task">
        <div class="task-item-content">
          <input type="checkbox" :checked="task.completed" @change="taskStore.toggleTaskCompletion(task.id!)" class="task-checkbox"/>
          <div>
            <h3 :class="{ 'completed': task.completed }">{{ task.title }}</h3>
          </div>
        </div>
        <button @click="taskStore.deleteTask(task.id!)" class="btn btn-danger btn-sm">
          <i class="fas fa-trash"></i>
        </button>
      </div>
    </div>
    <div v-if="!isLoading && !tasks.length">
      <p>Super! Keine offenen Aufgaben.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import { storeToRefs } from 'pinia';
import type { Task } from '@/services/db';

const taskStore = useTaskStore();
// Diese Variablen werden jetzt im Template verwendet, was den Fehler behebt.
const { tasks, isLoading, error } = storeToRefs(taskStore);

const newTask = ref<Omit<Task, 'id' | 'createdAt' | 'completed'>>({
  title: '',
  priority: 'medium',
  dueDate: '',
});

const handleAddTask = () => {
  if (newTask.value.title.trim()) {
    taskStore.addTask({
      ...newTask.value,
      // Stelle sicher, dass dueDate ein leerer String ist, wenn nicht gesetzt, statt null
      dueDate: newTask.value.dueDate || undefined
    });
    // Formular zurücksetzen
    newTask.value.title = '';
    newTask.value.priority = 'medium';
    newTask.value.dueDate = '';
  }
};
</script>

<style scoped>
.task-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  border-left-width: 5px;
  border-left-style: solid;
}
.task-item-content {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.task-checkbox {
  width: 20px;
  height: 20px;
}
h3.completed {
  text-decoration: line-through;
  color: var(--color-text-soft);
}
.completed-task {
 opacity: 0.7;
}
.priority-high {
  border-left-color: var(--color-danger);
}
.priority-medium {
  border-left-color: var(--color-warning);
}
.priority-low {
  border-left-color: var(--color-info);
}
.due-date {
  font-size: 0.8rem;
  color: var(--color-text-soft);
  margin: 0;
}
</style>