# Datenbank (Dexie.js)

Das Herzstück der Datenpersistenz in Personal Tracker ist eine clientseitige IndexedDB-Datenbank, die über Dexie.js verwaltet wird. Dexie.js vereinfacht die Interaktion mit IndexedDB erheblich durch eine intuitive, Promise-basierte API.

**Datei:** `src/services/db.ts`
Diese Datei ist der zentrale Punkt für die gesamte Datenbankkonfiguration.

**Datenbankklasse** `PersonalTrackerDB`
Die Klasse PersonalTrackerDB erbt von Dexie und definiert das Datenbankschema.

```ts
export class PersonalTrackerDB
import Dexie, { type Table } from 'dexie';
import type { Task } from '@/types';
// ... import other types

export class PersonalTrackerDB extends Dexie {
    tasks!: Table<Task>;
    habits!: Table<Habit>;
    daily_events!: Table<DailyEvent>;
    notes!: Table<Note>;
    budget_items!: Table<BudgetItem>;

    constructor() {
        super('PersonalTrackerDB');
        this.version(1).stores({
            tasks: '++id, title, done, created_at',
            habits: '++id, title, created_at, last_completed_at',
            daily_events: '++id, title, date, created_at',
            notes: '++id, title, content, created_at',
            budget_items: '++id, title, amount, type, date, created_at'
        });
    }
}

export const db = new PersonalTrackerDB();
```

## Schema und Tabellen

Die Datenbank mit dem Namen PersonalTrackerDB wird in Version 1 initialisiert. Sie enthält die folgenden Tabellen (Object Stores):

1. **tasks**: Speichert die Aufgaben des Benutzers.

- **id**: Primärschlüssel (automatisch inkrementiert).
- **title**: Der Titel der Aufgabe.title: Der Titel der Aufgabe.
- **done**: Ein boolescher Wert, der angibt, ob die Aufgabe erledigt ist.
- **created_at**: Zeitstempel der Erstellung.

2. **habits**: Speichert die Gewohnheiten des Benutzers.

- **id**: Primärschlüssel (automatisch inkrementiert).
- **title**: Der Name der Gewohnheit.
- **created_at**: Zeitstempel der Erstellung.
- **last_completed_at**: Zeitstempel der letzten Ausführung.

3. **daily_events**: Speichert tägliche Ereignisse oder Journaleinträge.

- **id**: Primärschlüssel (automatisch inkrementiert).
- **title**: Der Titel des Ereignisses.
- **date**: Das Datum des Ereignisses.
- **created_at**: Zeitstempel der Erstellung.

4. **notes**: Zum Speichern von Notizen.

- **id**: Primärschlüssel (automatisch inkrementiert).
- **title**: Der Titel der Notiz.
- **content**: Der Inhalt der Notiz.
- **created_at**: Zeitstempel der Erstellung.

5. **budget_items**: Zur Verwaltung von Einnahmen und Ausgaben.

- **id**: Primärschlüssel.
- **title**: Beschreibung des Postens.
- **amount**: Der Betrag.
- **type**: Art des Postens ('income' oder 'expense').
- **date**: Datum des Postens.
- **created_at**: Zeitstempel der Erstellung.

## Verwendung

Die exportierte db-Instanz wird in den verschiedenen Pinia Stores verwendet, um CRUD-Operationen (Create, Read, Update, Delete) auf den Daten auszuführen. Alle Datenbankinteraktionen sind asynchron.
