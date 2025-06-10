<template>
  <div class="budget-view">
    <div class="tabs">
      <button :class="{ active: activeTab === 'overview' }" @click="activeTab = 'overview'">
        <i class="fas fa-chart-line"></i><span>Übersicht & Analyse</span>
      </button>
      <button :class="{ active: activeTab === 'add' }" @click="activeTab = 'add'">
        <i class="fas fa-plus-circle"></i><span>Neue Buchung</span>
      </button>
      <button :class="{ active: activeTab === 'accounts' }" @click="activeTab = 'accounts'">
        <i class="fas fa-wallet"></i><span>Konten</span>
      </button>
      <button :class="{ active: activeTab === 'categories' }" @click="activeTab = 'categories'">
        <i class="fas fa-tags"></i><span>Kategorien</span>
      </button>
    </div>

    <div class="tab-content">
      <div v-if="error" class="error-message">{{ error }}</div>
      <div v-if="isLoading" class="loading-indicator">Lade Daten...</div>

      <div v-show="activeTab === 'overview'" class="overview-grid">
        <div class="card full-width">
          <div class="card-header">
            <h3>Kontostandsverlauf & Prognose</h3>
          </div>
          <LineChart :chart-data="balanceHistoryChartData" />
        </div>

        <FinancialOverview />

        <div class="card">
          <div class="card-header">
            <h3>Ausgaben nach Kategorie (Pareto)</h3>
          </div>
          <ParetoChart :chart-data="paretoChartData" />
        </div>

        <div class="card transaction-list-card full-width">
          <div class="card-header">
            <div class="header-content">
              <h3>Letzte Buchungen</h3>
              <span class="total-balance">Gesamtsaldo: {{ formatCurrency(totalBalance) }}</span>
            </div>
          </div>
          <ul class="list-group">
            <li v-for="tx in transactions.slice(0, 20)" :key="tx.id" class="list-group-item">
              <div class="tx-details">
                <span class="tx-date">{{ formatDate(tx.date) }}</span>
                <span class="tx-desc">{{ tx.description }}</span>
                <small class="tx-account">{{ getAccountName(tx.accountId) }}</small>
              </div>
              <div class="tx-amount">
                <span :class="tx.amount >= 0 ? 'text-success' : 'text-danger'">{{ formatCurrency(tx.amount) }}</span>
              </div>
              <div class="tx-actions">
                <button @click="router.push(`/budget/transaction/${tx.id}/edit`)" class="btn btn-sm btn-secondary"
                  title="Bearbeiten">
                  <i class="fas fa-pencil-alt"></i>
                </button>
              </div>
            </li>
            <li v-if="!transactions.length" class="list-group-item empty-state">
              Keine Buchungen vorhanden.
            </li>
          </ul>
        </div>
      </div>

      <div v-if="activeTab === 'add'" class="card">
        <div class="card-header">
          <h3>Neue Buchung erfassen</h3>
        </div>
        <TransactionForm @save="handleSaveTransaction" @close="activeTab = 'overview'" />
      </div>

      <div v-if="activeTab === 'accounts'">
        <AccountManager />
      </div>

      <div v-if="activeTab === 'categories'">
        <CategoryManager />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';
import { useRouter } from 'vue-router';
import type { Transaction } from '@/services/db';

import TransactionForm from '@/components/budget/TransactionForm.vue';
import AccountManager from '@/components/budget/AccountManager.vue';
import CategoryManager from '@/components/budget/CategoryManager.vue';
import FinancialOverview from '@/components/budget/FinancialOverview.vue';
import LineChart from '@/components/budget/LineChart.vue';
import ParetoChart from '@/components/budget/ParetoChart.vue';

const router = useRouter();
const budgetStore = useBudgetStore();
const { accounts, transactions, categories, isLoading, error, totalBalance } = storeToRefs(budgetStore);

const activeTab = ref('overview');

const handleSaveTransaction = async (data: Transaction) => {
  await budgetStore.addTransaction(data);
  if (!error.value) {
    activeTab.value = 'overview'; // Nach Speichern zurück zur Übersicht
  }
};

const formatDate = (date: Date | string) => new Date(date).toLocaleDateString('de-DE', { year: '2-digit', month: '2-digit', day: '2-digit' });
const formatCurrency = (amount: number) => new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
const getAccountName = (id: number) => accounts.value.find(a => a.id === id)?.name || 'N/A';

