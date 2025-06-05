// src/stores/noteStore.ts
import { defineStore } from 'pinia';
import { db, type Note } from '@/services/db'; // Note Interface kommt von db.ts
import { liveQuery, type Observable as DxObservable } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

export const useNoteStore = defineStore('notes', () => {
  const notes = ref<Note[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  const searchTerm = ref('');
  const selectedTags = ref<string[]>([]);

  let liveNotesQuerySubscription: DxObservable.Subscription | null = null;

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
        if (result.length > 0) {
          console.log('Fetched notes sample, first note tags:', JSON.stringify(result[0].tags));
        }
        isLoading.value = false;
      },
      error: (err) => {
        console.error('Dexie liveQuery error:', err);
        error.value = 'Failed to load notes from database.';
        isLoading.value = false;
      },
    });
  };

  const addNote = async (noteData: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      const now = new Date();

      // Defensive Data Processing für Tags
      let processedTags: string[] = [];
      if (Array.isArray(noteData.tags)) {
        processedTags = noteData.tags.map(tag => (typeof tag === 'string' ? tag.trim() : String(tag || '').trim())).filter(tag => tag.length > 0);
      } else if (noteData.tags !== undefined && noteData.tags !== null) {
        console.warn(`addNote: noteData.tags was expected to be an array, but received type ${typeof noteData.tags}. Value:`, noteData.tags);
        const tagAsString = String(noteData.tags).trim();
        if (tagAsString.length > 0) {
          processedTags = [tagAsString];
        }
      }
      console.log('addNote: Incoming noteData.tags:', noteData.tags);
      console.log('addNote: Processed tags:', processedTags);

      const noteToAdd = {
        title: typeof noteData.title === 'string' ? noteData.title : String(noteData.title || ''),
        content: typeof noteData.content === 'string' ? noteData.content : String(noteData.content || ''),
        tags: [...processedTags], // Stelle sicher, dass es ein neues, sauberes Array ist
        createdAt: now,
        updatedAt: now,
      };

      console.log('addNote: Object being added to Dexie:', JSON.stringify(noteToAdd, null, 2));
      console.log('addNote: Inspecting noteToAdd just before add:');
      console.log(`  title: (${typeof noteToAdd.title}) "${noteToAdd.title}"`);
      console.log(`  content: (${typeof noteToAdd.content}) "${noteToAdd.content.substring(0, 50)}..."`);
      console.log(`  tags: (${typeof noteToAdd.tags})`, noteToAdd.tags, `Is Array: ${Array.isArray(noteToAdd.tags)}`);
      if (Array.isArray(noteToAdd.tags)) {
        noteToAdd.tags.forEach((tag, index) => {
          console.log(`    tags[${index}]: (${typeof tag}) "${tag}"`);
        });
      }

      await db.notes.add(noteToAdd);
      console.log('Note added successfully!');
      error.value = null; 
    } catch (e: any) {
      console.error('Failed to add note:', e);
      if (e.name === 'DataCloneError') {
        console.error('Original noteData that caused DataCloneError:', JSON.stringify(noteData, null, 2));
      }
      error.value = `Failed to add note: ${e.message || e.name}`;
    }
  };

  const updateNote = async (note: Note) => {
    if (note.id === undefined) {
      error.value = 'Note ID is undefined, cannot update.';
      return;
    }
    try {
      // Defensive Data Processing für Tags
      let processedTags: string[] = [];
      if (Array.isArray(note.tags)) {
        processedTags = note.tags.map(tag => (typeof tag === 'string' ? tag.trim() : String(tag || '').trim())).filter(tag => tag.length > 0);
      } else if (note.tags !== undefined && note.tags !== null) {
        // Dieser Fall sollte bei einem 'Note' Objekt seltener auftreten, aber zur Sicherheit
        console.warn(`updateNote: note.tags was expected to be an array, but received type ${typeof note.tags}. Value:`, note.tags);
        const tagAsString = String(note.tags).trim();
        if (tagAsString.length > 0) {
          processedTags = [tagAsString];
        }
      }
      console.log('updateNote: Incoming note.tags:', note.tags);
      console.log('updateNote: Processed tags for update:', processedTags);

      const noteToUpdate = {
        ...note, // Beinhaltet die original ID und createdAt
        title: typeof note.title === 'string' ? note.title : String(note.title || ''),
        content: typeof note.content === 'string' ? note.content : String(note.content || ''),
        tags: [...processedTags], // Stelle sicher, dass es ein neues, sauberes Array ist
        updatedAt: new Date()
      };

      console.log('updateNote: Object being updated in Dexie:', JSON.stringify(noteToUpdate, null, 2));
      console.log('updateNote: Inspecting noteToUpdate just before update:');
      console.log(`  id: ${noteToUpdate.id}`);
      console.log(`  title: (${typeof noteToUpdate.title}) "${noteToUpdate.title}"`);
      console.log(`  tags: (${typeof noteToUpdate.tags})`, noteToUpdate.tags, `Is Array: ${Array.isArray(noteToUpdate.tags)}`);
      if (Array.isArray(noteToUpdate.tags)) {
        noteToUpdate.tags.forEach((tag, index) => {
          console.log(`    tags[${index}]: (${typeof tag}) "${tag}"`);
        });
      }
      
      await db.notes.update(note.id, noteToUpdate);
      console.log('Note updated successfully!');
      error.value = null; 
    } catch (e: any) {
      console.error('Failed to update note:', e);
      error.value = `Failed to update note: ${e.message || e.name}`;
    }
  };

  const deleteNote = async (id: number) => {
    console.log(`NoteStore: deleteNote aufgerufen für ID: ${id}`); // NEUES LOG
    if (typeof id !== 'number' || isNaN(id)) {
      console.error('NoteStore: Ungültige ID für deleteNote empfangen:', id);
      error.value = 'Ungültige ID zum Löschen empfangen.';
      return;
    }
    try {
      await db.notes.delete(id);
      console.log(`NoteStore: Notiz mit ID: ${id} erfolgreich aus Dexie gelöscht.`); // NEUES LOG
      error.value = null; 
      // Die LiveQuery in fetchNotes sollte die notes.value automatisch aktualisieren.
      // Ein explizites fetchNotes() ist hier normalerweise nicht nötig, kann aber bei Problemen erwogen werden.
    } catch (e: any) {
      console.error(`NoteStore: Fehler beim Löschen der Notiz mit ID: ${id}`, e); // Angepasstes LOG
      error.value = `Fehler beim Löschen der Notiz: ${e.message || e.name}`;
    }
  };

  const getNoteById = async (id: number): Promise<Note | undefined> => {
    try {
      const note = await db.notes.get(id);
      if (note) {
        console.log(`getNoteById: Fetched note ID ${id}, tags:`, JSON.stringify(note.tags));
      }
      error.value = null; 
      return note;
    } catch (e: any) {
        console.error('Failed to get note by ID:', e);
        error.value = `Failed to retrieve note: ${e.message || e.name}`;
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

  const allTags = computed<string[]>(() => {
    const tagsSet = new Set<string>();
    notes.value.forEach(note => {
      if (Array.isArray(note.tags)) {
        note.tags.forEach(tag => {
          if (typeof tag === 'string') {
            tagsSet.add(tag.trim());
          }
        });
      }
    });
    return Array.from(tagsSet).sort((a, b) => a.localeCompare(b));
  });

  const filteredNotes = computed<Note[]>(() => {
    return notes.value.filter(note => {
      const searchLower = searchTerm.value.toLowerCase().trim();
      const titleMatch = searchLower && typeof note.title === 'string' ? note.title.toLowerCase().includes(searchLower) : true;
      const contentMatch = searchLower && typeof note.content === 'string' ? note.content.toLowerCase().includes(searchLower) : true;
      const searchMatch = titleMatch || contentMatch;

      const tagsMatch = selectedTags.value.length > 0
        ? selectedTags.value.every(st => 
            Array.isArray(note.tags) && note.tags.map(t => String(t).toLowerCase()).includes(st.toLowerCase())
          )
        : true;
      
      return searchMatch && tagsMatch;
    });
  });

  const setSearchTerm = (term: string) => {
    searchTerm.value = term;
  };

  const setSelectedTags = (tags: string[]) => {
    selectedTags.value = tags.map(tag => String(tag)); 
  };

  return {
    notes,
    isLoading,
    error,
    addNote,
    updateNote,
    deleteNote,
    getNoteById,
    fetchNotes,
    searchTerm,
    selectedTags,
    allTags,
    filteredNotes,
    setSearchTerm,
    setSelectedTags,
  };
});