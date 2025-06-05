<template>
  <div class="dashboard-view">
    <h1>Dashboard</h1>

    <section class="dashboard-section">
      <h2>Aufgabenübersicht</h2>
      <div class="dashboard-metrics">
        <div class="metric-item">
          <span class="metric-value">{{ taskStore.highPriorityTasksCount }}</span>
          <span class="metric-label">Offene Aufgaben mit hoher Priorität</span>
        </div>
        <div class="metric-item" v-if="taskStore.nextDueTask">
          <span class="metric-value">{{ taskStore.nextDueTask.title }}</span>
          <span class="metric-label">Nächste fällige Aufgabe: {{ formatDate(taskStore.nextDueTask.dueDate) }}</span>
        </div>
        <div class="metric-item" v-else>
          <span class="metric-label">Keine fälligen Aufgaben.</span>
        </div>
      </div>
    </section>

    <section class="dashboard-section">
      <h2>Heutige Gewohnheiten</h2>
      <div v-if="habitStore.isLoading" class="loading-message">Lade Gewohnheiten...</div>
      <div v-if="habitStore.error" class="error-message">{{ habitStore.error }}</div>
      <div v-if="!habitStore.isLoading && !habitStore.error">
        <div v-if="todaysHabits.length === 0" class="empty-state">
          Keine Gewohnheiten für heute oder alle bereits erledigt! Lege neue Gewohnheiten im Bereich "Habits" an.
        </div>
        <HabitListItem
          v-for="habit in todaysHabits"
          :key="habit.id"
          :habit="habit"
          @completion-toggled="refreshHabitDisplay"
        />
      </div>
    </section>

    </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import { useHabitStore } from '@/stores/habitStore';
import HabitListItem from '@/components/habits/HabitListItem.vue'; // Importieren
import type { Habit } from '@/services/db';

interface HabitForDisplay extends Habit {
  completedToday: boolean;
  isDue: boolean;
}

const taskStore = useTaskStore();
const habitStore = useHabitStore();

onMounted(async () => {
  // Stores sollten ihre Daten selbst beim Mounten laden,
  // aber ein expliziter Fetch kann hier für Konsistenz sorgen,
  // falls die Daten aus irgendeinem Grund nicht aktuell sind.
  // Die Stores verwenden liveQuery, daher sollte dies meist nicht nötig sein.
  if (taskStore.tasks.length === 0) {
    taskStore.fetchTasks();
  }
  // habitStore.fetchAllData() wird in onMounted des Stores selbst aufgerufen
});

const todaysHabits = computed<HabitForDisplay[]>(() => {
  return habitStore.habitsForTodayDashboard;
});

const formatDate = (dateString?: string) => {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  return date.toLocaleDateString('de-DE', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
};

// Diese Funktion könnte nützlich sein, wenn man nach einer Aktion die Anzeige
// manuell beeinflussen möchte, obwohl live queries das meiste abdecken sollten.
const refreshHabitDisplay = () => {
  // Die Reaktivität sollte dies automatisch handhaben.
  // Ggf. habitStore.fetchAllData() wenn man einen harten Refresh erzwingen will,
  // aber das ist normalerweise nicht nötig mit Live Queries.
  console.log("Habit completion toggled, dashboard display should update.");
};

</script>

<style scoped>
.dashboard-view {
  padding: 20px;
  text-align: left;
}

.dashboard-view h1 {
  color: var(--color-heading);
  margin-bottom: 30px;
  text-align: center;
}
.dashboard-view h2 {
  color: var(--color-heading);
  border-bottom: 2px solid var(--color-primary-light);
  padding-bottom: 8px;
  margin-top: 30px;
  margin-bottom: 20px;
  font-size: 1.5em;
}

.dashboard-section {
  margin-bottom: 30px;
  padding: 20px;
  background-color: var(--color-background);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.dashboard-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.metric-item {
  background-color: var(--color-background-soft);
  padding: 15px;
  border-radius: 6px;
  border: 1px solid var(--color-border-soft);
}

.metric-value {
  display: block;
  font-size: 1.8em;
  font-weight: bold;
  color: var(--color-primary);
  margin-bottom: 5px;
}

.metric-label {
  font-size: 0.95em;
  color: var(--color-text-soft);
}

.loading-message, .error-message, .empty-state {
  padding: 15px;
  margin-top: 10px;
  border-radius: 4px;
  text-align: center;
}

.loading-message {
  background-color: var(--color-info-background);
  color: var(--color-info-text);
  border: 1px solid var(--color-info-border);
}

.error-message {
  background-color: var(--color-warning-background);
  color: var(--color-warning-text);
  border: 1px solid var(--color-warning-border);
}
.empty-state {
  color: var(--color-text-light);
  background-color: var(--color-background-mute);
  padding: 20px;
  border-radius: 6px;
}
</style>