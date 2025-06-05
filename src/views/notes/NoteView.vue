<template>
  <div class="note-view-container">
    <div v-if="isLoading" class="loading-indicator">
      <p>Notiz wird geladen...</p>
      <div class="spinner"></div>
    </div>
    <div v-else-if="note" class="note-card-detail">
      <div class="note-header">
        <h2>{{ note.title }}</h2>
        <router-link :to="{ name: 'NoteList' }" class="btn btn-secondary btn-back">
          Zurück zur Übersicht
        </router-link>
      </div>
      <div class="note-body">
        <div class="note-meta-info">
          <p class="meta-item">
            <small>Erstellt: {{ formatDate(note.createdAt) }}</small>
          </p>
          <p class="meta-item">
            <small>Zuletzt geändert: {{ formatDate(note.updatedAt) }}</small>
          </p>
          <div class="tags-display" v-if="note.tags && note.tags.length > 0">
            <strong>Tags:</strong>
            <span v-for="tag in note.tags" :key="tag" class="tag-item-detail">{{ tag }}</span>
          </div>
          <div v-else class="tags-display">
            <small>Keine Tags vorhanden.</small>
          </div>
        </div>

        <div class="note-content-rendered-area">
          <div v-html="renderedMarkdownContent"></div>
        </div>
      </div>
      <div class="note-footer-actions">
        <router-link :to="{ name: 'NoteEdit', params: { id: note.id } }" class="btn btn-primary btn-edit">
          Bearbeiten
        </router-link>
        <button @click="confirmDeleteNoteHandler" class="btn btn-danger btn-delete">
          Löschen
        </button>
      </div>
    </div>
    <div v-else class="info-message not-found-message">
      <p>Notiz nicht gefunden.</p>
      <router-link :to="{ name: 'NoteList' }" class="btn-link-styled">Zurück zur Notizübersicht</router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useNoteStore } from '@/stores/noteStore';
import { marked } from 'marked';
import type { Note } from '@/services/db';

const route = useRoute();
const router = useRouter();
const noteStore = useNoteStore();

const note = ref<Note | null>(null);
const isLoading = ref(true);

const noteId = computed(() => {
  const idParam = route.params.id;
  return typeof idParam === 'string' ? Number(idParam) : NaN;
});

