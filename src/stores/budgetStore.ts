// src/stores/budgetStore.ts
import { defineStore } from 'pinia';
import { liveQuery, type Subscription } from 'dexie';
import { db, type Account, type Category, type Transaction } from '@/services/db';
import { ref, onMounted, onUnmounted, computed } from 'vue';

export const useBudgetStore = defineStore('budget', () => {
  // State
  const accounts = ref<Account[]>([]);
  const categories = ref<Category[]>([]);
  const transactions = ref<Transaction[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  // Live Query Subscriptions
  let accSub: Subscription | null = null;
  let catSub: Subscription | null = null;
  let transSub: Subscription | null = null;

  const fetchAll = () => {
    isLoading.value = true;
    error.value = null;

    // Accounts
    accSub?.unsubscribe();
    const accObs = liveQuery(() => db.accounts.orderBy('name').toArray());
    accSub = accObs.subscribe({
      next: data => accounts.value = data,
      error: e => { error.value = "Failed to load accounts."; console.error(e); }
    });

    // Categories
    catSub?.unsubscribe();
    const catObs = liveQuery(() => db.categories.orderBy('name').toArray());
    catSub = catObs.subscribe({
      next: data => categories.value = data,
      error: e => { error.value = "Failed to load categories."; console.error(e); }
    });
    
    // Transactions
    transSub?.unsubscribe();
    const transObs = liveQuery(() => db.transactions.orderBy('date').reverse().toArray());
    transSub = transObs.subscribe({
      next: data => transactions.value = data,
      error: e => { error.value = "Failed to load transactions."; console.error(e); }
    });

    isLoading.value = false;
  };

  onMounted(fetchAll);
  onUnmounted(() => {
    accSub?.unsubscribe();
    catSub?.unsubscribe();
    transSub?.unsubscribe();
  });

  // --- Actions ---

  const addAccount = async (data: Omit<Account, 'id' | 'createdAt' | 'balance'>) => {
    try {
      await db.accounts.add({ ...data, balance: 0, createdAt: new Date() });
    } catch (e) {
      console.error(e);
      error.value = "Failed to add account.";
    }
  };
  
  const addCategory = async (data: Omit<Category, 'id' | 'createdAt'>) => {
    try {
      await db.categories.add({ ...data, createdAt: new Date() });
    } catch (e) {
      console.error(e);
      error.value = "Failed to add category.";
    }
  };

  const addTransaction = async (data: Omit<Transaction, 'id' | 'createdAt'>) => {
    error.value = null;
    return db.transaction('rw', db.transactions, db.accounts, async () => {
      const amount = data.type === 'expense' ? -Math.abs(data.amount) : Math.abs(data.amount);

      await db.transactions.add({
        ...data,
        amount,
        createdAt: new Date()
      });

      if (data.type === 'transfer') {
        if (!data.toAccountId) throw new Error("Zielkonto für die Umbuchung fehlt.");
        
        const fromAccount = await db.accounts.get(data.accountId);
        const toAccount = await db.accounts.get(data.toAccountId);
        if (!fromAccount || !toAccount) throw new Error("Eines der Konten für die Umbuchung wurde nicht gefunden.");

        const newFromBalance = fromAccount.balance - Math.abs(amount);
        const newToBalance = toAccount.balance + Math.abs(amount);

        await db.accounts.update(data.accountId, { balance: newFromBalance });
        await db.accounts.update(data.toAccountId, { balance: newToBalance });

      } else {
        const account = await db.accounts.get(data.accountId);
        if (!account) throw new Error("Konto wurde nicht gefunden.");

        const newBalance = account.balance + amount;
        await db.accounts.update(data.accountId, { balance: newBalance });
      }
    }).catch(e => {
       console.error("Fehler in der Datenbanktransaktion:", e);
       error.value = `Transaktion konnte nicht hinzugefügt werden: ${(e as Error).message}`;
       throw e;
    });
  };

  const updateTransaction = async (originalTxId: number, newData: Omit<Transaction, 'id' | 'createdAt'>) => {
    error.value = null;
    return db.transaction('rw', db.transactions, db.accounts, async () => {
        const originalTx = await db.transactions.get(originalTxId);
        if (!originalTx) throw new Error("Transaction to update not found.");

        if (originalTx.type === 'transfer') {
            if (!originalTx.toAccountId) throw new Error("Original transaction is a corrupt transfer.");
            const fromAccount = await db.accounts.get(originalTx.accountId);
            const toAccount = await db.accounts.get(originalTx.toAccountId);
            if (!fromAccount || !toAccount) throw new Error("An account for the original transaction was not found.");

            await db.accounts.update(fromAccount.id!, { balance: fromAccount.balance + Math.abs(originalTx.amount) });
            await db.accounts.update(toAccount.id!, { balance: toAccount.balance - Math.abs(originalTx.amount) });
        } else {
            const account = await db.accounts.get(originalTx.accountId);
            if (!account) throw new Error("Account for the original transaction not found.");
            await db.accounts.update(account.id!, { balance: account.balance - originalTx.amount });
        }

        const newAmount = newData.type === 'expense' ? -Math.abs(newData.amount) : Math.abs(newData.amount);

        if (newData.type === 'transfer') {
            if (!newData.toAccountId) throw new Error("Target account for the updated transfer is missing.");
            const fromAccount = await db.accounts.get(newData.accountId);
            const toAccount = await db.accounts.get(newData.toAccountId);
            if (!fromAccount || !toAccount) throw new Error("An account for the updated transaction was not found.");
            
            await db.accounts.update(fromAccount.id!, { balance: fromAccount.balance - Math.abs(newAmount) });
            await db.accounts.update(toAccount.id!, { balance: toAccount.balance + Math.abs(newAmount) });
        } else {
            const account = await db.accounts.get(newData.accountId);
            if (!account) throw new Error("Account for the updated transaction not found.");
            await db.accounts.update(account.id!, { balance: account.balance + newAmount });
        }

        await db.transactions.update(originalTxId, {
            description: newData.description,
            amount: newAmount,
            date: newData.date,
            type: newData.type,
            accountId: newData.accountId,
            toAccountId: newData.toAccountId,
            categoryId: newData.categoryId,
        });

    }).catch(e => {
        console.error("Error in updateTransaction DB transaction:", e);
        error.value = `Transaction could not be updated: ${(e as Error).message}`;
        throw e;
    });
  };
  
  const deleteTransaction = async (transactionId: number) => {
    error.value = null;
    return db.transaction('rw', db.transactions, db.accounts, async () => {
        const t = await db.transactions.get(transactionId);
        if (!t) throw new Error("Transaction not found");

        if (t.type === 'transfer') {
            if (!t.toAccountId) throw new Error("Corrupt transfer found");
            const fromAccount = await db.accounts.get(t.accountId);
            const toAccount = await db.accounts.get(t.toAccountId);
            if (!fromAccount || !toAccount) throw new Error("Account not found");
            
            const newFromBalance = fromAccount.balance + Math.abs(t.amount);
            const newToBalance = toAccount.balance - Math.abs(t.amount);
            await db.accounts.update(t.accountId, { balance: newFromBalance });
            await db.accounts.update(t.toAccountId, { balance: newToBalance });
        } else {
            const account = await db.accounts.get(t.accountId);
            if (!account) throw new Error("Account not found");
            const newBalance = account.balance - t.amount;
            await db.accounts.update(t.accountId, { balance: newBalance });
        }

        await db.transactions.delete(transactionId);

    }).catch(e => {
        console.error("Failed to delete transaction:", e);
        error.value = `Could not delete transaction: ${(e as Error).message}`;
        throw e;
    });
  };

  const totalBalance = computed(() => {
    return accounts.value.reduce((sum, account) => sum + account.balance, 0);
  });
  
  const expensePieChartData = computed(() => {
    const expenseByCategory = new Map<string, number>();

    transactions.value
      .filter(t => t.type === 'expense')
      .forEach(t => {
          const category = categories.value.find(c => c.id === t.categoryId);
          const categoryName = category ? category.name : 'Uncategorized';
          const currentTotal = expenseByCategory.get(categoryName) || 0;
          expenseByCategory.set(categoryName, currentTotal + Math.abs(t.amount));
      });

    const sortedData = Array.from(expenseByCategory.entries())
        .map(([name, total]) => ({ name, total }))
        .sort((a, b) => b.total - a.total);
    
    const chartColors = [
        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40',
        '#FFCD56', '#C9CBCF', '#F7464A', '#46BFBD', '#FDB45C'
    ];

    return {
      labels: sortedData.map(item => item.name),
      datasets: [
          { 
              label: 'Expenses by Category',
              data: sortedData.map(item => item.total),
              backgroundColor: sortedData.map((_, i) => chartColors[i % chartColors.length]),
          }
      ]
    };
  });
  
  const financialProjections = computed(() => {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
    const daysInMonth = endOfMonth.getDate();
    const dayOfMonth = now.getDate();

    const monthTransactions = transactions.value.filter(t => {
        const txDate = new Date(t.date);
        return txDate >= startOfMonth && txDate <= endOfMonth;
    });

    const incomeThisMonth = monthTransactions.filter(t => t.type === 'income').reduce((sum, t) => sum + t.amount, 0);
    const expensesThisMonth = monthTransactions.filter(t => t.type === 'expense').reduce((sum, t) => sum + Math.abs(t.amount), 0);

    const projectedIncome = (incomeThisMonth / dayOfMonth) * daysInMonth;
    const projectedExpenses = (expensesThisMonth / dayOfMonth) * daysInMonth;

    return {
        currentMonthIncome: incomeThisMonth,
        currentMonthExpenses: expensesThisMonth,
        projectedIncome: isNaN(projectedIncome) ? 0 : projectedIncome,
        projectedExpenses: isNaN(projectedExpenses) ? 0 : projectedExpenses,
    }
  });

  return {
    accounts,
    categories,
    transactions,
    isLoading,
    error,
    addAccount,
    addCategory,
    addTransaction,
    updateTransaction,
    deleteTransaction,
    fetchAll,
    totalBalance,
    expensePieChartData,
    projectedIncome: computed(() => financialProjections.value.projectedIncome),
    projectedExpenses: computed(() => financialProjections.value.projectedExpenses),
    currentMonthIncome: computed(() => financialProjections.value.currentMonthIncome),
    currentMonthExpenses: computed(() => financialProjections.value.currentMonthExpenses),
  };
});