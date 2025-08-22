<script>
import Papa from "papaparse";
import { onMount } from "svelte";

let data = [];
let categoryCounts = {};
let categories = [];
let counts = [];
let loading = true;

onMount(async () => {
    const response = await fetch("/2025_complete.csv");
    const csvText = await response.text();
    const parsed = Papa.parse(csvText, { header: true });
    data = parsed.data;
    // Count categories
    categoryCounts = {};
    data.forEach(row => {
        const cat = row.category_original;
        if (cat) {
            categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
        }
    });
    categories = Object.keys(categoryCounts);
    counts = Object.values(categoryCounts);
    loading = false;
});
</script>

{#if loading}
    <div>Loading...</div>
{:else}
    <svg width="600" height="400">
        {#each categories as cat, i}
            <rect
                x={i * (600 / categories.length) + 20}
                y={400 - (counts[i] / Math.max(...counts)) * 350}
                width={(600 / categories.length) - 30}
                height={(counts[i] / Math.max(...counts)) * 350}
                fill="#3498db"
            />
            <text
                x={i * (600 / categories.length) + 20 + ((600 / categories.length) - 30) / 2}
                y={400 - (counts[i] / Math.max(...counts)) * 350 - 5}
                text-anchor="middle"
                font-size="12"
                fill="#333"
            >{counts[i]}</text>
            <text
                x={i * (600 / categories.length) + 20 + ((600 / categories.length) - 30) / 2}
                y={395}
                text-anchor="middle"
                font-size="10"
                fill="#333"
                transform={`rotate(-45,${i * (600 / categories.length) + 20 + ((600 / categories.length) - 30) / 2},395)`}
            >{cat}</text>
        {/each}
    </svg>
{/if}

<style>
svg {
    background: #f9f9f9;
    border: 1px solid #eee;
    margin: 2rem 0;
}
</style>
