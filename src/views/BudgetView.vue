<template>
  <div class="budget-view">
    <h1>Haushaltsbuch</h1>

    <section class="kpi-section">
      <div class="kpi-card">
        <h3>Aktueller Saldo</h3>
        <p class="amount total">{{ formatCurrency(totalBalance) }}</p>
      </div>
      <div class="kpi-card">
        <h3>Prognose Einnahmen</h3>
        <p class="amount income">{{ formatCurrency(forecast.estimatedIncome) }}</p>
        <span>(Rest des Monats)</span>
      </div>
      <div class="kpi-card">
        <h3>Prognose Ausgaben</h3>
        <p class="amount expense">{{ formatCurrency(forecast.estimatedExpense) }}</p>
        <span>(Rest des Monats)</span>
      </div>
    </section>
    
    <section class="charts-section">
      <div class="chart-container">
        <h2>Finanzverlauf & Prognose</h2>
        <div class="chart-placeholder">
          <p>Hier das Linien-Diagramm einfügen.</p>
          <p>Sie müssen eine Charting-Bibliothek wie 'vue-chartjs' installieren.</p>
          <pre>npm install chart.js vue-chartjs</pre>
          <p><strong>Daten sind bereit:</strong> `budgetStore.financialHistoryAndForecastData`</p>
        </div>
      </div>
      <div class="chart-container">
        <h2>Ausgaben nach Kategorie (Pareto)</h2>
         <div class="chart-placeholder">
          <p>Hier das Pareto-Diagramm (Balken/Linie kombiniert) einfügen.</p>
          <p><strong>Daten sind bereit:</strong> `budgetStore.paretoChartData`</p>
        </div>
      </div>
    </section>

    <section class="actions-section">
      <h2>Aktionen</h2>
      <div class="action-forms">
        <p>Hier könnten Formulare zum Hinzufügen von Transaktionen, Konten und Kategorien als Komponenten eingebunden werden.</p>
      </div>
    </section>

    <section class="data-section">
        <h2>Letzte Transaktionen</h2>
        <ul>
            <li v-for="t in transactions.slice(0, 10)" :key="t.id">
                <span>{{ t.description }}</span>
                <span :class="t.type">{{ formatCurrency(t.amount) }}</span>
                <span>{{ new Date(t.date).toLocaleDateString() }}</span>
            </li>
        </ul>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

const budgetStore = useBudgetStore();
const { 
  accounts, 
  transactions, 
  endOfMonthForecast: forecast, // Alias für einfacheren Zugriff
} = storeToRefs(budgetStore);

const totalBalance = computed(() => {
  return accounts.value.reduce((sum, acc) => sum + acc.balance, 0);
});

const formatCurrency = (value: number | undefined) => {
  if (typeof value !== 'number') return '€ 0,00';
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
};

</script>

<style scoped>
.budget-view {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.kpi-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.kpi-card {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  text-align: center;
}

.kpi-card h3 {
  margin-top: 0;
  color: var(--color-text-light);
}

.kpi-card .amount {
  font-size: 2em;
  font-weight: 600;
  margin: 0.5rem 0;
}
.kpi-card .total { color: var(--color-text-heading); }
.kpi-card .income { color: var(--color-success, #198754); }
.kpi-card .expense { color: var(--color-danger, #dc3545); }

.kpi-card span {
  font-size: 0.9em;
  color: var(--color-text-light);
}

.charts-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.chart-container {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.chart-placeholder {
    border: 2px dashed var(--color-border, #dee2e6);
    padding: 2rem;
    text-align: center;
    color: var(--color-text-light);
    border-radius: 8px;
    background-color: var(--color-background-soft);
}

.data-section ul {
    list-style: none;
    padding: 0;
}
.data-section li {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem;
    border-bottom: 1px solid var(--color-border-soft);
}
.data-section li:last-child {
    border-bottom: none;
}
.data-section .income { color: var(--color-success); }
.data-section .expense { color: var(--color-danger); }
.data-section .transfer { color: var(--color-info); }


@media (max-width: 900px) {
  .charts-section {
    grid-template-columns: 1fr;
  }
}
</style>