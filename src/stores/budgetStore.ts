// src/stores/budgetStore.ts
import { defineStore } from 'pinia';
import { db, type Account, type Category, type Transaction } from '@/services/db';
import { liveQuery } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

export const useBudgetStore = defineStore('budget', () => {
  // State
  const accounts = ref<Account[]>([]);
  const categories = ref<Category[]>([]);
  const transactions = ref<Transaction[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  // Live Query Subscriptions
  let accSub: ZenObservable.Subscription | null = null;
  let catSub: ZenObservable.Subscription | null = null;
  let transSub: ZenObservable.Subscription | null = null;

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
    return db.transaction('rw', db.transactions, db.accounts, async () => {
      // 1. Betrag normalisieren (Ausgaben sind negativ)
      const amount = data.type === 'expense' ? -Math.abs(data.amount) : Math.abs(data.amount);

      // 2. Transaktion erstellen
      const transactionId = await db.transactions.add({
        ...data,
        amount,
        createdAt: new Date()
      });

      // 3. Kontostände aktualisieren
      if (data.type === 'transfer') {
        if (!data.toAccountId) throw new Error("Transfer requires a destination account.");
        // Geld vom Quellkonto abbuchen
        await db.accounts.update(data.accountId, { balance: db.dexie.cloned(prev => prev.balance - Math.abs(amount)) });
        // Geld auf Zielkonto gutschreiben
        await db.accounts.update(data.toAccountId, { balance: db.dexie.cloned(prev => prev.balance + Math.abs(amount)) });
      } else {
        // Bei Einnahme/Ausgabe Betrag auf Quellkonto anwenden
        await db.accounts.update(data.accountId, { balance: db.dexie.cloned(prev => prev.balance + amount) });
      }
      return transactionId;
    }).catch(e => {
       console.error(e);
       error.value = `Failed to add transaction: ${e}`;
    });
  };
  
  // --- Computed Properties (Getters) für Analysen & Diagramme ---

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
        t.date >= startOfPeriod && t.date <= endOfLastMonth &&
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
        avgExpensePerMonth: totalExpense / 3, // bleibt negativ
        periodStart: startOfPeriod,
        periodEnd: endOfLastMonth
    };
  });

  const endOfMonthForecast = computed(() => {
      const today = new Date();
      const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
      const remainingDays = lastDayOfMonth - today.getDate();
      
      if (remainingDays <= 0) return { income: 0, expense: 0 };

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

  const financialHistoryAndForecastData = computed(() => {
    const today = new Date();
    const labels: string[] = [];
    const historyData: (number|null)[] = [];
    
    const balancesByDate = new Map<string, number>();
    const totalCurrentBalance = accounts.value.reduce((sum, acc) => sum + acc.balance, 0);
    
    // Annahme: der aktuelle Saldo ist der Saldo am Ende von "heute"
    balancesByDate.set(today.toISOString().split('T')[0], totalCurrentBalance);

    let runningBalance = totalCurrentBalance;
    const sortedTransactions = [...transactions.value].sort((a, b) => b.date.getTime() - a.date.getTime());

    for (const t of sortedTransactions) {
      const dateStr = t.date.toISOString().split('T')[0];
      if (new Date(dateStr) < today) {
        if (!balancesByDate.has(dateStr)) {
           balancesByDate.set(dateStr, runningBalance);
        }
        runningBalance -= t.amount;
      }
    }
    
    // Verlauf der letzten 30 Tage
    for (let i = 29; i >= 0; i--) {
        const date = new Date();
        date.setDate(today.getDate() - i);
        const dateStr = date.toISOString().split('T')[0];
        labels.push(date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' }));
        historyData.push(balancesByDate.get(dateStr) || null);
    }

    // Fülle Lücken im Verlauf
    for (let i = 1; i < historyData.length; i++) {
        if (historyData[i] === null) {
            historyData[i] = historyData[i - 1];
        }
    }

    // Prognose bis Monatsende
    const forecastData = [...historyData]; // Kopiert die Verlaufsdaten
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
    fetchAll,
    // Getter
    last3FullMonthsAverage,
    endOfMonthForecast,
    paretoChartData,
    financialHistoryAndForecastData
  };
});