// src/types/note.ts
export interface Note {
  id?: number; // Should be number to match Dexie
  title: string;
  content: string;
  tags: string[];
  createdAt: Date;
  updatedAt: Date;
}