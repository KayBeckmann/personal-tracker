<template>
  <div class="dashboard">
    <h1>Dashboard</h1>

    <div v-if="taskStore.isLoading">Lade Dashboard Daten...</div>
    <div v-else-if="taskStore.error">{{ taskStore.error }}</div>
    <div v-else class="dashboard-grid">
      <div class="dashboard-widget">
        <h2>Wichtige Tasks</h2>
        <p>
          Anzahl Tasks mit hoher Priorität (offen):
          <strong>{{ taskStore.highPriorityTasksCount }}</strong>
        </p>
      </div>

      <div class="dashboard-widget">
        <h2>Nächster fälliger Task</h2>
        <div v-if="taskStore.nextDueTask">
          <p><strong>Titel:</strong> {{ taskStore.nextDueTask.title }}</p>
          <p><strong>Fällig am:</strong> {{ formatDate(taskStore.nextDueTask.dueDate) }}</p>
          <p><strong>Priorität:</strong> {{ taskStore.nextDueTask.priority }}</p>
        </div>
        <div v-else>
          <p>Keine offenen Tasks mit Fälligkeitsdatum.</p>
        </div>
      </div>

      <div class="dashboard-widget">
        <h2>Heutige Habits</h2>
        <div v-if="habitStore.isLoading">Lade Habits...</div>
        <div v-else-if="todayHabits.length === 0">Keine Habits für heute.</div>
        <ul v-else>
          <li v-for="habit in todayHabits" :key="habit.id" :class="{ completed: isHabitCompletedToday(habit.id!) }">
            {{ habit.name }} - {{ habit.streak }} Tage
            <button @click="toggleHabitToday(habit.id!)">
              {{ isHabitCompletedToday(habit.id!) ? 'Rückgängig' : 'Erledigt' }}
            </button>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTaskStore } from '@/stores/taskStore';
import { useHabitStore } from '@/stores/habitStore';
import { computed, onMounted } from 'vue';
import type { Habit } from '@/services/db';

const taskStore = useTaskStore();
const habitStore = useHabitStore();

const formatDate = (dateString: string | null | undefined) => {
  if (!dateString) return 'N/A';
  return new Date(dateString).toLocaleDateString('de-DE', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
};

const getTodayDateString = (): string => {
  return new Date().toISOString().split('T')[0]; // YYYY-MM-DD
}

// Nur Habits anzeigen, die heute relevant sind (z.B. täglich oder spezifischer Wochentag)
// Diese Logik muss ggf. verfeinert werden basierend auf habit.frequency
const todayHabits = computed(() => {
  const today = new Date();
  const todayStr = getTodayDateString();
  const dayOfWeek = today.toLocaleDateString('en-US', { weekday: 'short' }); // Mon, Tue, etc.

  return habitStore.habits.filter(habit => {
    if (habit.frequency === 'daily') return true;
    if (habit.frequency === 'weekly') {
        // Beispiel: Wenn wöchentlich, könnte man annehmen, dass es jeden Tag der Woche angezeigt wird,
        // oder man müsste einen "Starttag der Woche" im Habit speichern.
        // Hier vereinfacht: Zeige es an, wenn heute der Tag ist, an dem es zuletzt erledigt wurde
        // oder wenn es noch nie erledigt wurde.
        return true; // Muss verfeinert werden!
    }
    if (Array.isArray(habit.frequency) && habit.frequency.includes(dayOfWeek)) return true;
    return false;
  });
});

const isHabitCompletedToday = (habitId: number): boolean => {
  return habitStore.isHabitCompletedOnDate(habitId, getTodayDateString());
};

const toggleHabitToday = async (habitId: number) => {
  const today = getTodayDateString();
  const completed = !isHabitCompletedToday(habitId);
  await habitStore.logHabitDate(habitId, today, completed);
  // Streak wird im Store aktualisiert
};

// Sicherstellen, dass die Stores geladen sind
onMounted(() => {
  if (taskStore.tasks.length === 0 && !taskStore.isLoading) {
    taskStore.fetchTasks();
  }
  if (habitStore.habits.length === 0 && !habitStore.isLoading) {
    habitStore.fetchAllData();
  }
});
</script>

<style scoped>
.dashboard {
  padding: 20px;
}
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}
.dashboard-widget {
  background-color: #f9f9f9;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.dashboard-widget h2 {
  margin-top: 0;
  color: #333;
}
.dashboard-widget p {
    color: #555;
}
.dashboard-widget strong {
    color: #000;
}
.completed {
  text-decoration: line-through;
  color: grey;
}
ul {
  list-style: none;
  padding: 0;
}
li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}
li:last-child {
  border-bottom: none;
}
</style>