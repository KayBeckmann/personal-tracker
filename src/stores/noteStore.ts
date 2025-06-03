// src/stores/noteStore.ts
import { defineStore } from 'pinia';
import { db, type Note } from '@/services/db';
import { liveQuery } from 'dexie';
import { ref, onMounted, onUnmounted } from 'vue';

export const useNoteStore = defineStore('notes', () => {
  const notes = ref<Note[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveNotesQuerySubscription: ZenObservable.Subscription | null = null;

  const fetchNotes = () => {
    isLoading.value = true;
    error.value = null;
    if (liveNotesQuerySubscription) {
        liveNotesQuerySubscription.unsubscribe();
    }
    const observable = liveQuery(() => db.notes.orderBy('updatedAt').reverse().toArray());
    liveNotesQuerySubscription = observable.subscribe({
      next: (result) => {
        notes.value = result;
        isLoading.value = false;
      },
      error: (err) => {
        console.error('Dexie liveQuery error:', err);
        error.value = 'Failed to load notes from database.';
        isLoading.value = false;
      },
    });
  };

  const addNote = async (note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      const now = new Date();
      await db.notes.add({
        ...note,
        createdAt: now,
        updatedAt: now,
      });
    } catch (e) {
      console.error('Failed to add note:', e);
      error.value = 'Failed to add note.';
    }
  };

  const updateNote = async (note: Note) => {
    if (note.id === undefined) {
      error.value = 'Note ID is undefined, cannot update.';
      return;
    }
    try {
      await db.notes.update(note.id, { ...note, updatedAt: new Date() });
    } catch (e) {
      console.error('Failed to update note:', e);
      error.value = 'Failed to update note.';
    }
  };

  const deleteNote = async (id: number) => {
    try {
      await db.notes.delete(id);
    } catch (e) {
      console.error('Failed to delete note:', e);
      error.value = 'Failed to delete note.';
    }
  };

  const getNoteById = async (id: number): Promise<Note | undefined> => {
    try {
      return await db.notes.get(id);
    } catch (e) {
        console.error('Failed to get note by ID:', e);
        error.value = 'Failed to retrieve note.';
        return undefined;
    }
  }

  onMounted(() => {
    fetchNotes();
  });

  onUnmounted(() => {
    if (liveNotesQuerySubscription) {
        liveNotesQuerySubscription.unsubscribe();
    }
  });

  return {
    notes,
    isLoading,
    error,
    addNote,
    updateNote,
    deleteNote,
    getNoteById,
    fetchNotes
  };
});