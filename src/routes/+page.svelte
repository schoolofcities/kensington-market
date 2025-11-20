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
    import TimelineLegend from "$lib/TimelineLegend.svelte";
    import kmcltImage from "../assets/kmclt.png";

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
        <p>
            <a href="">Farzaneh Hemmasi</a>, <a href="">Emily Hertzman</a>,
            <a href="">Scott McCallum</a> | Month 2025
        </p>

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

        <div class="blog-text">
            <h2>The Disappearance of Small Grocers</h2>
            <p>
                We were interested in mapping two major trends observed in
                Kensington Market over the past 20 years: (1) the disappearance
                of small grocers and (2) the rise of cannabis stores.
            </p>
            <p>
                We were particularly interested in mapping the change of these
                two categories as they symbolize the broader shift in Kensington
                Market from a historically livable neighbourhood, where
                amenities for everyday life such as produce and raw food stores
                are accessible and close by from a variety of small businesses,
                to a retail destination, largely centered around shopping and
                leisure.
            </p>

            <p>
                The proliferation of cannabis stores is both notable and
                noticeable. In 2025 there were 5 cannabis stores in the
                neighbourhood. For a neighbourhood the size of Kensington Market
                to have this many cannabis stores is telling of the broader
                change from serving the local community to serving customers
                from outside the neighbourhood.
            </p>
            <p>
                Increasingly a site of leisure and consumption, landlords may
                have favoured higher-paying tenants, such as cannabis retailers,
                over other businesses such as traditional grocers. Rents go up,
                local amenities get priced out, the neighbourhood changes.
            </p>
        </div>
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
                <MapTimeline
                    bind:sliderYear
                    bind:hoveredAddress
                    {enabledTypes}
                />
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
        height: auto; /* Allow container to grow with content */
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

    @media (max-width: 900px) {
        .timeline-map-container {
            flex-direction: column;
            min-height: 0; /* Remove min-height constraint */
        }

        .timeline-section {
            order: 2;
            border-right: none;
            border-top: 1px solid #000;
            height: 350px; /* Fixed height for mobile */
        }

        .map-section {
            order: 1;
            height: 350px; /* Fixed height for mobile */
        }
    }
</style>
