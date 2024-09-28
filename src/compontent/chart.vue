<script setup lang="ts">
import { getAPIData } from '../results/results'
import VueApexCharts from "vue3-apexcharts";
import type { ApexOptions } from 'apexcharts';
import { onMounted, ref, toRaw } from "vue"
import "../assets/css/chart.css"

let props = defineProps({
    filename: {
        type: String,
        required: true
    }
})

let name = "";

let memorySeries = ref([] as ApexAxisChartSeries)
let cpuSeries = ref([] as ApexAxisChartSeries)

let showChart = ref(false)

let memoryMin = ref(0)
let memoryMax = ref(0)
let memoryAvg = ref(0)

let cpuMin = ref(0)
let cpuMax = ref(0)
let cpuAvg = ref(0)

onMounted(async () => {
    await go();
    showChart.value = true
})

setInterval(() => {
    //go()
}, 5000);

async function go() {

    let resultData = await getAPIData(props.filename)

    if (resultData != null && resultData.data != null) {

        let results = resultData.data
        if (results.length > 0) {
            name = results[0].name;
        }

        let memoryDates = new Array<[number, number | null]>()
        let cpuDates = new Array<[number, number | null]>()
        let rawMemoryData = new Array<number>();
        let rawCpuData = new Array<number>();

        results.forEach((result) => {
            memoryDates.push([result.time, result.memory])
            cpuDates.push([result.time, result.cpu])

            rawMemoryData.push(result.memory)
            rawCpuData.push(result.cpu)
        })

        memoryMin.value = Math.min(...rawMemoryData)
        memoryMax.value = Math.max(...rawMemoryData)

        let memorySum = 0
        rawMemoryData.forEach((value) => {
            memorySum += value
        })

        memoryAvg.value = memorySum / rawMemoryData.length;

        cpuMin.value = Math.min(...rawCpuData)
        cpuMax.value = Math.max(...rawCpuData)

        let cpuSum = 0
        rawCpuData.forEach((value) => {
            cpuSum += value
        })

        cpuAvg.value = cpuSum / rawCpuData.length;

        memorySeries.value = [{
            name: "memory (MiB)",
            data: memoryDates
        }]

        cpuSeries.value = [{
            name: "cpu (m)",
            data: cpuDates
        }]
    }
}

let memoryYAxis = {
    labels: {
        formatter: function (value) {
            return (value / 1049000).toFixed(0)
        }
    },
    title: "memory (MiB)"
} as ApexYAxis

let cpuYAxis = {
    labels: {
        formatter: function (value) {
            return (value).toFixed(0)
        }
    },
    title: "cpu (m)"
} as ApexYAxis

let xAxis = {
    type: "datetime",
    labels: {
        formatter(value, timestamp, opts) {
            if (timestamp != null) {
                let returnValue = new Date(timestamp)
                return returnValue.getHours() + ":" + returnValue.getMinutes() + ":" + returnValue.getSeconds() + "." + returnValue.getMilliseconds()
            }

            return ""
        },
    }
} as ApexXAxis


let chart = {
    zoom: {
        type: "x",
        enable: true,
        autoScaleYaxis: true
    }
} as ApexChart


let memoryOptions = {
    chart: chart,
    xaxis: xAxis,
    yaxis: memoryYAxis,
    title: { text: name } as ApexTitleSubtitle
} as ApexOptions

let cpuOptions = {
    chart: chart,
    xaxis: xAxis,
    yaxis: cpuYAxis,
    title: { text: name } as ApexTitleSubtitle
} as ApexOptions


</script>
<template>
    <el-card class="chart-container">
        <div class="chart-header">
            <h2>{{ props.filename.replace(".csv", "") }}</h2>
        </div>
        <div class="chart-usage">
            <h3>memory</h3>
            <div class="chart-stats">
                <table class="chart-stats-table">
                    <tbody>
                        <tr>
                            <th>Min (MiB)</th>
                            <th>Max (MiB)</th>
                            <th>Avg (MiB)</th>
                        </tr>
                        <tr>
                            <td>{{ (memoryMin / 1049000).toFixed(2) }}</td>
                            <td>{{ (memoryMax / 1049000).toFixed(2) }}</td>
                            <td>{{ (memoryAvg / 1049000).toFixed(2) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="chart-chart">
                <VueApexCharts height="100%" width="100%" type="line" :chart="chart" :options="memoryOptions"
                    :series="toRaw(memorySeries)">
                </VueApexCharts>
            </div>
        </div>
        <div class="chart-usage">
            <h3>CPU</h3>
            <div class="chart-stats">
                <table class="chart-stats-table">
                    <tbody>
                        <tr>
                            <th>Min (m)</th>
                            <th>Max (m)</th>
                            <th>Avg (m)</th>
                        </tr>
                        <tr>
                            <td>{{ cpuMin }}</td>
                            <td>{{ cpuMax }}</td>
                            <td>{{ cpuAvg.toFixed(0) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="chart-chart">
                <VueApexCharts height="100%" width="100%" type="line" :chart="chart" :options="cpuOptions"
                    :series="toRaw(cpuSeries)">
                </VueApexCharts>
            </div>
        </div>
    </el-card>
</template>