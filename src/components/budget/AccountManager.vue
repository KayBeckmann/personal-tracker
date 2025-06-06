<template>
  <div class="card">
    <h3>Konten verwalten</h3>
    <ul class="item-list">
      <li v-for="account in accounts" :key="account.id">
        <span>
          {{ account.name }}
          <small v-if="!account.includeInAverage">(ignoriert)</small>
        </span>
        <span class="balance">{{ formatCurrency(account.balance) }}</span>
      </li>
       <li v-if="!accounts.length" class="empty-state">
        Noch keine Konten angelegt.
      </li>
    </ul>
    <form @submit.prevent="handleCreateAccount" class="form-inline">
      <input v-model="newAccountName" type="text" placeholder="Neues Konto" required />
      <div class="checkbox-wrapper">
        <input v-model="newAccountInclude" type="checkbox" id="includeInAverage" />
        <label for="includeInAverage">In Durchschnitte einbeziehen</label>
      </div>
      <button type="submit">Hinzufügen</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

const budgetStore = useBudgetStore();
const { accounts } = storeToRefs(budgetStore);

const newAccountName = ref('');
const newAccountInclude = ref(true);

const handleCreateAccount = () => {
  if (newAccountName.value.trim()) {
    budgetStore.addAccount({
      name: newAccountName.value,
      includeInAverage: newAccountInclude.value,
    });
    newAccountName.value = '';
    newAccountInclude.value = true;
  }
};

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
};
</script>

<style scoped>
.card {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}
.item-list {
  list-style: none;
  padding: 0;
  margin-bottom: 1rem;
}
.item-list li {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border-soft);
}
.item-list li small {
  color: var(--color-text-light);
  font-size: 0.8em;
  margin-left: 4px;
}
.balance {
  font-weight: 500;
}
.form-inline {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}
.form-inline input[type="text"] {
  flex-grow: 1;
  padding: 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: 4px;
}
.form-inline button {
  padding: 0.5rem 1rem;
}
.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.empty-state {
  color: var(--color-text-light);
  text-align: center;
  padding: 1rem 0;
  border-bottom: none;
}
</style>