// src/stores/dailyEventStore.ts
import { defineStore } from 'pinia';
import { db, type DailyEvent } from '@/services/db';
import { liveQuery, type Subscription } from 'dexie';
import { ref, onMounted, onUnmounted } from 'vue';

export const useDailyEventStore = defineStore('dailyEvents', () => {
  const events = ref<DailyEvent[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveEventsQuerySubscription: Subscription | null = null;

  const fetchEvents = () => {
    isLoading.value = true;
    error.value = null;
    if (liveEventsQuerySubscription) {
        liveEventsQuerySubscription.unsubscribe();
    }
    // Sortiere nach Startzeit, neueste zuerst
    const observable = liveQuery(() => db.dailyEvents.orderBy('startTime').reverse().toArray());
    liveEventsQuerySubscription = observable.subscribe({
      next: (result) => {
        events.value = result;
        isLoading.value = false;
      },
      error: (err) => {
        console.error('Dexie liveQuery error:', err);
        error.value = 'Failed to load daily events from database.';
        isLoading.value = false;
      },
    });
  };

  const addEvent = async (event: Omit<DailyEvent, 'id' | 'createdAt'>) => {
    try {
      await db.dailyEvents.add({
        ...event,
        createdAt: new Date(),
      });
      error.value = null;
    } catch (e) {
      console.error('Failed to add event:', e);
      error.value = 'Failed to add event.';
    }
  };

  const updateEvent = async (event: DailyEvent) => {
    if (event.id === undefined) {
      error.value = 'Event ID is undefined, cannot update.';
      return;
    }
    try {
      await db.dailyEvents.update(event.id, event);
      error.value = null;
    } catch (e) {
      console.error('Failed to update event:', e);
      error.value = 'Failed to update event.';
    }
  };

  const deleteEvent = async (id: number) => {
    try {
      await db.dailyEvents.delete(id);
      error.value = null;
    } catch (e) {
      console.error('Failed to delete event:', e);
      error.value = 'Failed to delete event.';
    }
  };

  const getEventsForDate = (date: string): DailyEvent[] => {
    return events.value.filter(event => {
      // Stellt sicher, dass event.startTime ein gültiges Date-Objekt ist.
      if (event.startTime instanceof Date && !isNaN(event.startTime.getTime())) {
        return event.startTime.toISOString().split('T')[0] === date;
      }
      // Fallback, da die DB inkonsistente Daten enthalten kann.
      if (typeof event.startTime === 'string') {
        return event.startTime.startsWith(date);
      }
      return false;
    }).sort((a, b) => new Date(a.startTime).getTime() - new Date(b.startTime).getTime());
  };

  onMounted(() => {
    fetchEvents();
  });

  onUnmounted(() => {
    if (liveEventsQuerySubscription) {
        liveEventsQuerySubscription.unsubscribe();
    }
  });

  return {
    events,
    isLoading,
    error,
    addEvent,
    updateEvent,
    deleteEvent,
    getEventsForDate,
    fetchEvents
  };
});