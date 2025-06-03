// src/router/index.ts
import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';
import DashboardView from '@/views/DashboardView.vue'; // @-Alias verwenden

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Dashboard',
    component: DashboardView,
  },
  {
    path: '/tasks',
    name: 'Tasks',
    component: () => import('@/views/TasksView.vue'), // @-Alias verwenden
  },
  {
    path: '/notes',
    name: 'Notes',
    component: () => import('@/views/NotesView.vue'), // @-Alias verwenden
  },
  {
    path: '/habits',
    name: 'Habits',
    component: () => import('@/views/HabitsView.vue'), // @-Alias verwenden
  },
  {
    path: '/events',
    name: 'DailyEvents',
    component: () => import('@/views/DailyEventsView.vue'), // @-Alias verwenden
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;