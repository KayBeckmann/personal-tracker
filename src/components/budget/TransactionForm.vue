<template>
  <div class="card">
    <h3>Neue Transaktion erfassen</h3>
    <form @submit.prevent="handleTransactionSubmit">
      <div class="form-grid">
        <div class="form-group">
          <label for="type">Typ</label>
          <select id="type" v-model="transaction.type" required>
            <option value="expense">Ausgabe</option>
            <option value="income">Einnahme</option>
            <option value="transfer">Umbuchung</option>
          </select>
        </div>
        
        <div class="form-group">
          <label for="description">Beschreibung</label>
          <input id="description" type="text" v-model="transaction.description" required />
        </div>

        <div class="form-group">
          <label for="amount">Betrag (€)</label>
          <input id="amount" type="number" step="0.01" min="0" v-model.number="transaction.amount" required />
        </div>

        <div class="form-group">
          <label for="date">Datum</label>
          <input id="date" type="date" v-model="transaction.date" required />
        </div>
        
        <div class="form-group">
          <label for="account">{{ transaction.type === 'transfer' ? 'Von Konto' : 'Konto' }}</label>
          <select id="account" v-model.number="transaction.accountId" required>
            <option v-if="!accounts.length" disabled value="0">Bitte zuerst Konto anlegen</option>
            <option v-for="acc in accounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
          </select>
        </div>
        
        <div v-if="transaction.type === 'transfer'" class="form-group">
          <label for="toAccount">Auf Konto</label>
          <select id="toAccount" v-model.number="transaction.toAccountId" :required="transaction.type === 'transfer'">
            <option v-if="!availableToAccounts.length" disabled value="0">Kein anderes Konto verfügbar</option>
            <option v-for="acc in availableToAccounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
          </select>
        </div>

        <div v-if="transaction.type !== 'transfer'" class="form-group">
          <label for="category">Kategorie</label>
          <select id="category" v-model.number="transaction.categoryId" :required="transaction.type !== 'transfer'">
             <option v-if="!availableCategories.length" disabled value="">Bitte zuerst Kategorie anlegen</option>
             <option v-for="cat in availableCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>
      </div>
      <button type="submit" class="submit-btn" :disabled="!isFormValid">Transaktion speichern</button>
    </form>
    <p v-if="store.error" class="error-msg">{{ store.error }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';
import type { Category } from '@/services/db';

const store = useBudgetStore();
const { accounts, categories } = storeToRefs(store);

const getInitialTransactionState = () => ({
  type: 'expense' as 'income' | 'expense' | 'transfer',
  description: '',
  amount: 0,
  date: new Date().toISOString().split('T')[0],
  accountId: accounts.value[0]?.id || 0,
  toAccountId: undefined as number | undefined,
  categoryId: undefined as number | undefined,
});

const transaction = reactive(getInitialTransactionState());

const availableCategories = computed<Category[]>(() => {
  return categories.value.filter(c => c.type === transaction.type);
});

const availableToAccounts = computed(() => {
    return accounts.value.filter(acc => acc.id !== transaction.accountId);
});

const isFormValid = computed(() => {
    if(!transaction.accountId || transaction.amount <= 0) return false;
    if(transaction.type === 'transfer') return !!transaction.toAccountId;
    if(transaction.type !== 'transfer') return !!transaction.categoryId;
    return true;
});

watch(() => transaction.type, (newType) => {
    transaction.categoryId = undefined;
    transaction.toAccountId = undefined;
    if (newType === 'transfer' && accounts.value.length > 1) {
        transaction.toAccountId = availableToAccounts.value[0]?.id;
    } else if (newType !== 'transfer' && availableCategories.value.length > 0) {
        transaction.categoryId = availableCategories.value[0]?.id;
    }
});

watch(accounts, (newAccounts) => {
    if (!transaction.accountId && newAccounts.length > 0) {
        transaction.accountId = newAccounts[0].id!;
    }
}, { immediate: true });


const handleTransactionSubmit = async () => {
    if (!isFormValid.value) return;

    if (transaction.type === 'transfer' && transaction.accountId === transaction.toAccountId) {
        alert("Quell- und Zielkonto dürfen nicht identisch sein.");
        return;
    }

    await store.addTransaction({
        type: transaction.type,
        description: transaction.description,
        amount: transaction.amount,
        date: new Date(transaction.date),
        accountId: transaction.accountId,
        categoryId: transaction.categoryId,
        toAccountId: transaction.toAccountId,
    });
    
    // Reset form
    const initialState = getInitialTransactionState();
    Object.keys(initialState).forEach(key => {
        transaction[key] = initialState[key];
    });
};
</script>

<style scoped>
.card {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}
.form-group {
  display: flex;
  flex-direction: column;
}
.form-group label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--color-text-soft);
}
.form-group input, .form-group select {
  padding: 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: 4px;
  background-color: var(--color-background-soft);
  font-size: 1rem;
}
.submit-btn {
  margin-top: 1.5rem;
  width: 100%;
  padding: 0.85rem;
  background-color: var(--color-primary);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: background-color 0.2s;
}
.submit-btn:hover:not(:disabled) {
  background-color: var(--color-primary-dark);
}
.submit-btn:disabled {
    background-color: var(--color-secondary);
    cursor: not-allowed;
}
.error-msg {
    color: var(--color-danger);
    margin-top: 1rem;
    text-align: center;
}
</style>