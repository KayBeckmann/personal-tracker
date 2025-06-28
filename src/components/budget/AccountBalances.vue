<template>
  <div class="card account-balances-card">
    <div class="card-header">
      <h3><i class="fa-solid fa-wallet"></i> Kontostände</h3>
    </div>
    <div class="card-content">
      <ul class="account-list">
        <li v-for="account in accounts" :key="account.id" class="account-item">
          <span class="account-name">{{ account.name }}</span>
          <span class="account-balance">{{ formatCurrency(account.balance) }}</span>
        </li>
      </ul>
      <hr>
      <div class="total-balance">
        <span class="total-label">Gesamtsaldo</span>
        <span class="total-amount">{{ formatCurrency(totalBalance) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

const budgetStore = useBudgetStore();
const { accounts, totalBalance } = storeToRefs(budgetStore);

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
};
</script>

<style scoped>
.account-balances-card .card-content {
  padding: 1rem;
}

.account-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.account-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
}

.account-item:last-child {
  border-bottom: none;
}

.account-name {
  font-weight: 500;
}

.account-balance {
  font-weight: bold;
}

.total-balance {
  display: flex;
  justify-content: space-between;
  font-size: 1.2rem;
  font-weight: bold;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
}
</style>
