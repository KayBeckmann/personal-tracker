<template>
  <div class="budget-view">
    <h1>Budget Management</h1>

    <div class="balances-summary">
      <div class="total-balance-card">
        <h3>Total Balance</h3>
        <p class="balance-amount">{{ formatCurrency(budgetStore.totalBalance) }}</p>
      </div>
      <div class="account-balances-card">
        <h4>Account Balances</h4>
        <ul class="account-balances-list">
          <li v-for="account in budgetStore.accounts" :key="account.id">
            <span>{{ account.name }}</span>
            <span class="account-balance-amount">{{ formatCurrency(account.balance) }}</span>
          </li>
          <li v-if="!budgetStore.accounts.length" class="no-items">
            No accounts yet.
          </li>
        </ul>
      </div>
    </div>

    <div class="tabs">
      <button @click="activeTab = 'transactions'" :class="{ active: activeTab === 'transactions' }">Transactions</button>
      <button @click="activeTab = 'add'" :class="{ active: activeTab === 'add' }">Add Transaction</button>
      <button @click="activeTab = 'categories'" :class="{ active: activeTab === 'categories' }">Manage Categories</button>
      <button @click="activeTab = 'accounts'" :class="{ active: activeTab === 'accounts' }">Manage Accounts</button>
    </div>

    <div v-if="budgetStore.error" class="error-message">
        {{ budgetStore.error }}
    </div>

    <div v-if="activeTab === 'transactions'" class="tab-content">
      <h2>Recent Transactions</h2>
      <div v-if="budgetStore.isLoading">Loading...</div>
      <div v-else class="transaction-list">
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Description</th>
              <th>Category</th>
              <th>Account</th>
              <th>Amount</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tx in budgetStore.transactions" :key="tx.id">
              <td>{{ formatDate(tx.date) }}</td>
              <td>{{ tx.description }}</td>
              <td>{{ getCategoryName(tx.categoryId) }}</td>
              <td>{{ getAccountName(tx.accountId) }} <span v-if="tx.type === 'transfer'">→ {{ getAccountName(tx.toAccountId) }}</span></td>
              <td :class="tx.amount < 0 ? 'expense' : 'income'">
                {{ formatCurrency(tx.amount) }}
              </td>
              <td>
                  <button @click="editTransaction(tx.id!)" class="action-btn edit-btn">Edit</button>
                  <button @click="confirmDelete(tx.id!)" class="action-btn delete-btn">Delete</button>
              </td>
            </tr>
            <tr v-if="!budgetStore.transactions.length">
              <td colspan="6">No transactions yet.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="activeTab === 'add'" class="tab-content">
      <h2>Add New Transaction</h2>
      <form @submit.prevent="handleAddNewTransaction" class="manage-form vertical-form" v-if="budgetStore.accounts.length > 0">
          <div class="form-group">
              <label for="new-desc">Description</label>
              <input id="new-desc" type="text" v-model="newTransactionData.description" required placeholder="e.g., Groceries, Salary">
          </div>

          <div class="form-group">
              <label for="new-amount">Amount</label>
              <input id="new-amount" type="number" v-model.number="newTransactionData.amount" required step="0.01" min="0" placeholder="0.00">
          </div>
          
          <div class="form-group">
              <label for="new-date">Date</label>
              <input id="new-date" type="date" v-model="dateInput" required>
          </div>
          
          <div class="form-group">
              <label for="new-type">Type</label>
              <select id="new-type" v-model="newTransactionData.type" required>
                  <option value="expense">Expense</option>
                  <option value="income">Income</option>
                  <option value="transfer">Transfer</option>
              </select>
          </div>

          <div class="form-group">
              <label for="new-account">{{ newTransactionData.type === 'transfer' ? 'From Account' : 'Account' }}</label>
              <select id="new-account" v-model.number="newTransactionData.accountId" required>
                  <option v-for="acc in budgetStore.accounts" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
              </select>
          </div>

          <div v-if="newTransactionData.type === 'transfer'" class="form-group">
              <label for="new-to-account">To Account</label>
              <select id="new-to-account" v-model.number="newTransactionData.toAccountId" required>
                  <option :value="undefined">-- Select Target Account --</option>
                  <option v-for="acc in budgetStore.accounts.filter(a => a.id !== newTransactionData.accountId)" :key="acc.id" :value="acc.id">{{ acc.name }}</option>
              </select>
          </div>

          <div v-if="newTransactionData.type !== 'transfer'" class="form-group">
              <label for="new-category">Category</label>
              <select id="new-category" v-model.number="newTransactionData.categoryId">
                  <option :value="undefined">-- No Category --</option>
                  <option v-for="cat in availableCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
              </select>
          </div>
          
          <div class="form-actions">
              <button type="submit" class="btn-primary">Add Transaction</button>
          </div>
      </form>
       <div v-else>
          <p>Please create an account first before adding a transaction.</p>
      </div>
    </div>

    <div v-if="activeTab === 'categories'" class="tab-content">
      <h2>Categories</h2>
      <form @submit.prevent="handleAddNewCategory" class="manage-form">
          <input type="text" v-model="newCategory.name" placeholder="New category name" required>
          <select v-model="newCategory.type">
              <option value="income">Income</option>
              <option value="expense">Expense</option>
          </select>
          <button type="submit" class="btn-primary">Add Category</button>
      </form>
      <ul class="item-list">
          <li v-for="cat in budgetStore.categories" :key="cat.id">
              <span>{{ cat.name }} ({{cat.type}})</span>
          </li>
      </ul>
    </div>

    <div v-if="activeTab === 'accounts'" class="tab-content">
        <h2>Accounts</h2>
        <form @submit.prevent="handleAddNewAccount" class="manage-form">
            <input type="text" v-model="newAccount.name" placeholder="New account name" required>
            <label class="checkbox-label">
                <input type="checkbox" v-model="newAccount.includeInAverage">
                Include in average calculation
            </label>
            <button type="submit" class="btn-primary">Add Account</button>
        </form>
        <ul class="item-list">
            <li v-for="acc in budgetStore.accounts" :key="acc.id">
                <span>{{ acc.name }} ({{ formatCurrency(acc.balance) }})</span>
            </li>
        </ul>
    </div>

  </div>
