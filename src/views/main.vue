<script setup lang="ts">
import chart from '@/compontent/chart.vue';
import { getData } from '@/results/results';
import { Result } from '@/results/types/result';
import { onMounted, ref } from 'vue';


let resultFiles = ref(new Array<string>())

onMounted(async () => {
    let responseData = await getData()
    resultFiles.value = responseData.data




})




</script>

<template>

    <div class="chart-stack ">
        <template v-for="file in resultFiles">
            <chart :filename="file"></chart>
        </template>
    </div>


</template>
<!-- <script setup lang="ts">
import { getAPIData } from '../results/results'
import VueApexCharts from "vue3-apexcharts";
import type { ApexOptions } from 'apexcharts';
import { ref, toRaw } from "vue"


// let props = defineProps({
//     filename: {
//         type: String,
//         required: true
//     }
// })

let series = ref([] as ApexAxisChartSeries)

setInterval(() => {
    //go()
}, 5000);


async function go() {

    let resultData = await getAPIData("sps-api-74b9584b75-rkt5z.csv")

    if (resultData != null && resultData.data != null) {

        let results = resultData.data

        let dates = new Array<[number, number | null]>()

        results.forEach((result) => {
            dates.push([result.time, result.memory])
        })

        series.value = [{
            name: "memory (MiB)",
            data: dates
        }]
    }
}

let yAxis = {
    labels: {
        formatter: function (value) {
            return (value / 1049000).toFixed(0)
        }
    },
    title: "memory (MiB)"
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


let options = {
    chart: chart,
    xaxis: xAxis,
    yaxis: yAxis,
    title: { text: "bob" } as ApexTitleSubtitle
} as ApexOptions


</script>
<template>

    <VueApexCharts type="line" :chart="chart" :options="options" :series="toRaw(series)" />


</template> -->


<!-- <script setup lang="ts">

import chart from '../compontent/chart.vue';
import { ref } from "vue"
// let series = ref([] as ApexAxisChartSeries)

// setInterval(() => {
//     go()
// }, 5000);




//     let response = await getData()

//     let resultData = await getAPIData(response.data[0])

//     if (resultData != null && resultData.data != null) {

//         let results = resultData.data

//         let dates = new Array<[number, number | null]>()

//         results.forEach((result) => {
//             dates.push([result.time, result.memory])
//         })

//         series.value = [{
//             name: "memory (MiB)",
//             data: dates
//         }]
//     }
// }

// let yAxis = {
//     labels: {
//         formatter: function (value) {
//             return (value / 1049000).toFixed(0)
//         }
//     },
//     title: "memory (MiB)"
// } as ApexYAxis

// let xAxis = {
//     type: "datetime",
//     labels: {
//         formatter(value, timestamp, opts) {
//             if (timestamp != null) {
//                 let returnValue = new Date(timestamp)
//                 return returnValue.getHours() + ":" + returnValue.getMinutes() + ":" + returnValue.getSeconds() + "." + returnValue.getMilliseconds()
//             }

//             return ""
//         },
//     }
// } as ApexXAxis


// let chart = {
//     type: "line",
//     zoom: {
//         type: "x",
//         enable: true,
//         autoScaleYaxis: true
//     }
// } as ApexChart


// let options = {
//     chart: chart,
//     xaxis: xAxis,
//     yaxis: yAxis
// } as ApexOptions


let show = ref(false)

function go() {
    show.value = true
}

</script>
<template>

    <button v-on:click="go">go</button>

    <chart v-if="show" filename="sps-api-74b9584b75-rkt5z.csv"></chart>



</template> -->


<!-- <script setup lang="ts">
import { Chart, Grid, Line } from 'vue3-charts'
import { getData, getAPIData } from '../results/results'
import { ref } from "vue"
import type { Ref } from "vue"
import type { Result } from '@/results/types/result';
import type { Data, Direction } from 'vue3-charts/dist/types';

import VueApexCharts from "vue3-apexcharts";



let chartData: Ref<Array<Data>> = ref(new Array<Data>());
let direction: Ref<Direction> = ref('horizontal')

async function getAllTheData() {
    let response = await getData()

    let csvfiles = response.data


    let data = await getAPIData(csvfiles[0])
    if (data != null && data.data != null) {

        let convertedData = new Array<Data>()

        data.data.forEach((result: Result) => {
            convertedData.push({
                "time": result.time,
                "memory": result.memory,
                "cpu": result.cpu,
                "name": result.name,
            } as Data)

            if (convertedData.length > 100) {
                return
            }
        })


        chartData.value = convertedData
    }

}
</script>

<template>
    <h2>Hello there</h2>
    <button @click="getAllTheData()">get The data</button>
    <Chart :size="{ width: 500, height: 500 }" :data="chartData" :direction="direction">
        <template #layers>
            <Grid strokeDasharray="2,2" />
            <Line :dataKeys="['time', 'memory']" />
        </template>
    </Chart>
</template> -->
