// src/views/TransactionEditView.vue

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useBudgetStore } from '@/stores/budgetStore';
import { db, type Transaction, type Account, type Category } from '@/services/db';

const props = defineProps<{
  id: string;
}>();

const router = useRouter();
const budgetStore = useBudgetStore();
const transactionData = ref<Transaction | null>(null);

onMounted(async () => {
    const txId = parseInt(props.id, 10);
    if (!isNaN(txId)) {
        const tx = await db.transactions.get(txId);
        if (tx) {
            transactionData.value = {
                ...tx,
                amount: Math.abs(tx.amount), // for form binding
                date: new Date(tx.date) // ensure it's a Date object
            };
        } else {
            console.error('Transaction not found');
            router.push('/budget');
        }
    }
});

const availableCategories = computed(() => {
    if (!transactionData.value) return [];
    return budgetStore.categories.filter((c: Category) => c.type === transactionData.value!.type);
});

const availableToAccounts = computed(() => {
    if (!transactionData.value) return [];
    return budgetStore.accounts.filter((acc: Account) => acc.id !== transactionData.value!.accountId);
});

const handleUpdate = async () => {
    if (!transactionData.value) return;

    // Construct the data payload for the update
    const dataToUpdate: Omit<Transaction, 'id' | 'createdAt'> = {
        description: transactionData.value.description,
        amount: transactionData.value.amount,
        date: new Date(transactionData.value.date),
        type: transactionData.value.type,
        accountId: transactionData.value.accountId,
        toAccountId: transactionData.value.type === 'transfer' ? transactionData.value.toAccountId : undefined,
        categoryId: transactionData.value.type !== 'transfer' ? transactionData.value.categoryId : undefined,
    };
    
    await budgetStore.updateTransaction(transactionData.value.id!, dataToUpdate);
    router.push('/budget');
};

</script>

<template>
  <div class="transaction-edit-view">
    <h1>Edit Transaction</h1>
    <div v-if="transactionData" class="card">
      <form @submit.prevent="handleUpdate">
        
        <div class="form-group">
            <label>Type</label>
            <select v-model="transactionData.type">
                <option value="expense">Expense</option>
                <option value="income">Income</option>
                <option value="transfer">Transfer</option>
            </select>
        </div>

        <div class="form-group" v-if="transactionData.type === 'transfer'">
            <label for="toAccount">To Account</label>
            <select id="toAccount" v-model.number="transactionData.toAccountId" required>
                <option disabled :value="undefined">Select target account</option>
                <option v-for="acc in availableToAccounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
            </select>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Update Transaction</button>
          <router-link to="/budget" class="btn btn-secondary">Cancel</router-link>
        </div>
      </form>
    </div>
    <div v-else>
      <p>Loading transaction...</p>
    </div>
  </div>
</template>