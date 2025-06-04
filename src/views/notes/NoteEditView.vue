<template>
    <div class="note-edit-view-container">
      <div class="card">
        <div class="card-header">
          <h1 class="h3 mb-0">{{ isEditing ? 'Notiz bearbeiten' : 'Neue Notiz erstellen' }}</h1>
        </div>
        <div class="card-body">
          <form @submit.prevent="saveNote">
            <div class="mb-3">
              <label for="note-title" class="form-label">Titel:</label>
              <input type="text" id="note-title" class="form-control" v-model.trim="formData.title" required />
            </div>
  
            <div class="mb-3">
              <label for="note-content" class="form-label">Inhalt (Markdown):</label>
              <textarea id="note-content" class="form-control" v-model="formData.content" rows="12" required></textarea>
              <small class="form-text text-muted">
                Du kannst hier Markdown zur Formatierung verwenden.
                <a href="https://www.markdownguide.org/basic-syntax/" target="_blank" rel="noopener noreferrer">Markdown-Hilfe</a>
              </small>
            </div>
  
            <div class="mb-3">
              <label for="note-tags-input" class="form-label">Tags hinzufügen (kommagetrennt):</label>
              <div class="input-group">
                <input
                  type="text"
                  id="note-tags-input"
                  class="form-control"
                  v-model.trim="tagsInput"
                  @keydown.enter.prevent="addTagsFromInput"
                  placeholder="z.B. arbeit, projekt, idee"
                />
                <button class="btn btn-outline-secondary" type="button" @click="addTagsFromInput">
                  <i class="fas fa-plus"></i> Hinzufügen
                </button>
              </div>
              <small class="form-text text-muted">Drücke Enter oder klicke auf "Hinzufügen", um die eingegebenen Tags zu übernehmen.</small>
            </div>
  
            <div class="mb-3" v-if="formData.tags.length > 0">
              <label class="form-label">Aktuelle Tags:</label>
              <div class="current-tags-display">
                <span v-for="tag in formData.tags" :key="tag" class="tag me-2 mb-2">
                  {{ tag }}
                  <button type="button" class="btn-remove-tag" @click="removeTag(tag)" title="Tag entfernen">&times;</button>
                </span>
              </div>
            </div>
             <div v-else class="mb-3">
               <p class="text-muted fst-italic">Noch keine Tags hinzugefügt.</p>
             </div>
  
  
            <div v-if="noteStore.error" class="alert alert-danger mt-3">
              Fehler beim Speichern: {{ noteStore.error }}
            </div>
  
            <div class="form-actions d-flex justify-content-end gap-2 mt-4">
              <button type="button" class="btn btn-secondary" @click="cancelEdit">
                <i class="fas fa-times"></i> Abbrechen
              </button>
              <button type="submit" class="btn btn-primary" :disabled="noteStore.isLoading">
                <span v-if="noteStore.isLoading" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
                <i v-else class="fas fa-save"></i>
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
  import type { Note } from '@/services/db'; //
  
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
  
  const tagsInput = ref(''); // Für das Eingabefeld der Tags
  
  const resetForm = () => {
    formData.value = { title: '', content: '', tags: [] };
    tagsInput.value = '';
    noteStore.error = null; // Fehler zurücksetzen
  };
  
  const loadNoteForEditing = async () => {
    if (isEditing.value && noteId.value !== null && !isNaN(noteId.value)) {
      noteStore.error = null; // Fehler zurücksetzen
      const existingNote = await noteStore.getNoteById(noteId.value);
      if (existingNote) {
        formData.value.title = existingNote.title;
        formData.value.content = existingNote.content;
        formData.value.tags = existingNote.tags ? [...existingNote.tags] : []; // Kopie erstellen
      } else {
        console.error(`Notiz mit ID ${noteId.value} nicht gefunden.`);
        noteStore.error = `Notiz mit ID ${noteId.value} nicht gefunden.`;
        // Optional: Zurück zur Liste oder Fehlerseite navigieren
        // router.push({ name: 'NoteList' });
      }
    } else {
      resetForm();
    }
  };
  
  // Initiales Laden oder Reset des Formulars
  onMounted(loadNoteForEditing);
  
  // Wenn sich die Route ändert (z.B. von Bearbeiten zu Neu), Formular neu laden/resetten
  watch(() => route.params.id, () => {
      loadNoteForEditing();
  });
  
  
  const addTagsFromInput = () => {
    if (tagsInput.value.trim() === '') return;
  
    const newTags = tagsInput.value
      .split(',')
      .map(tag => tag.trim().toLowerCase())
      .filter(tag => tag !== ''); // Leere Tags entfernen
  
    newTags.forEach(newTag => {
      if (!formData.value.tags.includes(newTag)) {
        formData.value.tags.push(newTag);
      }
    });
    formData.value.tags.sort(); // Tags alphabetisch sortieren
    tagsInput.value = ''; // Eingabefeld leeren
  };
  
  const removeTag = (tagToRemove: string) => {
    formData.value.tags = formData.value.tags.filter(tag => tag !== tagToRemove);
  };
  
  const saveNote = async () => {
    if (!formData.value.title) {
      alert('Bitte gib einen Titel ein.');
      return;
    }
    // Stelle sicher, dass alle Tags aus dem Input-Feld verarbeitet wurden
    addTagsFromInput();
  
    try {
      if (isEditing.value && noteId.value !== null) {
        // Bestehende Notiz aktualisieren
        const noteToUpdate: Note = {
          id: noteId.value,
          title: formData.value.title,
          content: formData.value.content,
          tags: formData.value.tags,
          createdAt: new Date(), // Wird im Store ggf. ignoriert oder durch das Original ersetzt
          updatedAt: new Date(), // Wird im Store auf den aktuellen Zeitpunkt gesetzt
        };
        await noteStore.updateNote(noteToUpdate);
        router.push({ name: 'NoteView', params: { id: noteId.value } });
      } else {
        // Neue Notiz erstellen
        // Das `id` wird von Dexie automatisch vergeben (auto-increment)
        // `createdAt` und `updatedAt` werden im Store gesetzt.
        const noteDataForStore: Omit<Note, 'id' | 'createdAt' | 'updatedAt'> = {
            title: formData.value.title,
            content: formData.value.content,
            tags: formData.value.tags,
        };
        await noteStore.addNote(noteDataForStore);
        // Finde die zuletzt hinzugefügte Notiz, um zur ihrer Ansicht zu navigieren.
        // Dies ist etwas umständlich, da addNote keine ID zurückgibt.
        // Wir verlassen uns darauf, dass der liveQuery den Store schnell aktualisiert.
        // Eine robustere Methode wäre, wenn addNote die neue ID zurückgeben würde.
        // Hier einfach zur Liste, da die neue Notiz dort erscheint.
        const latestNote = [...noteStore.notes].sort((a,b) => b.createdAt.getTime() - a.createdAt.getTime())[0];
        if(latestNote && latestNote.id !== undefined){
            router.push({ name: 'NoteView', params: { id: latestNote.id } });
        } else {
            router.push({ name: 'NoteList' }); // Fallback zur Liste
        }
      }
    } catch (error) {
      console.error("Fehler beim Speichern der Notiz:", error);
      // Der Fehler sollte bereits im Store gesetzt sein und oben angezeigt werden.
    }
  };
  
  const cancelEdit = () => {
    if (isEditing.value && noteId.value !== null) {
      router.push({ name: 'NoteView', params: { id: noteId.value } });
    } else {
      router.push({ name: 'NoteList' });
    }
  };
  </script>
  
  <style scoped>
  .note-edit-view-container {
    max-width: 800px;
    margin: 20px auto;
    padding: 15px;
  }
  
  .card {
    border-radius: 0.5rem;
  }
  
  .card-header {
    background-color: #f8f9fa;
  }
  
  textarea#note-content {
    min-height: 250px; /* Mehr Platz für Markdown */
    font-family: 'Courier New', Courier, monospace; /* Monospace für Markdown-Eingabe */
    font-size: 0.95em;
  }
  
  .current-tags-display {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem; /* Abstand zwischen den Tags */
    padding: 0.5rem;
    background-color: #f8f9fa; /* Leichter Hintergrund, um Tags hervorzuheben */
    border-radius: 0.25rem;
    border: 1px solid #dee2e6;
  }
  
  .tag {
    display: inline-flex; /* Für vertikale Zentrierung des Buttons */
    align-items: center;
    background-color: #007bff;
    color: white;
    padding: 0.35em 0.75em;
    border-radius: 0.25rem;
    font-size: 0.9em;
  }
  
  .btn-remove-tag {
    background: none;
    border: none;
    color: white;
    margin-left: 0.5em;
    padding: 0 0.3em;
    line-height: 1; /* Verhindert extra Höhe */
    font-size: 1.2em; /* Größeres Kreuz */
    font-weight: bold;
    cursor: pointer;
    opacity: 0.7;
  }
  .btn-remove-tag:hover {
    opacity: 1;
  }
  
  .form-actions {
    margin-top: 1.5rem;
  }
  
  .btn-primary {
      background-color: #0d6efd;
      border-color: #0d6efd;
  }
  .btn-secondary {
      background-color: #6c757d;
      border-color: #6c757d;
      color: white;
  }
  </style>