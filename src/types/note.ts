// src/types/note.ts
export interface Note {
    id: string; // Eindeutige ID, z.B. UUID
    title: string; // Titel der Notiz
    content: string; // Markdown-Inhalt
    tags: string[]; // Array von Tags
    createdAt: number; // Timestamp (Millisekunden seit Epoche)
    updatedAt: number; // Timestamp (Millisekunden seit Epoche)
  }