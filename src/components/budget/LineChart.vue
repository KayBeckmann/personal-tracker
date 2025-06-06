<template>
  <div class="chart-wrapper">
    <canvas ref="canvasEl"></canvas>
    <div v-if="isEmpty" class="chart-empty-state">
      <p>Nicht genügend Daten für die Verlaufansicht vorhanden.</p>
      <p>Bitte erfassen Sie einige Transaktionen.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
// KORREKTUR: LineController importiert
import { Chart, Title, Tooltip, Legend, LineElement, CategoryScale, LinearScale, PointElement, LineController, type ChartOptions } from 'chart.js';

// KORREKTUR: LineController registriert
Chart.register(Title, Tooltip, Legend, LineElement, CategoryScale, LinearScale, PointElement, LineController);

const props = defineProps<{
  chartData: {
    labels: string[];
    historyData: (number | null)[];
    forecastData: (number | null)[];
  }
}>();

const canvasEl = ref<HTMLCanvasElement | null>(null);
let chartInstance: Chart | null = null;

const isEmpty = computed(() => !props.chartData.historyData.some(d => d !== null));

const chartOptions: ChartOptions<'line'> = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'top' },
    title: { display: false },
  },
  scales: {
    y: {
      ticks: {
        callback: (value) => new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR', notation: 'compact' }).format(Number(value)),
      }
    }
  }
};

onMounted(() => {
  if (canvasEl.value) {
    chartInstance = new Chart(canvasEl.value, {
      type: 'line',
      data: {
        labels: [],
        datasets: [],
      },
      options: chartOptions,
    });
    updateChart();
  }
});

onUnmounted(() => {
  chartInstance?.destroy();
});

watch(() => props.chartData, () => {
  updateChart();
}, { deep: true });


function updateChart() {
  if (chartInstance) {
    chartInstance.data.labels = props.chartData.labels;
    chartInstance.data.datasets = [
      {
        label: 'Kontostand (Verlauf)',
        backgroundColor: 'rgba(0, 123, 255, 0.5)',
        borderColor: 'rgba(0, 123, 255, 1)',
        data: props.chartData.historyData,
        tension: 0.1,
        spanGaps: true,
      },
      {
        label: 'Kontostand (Prognose)',
        backgroundColor: 'rgba(25, 135, 84, 0.2)',
        borderColor: 'rgba(25, 135, 84, 1)',
        borderDash: [5, 5],
        data: props.chartData.forecastData,
        tension: 0.1,
      }
    ];
    chartInstance.update();
  }
}
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
  text-align: center;
  color: var(--color-text-light);
  border-radius: 8px;
  background-color: var(--color-background-soft);
}
</style>