<script>
    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";

        let sliderYear = 2025;

</script>

<Timeline bind:sliderYear />
<MapTimeline {sliderYear} />
<Dashboard />


<style>
</style>
