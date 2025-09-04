<script>
    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";

    let sliderYear = 2025.5;
    let hoveredAddress = null; // Shared hover state

</script>

<MapTimeline {sliderYear} bind:hoveredAddress />
<Timeline bind:sliderYear bind:hoveredAddress />

<style>
</style>