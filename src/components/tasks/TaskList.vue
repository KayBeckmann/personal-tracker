// TaskList.vue (oder wo Ihre Task-Liste ist)
<template>
  <div class="task-list-container">
    <CreateTaskForm 
      v-if="showForm" 
      :taskToEdit="taskToEdit"
      @form-submitted="handleFormClose"
      @cancel-edit="handleFormClose"
    />

    <div class="task-list">
      <h2>Meine Tasks</h2>
      <button @click="openCreateForm" v-if="!showForm" class="add-task-button">Neuen Task hinzufügen</button>

      <div v-if="taskStore.isLoading">Lade Tasks...</div>
      <div v-else-if="taskStore.error" class="error">{{ taskStore.error }}</div>
      <div v-else-if="taskStore.tasks.length === 0 && !showForm">Keine Tasks vorhanden. Füge einen neuen hinzu!</div>
      <ul v-else>
        <li v-for="task in taskStore.tasks" :key="task.id" :class="{ completed: task.completed }">
          <div class="task-info">
            <strong @click="toggleCompletion(task.id!)" style="cursor: pointer;">{{ task.title }}</strong>
            <p v-if="task.description">{{ task.description }}</p>
            <small>Priorität: {{ task.priority }} | Fällig: {{ formatDate(task.dueDate) }}</small>
          </div>
          <div class="task-actions">
            <button @click="startEditTask(task)">Bearbeiten</button>
            <button @click="removeTask(task.id!)" class="danger">Löschen</button>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import type { Task } from '@/services/db';
import CreateTaskForm from '@/components/tasks/CreateTaskForm.vue'; // Pfad anpassen, falls nötig

const taskStore = useTaskStore();

const showForm = ref(false); // Steuert die Sichtbarkeit des Formulars
const taskToEdit = ref<Task | null>(null); // Hält den Task, der bearbeitet wird

const formatDate = (dateString: string | null | undefined) => {
  if (!dateString) return 'N/A';
  // Stellt sicher, dass der String als UTC behandelt wird, um Zeitzonenprobleme bei reiner Datumseingabe zu vermeiden
  try {
    const date = new Date(dateString + 'T00:00:00Z'); // Als UTC interpretieren
    return date.toLocaleDateString('de-DE', { timeZone: 'UTC' }); // Und als UTC formatieren
  } catch (e) {
    return 'Ungültiges Datum';
  }
};

const toggleCompletion = (id: number) => {
  taskStore.toggleTaskCompletion(id);
};

const removeTask = (id: number) => {
  if (confirm('Diesen Task wirklich löschen?')) {
    taskStore.deleteTask(id);
  }
};

const startEditTask = (task: Task) => {
  console.log('Edit task:', task); // Bestehendes Log
  taskToEdit.value = { ...task }; // Wichtig: Kopie erstellen für die Bearbeitung
  showForm.value = true;
};

const openCreateForm = () => {
  taskToEdit.value = null; // Sicherstellen, dass wir im "Erstellen"-Modus sind
  showForm.value = true;
};

const handleFormClose = () => {
  showForm.value = false;
  taskToEdit.value = null; // Formular zurücksetzen
};

// Falls die Tasks nicht automatisch durch den Store geladen werden (onMounted im Store sollte das tun)
// import { onMounted } from 'vue';
// onMounted(() => {
//   if (taskStore.tasks.length === 0 && !taskStore.isLoading) {
//     taskStore.fetchTasks();
//   }
// });
</script>

<style scoped>
.task-list-container {
  /* Stellt sicher, dass der Container Platz für das Formular und die Liste hat */
}
.add-task-button {
  margin-bottom: 20px;
  padding: 10px 15px;
  background-color: #4DBA87;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.add-task-button:hover {
  background-color: #368a67;
}
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
  flex-wrap: wrap; /* Besser für kleinere Bildschirme */
}
.task-list li.completed strong {
  text-decoration: line-through;
  color: #888;
}
.task-info {
  flex-grow: 1;
  margin-right: 10px; /* Abstand zu den Aktionen */
}
.task-info p {
  font-size: 0.9em;
  color: #555;
  margin: 5px 0;
  word-break: break-word; /* Lange Beschreibungen umbrechen */
}
.task-info small {
  font-size: 0.8em;
  color: #777;
}
.task-actions {
  display: flex; /* Buttons nebeneinander */
  flex-shrink: 0; /* Verhindert, dass die Buttons schrumpfen */
}
.task-actions button {
  margin-left: 10px;
  padding: 5px 10px;
  border: none;
  border-radius: 3px;
  cursor: pointer;
}
.task-actions button:first-child {
  margin-left: 0; /* Kein linker Rand für den ersten Button in den Aktionen */
}
.task-actions button.danger {
  background-color: #e74c3c;
  color: white;
}
.task-actions button.danger:hover {
  background-color: #c0392b;
}
.error {
  color: red;
  margin-bottom: 10px;
}
</style>