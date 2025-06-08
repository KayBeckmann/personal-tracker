<script setup lang="ts">
import { ref, watch } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';
import type { Transaction } from '@/services/db';
import { useRouter } from 'vue-router';
import TransactionForm from '@/components/budget/TransactionForm.vue';

const budgetStore = useBudgetStore();
const router = useRouter();
const { 
  accounts, 
  transactions, 
  isLoading, 
  error,
  totalBalance
} = storeToRefs(budgetStore);

const showAddForm = ref(false);

const newTransactionTemplate = (): Omit<Transaction, 'id'> => ({
  description: '',
  amount: 0,
  date: new Date(),
  type: 'expense',
  accountId: accounts.value.length > 0 ? accounts.value[0].id! : 0,
  toAccountId: undefined,
  categoryId: undefined,
  createdAt: new Date(), // Add createdAt to satisfy the Transaction type
});

const newTransactionData = ref<Omit<Transaction, 'id'>>(newTransactionTemplate());

watch(showAddForm, (isShown) => {
  if (isShown) {
    newTransactionData.value = newTransactionTemplate();
  }
});

const handleSaveTransaction = async (data: Transaction) => {
  await budgetStore.addTransaction(data);
  if (!error.value) {
    showAddForm.value = false;
  }
};

const formatDate = (date: Date | string) => {
    return new Date(date).toLocaleDateString('de-DE', { year: '2-digit', month: '2-digit', day: '2-digit' });
};

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
};

const getAccountName = (id: number) => accounts.value.find(a => a.id === id)?.name || 'N/A';
</script>

<template>
  <div class="budget-view">
    <div class="card">
      <div class="card-header">
        <div class="header-content">
            <h2>Budget</h2>
            <span class="total-balance">Total: {{ formatCurrency(totalBalance) }}</span>
        </div>
        <button class="btn btn-primary" @click="showAddForm = !showAddForm">
          {{ showAddForm ? 'Cancel' : 'New Transaction' }}
        </button>
      </div>

      <div v-if="showAddForm" class="card-body">
        <TransactionForm 
            :initial-data="null"
            @save="handleSaveTransaction" 
            @close="showAddForm = false"
        />
      </div>

      <div v-if="isLoading">Loading...</div>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>
      
      <div class="card-body" v-if="!isLoading && !error">
        <h3>Transactions</h3>
        <ul class="list-group">
          <li v-for="tx in transactions" :key="tx.id" class="list-group-item">
            <div class="tx-details">
                <span class="tx-date">{{ formatDate(tx.date) }}</span>
                <span class="tx-desc">{{ tx.description }}</span>
                <small class="tx-account">{{ getAccountName(tx.accountId) }}</small>
            </div>
            <div class="tx-amount">
                <span :class="tx.amount >= 0 ? 'text-success' : 'text-danger'">
                  {{ formatCurrency(tx.amount) }}
                </span>
            </div>
            <div class="tx-actions">
                <button @click="router.push(`/budget/transaction/${tx.id}/edit`)" class="btn btn-sm btn-secondary" title="Edit">
                    <i class="fas fa-pencil-alt"></i>
                </button>
                <button @click="budgetStore.deleteTransaction(tx.id!)" class="btn btn-sm btn-danger" title="Delete">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.header-content {
    display: flex;
    align-items: baseline;
    gap: 1rem;
}
.total-balance {
    font-size: 1.1rem;
    color: var(--color-text-soft);
}
.list-group-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1.25rem;
  border-bottom: 1px solid var(--color-border);
  gap: 1rem;
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
.text-success { color: var(--color-success); }
.text-danger { color: var(--color-danger); }
.alert-danger { color: var(--color-danger); }
</style>