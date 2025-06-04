<template>
    <div class="note-view-container">
      <div v-if="isLoading" class="loading-indicator">
        <p>Notiz wird geladen...</p>
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>
      <div v-else-if="note" class="note-view card">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h1 class="card-title mb-0 h3">{{ note.title }}</h1>
          <router-link :to="{ name: 'NoteList' }" class="btn btn-sm btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Zurück zur Übersicht
          </router-link>
        </div>
        <div class="card-body">
          <div class="note-meta mb-3">
            <p class="meta-item">
              <small class="text-muted">Erstellt: {{ formatDate(note.createdAt) }}</small>
            </p>
            <p class="meta-item">
              <small class="text-muted">Zuletzt geändert: {{ formatDate(note.updatedAt) }}</small>
            </p>
            <div class="tags mt-2" v-if="note.tags && note.tags.length > 0">
              <strong>Tags:</strong>
              <span v-for="tag in note.tags" :key="tag" class="tag ms-1">{{ tag }}</span>
            </div>
            <div v-else class="tags mt-2">
               <small class="text-muted">Keine Tags vorhanden.</small>
            </div>
          </div>
  
          <div class="note-content-rendered border p-3 rounded bg-light">
            <div v-html="renderedMarkdown"></div>
          </div>
        </div>
        <div class="card-footer note-actions">
          <router-link :to="{ name: 'NoteEdit', params: { id: note.id } }" class="btn btn-primary me-2">
            <i class="fas fa-edit"></i> Bearbeiten
          </router-link>
          <button @click="confirmDeleteNote" class="btn btn-danger">
            <i class="fas fa-trash"></i> Löschen
          </button>
        </div>
      </div>
      <div v-else class="alert alert-warning not-found-container">
        <p>Notiz nicht gefunden.</p>
        <router-link :to="{ name: 'NoteList' }" class="btn btn-link">Zurück zur Notizübersicht</router-link>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, computed, onMounted, watch } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { useNoteStore } from '@/stores/noteStore';
  import { marked } from 'marked'; // Markdown-Renderer
  import type { Note } from '@/services/db'; // Typ-Import
  
  const route = useRoute();
  const router = useRouter();
  const noteStore = useNoteStore();
  
  const note = ref<Note | null>(null);
  const isLoading = ref(true);
  
  // Die ID der Notiz aus den Routenparametern
  const noteId = computed(() => Number(route.params.id));
  
  const loadNote = async () => {
    isLoading.value = true;
    note.value = null; // Reset note before loading
    if (isNaN(noteId.value)) {
      console.error('Invalid Note ID:', route.params.id);
      isLoading.value = false;
      // Optional: redirect to an error page or note list
      router.push({ name: 'NoteList' });
      return;
    }
    try {
      // Versuche, die Notiz direkt aus dem Store zu bekommen (falls sie schon geladen ist)
      const existingNote = noteStore.notes.find(n => n.id === noteId.value);
      if (existingNote) {
          note.value = existingNote;
      } else {
          // Falls nicht im Store (z.B. direkter Link-Aufruf), spezifisch laden
          const fetchedNote = await noteStore.getNoteById(noteId.value);
          note.value = fetchedNote || null;
      }
  
    } catch (error) {
      console.error("Fehler beim Laden der Notiz:", error);
    } finally {
      isLoading.value = false;
    }
  };
  
  // Lade die Notiz beim Mounten der Komponente und wenn sich die ID ändert
  onMounted(loadNote);
  watch(noteId, loadNote, { immediate: true }); // immediate: true, um auch initial zu laden, falls onMounted nicht reicht.
  
  // Beobachte Änderungen im Store, um die Ansicht zu aktualisieren, falls die Notiz extern geändert wird.
  watch(() => noteStore.notes, (newNotes) => {
      const updatedNote = newNotes.find(n => n.id === noteId.value);
      if (updatedNote) {
          note.value = updatedNote;
      } else if (!isLoading.value && note.value) {
          // Die Notiz wurde möglicherweise gelöscht
          note.value = null;
      }
  }, { deep: true });
  
  
  const renderedMarkdown = computed(() => {
    if (note.value && note.value.content) {
      // Konfiguration für marked, um z.B. line breaks zu erhalten
      // marked.setOptions({
      //   breaks: true, // Wandelt einfache Zeilenumbrüche in <br> um
      //   gfm: true,    // GitHub Flavored Markdown
      // });
      return marked(note.value.content);
    }
    return '';
  });
  
  const formatDate = (dateValue: Date | string | number) => {
    if (!dateValue) return 'N/A';
    const date = new Date(dateValue);
    return date.toLocaleDateString('de-DE', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };
  
  const confirmDeleteNote = async () => {
    if (note.value && note.value.id !== undefined && window.confirm('Bist du sicher, dass du diese Notiz löschen möchtest?')) {
      await noteStore.deleteNote(note.value.id);
      router.push({ name: 'NoteList' }); // Nach dem Löschen zurück zur Liste
    }
  };
  </script>
  
  <style scoped>
  .note-view-container {
    max-width: 900px;
    margin: 20px auto;
    padding: 15px;
  }
  
  .note-view.card {
    border-radius: 0.5rem;
    box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  }
  
  .card-header {
    background-color: #f8f9fa; /* Helles Grau für den Header */
  }
  
  .card-title {
    font-size: 1.75rem; /* Größerer Titel */
  }
  
  .note-meta {
    font-size: 0.9em;
    color: #555;
    border-bottom: 1px solid #eee;
    padding-bottom: 15px;
    margin-bottom: 20px;
  }
  .note-meta .meta-item {
    margin-bottom: 0.25rem;
  }
  
  .tags .tag {
    display: inline-block;
    background-color: #007bff; /* Blau für Tags */
    color: white;
    padding: 0.3em 0.75em;
    border-radius: 0.25rem;
    margin-right: 5px;
    font-size: 0.9em;
  }
  
  .note-content-rendered {
    background-color: #ffffff; /* Weißer Hintergrund für den Inhalt */
    min-height: 150px; /* Mindesthöhe für den Inhalt */
    line-height: 1.6;
  }
  
  /* Basis-Styling für gerenderte Markdown-Elemente (kann erweitert werden) */
  .note-content-rendered :deep(h1),
  .note-content-rendered :deep(h2),
  .note-content-rendered :deep(h3),
  .note-content-rendered :deep(h4),
  .note-content-rendered :deep(h5),
  .note-content-rendered :deep(h6) {
    margin-top: 1.2em;
    margin-bottom: 0.6em;
    font-weight: 600;
  }
  .note-content-rendered :deep(h1) { font-size: 1.8em; }
  .note-content-rendered :deep(h2) { font-size: 1.6em; }
  .note-content-rendered :deep(h3) { font-size: 1.4em; }
  
  
  .note-content-rendered :deep(p) {
    margin-bottom: 1em;
  }
  
  .note-content-rendered :deep(ul),
  .note-content-rendered :deep(ol) {
    margin-bottom: 1em;
    padding-left: 2em; /* Einrückung für Listen */
  }
  
  .note-content-rendered :deep(blockquote) {
    margin-left: 0;
    padding: 0.5em 1em;
    border-left: 4px solid #ccc;
    background-color: #f8f9fa;
    color: #555;
    font-style: italic;
  }
  
  .note-content-rendered :deep(pre) {
    background-color: #282c34; /* Dunkler Hintergrund für Code-Blöcke */
    color: #abb2bf; /* Heller Text für Code-Blöcke */
    padding: 1em;
    overflow-x: auto; /* Horizontales Scrollen für lange Zeilen */
    border-radius: 4px;
    font-family: 'Fira Code', 'Courier New', Courier, monospace; /* Code-freundliche Schriftart */
  }
  
  .note-content-rendered :deep(code) {
    font-family: 'Fira Code', 'Courier New', Courier, monospace;
    background-color: #e9ecef; /* Heller Hintergrund für Inline-Code */
    color: #c7254e; /* Rötliche Farbe für Inline-Code, ähnlich Bootstrap */
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
  }
  .note-content-rendered :deep(pre code) {
    background-color: transparent; /* Kein extra Hintergrund, wenn in <pre> */
    color: inherit; /* Farbe von <pre> erben */
    padding: 0;
    border-radius: 0;
    font-size: inherit; /* Größe von <pre> erben */
  }
  
  .note-content-rendered :deep(table) {
    width: 100%;
    margin-bottom: 1rem;
    border-collapse: collapse;
  }
  .note-content-rendered :deep(th),
  .note-content-rendered :deep(td) {
    padding: 0.75rem;
    vertical-align: top;
    border: 1px solid #dee2e6;
  }
  .note-content-rendered :deep(thead th) {
    vertical-align: bottom;
    border-bottom: 2px solid #dee2e6;
    background-color: #f8f9fa;
  }
  
  .note-actions {
    padding: 1rem;
    background-color: #f8f9fa; /* Passend zum Header */
    display: flex;
    justify-content: flex-end;
  }
  
  .btn-primary {
    background-color: #0d6efd;
    border-color: #0d6efd;
  }
  .btn-danger {
    background-color: #dc3545;
    border-color: #dc3545;
  }
  
  .loading-indicator, .not-found-container {
    text-align: center;
    padding: 40px 20px;
  }
  </style>