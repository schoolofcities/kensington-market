<script>
    import TimelineVisualization from "$lib/TimelineVisualization.svelte";
    import sankeyImage from "../assets/sankey-2007-2025.png";
    import drumMap from "../assets/drum-map.png";
    import pieNonRes from "../assets/pieNonRes.png";
    import pieRestaurants from "../assets/pieRestaurants.png";
    import pieRetail from "../assets/pieRetail.png";
    import bars from "../assets/bars.png";

    let sliderYear = 2025.5;
    let hoveredAddress = null; // Shared hover state
    let yearlyTypeCounts = {}; // Shared between Timeline and Legend
    let enabledTypes = {}; // Shared filter state
</script>

<!-- Blog Content -->
<main>
    <div class="text-content">
        <h1>Kensington Market: A Neighbourhood of Change</h1>
        <div class="authors">
            <p>
                Authors:
                <a href="https://farzaneh-hemmasi.com/" target="_blank"
                    >Farzaneh Hemmasi</a
                >,
                <a
                    href="https://www.linkedin.com/in/emily-hertzman-8b312b88/"
                    target="_blank">Emily Hertzman</a
                >,
            </p>
            <p>
                Data visualisation:
                <a
                    href="https://www.linkedin.com/in/scott-christian-mccallum/"
                    target="_blank">Scott McCallum</a
                >
            </p>
            <p>February 2026</p>
        </div>
        <div class="" style="display: flex; justify-content: center;">
            <img src={drumMap} alt="" style="width: 90%;" />
        </div>
        <div class="caption">
            Business Map of The Kensington Market from The Kensington Market
            Drum, December-January 1989-1990. C/o [map author]
        </div>

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

        <div class="pie-charts" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 0; margin: 0;">
            <div style="display: flex; flex-direction: column; align-items: center;">
                <img src={pieNonRes} alt="Pie chart of non-restaurant businesses" style="height: 250px; width: auto;" />
            </div>
            <div style="display: flex; flex-direction: column; align-items: center;">
                <img src={pieRestaurants} alt="Pie chart of restaurants" style="height: 250px; width: auto;" />
            </div>
            <div style="display: flex; flex-direction: column; align-items: center;">
                <img src={pieRetail} alt="Pie chart of retail" style="height: 250px; width: auto;" />
            </div>
        </div>
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

        <div class="sankey" style="display: flex; justify-content: center;">
            <img                src={bars}
                alt="Bar chart"
                style="width: 90%; max-width: 500px;"
            />
        </div>

        <div class="sankey" style="display: flex; justify-content: center;">
            <img                src={sankeyImage}
                alt="Sankey diagram showing business transitions 2007-2025"
                style="width: 100%; max-width: 500px;"
            />
        </div>

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

        <div class="blog-text">
            <h2>The Disappearance of Small Grocers</h2>
        </div>


    <!-- Timeline and Map with shared legend header -->
    <h2 class="section-title">
        Mapping the disappearance of grocers and the rise of cannabis stores
        since 2007
    </h2>
    <TimelineVisualization
        bind:sliderYear
        bind:hoveredAddress
        bind:yearlyTypeCounts
        bind:enabledTypes
    />

    <div class="text-content">
        <div class="blog-text">
            <h2>Conclusion</h2>

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
    </div>
</main>

<style>
    .section-title {
        font-size: 1.2rem;
        font-weight: 500;
        margin: 0rem auto 0rem auto;
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
        line-height: 1.2;
        color: #5c5c5c;
        background-color: #ffffff;
    }

    main {
        padding: 0rem 2rem 4rem 2rem;
    }

    .text-content {
        max-width: 800px;
        margin: 0 auto;
    }

    h1 {
        margin-bottom: 0em;
        color: #222;
    }

    .authors {
        font-size: 0.8rem;
        line-height: 0.5;
    }

    .blog-text {
        font-size: 1.1rem;
        color: #2c2c2c;
        max-width: 800px;
    }

    .blog-text p {
        margin-bottom: 1.5rem;
    }

    .sankey {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .caption {
        font-size: 0.8rem;
        color: #979797;
        margin-top: 0.5rem;
        text-align: center;
    }
</style>
