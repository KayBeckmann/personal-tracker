<template>
  <div class="card">
    <h3>Kategorien verwalten</h3>
    <div class="category-lists">
        <div>
            <h4>Einnahmen</h4>
            <ul class="item-list">
                <li v-for="cat in incomeCategories" :key="cat.id">{{ cat.name }}</li>
                <li v-if="!incomeCategories.length" class="empty-state">Keine</li>
            </ul>
        </div>
        <div>
            <h4>Ausgaben</h4>
            <ul class="item-list">
                <li v-for="cat in expenseCategories" :key="cat.id">{{ cat.name }}</li>
                <li v-if="!expenseCategories.length" class="empty-state">Keine</li>
            </ul>
        </div>
    </div>
    <form @submit.prevent="handleCreateCategory" class="form-inline">
      <input v-model="newCategoryName" type="text" placeholder="Neue Kategorie" required />
      <select v-model="newCategoryType" required>
        <option value="expense">Ausgabe</option>
        <option value="income">Einnahme</option>
      </select>
      <button type="submit">Hinzufügen</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useBudgetStore } from '@/stores/budgetStore';
import { storeToRefs } from 'pinia';

const budgetStore = useBudgetStore();
const { categories } = storeToRefs(budgetStore);

const newCategoryName = ref('');
const newCategoryType = ref<'income' | 'expense'>('expense');

const incomeCategories = computed(() => categories.value.filter(c => c.type === 'income'));
const expenseCategories = computed(() => categories.value.filter(c => c.type === 'expense'));

const handleCreateCategory = () => {
  if (newCategoryName.value.trim()) {
    budgetStore.addCategory({
      name: newCategoryName.value,
      type: newCategoryType.value,
    });
    newCategoryName.value = '';
  }
};
</script>

<style scoped>
.card {
  background-color: var(--color-background, #fff);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}
.category-lists {
    display: flex;
    gap: 2rem;
    margin-bottom: 1rem;
}
.category-lists > div {
    flex: 1;
}
.item-list {
  list-style: none;
  padding: 0;
}
.item-list li {
  padding: 0.25rem 0;
}
.form-inline {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}
.form-inline input, .form-inline select {
  flex-grow: 1;
  padding: 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: 4px;
}
.form-inline button {
  padding: 0.5rem 1rem;
}
.empty-state {
  color: var(--color-text-light);
  font-style: italic;
}

@media (max-width: 480px) {
  .category-lists {
    flex-direction: column;
  }

  .form-inline {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>