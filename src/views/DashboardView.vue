<template>
  <div class="dashboard-view">
    <h1>Dashboard</h1>
    <div v-if="isLoading" class="loading-indicator">
      <p>Lade Dashboard-Daten...</p>
    </div>
    <div v-else class="grid-container">
      <div class="card task-summary-card">
        <div class="card-header">
          <h3><i class="fa-solid fa-list-check"></i> Aufgaben-Überblick</h3>
        </div>
        <div class="card-content">
          <div class="summary-item">
            <span class="count">{{ highPriorityTasksCount }}</span>
            <p>Offene Aufgaben mit hoher Priorität</p>
          </div>
          <div v-if="nextDueTask && nextDueTask.dueDate" class="summary-item">
            <h4>Nächste fällige Aufgabe:</h4>
            <div>
              <input type="checkbox" :id="'task-checkbox-' + nextDueTask.id" :checked="nextDueTask.completed"
                @change="toggleTaskCompletion(nextDueTask.id!)" />
              <label :for="'task-checkbox-' + nextDueTask.id">{{ nextDueTask.title }}</label>
            </div>
            <span>Fällig am: {{ new Date(nextDueTask.dueDate).toLocaleDateString('de-DE') }}</span>
          </div>
          <div v-else class="summary-item">
            <p>Keine fälligen Aufgaben.</p>
          </div>
        </div>
      </div>

      <div class="card habits-today-card">
        <div class="card-header">
          <h3><i class="fa-solid fa-person-walking"></i> Heutige Gewohnheiten</h3>
        </div>
        <div class="card-content">
          <ul v-if="habitsForTodayDashboard.length">
            <li v-for="habit in habitsForTodayDashboard" :key="habit.id" :class="{ completed: habit.completedToday }">
              <input type="checkbox" :id="'habit-checkbox-dash-' + habit.id" :checked="habit.completedToday"
                @change="toggleHabitCompletion(habit.id!)" class="habit-checkbox" />
              <label :for="'habit-checkbox-dash-' + habit.id">
                {{ habit.name }} (Streak: {{ habit.streak }})
              </label>
            </li>
          </ul>
          <p v-else>Für heute stehen keine Gewohnheiten an.</p>
        </div>
      </div>

      <div class="card budget-chart-card">
        <div class="card-header">
          <h3><i class="fa-solid fa-chart-pie"></i> Ausgaben nach Kategorie</h3>
        </div>
        <div class="card-content">
          <div v-if="hasExpenses" class="chart-container">
            <Pie :data="expensePieChartData" :options="chartOptions" />
          </div>
          <p v-else>Keine Ausgaben vorhanden, um ein Diagramm anzuzeigen.</p>
        </div>
      </div>

      <FinancialOverview />

    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useTaskStore } from '@/stores/taskStore';
import { useHabitStore } from '@/stores/habitStore';
import { useBudgetStore } from '@/stores/budgetStore';
import { Pie } from 'vue-chartjs';
import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement, CategoryScale } from 'chart.js';
import FinancialOverview from '@/components/budget/FinancialOverview.vue';

ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);

// Task Store
const taskStore = useTaskStore();
const { highPriorityTasksCount, nextDueTask } = storeToRefs(taskStore);
const { toggleTaskCompletion } = taskStore;

// Habit Store
const habitStore = useHabitStore();
const { habitsForTodayDashboard } = storeToRefs(habitStore);
const { toggleHabitCompletionForToday } = habitStore;

// Budget Store
const budgetStore = useBudgetStore();
const { expensePieChartData, isLoading } = storeToRefs(budgetStore);

const hasExpenses = computed(() =>
  expensePieChartData.value.datasets[0] && expensePieChartData.value.datasets[0].data.length > 0
);

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const,
      labels: {
        color: '#f0f6fc'
      }
    },
    title: {
      display: false
    }
  }
};

const toggleHabitCompletion = (habitId: number) => {
  toggleHabitCompletionForToday(habitId);
}
</script>

<style scoped>
.dashboard-view h1 {
  margin-bottom: 1.5rem;
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.card {
  display: flex;
  flex-direction: column;
}

.card-header {
  flex-shrink: 0;
}

.card-content {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.summary-item {
  text-align: center;
  margin-bottom: 1rem;
}

.summary-item .count {
  font-size: 3rem;
  font-weight: bold;
  color: var(--color-primary);
  display: block;
}

.habits-today-card ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.habits-today-card li {
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
}

.habits-today-card li.completed label {
  text-decoration: line-through;
  color: var(--color-text-soft);
}

.habit-checkbox {
  margin-right: 10px;
}

.habits-today-card li:last-child {
  border-bottom: none;
}

.budget-chart-card .card-content {
  min-height: 300px;
}
</style>