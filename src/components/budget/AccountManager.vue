<template>
  <div class="card">
    <h3>Konten verwalten</h3>
    <ul class="item-list">
      <li v-for="account in accounts" :key="account.id">
        <span>
          {{ account.name }}
          <small v-if="!account.includeInAverage">(wird in Prognosen ignoriert)</small>
        </span>
        <span class="balance">{{ formatCurrency(account.balance) }}</span>
      </li>
      <li v-if="!accounts.length" class="empty-state">
        Noch keine Konten angelegt.
      </li>
    </ul>

    <h4>Neues Konto anlegen</h4>
    <form @submit.prevent="handleCreateAccount" class="form-grid">
      <div class="form-group">
        <label for="account-name">Kontoname</label>
        <input v-model="newAccountName" id="account-name" type="text" placeholder="z.B. Girokonto" required />
      </div>

      <div class="form-group">
        <label for="initial-balance">Startbetrag (€)</label>
        <input v-model.number="newAccountBalance" id="initial-balance" type="number" step="0.01" required />
      </div>

      <div class="form-group checkbox-wrapper">
        <input v-model="newAccountInclude" type="checkbox" id="includeInAverage" />
        <label for="includeInAverage">In Prognosen einbeziehen</label>
      </div>

      <button type="submit" class="btn-submit">Konto Hinzufügen</button>
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
const newAccountBalance = ref(0); // Standardwert 0
const newAccountInclude = ref(true);

const handleCreateAccount = () => {
  if (newAccountName.value.trim()) {
    budgetStore.addAccount({
      name: newAccountName.value,
      balance: newAccountBalance.value, // Startbetrag übergeben
      includeInAverage: newAccountInclude.value,
    });
    newAccountName.value = '';
    newAccountBalance.value = 0; // Zurücksetzen
    newAccountInclude.value = true;
  }
};

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
};
</script>

<style scoped>
.card {
  background-color: var(--color-background-soft);
  padding: 1.5rem;
  border-radius: 8px;
}

.item-list {
  list-style: none;
  padding: 0;
  margin-bottom: 2rem;
}

.item-list li {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--color-border);
}

.item-list li:last-child {
  border-bottom: none;
}

.item-list li small {
  color: var(--color-text-soft);
  font-size: 0.8em;
  margin-left: 4px;
  display: block;
}

.balance {
  font-weight: 500;
  font-size: 1.1em;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  align-items: flex-end;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 0.25rem;
  font-size: 0.9em;
  color: var(--color-text-soft);
}

.form-group input[type="text"],
.form-group input[type="number"] {
  width: 100%;
  padding: 0.6rem;
  border: 1px solid var(--color-border);
  border-radius: 4px;
}

.checkbox-wrapper {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  padding-bottom: 0.6rem;
  /* Damit es auf gleicher Höhe wie die Buttons ist */
}

.btn-submit {
  padding: 0.6rem 1rem;
  background-color: var(--color-primary);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  height: fit-content;
}

.empty-state {
  color: var(--color-text-soft);
  text-align: center;
  padding: 1rem 0;
  border-bottom: none;
}

@media (max-width: 480px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>