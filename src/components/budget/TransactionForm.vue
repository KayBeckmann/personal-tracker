<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import type { Transaction } from '@/services/db';

const props = defineProps<{
  initialData?: Transaction | null;
}>();

const emit = defineEmits(['save', 'close']);

const budgetStore = useBudgetStore();

const localTransaction = ref<Omit<Transaction, 'id'>>({
  description: '',
  amount: 0,
  date: new Date(),
  type: 'expense',
  accountId: 0,
  categoryId: undefined,
  toAccountId: undefined,
  createdAt: new Date(),
});

// Watch for changes in initialData to populate the form for editing
watch(() => props.initialData, (newData) => {
  if (newData) {
    localTransaction.value = {
        ...newData,
        date: new Date(newData.date),
        amount: Math.abs(newData.amount), // Form works with positive numbers
    };
  }
}, { immediate: true });


const availableCategories = computed(() => {
  if (localTransaction.value.type === 'transfer') return [];
  return budgetStore.categories.filter(c => c.type === localTransaction.value.type);
});

const availableAccounts = computed(() => budgetStore.accounts);

const handleSubmit = () => {
  const dataToSave: Transaction = {
    ...localTransaction.value,
    id: props.initialData?.id, // include id if we are editing
    amount: localTransaction.value.type === 'expense' 
        ? -Math.abs(localTransaction.value.amount) 
        : Math.abs(localTransaction.value.amount),
    date: new Date(localTransaction.value.date)
  };
  emit('save', dataToSave);
};

const handleDateChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    localTransaction.value.date = new Date(target.value);
};

</script>

<template>
  <form @submit.prevent="handleSubmit" class="transaction-form">
    <div class="form-group">
      <label for="type">Type</label>
      <select id="type" v-model="localTransaction.type" class="form-control">
        <option value="expense">Expense</option>
        <option value="income">Income</option>
        <option value="transfer">Transfer</option>
      </select>
    </div>

    <div class="form-group">
      <label for="description">Description</label>
      <input type="text" id="description" v-model="localTransaction.description" class="form-control" required>
    </div>

    <div class="form-group">
      <label for="amount">Amount</label>
      <input type="number" id="amount" v-model.number="localTransaction.amount" class="form-control" required min="0.01" step="0.01">
    </div>
    
    <div class="form-group">
      <label for="date">Date</label>
      <input type="date" id="date" :value="localTransaction.date.toISOString().split('T')[0]" @change="handleDateChange" class="form-control" required>
    </div>

    <div class="form-group">
      <label for="account">{{ localTransaction.type === 'transfer' ? 'From Account' : 'Account' }}</label>
      <select id="account" v-model.number="localTransaction.accountId" class="form-control" required>
        <option v-for="account in availableAccounts" :key="account.id" :value="account.id">{{ account.name }}</option>
      </select>
    </div>

    <div v-if="localTransaction.type === 'transfer'" class="form-group">
      <label for="toAccount">To Account</label>
      <select id="toAccount" v-model.number="localTransaction.toAccountId" class="form-control" required>
        <option v-for="account in availableAccounts" :key="account.id" :value="account.id">{{ account.name }}</option>
      </select>
    </div>
    
    <div v-if="localTransaction.type !== 'transfer'" class="form-group">
      <label for="category">Category</label>
      <select id="category" v-model.number="localTransaction.categoryId" class="form-control" :required="['income', 'expense'].includes(localTransaction.type)">
        <option disabled :value="undefined">Select a category</option>
        <option v-for="cat in availableCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
      </select>
    </div>

    <div class="form-actions">
        <button type="submit" class="btn btn-primary">Save</button>
        <button type="button" @click="$emit('close')" class="btn btn-secondary">Cancel</button>
    </div>
  </form>
</template>

<style scoped>
.transaction-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.form-actions {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
}
</style>