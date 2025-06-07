<template>
  <div class="dashboard">
    <h1>Dashboard</h1>

    <h2>At a Glance</h2>
    <div class="stats-grid">
      <div class="stat-card">
        <h3>High Priority Tasks</h3>
        <p class="stat-number">{{ taskStore.highPriorityTasksCount }}</p>
      </div>
      <div class="stat-card">
        <h3>Next Due Task</h3>
        <p v-if="taskStore.nextDueTask" class="stat-detail">
          {{ taskStore.nextDueTask.title }} on {{ formatDate(taskStore.nextDueTask.dueDate) }}
        </p>
        <p v-else>No upcoming tasks</p>
      </div>

      <div class="stat-card">
        <h3>Total Balance</h3>
        <p class="stat-number">{{ formatCurrency(budgetStore.totalBalance) }}</p>
      </div>
       <div class="stat-card">
        <h3>End of Month Forecast</h3>
        <p class="stat-detail">
            <span>Income: ~{{ formatCurrency(budgetStore.endOfMonthForecast.estimatedIncome) }}</span><br>
            <span>Expense: ~{{ formatCurrency(budgetStore.endOfMonthForecast.estimatedExpense, true) }}</span>
        </p>
      </div>
    </div>

    <h2>Today's Habits</h2>
    <div class="habits-section">
      <div v-if="habitStore.isLoading">Loading habits...</div>
      <div v-else-if="habitStore.habitsForTodayDashboard.length > 0" class="habits-grid">
        <div 
          v-for="habit in habitStore.habitsForTodayDashboard" 
          :key="habit.id" 
          class="habit-card" 
          :class="{ 'completed': habit.completedToday }">
            <span class="habit-name">{{ habit.name }}</span>
            <input 
              type="checkbox"
              :checked="habit.completedToday"
              @change="toggleHabit(habit.id!)"
              class="habit-checkbox"
              :aria-label="`Mark ${habit.name} as ${habit.completedToday ? 'not done' : 'done'}`"
            />
        </div>
      </div>
      <p v-else>No habits scheduled for today.</p>
    </div>

    <div class="chart-container">
        <h2>Expense Distribution</h2>
        <ExpensePieChart v-if="!budgetStore.isLoading && budgetStore.expensePieChartData.datasets[0].data.length" :data="budgetStore.expensePieChartData" />
        <p v-else-if="budgetStore.isLoading">Loading chart data...</p>
        <p v-else>No expense data available for the chart.</p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useTaskStore } from '@/stores/taskStore';
import { useBudgetStore } from '@/stores/budgetStore';
import { useHabitStore } from '@/stores/habitStore';
import { onMounted } from 'vue';
import ExpensePieChart from '@/components/ExpensePieChart.vue';

const taskStore = useTaskStore();
const budgetStore = useBudgetStore();
const habitStore = useHabitStore();

onMounted(() => {
  taskStore.fetchTasks();
  budgetStore.fetchAll();
  habitStore.fetchAllData();
});

const toggleHabit = (habitId: number) => {
  if (typeof habitId === 'number') {
    habitStore.toggleHabitCompletionForToday(habitId);
  }
};

const formatCurrency = (value: number, isExpense: boolean = false) => {
  const absValue = isExpense ? Math.abs(value) : value;
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(absValue);
};

const formatDate = (dateString?: string) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString('de-DE');
}
</script>

<style scoped>
.dashboard {
  text-align: left;
}
h2 {
    margin-top: 2.5rem;
    margin-bottom: 1rem;
    border-bottom: 1px solid var(--color-border);
    padding-bottom: 0.5rem;
}
.stats-grid, .habits-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}
.stat-card {
  background-color: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  transition: transform 0.2s;
}
.stat-card:hover {
    transform: translateY(-5px);
}
.stat-card h3 {
  margin-top: 0;
  color: var(--color-heading);
}
.stat-number {
  font-size: 2.5rem;
  font-weight: bold;
  color: var(--color-primary);
}
.stat-detail {
    font-size: 1rem;
    color: var(--color-text-soft);
    line-height: 1.5;
}

/* Corrected habit-card styles */
.habit-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: var(--color-background);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    transition: all 0.2s;
}
.habit-card.completed {
    background-color: var(--color-info-background);
    border-color: var(--color-info-border);
    color: var(--color-text-soft);
}
.habit-name {
    font-weight: 500;
    padding-right: 1rem;
}
.habit-checkbox {
    width: 22px;
    height: 22px;
    cursor: pointer;
    flex-shrink: 0;
    
    /* Better custom checkbox styling */
    appearance: none;
    -webkit-appearance: none;
    background-color: var(--color-background-soft);
    border: 2px solid var(--color-border-hover);
    border-radius: 4px;
    display: grid;
    place-content: center;
    transition: background-color 0.2s, border-color 0.2s;
}
.habit-checkbox:hover {
    border-color: var(--color-primary);
}
.habit-checkbox::before {
    content: '';
    width: 12px;
    height: 12px;
    transform: scale(0);
    transition: 120ms transform ease-in-out;
    box-shadow: inset 1em 1em var(--color-primary);
    transform-origin: bottom left;
    clip-path: polygon(14% 44%, 0 65%, 50% 100%, 100% 16%, 80% 0%, 43% 62%);
}
.habit-checkbox:checked {
    background-color: var(--color-primary-light);
    border-color: var(--color-primary);
}
.habit-checkbox:checked::before {
    transform: scale(1);
}

.chart-container {
  margin-top: 2rem;
  padding: 1.5rem;
  background-color: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  height: 450px;
}
</style>