<template>
  <div class="chart-wrapper">
    <canvas ref="canvasEl"></canvas>
    <div v-if="isEmpty" class="chart-empty-state">
      <p>Keine Ausgaben vorhanden, um sie nach Kategorien aufzuteilen.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
import {
  Chart,
  Title,
  Tooltip,
  Legend,
  BarElement,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  BarController,
  LineController,
  type ChartOptions
} from 'chart.js';

// Alle notwendigen Controller und Elemente für ein gemischtes Diagramm registrieren
Chart.register(Title, Tooltip, Legend, BarElement, LineElement, CategoryScale, LinearScale, PointElement, BarController, LineController);

const props = defineProps<{
  chartData: {
    labels: string[];
    datasets: {
      label: string;
      data: number[];
    }[];
  }
}>();

const canvasEl = ref<HTMLCanvasElement | null>(null);
let chartInstance: Chart | null = null;

const isEmpty = computed(() => !props.chartData.datasets[0]?.data.length);

const chartOptions: ChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'top' },
    title: { display: false },
    tooltip: {
      callbacks: {
        label: (context: any) => {
          let label = context.dataset.label || '';
          if (label) label += ': ';
          if (context.parsed.y !== null) {
            label += (context.dataset.yAxisID === 'y1')
              ? `${context.parsed.y.toFixed(2)}%`
              : new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(context.parsed.y);
          }
          return label;
        }
      }
    }
  },
  scales: {
    y: {
      type: 'linear',
      display: true,
      position: 'left',
      title: { display: true, text: 'Betrag in €' },
      ticks: {
        callback: (value) => new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR', notation: 'compact' }).format(Number(value)),
      }
    },
    y1: {
      type: 'linear',
      display: true,
      position: 'right',
      min: 0,
      max: 100,
      title: { display: true, text: 'Kumulativer Anteil' },
      ticks: { callback: (value) => `${value}%` },
      grid: { drawOnChartArea: false },
    },
  },
};

// Diese Funktion aktualisiert die Daten des Diagramms, ohne es neu zu erstellen.
function updateChart() {
  if (chartInstance) {
    chartInstance.data.labels = props.chartData.labels;
    chartInstance.data.datasets = [
      {
        type: 'bar' as const,
        label: 'Ausgaben (€)',
        backgroundColor: 'rgba(0, 123, 255, 0.7)',
        data: props.chartData.datasets[0]?.data || [],
        yAxisID: 'y',
      },
      {
        type: 'line' as const,
        label: 'Kumulativ (%)',
        borderColor: '#dc3545',
        backgroundColor: 'transparent',
        data: props.chartData.datasets[1]?.data || [],
        yAxisID: 'y1',
        tension: 0,
      },
    ];
    chartInstance.update();
  }
}

// Beobachtet die Daten und ruft die Update-Funktion auf.
watch(() => props.chartData, () => {
  updateChart();
}, { deep: true });

// Erstellt das Diagramm, wenn die Komponente geladen wird.
onMounted(() => {
  if (canvasEl.value) {
    chartInstance = new Chart(canvasEl.value, {
      type: 'bar', // Der Basistyp ist 'bar', die Datensätze definieren die Details
      data: { labels: [], datasets: [] },
      options: chartOptions,
    });
    updateChart();
  }
});

// Zerstört das Diagramm, wenn die Komponente entfernt wird.
onUnmounted(() => {
  chartInstance?.destroy();
});
</script>

<style scoped>
.chart-wrapper {
  position: relative;
  height: 350px;
}
.chart-empty-state {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border: 2px dashed var(--color-border, #dee2e6);
  padding: 2rem;
  text-align: center;
  color: var(--color-text-light);
  border-radius: 8px;
  background-color: var(--color-background-soft);
}
</style>