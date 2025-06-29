// src/router/index.ts
import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';
import DashboardView from '@/views/DashboardView.vue';

// Importiere die neuen Notiz-Komponenten
// Stelle sicher, dass die Pfade zu deinen .vue Dateien korrekt sind.
// Ich gehe davon aus, dass sie in einem Unterordner 'notes' innerhalb von 'views' liegen.
import NoteListView from '@/views/notes/NoteListView.vue';
import NoteView from '@/views/notes/NoteView.vue';
import NoteEditView from '@/views/notes/NoteEditView.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Dashboard',
    component: DashboardView,
  },
  {
    path: '/tasks',
    name: 'Tasks',
    component: () => import('@/views/TasksView.vue'),
  },
  // ANPASSUNG UND ERWEITERUNG DER NOTIZ-ROUTEN
  {
    path: '/notes/new',
    name: 'NoteCreate', // Zum Erstellen einer neuen Notiz
    component: NoteEditView, // Verwendet die Editieransicht
  },
  {
    path: '/notes', // Hauptpfad für Notizen
    name: 'NoteList', // Zeigt die Liste aller Notizen
    component: NoteListView, // Unsere neue Listenansicht
  },
  {
    path: '/notes/:id', // ':id' ist ein dynamischer Parameter für die Notiz-ID
    name: 'NoteView',   // Zeigt eine einzelne Notiz an
    component: NoteView,
    props: true, // Übergibt Routenparameter (z.B. :id) als Props an die Komponente
  },
  {
    path: '/notes/:id/edit',
    name: 'NoteEdit',   // Zum Bearbeiten einer bestehenden Notiz
    component: NoteEditView,
    props: true, // Übergibt Routenparameter (z.B. :id) als Props
  },
  // ENDE DER NOTIZ-ROUTEN ANPASSUNG
  {
    path: '/habits',
    name: 'Habits',
    component: () => import('@/views/HabitsView.vue'),
  },
  {
    path: '/events',
    name: 'DailyEvents',
    component: () => import('@/views/DailyEventsView.vue'),
  },
  // NEU: Route für das Haushaltsbuch
  {
    path: '/budget',
    name: 'Budget',
    component: () => import('@/views/BudgetView.vue'), // Die neue Hauptansicht für das Haushaltsbuch
  },
  // NEU: Route zum Bearbeiten einer Transaktion
  {
    path: '/budget/transaction/:id/edit',
    name: 'TransactionEdit',
    component: () => import('@/views/TransactionEditView.vue'),
    props: true
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('@/views/SettingsView.vue'),
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;