<template>
  <div class="card financial-overview-card">
    <div class="card-header">
      <h3><i class="fa-solid fa-chart-line"></i> Finanzübersicht</h3>
    </div>
    <div class="card-content">
      <div v-if="isLoading">
        <p>Finanzübersicht wird geladen...</p>
      </div>
      <div v-else>
        <div class="summary-item">
          <span class="value income">{{ formatCurrency(currentMonthIncome) }}</span>
          <p>Einnahmen diesen Monat</p>
        </div>
        <div class="summary-item">
          <span class="value expense">{{ formatCurrency(currentMonthExpenses) }}</span>
          <p>Ausgaben diesen Monat</p>
        </div>
        <hr>
        <div class="summary-item">
          <span class="value forecast-income">{{ formatCurrency(projectedIncome) }}</span>
          <p>Prognostizierte Einnahmen</p>
        </div>
        <div class="summary-item">
          <span class="value forecast-expense">{{ formatCurrency(projectedExpenses) }}</span>
          <p>Prognostizierte Ausgaben</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

const budgetStore = useBudgetStore();
const {
  isLoading,
  projectedIncome,
  projectedExpenses,
  currentMonthIncome,
  currentMonthExpenses,
} = storeToRefs(budgetStore);

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
};
</script>

<style scoped>
.financial-overview-card .card-content {
  text-align: center;
}

.summary-item {
  margin-bottom: 1rem;
}

.summary-item .value {
  font-size: 1.5rem;
  font-weight: bold;
  display: block;
}

.summary-item .value.income {
  color: var(--color-success);
}

.summary-item .value.expense {
  color: var(--color-danger);
}

.summary-item .value.forecast-income {
  color: #3fb950;
  /* slightly different green */
}

.summary-item .value.forecast-expense {
  color: #f85149;
  /* slightly different red */
}

.summary-item p {
  margin: 0;
  color: var(--color-text-soft);
}

.financial-overview-card hr {
  border: 0;
  border-top: 1px solid var(--color-border);
  margin: 1rem 0;
}
</style>