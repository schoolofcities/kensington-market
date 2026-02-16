<script>
    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import TimelineLegend from "$lib/TimelineLegend.svelte";

    let sliderYear = 2025.5;
    let hoveredAddress = null; // Shared hover state
    let yearlyTypeCounts = {}; // Shared between Timeline and Legend
    let enabledTypes = {}; // Shared filter state
</script>

<!-- Blog Content -->
<main>
    <div class="text-content">
        <h1>The title</h1>
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
    <h2 class="section-title">
        Mapping the disappearance of grocers and the rise of cannabis stores since 2007
    </h2>
    <h3></h3>
    <!-- <p class="section-description">
        The map and timeline below visualize the historical transitions of
        grocers and raw food vendors in Kensington Market. The visualization
        highlights how many locations originally operated as grocers and later
        transitioned into other types of businesses, illustrating patterns of
        commercial change and succession in the neighbourhood over time. Additionally, we tracked the rise of cannabis stores as an emerging retail subcategory of interest.
    </p> -->
    <div class="timeline-map-wrapper">
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
</main>

<style>
    .section-description {
        max-width: 800px;
        margin: 0 auto 2rem auto;
        font-size: 1rem;
        color: #444;
        text-align: left;
    }
    .section-title {
        font-size: 1.2rem;
        font-weight: 500;
        margin: 2rem auto 1rem auto;
        color: #222;
        letter-spacing: 0.01em;
        max-width: 800px;
        text-align: left;
    }
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
        background-color: #ffffff;
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
        max-width: 800px;
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
        position: relative;
    }
    .legend-overlay {
        position: absolute;
        left: 0;
        right: 0;
        bottom: 0;
        z-index: 100;
        padding: 16px 32px 20px 32px;
        display: flex;
        flex-wrap: wrap;
        gap: 10px 16px;
        width: 100%;
        min-width: 0;
        max-width: none;
        background: none !important;
        box-shadow: none !important;
        border-radius: 0 !important;
        align-items: center;
        box-sizing: border-box;
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
        border-top: 1px solid #000;
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
    .map-column {
        flex: 1;
        min-width: 0;
        border-top: 1px solid #000;
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
</style>
