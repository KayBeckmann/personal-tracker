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

export interface Note {
  id?: number;
  title: string;
  content: string;
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

export class MySubClassedDexie extends Dexie {
  tasks!: Table<Task>;
  notes!: Table<Note>;
  habits!: Table<Habit>;
  habitEntries!: Table<HabitEntry>;
  dailyEvents!: Table<DailyEvent>;

  constructor() {
    super('myPwaAppDB');
    this.version(1).stores({
      tasks: '++id, title, priority, dueDate, completed, createdAt',
      notes: '++id, title, createdAt, updatedAt',
      habits: '++id, name, frequency, createdAt',
      habitEntries: '++id, habitId, date, completed', // Index für schnelle Abfragen nach Habit und Datum
      dailyEvents: '++id, title, type, startTime, createdAt',
    });
  }
}

export const db = new MySubClassedDexie();