</template>

<script lang="ts" setup>
import { useBudgetStore } from '@/stores/budgetStore';
import { useRouter } from 'vue-router';
import { onMounted, ref, computed, watch } from 'vue';

const budgetStore = useBudgetStore();
const router = useRouter();
const activeTab = ref('transactions');

// --- State for Forms ---
const newCategory = ref({ name: '', type: 'expense' as 'income' | 'expense' });
const newAccount = ref({ name: '', includeInAverage: true });

const dateInputToDate = (dateStr: string) => new Date(dateStr);
const dateToDateInput = (date: Date) => date.toISOString().split('T')[0];

const dateInput = ref(dateToDateInput(new Date()));

const getDefaultAccountId = () => budgetStore.accounts.length > 0 ? budgetStore.accounts[0].id : undefined;

const newTransactionData = ref({
    description: '',
    amount: 0,
    date: new Date(),
    type: 'expense' as 'income' | 'expense' | 'transfer',
    accountId: getDefaultAccountId(),
    toAccountId: undefined,
    categoryId: undefined,
});

// --- Computed Properties ---
const availableCategories = computed(() => {
    if (newTransactionData.value.type === 'transfer') return [];
    return budgetStore.categories.filter(c => c.type === newTransactionData.value.type);
});


// --- Watchers to keep state clean ---
watch(() => newTransactionData.value.type, (newType) => {
    newTransactionData.value.categoryId = undefined;
    newTransactionData.value.toAccountId = undefined;
});

watch(() => budgetStore.accounts, (newAccounts) => {
    if (newTransactionData.value.accountId === undefined && newAccounts.length > 0) {
        newTransactionData.value.accountId = newAccounts[0].id;
    }
}, { deep: true });

// --- Methods ---
onMounted(() => {
    budgetStore.fetchAll();
});

const handleAddNewTransaction = async () => {
    if (newTransactionData.value.type === 'transfer' && (!newTransactionData.value.toAccountId || newTransactionData.value.accountId === newTransactionData.value.toAccountId)) {
        alert("For transfers, 'From' and 'To' accounts must be selected and different.");
        return;
    }
    
    // Assign date from input
    newTransactionData.value.date = dateInputToDate(dateInput.value);

    await budgetStore.addTransaction(newTransactionData.value);

    if (!budgetStore.error) {
        // Reset form
        newTransactionData.value = {
            description: '',
            amount: 0,
            date: new Date(),
            type: 'expense',
            accountId: getDefaultAccountId(),
            toAccountId: undefined,
            categoryId: undefined,
        };
        dateInput.value = dateToDateInput(new Date());
    }
};

const handleAddNewCategory = async () => {
    if (!newCategory.value.name.trim()) return;
    await budgetStore.addCategory(newCategory.value);
    newCategory.value.name = '';
};

