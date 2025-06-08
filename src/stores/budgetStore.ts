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
       error.value = `Transaktion konnte nicht hinzugefügt werden: ${e.message}`;
       throw e;
    });
  };

  const updateTransaction = async (originalTxId: number, newData: Omit<Transaction, 'id' | 'createdAt'>) => {
    error.value = null;
    return db.transaction('rw', db.transactions, db.accounts, async () => {
        // 1. Get the original transaction
        const originalTx = await db.transactions.get(originalTxId);
        if (!originalTx) throw new Error("Transaction to update not found.");

        // 2. Revert the original transaction's effect on account balances
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

        // 3. Apply the new transaction's effect on account balances
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

        // 4. Finally, update the transaction record itself
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
        error.value = `Transaction could not be updated: ${e.message}`;
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
        error.value = `Could not delete transaction: ${e.message}`;
        throw e;
    });
  };

  // --- Computed Properties (Getters) ---

  const totalBalance = computed(() => {
    return accounts.value.reduce((sum: number, account: Account) => sum + account.balance, 0);
  });
  
  const last3FullMonthsAverage = computed(() => {
    const today = new Date();
    const endOfLastMonth = new Date(today.getFullYear(), today.getMonth(), 0);
    const startOfPeriod = new Date(endOfLastMonth);
    startOfPeriod.setMonth(startOfPeriod.getMonth() - 2, 1);
    startOfPeriod.setHours(0, 0, 0, 0);

    const accountIdsToInclude = accounts.value
        .filter(a => a.includeInAverage)
        .map(a => a.id!);
        
    const relevantTransactions = transactions.value.filter(t => 
        new Date(t.date) >= startOfPeriod && new Date(t.date) <= endOfLastMonth &&
        accountIdsToInclude.includes(t.accountId) &&
        t.type !== 'transfer'
    );

    const totalIncome = relevantTransactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);

    const totalExpense = relevantTransactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);
        
    return {
        avgIncomePerMonth: totalIncome / 3,
        avgExpensePerMonth: totalExpense / 3,
        periodStart: startOfPeriod,
        periodEnd: endOfLastMonth
    };
  });

  const endOfMonthForecast = computed(() => {
      const today = new Date();
      const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
      const remainingDays = lastDayOfMonth - today.getDate();
      
      if (remainingDays <= 0) return { estimatedIncome: 0, estimatedExpense: 0 };

      const dailyAvgIncome = last3FullMonthsAverage.value.avgIncomePerMonth / 30.44;
      const dailyAvgExpense = last3FullMonthsAverage.value.avgExpensePerMonth / 30.44;

      return {
          estimatedIncome: dailyAvgIncome * remainingDays,
          estimatedExpense: dailyAvgExpense * remainingDays,
      };
  });
  
  const paretoChartData = computed(() => {
      const expenseByCategory = new Map<string, number>();

      transactions.value
        .filter(t => t.type === 'expense')
        .forEach(t => {
            const categoryName = categories.value.find(c => c.id === t.categoryId)?.name || 'Uncategorized';
            const currentTotal = expenseByCategory.get(categoryName) || 0;
            expenseByCategory.set(categoryName, currentTotal + Math.abs(t.amount));
        });

      const sortedData = Array.from(expenseByCategory.entries())
        .map(([name, total]) => ({ name, total }))
        .sort((a, b) => b.total - a.total);
        
      const totalExpense = sortedData.reduce((sum, item) => sum + item.total, 0);
      
      if (totalExpense === 0) {
        return { labels: [], datasets: [{ label: 'Amount', data: [] }, { label: 'Cumulative %', data: [] }] };
      }

      let cumulativePercentage = 0;
      const paretoData = sortedData.map(item => {
        const percentage = (item.total / totalExpense) * 100;
        cumulativePercentage += percentage;
        return { ...item, percentage, cumulativePercentage };
      });

      return {
        labels: paretoData.map(item => item.name),
        datasets: [
            { label: 'Amount', data: paretoData.map(item => item.total) },
            { label: 'Cumulative %', data: paretoData.map(item => item.cumulativePercentage) }
        ]
      };
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

  const financialHistoryAndForecastData = computed(() => {
    const today = new Date();
    today.setHours(0,0,0,0);
    const labels: string[] = [];
    const historyData: (number|null)[] = [];
    
    const balancesByDate = new Map<string, number>();
    const totalCurrentBalance = accounts.value.reduce((sum, acc) => sum + acc.balance, 0);
    
    balancesByDate.set(today.toISOString().split('T')[0], totalCurrentBalance);

    let runningBalance = totalCurrentBalance;
    const sortedTransactions = [...transactions.value].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    for (const t of sortedTransactions) {
      const transactionDate = new Date(t.date);
      transactionDate.setHours(0,0,0,0);
      
      if (transactionDate.getTime() < today.getTime()) {
        const dateStr = transactionDate.toISOString().split('T')[0];
        if (!balancesByDate.has(dateStr)) {
           balancesByDate.set(dateStr, runningBalance);
        }
        runningBalance -= t.amount;
      }
    }
    
    for (let i = 29; i >= 0; i--) {
        const date = new Date();
        date.setDate(today.getDate() - i);
        date.setHours(0,0,0,0);
        const dateStr = date.toISOString().split('T')[0];
        labels.push(date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' }));
        historyData.push(balancesByDate.get(dateStr) || null);
    }

    for (let i = 1; i < historyData.length; i++) {
        if (historyData[i] === null) {
            historyData[i] = historyData[i - 1];
        }
    }

    const forecastData: (number | null)[] = new Array(historyData.length -1).fill(null);
    forecastData.push(historyData[historyData.length-1]);
    
    const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
    let lastBalance = forecastData[forecastData.length - 1] || totalCurrentBalance;
    const dailyChange = (last3FullMonthsAverage.value.avgIncomePerMonth + last3FullMonthsAverage.value.avgExpensePerMonth) / 30.44;

    for (let i = 1; i <= (lastDayOfMonth.getDate() - today.getDate()); i++) {
        const forecastDate = new Date();
        forecastDate.setDate(today.getDate() + i);
        labels.push(forecastDate.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' }));
        lastBalance += dailyChange;
        forecastData.push(lastBalance);
    }
    
    return { labels, historyData, forecastData };
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
    last3FullMonthsAverage,
    endOfMonthForecast,
    paretoChartData,
    expensePieChartData,
    financialHistoryAndForecastData
  };
});