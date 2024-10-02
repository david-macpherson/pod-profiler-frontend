<script setup lang="ts">
import chart from '@/compontent/chart.vue';
import { getData } from '@/results/results';
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
