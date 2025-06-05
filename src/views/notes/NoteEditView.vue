<template>
  <div class="note-edit-container">
    <div class="note-form-card">
      <div class="note-form-header">
        <h2>{{ isEditing ? 'Notiz bearbeiten' : 'Neue Notiz erstellen' }}</h2>
      </div>
      <div class="note-form-body">
        <form @submit.prevent="saveNoteHandler">
          <div class="form-group">
            <label for="note-title">Titel:</label>
            <input type="text" id="note-title" v-model.trim="formData.title" required />
          </div>

          <div class="form-group">
            <label for="note-content">Inhalt (Markdown):</label>
            <textarea id="note-content" v-model="formData.content" rows="12" required></textarea>
            <small class="markdown-help">
              Du kannst hier Markdown zur Formatierung verwenden.
              <a href="https://www.markdownguide.org/basic-syntax/" target="_blank" rel="noopener noreferrer">Markdown-Hilfe</a>
            </small>
          </div>

          <div class="form-group">
            <label for="note-tags-input">Tags hinzufügen (kommagetrennt):</label>
            <div class="tags-input-group">
              <input
                type="text"
                id="note-tags-input"
                v-model.trim="newTagInput"
                @keydown.enter.prevent="addTagsFromInputHandler"
                placeholder="z.B. arbeit, projekt, idee"
              />
              <button type="button" class="btn-add-tag" @click="addTagsFromInputHandler">
                Hinzufügen
              </button>
            </div>
            <small class="input-hint">Drücke Enter oder klicke auf "Hinzufügen", um die Tags zu übernehmen.</small>
          </div>

          <div class="form-group available-tags-section" v-if="availableTags.length > 0">
            <label>Verfügbare Tags (klicken zum Hinzufügen):</label>
            <div class="available-tags-container">
              <button
                type="button"
                v-for="tag in availableTags"
                :key="tag"
                class="tag-suggestion"
                @click="addSuggestedTag(tag)"
                :disabled="formData.tags.includes(tag.toLowerCase())"
              >
                {{ tag }}
              </button>
            </div>
          </div>

          <div class="form-group current-tags-section" v-if="formData.tags.length > 0">
            <label>Aktuelle Tags:</label>
            <div class="current-tags-container">
              <span v-for="tag in formData.tags" :key="tag" class="tag-item">
                {{ tag }}
                <button type="button" class="btn-remove-tag" @click="removeTagHandler(tag)" title="Tag entfernen">&times;</button>
              </span>
            </div>
          </div>
          <div v-else class="form-group">
            <p class="no-tags-text">Noch keine Tags hinzugefügt.</p>
          </div>

          <div v-if="noteStore.error" class="error-message">
            Fehler beim Speichern: {{ noteStore.error }}
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="cancelEditHandler">
              Abbrechen
            </button>
            <button type="submit" class="btn btn-primary" :disabled="noteStore.isLoading">
              <span v-if="noteStore.isLoading" class="spinner"></span>
              {{ isEditing ? 'Änderungen speichern' : 'Notiz erstellen' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useNoteStore } from '@/stores/noteStore';
import type { Note } from '@/services/db';

const route = useRoute();
const router = useRouter();
const noteStore = useNoteStore();

const isEditing = computed(() => route.params.id !== undefined);
const noteId = computed(() => isEditing.value ? Number(route.params.id) : null);

const formData = ref<{
  title: string;
  content: string;
  tags: string[];
}>({
  title: '',
  content: '',
  tags: [],
});

const newTagInput = ref(''); // Für das Eingabefeld der Tags

// Verfügbare Tags aus dem Store holen
const availableTags = computed(() => {
  // Filtert bereits zur Notiz hinzugefügte Tags (Groß-/Kleinschreibung ignorieren)
  // und sortiert sie für eine konsistente Anzeige.
  const currentNoteTagsLower = formData.value.tags.map(t => t.toLowerCase());
  return noteStore.allTags
    .filter(tag => !currentNoteTagsLower.includes(tag.toLowerCase()))
    .sort((a,b) => a.localeCompare(b));
});

const resetForm = () => {
  formData.value = { title: '', content: '', tags: [] };
  newTagInput.value = '';
  if (noteStore.error) { // Nur zurücksetzen, wenn ein Fehler da war, um Flackern zu vermeiden
    noteStore.error = null;
  }
};

const loadNoteForEditing = async () => {
  if (isEditing.value && noteId.value !== null && !isNaN(noteId.value)) {
    if (noteStore.error) noteStore.error = null;
    const existingNote = await noteStore.getNoteById(noteId.value);
    if (existingNote) {
      formData.value.title = existingNote.title;
      formData.value.content = existingNote.content;
      formData.value.tags = existingNote.tags ? [...existingNote.tags.map(t => t.toLowerCase())] : []; // Kopie, lowercase
    } else {
      console.error(`Notiz mit ID ${noteId.value} nicht gefunden.`);
      noteStore.error = `Notiz mit ID ${noteId.value} nicht gefunden.`;
      // router.push({ name: 'NoteList' }); // Optional
    }
  } else {
    resetForm();
  }
};

onMounted(async () => {
  // Sicherstellen, dass die Tags aus dem Store geladen sind, bevor die Notiz geladen wird
  // falls allTags auf notes.value basiert, die initial geladen werden müssen.
  if (noteStore.notes.length === 0 && !noteStore.isLoading) {
    await noteStore.fetchNotes(); // Wird implizit durch onMounted im Store schon gemacht, aber zur Sicherheit
  }
  loadNoteForEditing();
});

watch(() => route.params.id, () => {
  loadNoteForEditing();
});

const addTagsFromInputHandler = () => {
  if (newTagInput.value.trim() === '') return;

  const newTagsToAdd = newTagInput.value
    .split(',')
    .map(tag => tag.trim().toLowerCase())
    .filter(tag => tag !== '' && !formData.value.tags.includes(tag)); // Leere und Duplikate vermeiden

  if (newTagsToAdd.length > 0) {
    formData.value.tags.push(...newTagsToAdd);
    formData.value.tags.sort();
  }
  newTagInput.value = '';
};

const addSuggestedTag = (tag: string) => {
  const lowerTag = tag.toLowerCase();
  if (lowerTag.trim() !== '' && !formData.value.tags.includes(lowerTag)) {
    formData.value.tags.push(lowerTag);
    formData.value.tags.sort();
  }
};

const removeTagHandler = (tagToRemove: string) => {
  formData.value.tags = formData.value.tags.filter(tag => tag !== tagToRemove.toLowerCase());
};

const saveNoteHandler = async () => {
  if (!formData.value.title.trim()) {
    // Hier könntest du eine bessere Nutzerbenachrichtigung einbauen
    alert('Bitte gib einen Titel ein.');
    return;
  }
  // Verarbeite alle Tags, die noch im Input-Feld stehen
  addTagsFromInputHandler();

  console.log('NoteEditView: saveNoteHandler - formData.tags being prepared:', JSON.stringify(formData.value.tags));

  try {
    if (isEditing.value && noteId.value !== null) {
      const noteToUpdate: Note = {
        id: noteId.value, // id ist nötig für update
        title: formData.value.title,
        content: formData.value.content,
        tags: [...formData.value.tags], // explizite Kopie des Arrays
        // createdAt wird nicht geändert, updatedAt wird im Store gesetzt
        createdAt: (await noteStore.getNoteById(noteId.value))?.createdAt || new Date(), // Original-Datum beibehalten
        updatedAt: new Date() // Platzhalter, wird im Store überschrieben
      };
      await noteStore.updateNote(noteToUpdate);
      router.push({ name: 'NoteView', params: { id: noteId.value } });
    } else {
      const noteDataForStore: Omit<Note, 'id' | 'createdAt' | 'updatedAt'> = {
        title: formData.value.title,
        content: formData.value.content,
        tags: [...formData.value.tags], // explizite Kopie des Arrays
      };
      await noteStore.addNote(noteDataForStore);
      
      // Navigation zur neuen Notiz (verbesserte Logik)
      // Warte kurz, damit der Store sich aktualisieren kann durch liveQuery
      setTimeout(() => {
        const latestNote = [...noteStore.notes] // Kopie für Sortierung
            .sort((a,b) => (b.createdAt?.getTime() || 0) - (a.createdAt?.getTime() || 0))[0];
        
        if(latestNote && latestNote.id !== undefined){
            router.push({ name: 'NoteView', params: { id: latestNote.id } });
        } else {
            router.push({ name: 'NoteList' });
        }
      }, 200); // Kurze Verzögerung
    }
  } catch (error) {
    console.error("Fehler beim Speichern der Notiz in Komponente:", error);
    // Fehlerbehandlung erfolgt primär über den Store und wird oben im Template angezeigt
  }
};

const cancelEditHandler = () => {
  if (isEditing.value && noteId.value !== null) {
    router.push({ name: 'NoteView', params: { id: noteId.value } });
  } else {
    router.push({ name: 'NoteList' });
  }
};
</script>

<style scoped>
.note-edit-container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 1rem;
  background-color: var(--color-background-soft); /* Beispiel für Variable, falls du ein Theming hast */
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.note-form-card { /* Ersetzt .card */
  /* Keine spezifischen Styles hier, da .note-edit-container schon das Aussehen übernimmt */
}

.note-form-header { /* Ersetzt .card-header */
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--color-border, #e0e0e0);
  margin-bottom: 1.5rem;
}

.note-form-header h2 {
  margin: 0;
  font-size: 1.75rem;
  color: var(--color-heading, #333);
}

.note-form-body { /* Ersetzt .card-body */
  padding: 0 1.5rem 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--color-text-soft, #555);
}

.form-group input[type="text"],
.form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid var(--color-border, #ccc);
  border-radius: 4px;
  font-size: 1rem;
  box-sizing: border-box; /* Wichtig für korrekte Breite */
  transition: border-color 0.2s ease-in-out;
}
.form-group input[type="text"]:focus,
.form-group textarea:focus {
  border-color: var(--color-primary, #007bff);
  outline: none;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}


textarea#note-content {
  min-height: 250px;
  font-family: 'Courier New', Courier, monospace;
  font-size: 0.95em;
  line-height: 1.5;
}

.markdown-help {
  font-size: 0.85em;
  color: #6c757d;
}
.markdown-help a {
  color: var(--color-primary, #007bff);
  text-decoration: none;
}
.markdown-help a:hover {
  text-decoration: underline;
}

.tags-input-group {
  display: flex;
  gap: 0.5rem;
}
.tags-input-group input[type="text"] {
  flex-grow: 1;
}

.input-hint {
  font-size: 0.85em;
  color: #6c757d;
  display: block;
  margin-top: 0.25rem;
}

.btn-add-tag,
.btn-primary,
.btn-secondary {
  padding: 0.6em 1.2em;
  font-size: 0.9rem;
  border-radius: 4px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: background-color 0.2s ease, border-color 0.2s ease;
  text-align: center;
  font-weight: 500;
}

.btn-add-tag {
  background-color: #6c757d; /* Sekundärfarbe */
  color: white;
  border-color: #6c757d;
}
.btn-add-tag:hover {
  background-color: #5a6268;
  border-color: #545b62;
}


.available-tags-section,
.current-tags-section {
  margin-top: 1rem;
}
.available-tags-container,
.current-tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  padding: 0.75rem;
  background-color: var(--color-background, #f8f9fa);
  border-radius: 4px;
  border: 1px solid var(--color-border-hover, #dee2e6);
}

.tag-suggestion {
  background-color: var(--color-secondary, #6c757d);
  color: white;
  padding: 0.3em 0.6em;
  border-radius: 0.2rem;
  font-size: 0.85em;
  border: none;
  cursor: pointer;
}
.tag-suggestion:disabled {
  background-color: #aaa;
  cursor: not-allowed;
}
.tag-suggestion:hover:not(:disabled) {
  background-color: var(--color-secondary-dark, #5a6268);
}


.tag-item {
  display: inline-flex;
  align-items: center;
  background-color: var(--color-primary, #007bff);
  color: white;
  padding: 0.4em 0.8em;
  border-radius: 0.25rem;
  font-size: 0.9em;
}

.btn-remove-tag {
  background: none;
  border: none;
  color: white;
  margin-left: 0.6em;
  padding: 0 0.3em;
  line-height: 1;
  font-size: 1.3em;
  font-weight: bold;
  cursor: pointer;
  opacity: 0.7;
}
.btn-remove-tag:hover {
  opacity: 1;
}

.no-tags-text {
  color: #6c757d;
  font-style: italic;
  padding: 0.5rem 0;
}

.error-message {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
  padding: 0.75rem 1.25rem;
  border-radius: 0.25rem;
  margin-top: 1rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--color-border, #e0e0e0);
}


.btn-primary {
  background-color: var(--color-primary, #007bff);
  border-color: var(--color-primary, #007bff);
  color: white;
}
.btn-primary:hover {
  background-color: var(--color-primary-dark, #0056b3);
  border-color: var(--color-primary-darker, #004085);
}
.btn-primary:disabled {
  background-color: #a0c7e4;
  border-color: #a0c7e4;
  cursor: not-allowed;
}


.btn-secondary {
  background-color: #6c757d;
  border-color: #6c757d;
  color: white;
}
.btn-secondary:hover {
  background-color: #5a6268;
  border-color: #545b62;
}

/* Einfacher Spinner als Ersatz für Bootstrap Spinner */
.spinner {
  display: inline-block;
  width: 1em;
  height: 1em;
  vertical-align: text-bottom;
  border: 0.15em solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spinner-border 0.75s linear infinite;
  margin-right: 0.5em;
}

@keyframes spinner-border {
  to { transform: rotate(360deg); }
}

</style>