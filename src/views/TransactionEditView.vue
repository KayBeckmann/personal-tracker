<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useBudgetStore } from '@/stores/budgetStore';
import { db, type Transaction } from '@/services/db';
import TransactionForm from '@/components/budget/TransactionForm.vue';

const budgetStore = useBudgetStore();
const route = useRoute();
const router = useRouter();

// FIX for TS2741: Define the ref to hold a full Transaction object or null.
const transaction = ref<Transaction | null>(null);

const isEditMode = computed(() => !!route.params.id);
const isLoading = ref(true);

onMounted(async () => {
  if (budgetStore.accounts.length === 0 || budgetStore.categories.length === 0) {
      await budgetStore.fetchAll();
  }
  
  const txId = Number(route.params.id);
  if (isEditMode.value && txId) {
    // The data from the DB is already a full 'Transaction' object, so it can be assigned directly.
    const existingTx = await db.transactions.get(txId);
    if (existingTx) {
      transaction.value = existingTx;
    } else {
      // Handle case where transaction is not found by redirecting.
      await router.push('/budget');
    }
  }
  isLoading.value = false;
});

const handleDelete = async (transactionId: number) => {
  if (confirm('Are you sure you want to delete this transaction?')) {
    try {
      await budgetStore.deleteTransaction(transactionId);
      await router.push('/budget');
    } catch (error) {
      console.error("Failed to delete transaction:", error);
    }
  }
};
</script>

<template>
  <div class="card">
    <div class="card-header">
      <h2>Edit Transaction</h2>
    </div>
    <div class="card-body">
      <div v-if="isLoading">Loading...</div>
      <TransactionForm 
        v-else 
        :initial-data="transaction"
        @save="handleFormSubmit"
        @close="router.push('/budget')"
        @delete="handleDelete"
      />
    </div>
  </div>
</template>