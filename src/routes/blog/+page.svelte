<script>
    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";

        let sliderYear = 2025.5;

</script>


<MapTimeline {sliderYear} />
<Timeline bind:sliderYear />


<style>
</style>
