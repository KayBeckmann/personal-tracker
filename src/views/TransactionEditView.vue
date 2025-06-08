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

const handleFormSubmit = async (data: Transaction) => {
  try {
    // The form now emits a full Transaction object. We only need to ensure it has an ID for updating.
    if (isEditMode.value && data.id) {
        // The updateTransaction function expects the original ID and the new data.
        await budgetStore.updateTransaction(data.id, data);
    }
    await router.push('/budget');
  } catch (error) {
    console.error("Failed to save transaction:", error);
    // Optionally show an error message to the user.
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
      />
    </div>
  </div>
</template>