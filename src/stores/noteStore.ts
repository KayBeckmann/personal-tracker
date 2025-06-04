// src/stores/noteStore.ts
import { defineStore } from 'pinia';
import { db, type Note } from '@/services/db'; // Note Interface kommt von db.ts
import { liveQuery, type Observable as DxObservable } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

export const useNoteStore = defineStore('notes', () => {
  const notes = ref<Note[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  // NEU: Zustände für Filterung
  const searchTerm = ref('');
  const selectedTags = ref<string[]>([]);

  let liveNotesQuerySubscription: DxObservable.Subscription | null = null;

  const fetchNotes = () => {
    isLoading.value = true;
    error.value = null;
    if (liveNotesQuerySubscription) {
        liveNotesQuerySubscription.unsubscribe();
    }
    // Notizen werden standardmäßig nach dem letzten Update-Datum absteigend sortiert
    const observable = liveQuery(() => db.notes.orderBy('updatedAt').reverse().toArray()); //
    liveNotesQuerySubscription = observable.subscribe({
      next: (result) => {
        notes.value = result; //
        isLoading.value = false;
      },
      error: (err) => {
        console.error('Dexie liveQuery error:', err);
        error.value = 'Failed to load notes from database.'; //
        isLoading.value = false;
      },
    });
  };

  // addNote: Das `note` Argument sollte nun auch `tags` enthalten können.
  // Da `Omit<Note, ...>` verwendet wird und Note in db.ts `tags` enthält, ist das implizit korrekt.
  const addNote = async (noteData: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      const now = new Date();
      await db.notes.add({ //
        ...noteData, // Enthält title, content, und jetzt auch tags
        createdAt: now, //
        updatedAt: now, //
      });
    } catch (e) {
      console.error('Failed to add note:', e);
      error.value = 'Failed to add note.'; //
    }
  };

  // updateNote: Das `note` Argument vom Typ `Note` wird `tags` bereits enthalten.
  const updateNote = async (note: Note) => {
    if (note.id === undefined) {
      error.value = 'Note ID is undefined, cannot update.'; //
      return;
    }
    try {
      // Stelle sicher, dass tags ein Array ist, falls es von irgendwo als undefined kommt
      const tagsToUpdate = Array.isArray(note.tags) ? note.tags : [];
      await db.notes.update(note.id, { ...note, tags: tagsToUpdate, updatedAt: new Date() }); //
    } catch (e) {
      console.error('Failed to update note:', e);
      error.value = 'Failed to update note.'; //
    }
  };

  const deleteNote = async (id: number) => {
    try {
      await db.notes.delete(id); //
    } catch (e) {
      console.error('Failed to delete note:', e);
      error.value = 'Failed to delete note.'; //
    }
  };

  // getNoteById bleibt asynchron, was in Ordnung ist.
  const getNoteById = async (id: number): Promise<Note | undefined> => {
    try {
      return await db.notes.get(id); //
    } catch (e) {
        console.error('Failed to get note by ID:', e);
        error.value = 'Failed to retrieve note.'; //
        return undefined;
    }
  }

  onMounted(() => {
    fetchNotes(); //
  });

  onUnmounted(() => {
    if (liveNotesQuerySubscription) {
        liveNotesQuerySubscription.unsubscribe(); //
    }
  });

  // NEU: Getters (Computed Properties)
  const allTags = computed<string[]>(() => {
    const tagsSet = new Set<string>();
    notes.value.forEach(note => {
      if (Array.isArray(note.tags)) {
        note.tags.forEach(tag => tagsSet.add(tag.trim()));
      }
    });
    return Array.from(tagsSet).sort((a, b) => a.localeCompare(b));
  });

  const filteredNotes = computed<Note[]>(() => {
    return notes.value.filter(note => {
      const searchLower = searchTerm.value.toLowerCase().trim();
      const titleMatch = searchLower ? note.title.toLowerCase().includes(searchLower) : true;
      const contentMatch = searchLower ? note.content.toLowerCase().includes(searchLower) : true;
      const searchMatch = titleMatch || contentMatch;

      const tagsMatch = selectedTags.value.length > 0
        ? selectedTags.value.every(st => note.tags && note.tags.map(t => t.toLowerCase()).includes(st.toLowerCase()))
        : true;
      
      return searchMatch && tagsMatch;
    });
    // Die Sortierung erfolgt bereits in der liveQuery (`orderBy('updatedAt').reverse()`)
  });

  // NEU: Actions (Funktionen) zum Setzen der Filter
  const setSearchTerm = (term: string) => {
    searchTerm.value = term;
  };

  const setSelectedTags = (tags: string[]) => {
    selectedTags.value = tags;
  };

  return {
    notes, // Der rohe, nach updatedAt sortierte Array von Notizen
    isLoading,
    error,
    addNote,
    updateNote,
    deleteNote,
    getNoteById,
    fetchNotes,
    // Neue Elemente:
    searchTerm,
    selectedTags,
    allTags,
    filteredNotes,
    setSearchTerm,
    setSelectedTags,
  };
});