const loadNoteData = async () => {
  isLoading.value = true;
  note.value = null; 
  const currentId = noteId.value;

  if (isNaN(currentId)) {
    console.error('NoteView: Invalid Note ID from route params:', route.params.id);
    isLoading.value = false;
    router.push({ name: 'NoteList' }); // oder Fehlerseite
    return;
  }

  console.log(`NoteView: loadNoteData für ID: ${currentId}`);
  try {
    // Optimierung: Versuche zuerst aus dem bereits geladenen Array im Store zu lesen
    const existingNoteFromStore = noteStore.notes.find(n => n.id === currentId);
    if (existingNoteFromStore) {
      note.value = { ...existingNoteFromStore }; // Kopie erstellen
      console.log(`NoteView: Notiz ID ${currentId} aus Store-Array geladen.`);
    } else {
      // Fallback: Notiz spezifisch laden, falls nicht im Store-Array (z.B. direkter Link)
      console.log(`NoteView: Notiz ID ${currentId} nicht im Store-Array gefunden, lade via getNoteById...`);
      const fetchedNote = await noteStore.getNoteById(currentId);
      note.value = fetchedNote || null;
      if(fetchedNote) {
        console.log(`NoteView: Notiz ID ${currentId} via getNoteById geladen.`);
      } else {
        console.warn(`NoteView: Keine Notiz mit ID ${currentId} via getNoteById gefunden.`);
      }
    }
  } catch (error) {
    console.error(`NoteView: Fehler beim Laden der Notiz ID ${currentId}:`, error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(loadNoteData);

// Beobachte Änderungen der Route-ID, um die Notiz neu zu laden
watch(noteId, (newId, oldId) => {
  if (newId !== oldId && !isNaN(newId)) {
    loadNoteData();
  }
});

// Beobachte Änderungen an der spezifischen Notiz im Store (falls sie extern aktualisiert wird)
watch(() => noteStore.notes.find(n => n.id === noteId.value), (updatedNote) => {
  if (updatedNote) {
    note.value = { ...updatedNote }; // Aktualisiere mit einer Kopie
     console.log(`NoteView: Notiz ID ${noteId.value} durch Store-Watch aktualisiert.`);
  } else if (!isLoading.value && note.value) {
    // Wenn die Notiz nicht mehr im Store ist und wir nicht laden, wurde sie evtl. gelöscht
    console.log(`NoteView: Notiz ID ${noteId.value} nicht mehr im Store gefunden (evtl. gelöscht).`);
    note.value = null; 
  }
}, { deep: true });


const renderedMarkdownContent = computed(() => {
  if (note.value && note.value.content) {
    // marked.setOptions({ breaks: true, gfm: true }); // Globale Optionen besser zentral setzen
    return marked(note.value.content);
  }
  return '';
});

const formatDate = (dateValue: Date | string | number | undefined) => {
  if (!dateValue) return 'N/A';
  const date = new Date(dateValue);
  return date.toLocaleDateString('de-DE', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
};

const confirmDeleteNoteHandler = async () => {
  if (note.value && note.value.id !== undefined) {
    console.log(`NoteView: confirmDeleteNoteHandler aufgerufen für ID: ${note.value.id}`);
    if (window.confirm('Bist du sicher, dass du diese Notiz löschen möchtest?')) {
      console.log(`NoteView: Löschbestätigung erhalten für ID: ${note.value.id}. Rufe Store auf...`);
      await noteStore.deleteNote(note.value.id);
      console.log(`NoteView: noteStore.deleteNote(${note.value.id}) ausgeführt. Navigiere zur Liste...`);
      router.push({ name: 'NoteList' });
    } else {
      console.log(`NoteView: Löschvorgang für ID: ${note.value.id} abgebrochen.`);
    }
  } else {
    console.warn('NoteView: confirmDeleteNoteHandler aufgerufen, aber note.value oder note.value.id ist undefined.', note.value);
  }
};
</script>

<style scoped>
.note-view-container {
  max-width: 900px;
  margin: 2rem auto;
  padding: 1rem;
}

.note-card-detail {
  background-color: var(--color-background, #fff);
  border: 1px solid var(--color-border, #e0e0e0);
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.note-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--color-border, #e0e0e0);
  background-color: var(--color-background-soft, #f8f9fa);
}
.note-header h2 {
  margin: 0;
  font-size: 1.75rem;
  color: var(--color-heading);
}

.note-body {
  padding: 1.5rem;
}

.note-meta-info {
  font-size: 0.9em;
  color: var(--color-text-soft, #555);
  border-bottom: 1px solid var(--color-border-soft, #eee);
  padding-bottom: 1rem;
  margin-bottom: 1.5rem;
}
.note-meta-info .meta-item {
  margin-bottom: 0.3rem;
}
.tags-display {
  margin-top: 0.75rem;
}
.tags-display strong {
  margin-right: 0.5em;
}
.tag-item-detail {
  display: inline-block;
  background-color: var(--color-primary-light, #e0e0e0);
  color: var(--color-primary-dark, #333);
  padding: 0.3em 0.75em;
  border-radius: 4px;
  margin-right: 0.5em;
  margin-bottom: 0.5em; /* Für Umbrüche */
  font-size: 0.9em;
}

.note-content-rendered-area {
  background-color: var(--color-background-soft, #f9f9f9);
  padding: 1rem;
  border-radius: 4px;
  border: 1px solid var(--color-border-soft, #eee);
  min-height: 150px;
  line-height: 1.6;
}

/* Markdown Styles (Basis, kann erweitert werden) */
.note-content-rendered-area :deep(h1),
.note-content-rendered-area :deep(h2),
.note-content-rendered-area :deep(h3) {
  margin-top: 1.2em;
  margin-bottom: 0.6em;
  font-weight: 600;
  color: var(--color-heading);
}
.note-content-rendered-area :deep(p) { margin-bottom: 1em; }
.note-content-rendered-area :deep(ul),
.note-content-rendered-area :deep(ol) { margin-bottom: 1em; padding-left: 2em; }
.note-content-rendered-area :deep(blockquote) {
  margin: 1em 0; padding: 0.5em 1em; border-left: 4px solid var(--color-border, #ccc);
  background-color: var(--color-background-mute, #f1f1f1); color: var(--color-text-soft); font-style: italic;
}
.note-content-rendered-area :deep(pre) {
  background-color: var(--color-code-background, #282c34); color: var(--color-code-text, #abb2bf);
  padding: 1em; overflow-x: auto; border-radius: 4px; font-family: 'Courier New', Courier, monospace;
}
.note-content-rendered-area :deep(code) {
  font-family: 'Courier New', Courier, monospace; background-color: var(--color-inline-code-background, #e9ecef);
  color: var(--color-inline-code-text, #c7254e); padding: 0.2em 0.4em; border-radius: 3px; font-size: 0.9em;
}
.note-content-rendered-area :deep(pre code) { background-color: transparent; color: inherit; padding: 0; }
.note-content-rendered-area :deep(table) { width: auto; margin-bottom: 1rem; border-collapse: collapse; border: 1px solid var(--color-border, #dee2e6); }
.note-content-rendered-area :deep(th),
.note-content-rendered-area :deep(td) { padding: 0.5rem; border: 1px solid var(--color-border, #dee2e6); }
.note-content-rendered-area :deep(thead th) { background-color: var(--color-background-soft, #f8f9fa); }


.note-footer-actions {
  padding: 1rem 1.5rem;
  background-color: var(--color-background-soft, #f8f9fa);
  border-top: 1px solid var(--color-border, #e0e0e0);
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
}

.btn {
  padding: 0.6em 1.2em;
  font-size: 0.9rem;
  border-radius: 4px;
  border: 1px solid transparent;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  text-align: center;
  font-weight: 500;
}
.btn-primary {
  background-color: var(--color-primary, #007bff); color: white;
  border-color: var(--color-primary, #007bff);
}
.btn-primary:hover { background-color: var(--color-primary-dark, #0056b3); }
.btn-secondary {
  background-color: var(--color-secondary, #6c757d); color: white;
  border-color: var(--color-secondary, #6c757d);
}
.btn-secondary:hover { background-color: var(--color-secondary-dark, #5a6268); }
.btn-danger {
  background-color: var(--color-danger, #dc3545); color: white;
  border-color: var(--color-danger, #dc3545);
}
.btn-danger:hover { background-color: var(--color-danger-dark, #c82333); }

.loading-indicator, .info-message.not-found-message {
  text-align: center;
  padding: 3rem 1rem;
  font-size: 1.1em;
}
.info-message.not-found-message {
  background-color: var(--color-warning-background, #fff3cd);
  color: var(--color-warning-text, #664d03);
  border: 1px solid var(--color-warning-border, #ffecb5);
}
.btn-link-styled {
  color: var(--color-primary, #007bff);
  text-decoration: underline;
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
}
.btn-link-styled:hover {
  color: var(--color-primary-dark, #0056b3);
}

.spinner { /* Wiederverwendet von NoteEditView */
  display: inline-block;
  width: 1.5em; /* Etwas größer für Ladeanzeige */
  height: 1.5em;
  vertical-align: text-bottom;
  border: 0.2em solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spinner-border 0.75s linear infinite;
}
@keyframes spinner-border {
  to { transform: rotate(360deg); }
}
</style>