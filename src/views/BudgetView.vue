<template>
  <div class="budget-view">
    <header class="view-header">
      <h1>Haushaltsbuch</h1>
      <p>Ihr finanzieller Überblick an einem Ort.</p>
    </header>

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

    <div class="main-content-grid">
      <div class="main-column">
        <TransactionForm />
        
        <div class="card">
          <h2>Finanzverlauf & Prognose</h2>
          <LineChart :chart-data="financialHistoryAndForecastData" />
        </div>
      </div>

      <div class="sidebar-column">
        <AccountManager />
        <CategoryManager />
        <div class="card">
            <h2>Ausgaben nach Kategorie (Pareto)</h2>
            <ParetoChart :chart-data="paretoChartData" />
        </div>
      </div>
    </div>

    <section class="data-section card">
      <h2>Letzte 10 Transaktionen</h2>
      <ul class="item-list">
          <li v-for="t in transactions.slice(0, 10)" :key="t.id">
              <div class="transaction-details">
                <strong>{{ t.description }}</strong>
                <small>{{ new Date(t.date).toLocaleDateString('de-DE') }}</small>
              </div>
              <span class="amount" :class="t.type">{{ formatCurrency(t.amount) }}</span>
          </li>
          <li v-if="!transactions.length" class="empty-state">
            Bisher keine Transaktionen erfasst.
          </li>
      </ul>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

// Komponenten für die Verwaltung
import AccountManager from '@/components/budget/AccountManager.vue';
import CategoryManager from '@/components/budget/CategoryManager.vue';
import TransactionForm from '@/components/budget/TransactionForm.vue';

// NEU: Komponenten für die Diagramme importieren
import LineChart from '@/components/budget/LineChart.vue';
import ParetoChart from '@/components/budget/ParetoChart.vue';

const budgetStore = useBudgetStore();
const { 
  accounts, 
  transactions, 
  endOfMonthForecast: forecast,
  // Getter für die Diagrammdaten aus dem Store holen
  financialHistoryAndForecastData,
  paretoChartData,
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
.view-header {
  margin-bottom: 0;
}
.view-header h1 {
  margin-bottom: 0.5rem;
}
.view-header p {
  color: var(--color-text-soft);
  font-size: 1.1rem;
}
.main-content-grid {
    display: grid;
    grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
    gap: 2rem;
    align-items: start;
}
.main-column, .sidebar-column {
    display: flex;
    flex-direction: column;
    gap: 2rem;
}
@media (max-width: 1024px) {
    .main-content-grid {
        grid-template-columns: 1fr;
    }
}
.card {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  /* Definiert eine Mindesthöhe, damit Diagramme nicht springen */
  min-height: 350px; 
  display: flex;
  flex-direction: column;
}
.card h2 {
    margin-top: 0;
    margin-bottom: 1rem;
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
.kpi-card h3 { margin-top: 0; color: var(--color-text-light); }
.kpi-card .amount { font-size: 2em; font-weight: 600; margin: 0.5rem 0; }
.kpi-card .total { color: var(--color-text-heading); }
.kpi-card .income { color: var(--color-success, #198754); }
.kpi-card .expense { color: var(--color-danger, #dc3545); }
.kpi-card span { font-size: 0.9em; color: var(--color-text-light); }

.item-list { list-style: none; padding: 0; }
.item-list li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--color-border-soft);
}
.item-list li:last-child { border-bottom: none; }
.transaction-details { display: flex; flex-direction: column; }
.transaction-details small { color: var(--color-text-light); font-size: 0.8em; }
.amount.income { color: var(--color-success); }
.amount.expense { color: var(--color-danger); }
.amount.transfer { color: var(--color-info); }
.empty-state {
  color: var(--color-text-light);
  text-align: center;
  padding: 1rem 0;
  border-bottom: none;
}
</style>