const handleAddNewAccount = async () => {
    if(!newAccount.value.name.trim()) return;
    await budgetStore.addAccount(newAccount.value);
    newAccount.value.name = '';
    newAccount.value.includeInAverage = true;
};

const getCategoryName = (id?: number) => {
    if (id === undefined) return 'N/A';
    return budgetStore.categories.find(c => c.id === id)?.name || 'Uncategorized';
};

const getAccountName = (id?: number) => {
    if (id === undefined) return 'N/A';
    return budgetStore.accounts.find(a => a.id === id)?.name || 'Unknown Account';
};

const formatDate = (date: Date) => {
    return new Date(date).toLocaleDateString('de-DE');
};

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
};

const editTransaction = (id: number) => {
    router.push({ name: 'TransactionEdit', params: { id: id.toString() } });
};

const confirmDelete = (id: number) => {
    if (window.confirm('Are you sure you want to delete this transaction? This action cannot be undone.')) {
        budgetStore.deleteTransaction(id);
    }
};
</script>

<style scoped>
.budget-view {
  width: 100%;
}
.balances-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}
.total-balance-card, .account-balances-card {
    background-color: var(--color-background-soft);
    border: 1px solid var(--color-border-soft);
    border-radius: 8px;
    padding: 1.5rem;
}
.total-balance-card h3, .account-balances-card h4 {
    margin-top: 0;
    margin-bottom: 1rem;
    color: var(--color-heading);
}
.balance-amount {
    font-size: 2.5rem;
    font-weight: bold;
    color: var(--color-primary);
    margin: 0;
}
.account-balances-list {
    list-style: none;
    padding: 0;
    margin: 0;
}
.account-balances-list li {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid var(--color-border-soft);
}
.account-balances-list li:last-child {
    border-bottom: none;
}
.account-balance-amount {
    font-weight: 500;
}
.tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 1px solid var(--color-border);
}
.tabs button {
  padding: 0.75rem 1.5rem;
  border: none;
  background-color: transparent;
  cursor: pointer;
  font-size: 1rem;
  border-bottom: 3px solid transparent;
  transition: all 0.2s;
}
.tabs button.active {
  border-bottom-color: var(--color-primary);
  color: var(--color-primary);
  font-weight: bold;
}
.tab-content {
  padding: 1rem 0;
}
.transaction-list table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.transaction-list th, .transaction-list td {
  border: 1px solid var(--color-border);
  padding: 0.75rem;
  text-align: left;
}
.transaction-list thead {
    background-color: var(--color-background-mute);
}
.expense { color: var(--color-danger); }
.income { color: var(--color-success); }
.action-btn {
  padding: 0.3em 0.6em;
  font-size: 0.9em;
  margin-right: 5px;
  border-radius: 4px;
  cursor: pointer;
}
.edit-btn { background-color: var(--color-warning-background); border: 1px solid var(--color-warning-border); color: var(--color-warning-text); }
.delete-btn { background-color: #f8d7da; border: 1px solid #f5c2c7; color: var(--color-danger); }
.error-message { color: var(--color-danger); background-color: #f8d7da; padding: 1rem; border-radius: 5px; margin-bottom: 1rem; }

.manage-form {
    display: flex;
    gap: 1rem;
    align-items: center;
    flex-wrap: wrap;
    background-color: var(--color-background-soft);
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px solid var(--color-border-soft);
}
.manage-form input[type="text"] {
    flex-grow: 1;
    padding: 0.75rem;
    border: 1px solid var(--color-border);
    border-radius: 4px;
}
.manage-form select, .manage-form input {
     padding: 0.75rem;
    border: 1px solid var(--color-border);
    border-radius: 4px;
}
.checkbox-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.item-list {
    list-style: none;
    padding: 0;
    margin-top: 1.5rem;
}
.item-list li {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem;
    border: 1px solid var(--color-border-soft);
    border-radius: 4px;
    margin-bottom: 0.5rem;
    background-color: var(--color-background);
}
.item-list .no-items {
    justify-content: center;
    color: var(--color-text-light);
}

.vertical-form {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1rem;
    max-width: 500px;
    align-items: start; /* Korrigiert die Ausrichtung */
}
.vertical-form .form-group {
    display: flex;
    flex-direction: column;
}
.vertical-form .form-group label {
    margin-bottom: 0.5rem;
    font-weight: 500;
}
.vertical-form .form-actions {
    justify-self: start;
}
.btn-primary {
    background-color: var(--color-primary);
    color: white;
    border: none;
    padding: 0.6em 1.2em;
    border-radius: 8px;
    font-size: 1em;
    cursor: pointer;
    font-weight: 500;
}
</style>