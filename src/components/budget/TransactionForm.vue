// src/components/budget/TransactionForm.vue

<script setup lang="ts">
import { reactive, computed, watch, defineProps, defineEmits } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import type { Transaction, Category } from '@/services/db';

const props = defineProps<{
  initialData?: Transaction | null;
}>();

const emit = defineEmits(['close', 'save']);

const budgetStore = useBudgetStore();
const { accounts, categories } = budgetStore;

type TransactionFormData = {
  type: 'income' | 'expense' | 'transfer';
  description: string;
  amount: number;
  date: string;
  accountId: number;
  toAccountId?: number;
  categoryId?: number;
};

const getInitialState = (): TransactionFormData => ({
  type: 'expense',
  description: '',
  amount: 0,
  date: new Date().toISOString().split('T')[0],
  accountId: accounts.length > 0 ? accounts[0].id! : 0,
  toAccountId: undefined,
  categoryId: undefined
});

const initialState = getInitialState();
const transaction = reactive<TransactionFormData>({ ...initialState });

const availableCategories = computed(() => {
  return categories.filter((c: Category) => c.type === transaction.type);
});

const availableToAccounts = computed(() => {
    if (!transaction.accountId) return accounts;
    return accounts.filter((acc: any) => acc.id !== transaction.accountId);
});

const isFormValid = computed(() => {
  if(transaction.type !== 'transfer') return !!transaction.categoryId;
  return !!transaction.toAccountId;
});

watch(() => props.initialData, (data) => {
  if (data) {
    Object.assign(transaction, {
        ...data,
        date: new Date(data.date).toISOString().split('T')[0],
        amount: Math.abs(data.amount)
    });
  }
}, { immediate: true });

watch(() => transaction.type, () => {
    transaction.categoryId = undefined;
    transaction.toAccountId = undefined;
});

const resetForm = () => {
    const freshState = getInitialState();
    for (const key in freshState) {
        (transaction as any)[key] = (freshState as any)[key];
    }
};

const save = () => {
  emit('save', transaction, props.initialData?.id);
  resetForm();
};

</script>

<template>
  <form @submit.prevent="save" class="transaction-form card">
    <div class="form-group">
      <label>Type</label>
      <select v-model="transaction.type">
        <option value="expense">Expense</option>
        <option value="income">Income</option>
        <option value="transfer">Transfer</option>
      </select>
    </div>

    <div class="form-group" v-if="transaction.type !== 'transfer'">
      <label for="category">Category</label>
      <select id="category" v-model.number="transaction.categoryId" :required="transaction.type !== 'transfer'">
        <option disabled :value="undefined">Select a category</option>
        <option v-for="cat in availableCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
      </select>
    </div>

    <div class="form-group" v-if="transaction.type === 'transfer'">
      <label for="toAccount">To Account</label>
      <select id="toAccount" v-model.number="transaction.toAccountId" required>
        <option disabled :value="undefined">Select target account</option>
        <option v-for="acc in availableToAccounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
      </select>
    </div>

    <div class="form-actions">
        <button type="submit" class="btn btn-primary" :disabled="!isFormValid">Save</button>
        <button type="button" @click="$emit('close')" class="btn btn-secondary">Cancel</button>
    </div>
  </form>
</template>