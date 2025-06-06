import Dexie, { type Table } from 'dexie';

export interface Task {
  id?: number;
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  dueDate?: string; // ISO String z.B. '2024-12-31'
  completed: boolean;
  createdAt: Date;
}

// MODIFIZIERTES Note Interface: tags hinzugefügt
export interface Note {
  id?: number; // Auto-incrementing primary key, von Dexie verwaltet
  title: string;
  content: string; // Markdown Inhalt
  tags: string[];  // Array von Tags
  createdAt: Date;
  updatedAt: Date;
}

export interface Habit {
  id?: number;
  name: string;
  description?: string;
  frequency: 'daily' | 'weekly' | 'monthly'; // oder spezifische Tage
  streak: number;
  lastCompleted?: Date;
  createdAt: Date;
}

export interface HabitEntry {
  id?: number;
  habitId: number;
  date: string; // YYYY-MM-DD
  completed: boolean;
}


export interface DailyEvent {
  id?: number;
  title: string;
  description?: string;
  type: string; // z.B. 'Arbeit', 'Privat', 'Lernen'
  startTime: Date;
  endTime?: Date;
  createdAt: Date;
}

// NEU: Interfaces für das Haushaltsbuch
export interface Account {
  id?: number;
  name: string;
  balance: number;
  includeInAverage: boolean; // Soll dieses Konto für Durchschnittsberechnungen genutzt werden?
  createdAt: Date;
}

export interface Category {
  id?: number;
  name: string;
  type: 'income' | 'expense';
  createdAt: Date;
}

export interface Transaction {
  id?: number;
  description: string;
  amount: number; // > 0 für Einnahmen, < 0 für Ausgaben
  type: 'income' | 'expense' | 'transfer';
  accountId: number; // Quellkonto
  toAccountId?: number; // Zielkonto (nur für 'transfer')
  categoryId?: number;
  date: Date;
  createdAt: Date;
}


export class MySubClassedDexie extends Dexie {
  tasks!: Table<Task>;
  notes!: Table<Note>; // Verwendet das aktualisierte Note Interface
  habits!: Table<Habit>;
  habitEntries!: Table<HabitEntry>;
  dailyEvents!: Table<DailyEvent>;

  // NEU: Tabellen für das Haushaltsbuch
  accounts!: Table<Account>;
  categories!: Table<Category>;
  transactions!: Table<Transaction>;

  constructor() {
    super('myPwaAppDB');
    // Version 3: Fügt die Haushaltsbuch-Tabellen hinzu.
    // Diese Definition enthält alle bisherigen und neuen Tabellen,
    // um die Datenbankstruktur auf den neuesten Stand zu bringen.
    this.version(3).stores({
      // Bestehende Tabellen
      tasks: '++id, title, priority, dueDate, completed, createdAt',
      notes: '++id, title, *tags, createdAt, updatedAt',
      habits: '++id, name, frequency, createdAt',
      habitEntries: '++id, habitId, date, completed',
      dailyEvents: '++id, title, type, startTime, createdAt',
      
      // Neue Tabellen für das Haushaltsbuch
      accounts: '++id, name, includeInAverage',
      categories: '++id, name, type',
      // Indizes für Transaktionen zur Beschleunigung von Abfragen
      transactions: '++id, accountId, categoryId, date, type, toAccountId',
    });
  }
}

export const db = new MySubClassedDexie();