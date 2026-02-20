<script>
    import MapTimeline from "./MapTimeline.svelte";
    import Timeline from "./Timeline.svelte";
    import TimelineLegend from "./TimelineLegend.svelte";

    export let sliderYear = 2025.5;
    export let hoveredAddress = null;
    export let yearlyTypeCounts = {};
    export let enabledTypes = {};
</script>

<div class="timeline-visualization">
    <div class="timeline-map-container">
        <div class="timeline-column">
            <div class="timeline-block">
                <TimelineLegend
                    {sliderYear}
                    {yearlyTypeCounts}
                    bind:enabledTypes
                />
                <div class="timeline-content">
                    <Timeline
                        bind:sliderYear
                        bind:hoveredAddress
                        bind:yearlyTypeCounts
                    />
                </div>
            </div>
        </div>
        <div class="map-column">
            <MapTimeline
                bind:sliderYear
                bind:hoveredAddress
                {enabledTypes}
            />
        </div>
    </div>
</div>

<style>
    .timeline-visualization {
        margin: 2rem auto;
        max-width: 1200px;
        border: 1px solid #000;
        position: relative;
    }

    .timeline-map-container {
        display: flex;
        gap: 0;
        height: auto;
    }

    .timeline-column {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        border-right: 1px solid #000;
        height: 600px;
        min-height: 0;
    }

    .timeline-block {
        display: flex;
        flex-direction: column;
        height: 100%;
        min-height: 0;
    }

    .timeline-content {
        flex: 1 1 0%;
        min-height: 0;
        display: flex;
        flex-direction: column;
    }

    .map-column {
        flex: 1;
        min-width: 0;
        position: relative;
        display: flex;
        flex-direction: column;
    }

    @media (max-width: 900px) {
        .timeline-map-container {
            flex-direction: column;
            min-height: 0;
        }

        .timeline-column {
            order: 2;
            border-right: none;
            border-top: 1px solid #000;
            height: 240px;
        }

        .timeline-block {
            height: 100%;
            min-height: 0;
        }

        .timeline-content {
            flex: 1 1 0%;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }

        .map-column {
            order: 1;
            height: 600px;
        }
    }

    /* Tablet screens */
    @media (max-width: 768px) {
        .timeline-column {
            height: 200px;
        }

        .map-column {
            height: 400px;
        }
    }

    /* Mobile screens */
    @media (max-width: 480px) {
        .timeline-visualization {
            margin: 0.5rem 0.25rem;
        }

        .timeline-column {
            height: 150px;
        }

        .map-column {
            height: 300px;
        }
    }
</style>
