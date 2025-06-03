// src/stores/dailyEventStore.ts
import { defineStore } from 'pinia';
import { db, type DailyEvent } from '@/services/db';
import { liveQuery } from 'dexie';
import { ref, onMounted, onUnmounted } from 'vue';

export const useDailyEventStore = defineStore('dailyEvents', () => {
  const events = ref<DailyEvent[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  let liveEventsQuerySubscription: ZenObservable.Subscription | null = null;

  const fetchEvents = () => {
    isLoading.value = true;
    error.value = null;
    if (liveEventsQuerySubscription) {
        liveEventsQuerySubscription.unsubscribe();
    }
    // Sortiere nach Startzeit, neueste zuerst oder älteste zuerst, je nach Bedarf
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
    } catch (e) {
      console.error('Failed to update event:', e);
      error.value = 'Failed to update event.';
    }
  };

  const deleteEvent = async (id: number) => {
    try {
      await db.dailyEvents.delete(id);
    } catch (e) {
      console.error('Failed to delete event:', e);
      error.value = 'Failed to delete event.';
    }
  };

  const getEventsForDate = (date: string): DailyEvent[] => { // date im Format YYYY-MM-DD
    return events.value.filter(event => event.startTime.startsWith(date));
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