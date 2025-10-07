<script>
    // TO DO
    // Finalize mobile version
    // finalize categories and color selection
    // use static basemap instead of Carto
    // add sankey diagram
    // add pie charts
    // article

    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";
    import TimelineLegend from "$lib/TimelineLegend.svelte";
    import kmcltImage from "../../assets/kmclt.png";

    let sliderYear = 2025.5;
    let hoveredAddress = null; // Shared hover state
    let yearlyTypeCounts = {}; // Shared between Timeline and Legend
    let enabledTypes = {}; // Shared filter state
</script>

<!-- Blog Content -->
<main>
    <div class="text-content">
        <a href="/">
            <img src={kmcltImage} alt="Kensington Market" class="logo" />
        </a>
        <h1>Mapping change in Kensington Market</h1>

        <div class="blog-text">
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
                eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
                enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor
                in reprehenderit in voluptate velit esse cillum dolore eu fugiat
                nulla pariatur. Excepteur sint occaecat cupidatat non proident,
                sunt in culpa qui officia deserunt mollit anim id est laborum.
            </p>
        </div>

        <div class="pie-charts"></div>

        <div class="blog-text">
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
                eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
                enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor
                in reprehenderit in voluptate velit esse cillum dolore eu fugiat
                nulla pariatur. Excepteur sint occaecat cupidatat non proident,
                sunt in culpa qui officia deserunt mollit anim id est laborum.
            </p>
        </div>

        <div class="sankey"></div>
    </div>

    <!-- Timeline and Map with shared legend header -->
    <div class="timeline-map-wrapper">
        <!-- Legend as header -->
        <TimelineLegend {sliderYear} {yearlyTypeCounts} bind:enabledTypes />

        <!-- Timeline and Map side-by-side -->
        <div class="timeline-map-container">
            <div class="timeline-section">
                <Timeline
                    bind:sliderYear
                    bind:hoveredAddress
                    bind:yearlyTypeCounts
                />
            </div>
            <div class="map-section">
                <MapTimeline bind:sliderYear bind:hoveredAddress {enabledTypes} />
            </div>
        </div>
    </div>
</main>

<style>
    :global(body) {
        margin: 0;
        font-family:
            "FavoritVariable",
            -apple-system,
            BlinkMacSystemFont,
            "Segoe UI",
            Roboto,
            sans-serif;
        line-height: 1.6;
        color: #333;
    }

    header {
        padding: 0.5em 1em;
        border-bottom: 1px solid #e0e0e0;
    }

    .logo {
        height: 110px;
    }

    main {
        padding: 3rem 2rem 0 2rem;
    }

    .text-content {
        max-width: 600px;
        margin: 0 auto;
    }

    h1 {
        margin-bottom: 2rem;
        color: #222;
    }

    .blog-text {
        font-size: 1.1rem;
        color: #444;
    }

    .blog-text p {
        margin-bottom: 1.5rem;
    }

    .timeline-map-wrapper {
        margin: 2rem auto;
        max-width: 1200px;
        border: 1px solid #000;
    }

    .timeline-map-container {
        display: flex;
        gap: 0;
        min-height: 350px;
    }

    .timeline-section {
        flex: 1;
        min-width: 0;
        border-right: 1px solid #000;
    }

    .map-section {
        flex: 1;
        min-width: 0;
        border-top: 1px solid #000;
    }

    @media (max-width: 768px) {
        .timeline-map-wrapper {

        }

        .timeline-map-container {
            flex-direction: column;
            height: auto;
        }

        .timeline-section {
            order: 2;
            border-right: none;
            border-top: 1px solid #000;
        }

        .map-section {
            order: 1;
            height: 400px;
        }
    }
</style>
