<template>
  <div class="transaction-edit-view">
    <h1>Edit Transaction</h1>
    <form v-if="transactionData" @submit.prevent="submitForm">
        <div class="form-group">
            <label for="description">Description</label>
            <input type="text" id="description" v-model="transactionData.description" required>
        </div>

        <div class="form-group">
            <label for="amount">Amount</label>
            <input type="number" id="amount" v-model.number="transactionData.amount" required step="0.01" min="0">
        </div>
        
        <div class="form-group">
            <label for="date">Date</label>
            <input type="date" id="date" v-model="dateInput" required>
        </div>
        
        <div class="form-group">
            <label for="type">Type</label>
            <select id="type" v-model="transactionData.type" required>
                <option value="income">Income</option>
                <option value="expense">Expense</option>
                <option value="transfer">Transfer</option>
            </select>
        </div>

        <div class="form-group">
            <label for="accountId">{{ transactionData.type === 'transfer' ? 'From Account' : 'Account' }}</label>
            <select id="accountId" v-model.number="transactionData.accountId" required>
                <option v-for="acc in budgetStore.accounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
            </select>
        </div>

        <div v-if="transactionData.type === 'transfer'" class="form-group">
            <label for="toAccountId">To Account</label>
            <select id="toAccountId" v-model.number="transactionData.toAccountId" required>
                 <option v-for="acc in budgetStore.accounts.filter(a => a.id !== transactionData.accountId)" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
            </select>
        </div>

        <div v-if="transactionData.type !== 'transfer'" class="form-group">
            <label for="categoryId">Category</label>
            <select id="categoryId" v-model.number="transactionData.categoryId">
                <option :value="undefined">-- No Category --</option>
                <option v-for="cat in filteredCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </select>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="btn-primary">Update Transaction</button>
            <button type="button" @click="cancel">Cancel</button>
        </div>
        <div v-if="budgetStore.error" class="error-message">{{ budgetStore.error }}</div>
    </form>
    <div v-else-if="isLoading">Loading transaction...</div>
     <div v-else class="error-message">Could not load transaction data.</div>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useBudgetStore } from '@/stores/budgetStore';
import { db, type Transaction } from '@/services/db';

const router = useRouter();
const budgetStore = useBudgetStore();

const transactionData = ref<Omit<Transaction, 'id' | 'createdAt'> | null>(null);
const dateInput = ref('');
const isLoading = ref(true);

const props = defineProps<{
  id: string;
}>();

onMounted(async () => {
    await budgetStore.fetchAll(); // Make sure we have accounts and categories
    const transactionId = Number(props.id);
    if (!isNaN(transactionId)) {
        const tx = await db.transactions.get(transactionId);
        if (tx) {
            transactionData.value = {
                description: tx.description,
                amount: Math.abs(tx.amount), // Always edit the positive value
                date: tx.date,
                type: tx.type,
                accountId: tx.accountId,
                toAccountId: tx.toAccountId,
                categoryId: tx.categoryId,
            };
            dateInput.value = new Date(tx.date).toISOString().split('T')[0];
        }
    }
    isLoading.value = false;
});

const filteredCategories = computed(() => {
    if (!transactionData.value) return [];
    return budgetStore.categories.filter(c => c.type === transactionData.value!.type);
});

const submitForm = async () => {
    if (!transactionData.value) return;

    if (transactionData.value.type === 'transfer' && transactionData.value.accountId === transactionData.value.toAccountId) {
        alert("From and To accounts cannot be the same for a transfer.");
        return;
    }
    
    // Convert date string back to Date object
    transactionData.value.date = new Date(dateInput.value);

    // Clean up data for non-transfer types
    if (transactionData.value.type !== 'transfer') {
        transactionData.value.toAccountId = undefined;
    } else {
        transactionData.value.categoryId = undefined;
    }
    
    await budgetStore.updateTransaction(Number(props.id), transactionData.value);

    if (!budgetStore.error) {
        router.push({ name: 'Budget' });
    }
};

const cancel = () => {
    router.back();
};

// Reset category if type changes
watch(() => transactionData.value?.type, (newType, oldType) => {
    if (newType !== oldType && transactionData.value) {
        transactionData.value.categoryId = undefined;
    }
})

</script>

<style scoped>
.transaction-edit-view {
  max-width: 600px;
  margin: 2rem auto;
  padding: 2rem;
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: 8px;
}
.form-group {
  margin-bottom: 1.5rem;
  text-align: left;
}
.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
}
.form-group input, .form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: 4px;
  font-size: 1rem;
}
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}
.btn-primary {
    background-color: var(--color-primary);
    color: white;
    border: none;
    padding: 0.6em 1.2em;
    border-radius: 8px;
    font-size: 1em;
    cursor: pointer;
}
.form-actions button:not(.btn-primary) {
     background-color: var(--color-background-mute);
     border: 1px solid var(--color-border);
}
.error-message {
    color: var(--color-danger);
    margin-top: 1rem;
}
</style>