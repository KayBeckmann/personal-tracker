<template>
  <div class="task-list">
    <h2>Meine Tasks</h2>
    <div v-if="taskStore.isLoading">Lade Tasks...</div>
    <div v-else-if="taskStore.error" class="error">{{ taskStore.error }}</div>
    <div v-else-if="taskStore.tasks.length === 0">Keine Tasks vorhanden. Füge einen neuen hinzu!</div>
    <ul v-else>
      <li v-for="task in taskStore.tasks" :key="task.id" :class="{ completed: task.completed }">
        <div class="task-info">
          <strong @click="toggleCompletion(task.id!)" style="cursor: pointer;">{{ task.title }}</strong>
          <p v-if="task.description">{{ task.description }}</p>
          <small>Priorität: {{ task.priority }} | Fällig: {{ formatDate(task.dueDate) }}</small>
        </div>
        <div class="task-actions">
          <button @click="editTask(task)">Bearbeiten</button>
          <button @click="removeTask(task.id!)" class="danger">Löschen</button>
        </div>
      </li>
    </ul>
    </div>
</template>

<script setup lang="ts">
import { useTaskStore } from '@/stores/taskStore';
import type { Task } from '@/services/db';

const taskStore = useTaskStore();

const formatDate = (dateString: string | null | undefined) => {
  if (!dateString) return 'N/A';
  return new Date(dateString).toLocaleDateString('de-DE');
};

const toggleCompletion = (id: number) => {
  taskStore.toggleTaskCompletion(id);
};

const removeTask = (id: number) => {
  if (confirm('Diesen Task wirklich löschen?')) {
    taskStore.deleteTask(id);
  }
};

const editTask = (task: Task) => {
  // Logik zum Öffnen eines Bearbeitungsformulars/Modals
  // Du könntest einen globalen State oder einen Event-Bus verwenden,
  // um ein Modal mit den Task-Daten zu öffnen.
  console.log('Edit task:', task);
  alert(`Bearbeite Task: ${task.title} (Implementierung für Formular fehlt)`);
};

// Initiales Laden, falls nicht schon im Store passiert
// onMounted(() => {
//   if (taskStore.tasks.length === 0) {
//     taskStore.fetchTasks();
//   }
// });
</script>

<style scoped>
.task-list {
  margin-top: 20px;
}
.task-list ul {
  list-style: none;
  padding: 0;
}
.task-list li {
  background-color: #fff;
  border: 1px solid #ddd;
  padding: 10px 15px;
  margin-bottom: 10px;
  border-radius: 5px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.task-list li.completed strong {
  text-decoration: line-through;
  color: #888;
}
.task-info {
  flex-grow: 1;
}
.task-info p {
  font-size: 0.9em;
  color: #555;
  margin: 5px 0;
}
.task-info small {
  font-size: 0.8em;
  color: #777;
}
.task-actions button {
  margin-left: 10px;
  padding: 5px 10px;
  border: none;
  border-radius: 3px;
  cursor: pointer;
}
.task-actions button.danger {
  background-color: #e74c3c;
  color: white;
}
.error {
  color: red;
  margin-bottom: 10px;
}
</style>