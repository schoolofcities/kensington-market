<script>
import { onMount } from "svelte";

let businesses = [];
const years = Array.from({length: 2025-2007+1}, (_,i) => 2007+i);
const typeColors = {
    "Grocer": "#2ecc71",
    "Vacant": "#bdc3c7",
    "Jewelry store": "#e67e22",
    "Cannabis store": "black",
    "Cannabis Store": "black",
    "Electronics store": "#3498db",
    "Take-out restaurant": "#f1c40f",
    "Restaurant": "#e74c3c",
    "Ice cream": "#9b59b6",
    "Parking lot": "#34495e",
    // Add more types as needed
};

function getColor(type) {
    return typeColors[type] || "#888";
}

function buildSegments(history) {
    history = [...history].sort((a,b) => a.year-b.year);
    if (history.length && history[0].year < 2007) {
        history[0].year = 2007;
    }
    let segments = [];
    for (let i=0; i<history.length; i++) {
        let start = history[i].year;
        let end = (i < history.length-1) ? history[i+1].year-1 : 2025;
        segments.push({start, end, type: history[i].type, name: history[i].name});
    }
    segments = segments.filter(s => s.end >= 2007 && s.start <= 2025)
        .map(s => ({
            start: Math.max(s.start, 2007),
            end: Math.min(s.end, 2025),
            type: s.type,
            name: s.name
        }));
    return segments;
}

onMount(async () => {
    const response = await fetch("/kmclt/src/data/businesses.geo.json");
    const data = await response.json();
    businesses = data.features.map(f => ({
        address: f.properties.address,
        history: f.properties.history
    }));
});
</script>

<div class="timeline-circles-container">
    <div class="timeline-circles-list">
        {#each businesses as biz}
            <div class="timeline-circles-row">
                <div class="timeline-circles-address">{biz.address}</div>
                <div class="timeline-circles-bar">
                    <svg width="100%" height="32" style="overflow:visible;">
                        <line x1="0" y1="16" x2="100%" y2="16" stroke="#ccc" stroke-dasharray="4 4" stroke-width="2" />
                        {#each years as year, i}
                            {#if biz.history.find(h => h.year === year)}
                                <circle 
                                    cx={(i/(years.length-1))*100+"%"} 
                                    cy="16" 
                                    r="8" 
                                    fill={getColor(biz.history.find(h => h.year === year).type)}>
                                    <title>{biz.history.find(h => h.year === year).name} ({biz.history.find(h => h.year === year).type}) {year}</title>
                                </circle>
                            {:else}
                                <circle cx={(i/(years.length-1))*100+"%"} cy="16" r="6" fill="#eee">
                                    <title>{year}</title>
                                </circle>
                            {/if}
                        {/each}
                    </svg>
                </div>
            </div>
        {/each}
    </div>
</div>

<style>
.timeline-circles-container {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 30vh;
    z-index: 9999;
    overflow-x: auto;
    background: #fff;
    padding: 0px 0 0 0;
    display: flex;
    justify-content: center;
    align-items: flex-start;
}
.timeline-circles-list {
    margin: 0 auto;
    max-width: 600px;
    border: 1px solid #ccc;
    width: 100%;
    position: relative;
    height: calc(100% - 24px);
    overflow-y: auto;
}
.timeline-circles-row {
    display: flex;
    align-items: center;
    margin-bottom: 0px;
    height: 32px;
}
.timeline-circles-address {
    width: 140px;
    font-weight: regular;
    font-size: 12px;
    background: #f8f8f8;
    padding: 2px 8px;
    border-radius: 0px;
    margin-right: 0px;
    flex-shrink: 0;
}
.timeline-circles-bar {
    position: relative;
    height: 32px;
    width: calc(100% - 200px);
    background: #fff;
    border-radius: 0px;
    overflow: visible;
}
</style>
