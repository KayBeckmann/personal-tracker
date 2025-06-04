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

export class MySubClassedDexie extends Dexie {
  tasks!: Table<Task>;
  notes!: Table<Note>; // Verwendet das aktualisierte Note Interface
  habits!: Table<Habit>;
  habitEntries!: Table<HabitEntry>;
  dailyEvents!: Table<DailyEvent>;

  constructor() {
    super('myPwaAppDB');
    // WICHTIG: Datenbankversion erhöhen, z.B. von 1 auf 2
    // Wenn deine aktuelle Version höher ist, erhöhe sie entsprechend.
    // Beispiel: Wenn du bei version(2) warst, jetzt version(3)
    this.version(2).stores({ // Annahme: vorherige Version war 1
      tasks: '++id, title, priority, dueDate, completed, createdAt',
      // MODIFIZIERTES notes Schema: *tags für Multi-Entry Index hinzugefügt
      notes: '++id, title, *tags, createdAt, updatedAt',
      habits: '++id, name, frequency, createdAt',
      habitEntries: '++id, habitId, date, completed',
      dailyEvents: '++id, title, type, startTime, createdAt',
    });
    // Falls du schon höhere Versionen hattest, musst du die Änderungen
    // in einer neuen .version(X).upgrade(...) Migration machen oder
    // die bestehende höchste Version anpassen, wenn sie noch nicht "final" war.
    // Für Einfachheit hier direkt in version(2) geändert.
  }
}

export const db = new MySubClassedDexie();