const balanceHistoryChartData = computed(() => {
  const sortedTransactions = [...transactions.value].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  const labels: string[] = [];
  const historyData: (number | null)[] = [];

  if (sortedTransactions.length > 0) {
    let currentBalance = totalBalance.value;
    const balancePoints = new Map<string, number>();

    // Berechne den Saldo rückwärts für jeden Tag mit einer Transaktion
    for (let i = sortedTransactions.length - 1; i >= 0; i--) {
      const tx = sortedTransactions[i];
      const dateStr = tx.date.toISOString().split('T')[0];
      balancePoints.set(dateStr, currentBalance);
      currentBalance -= tx.amount;
    }

    const firstTxDate = new Date(sortedTransactions[0].date);
    const today = new Date();
    const dates: string[] = [];
    for (let d = firstTxDate; d <= today; d.setDate(d.getDate() + 1)) {
      dates.push(d.toISOString().split('T')[0]);
    }

    let lastKnownBalance = currentBalance; // Startguthaben
    labels.push(...dates);
    historyData.push(...dates.map(date => {
      if (balancePoints.has(date)) {
        lastKnownBalance = balancePoints.get(date)!;
      }
      return lastKnownBalance;
    }));
  }

  // Einfache lineare Prognose
  const forecastData: (number | null)[] = [...historyData];
  if (historyData.length > 1) {
    const lastValue = historyData[historyData.length - 1]!;
    forecastData[forecastData.length - 1] = lastValue; // Letzten Punkt verbinden
    const trend = (lastValue - historyData[historyData.length - 2]!) || 0;
    for (let i = 1; i <= 7; i++) { // 7 Tage Prognose
      const futureDate = new Date();
      futureDate.setDate(new Date().getDate() + i);
      labels.push(futureDate.toISOString().split('T')[0]);
      forecastData.push(lastValue + trend * i);
    }
  }

  return { labels, historyData, forecastData };
});

const paretoChartData = computed(() => {
  const expenseByCategory = new Map<string, number>();
  transactions.value
    .filter(t => t.type === 'expense')
    .forEach(t => {
      const categoryName = categories.value.find(c => c.id === t.categoryId)?.name || 'Unkategorisiert';
      expenseByCategory.set(categoryName, (expenseByCategory.get(categoryName) || 0) + Math.abs(t.amount));
    });

  const sortedExpenses = Array.from(expenseByCategory.entries())
    .map(([label, value]) => ({ label, value }))
    .sort((a, b) => b.value - a.value);

  const totalExpense = sortedExpenses.reduce((sum, item) => sum + item.value, 0);
  let cumulative = 0;
  const cumulativePercentage = sortedExpenses.map(item => {
    cumulative += item.value;
    return (cumulative / totalExpense) * 100;
  });

  return {
    labels: sortedExpenses.map(item => item.label),
    datasets: [
      { label: 'Ausgaben (€)', data: sortedExpenses.map(item => item.value) },
      { label: 'Kumulativ (%)', data: cumulativePercentage }
    ]
  };
});

</script>

<style scoped>
.budget-view {
  width: 100%;
}

.tabs {
  display: flex;
  gap: 2px;
  margin-bottom: -1px;
  /* Lässt den aktiven Tab mit dem Inhalt verschmelzen */
  overflow-x: auto;
  scrollbar-width: none;
  /* Firefox */
}

.tabs::-webkit-scrollbar {
  display: none;
  /* Chrome, Safari, Opera */
}

.tabs button {
  padding: 10px 20px;
  cursor: pointer;
  border: 1px solid var(--color-border);
  border-bottom: none;
  background-color: var(--color-background-soft);
  color: var(--color-text-soft);
  border-radius: 8px 8px 0 0;
  font-size: 1rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
}

.tabs button.active {
  background-color: var(--color-background);
  color: var(--color-primary);
  border-bottom: 1px solid var(--color-background);
  z-index: 1;
}

.tab-content {
  background-color: var(--color-background);
  border: 1px solid var(--color-border);
  padding: 2rem;
  border-radius: 0 8px 8px 8px;
  width: 100%;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.full-width {
  grid-column: 1 / -1;
}

/* Transaktionsliste Stile */
.list-group {
  padding: 0;
  list-style: none;
}

.list-group-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--color-border);
  gap: 1rem;
}

.list-group-item:last-child {
  border-bottom: none;
}

.tx-details {
  flex-grow: 1;
}

.tx-date {
  font-weight: bold;
  margin-right: 1rem;
}

.tx-account {
  display: block;
  font-style: italic;
  color: var(--color-text-soft);
  font-size: 0.85rem;
}

.tx-amount {
  min-width: 100px;
  text-align: right;
  font-weight: bold;
}

.tx-actions {
  display: flex;
  gap: 0.5rem;
}

.text-success {
  color: var(--color-success);
}

.text-danger {
  color: var(--color-danger);
}

.total-balance {
  font-size: 1.1rem;
  color: var(--color-text-soft);
}

.header-content {
  display: flex;
  align-items: baseline;
  gap: 1rem;
}

.card-header h3 {
  margin: 0;
}

@media (max-width: 768px) {
  .tabs button span {
    display: none;
    /* Text auf kleinen Bildschirmen ausblenden */
  }

  .tabs button {
    flex-grow: 1;
    justify-content: center;
  }

  .tab-content {
    padding: 1rem;
  }
}
</style>