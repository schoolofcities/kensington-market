<script>
    // TO DO
    // Finalize mobile version
    // Pick a font
    // Use a static basemap instead of Carto
    // Write better info text
    // make legend and updating numbers very clear, in sentence context

    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";
    import kmcltImage from "../../assets/kmclt.png";

    let sliderYear = 2025.5;
    let hoveredAddress = null;
</script>

<div class="side-by-side">
    <div class="dashboard-container">
        <div class="dashboard-header" id="text">
            <div style="display: flex; align-items: center; gap: 16px;">
                <a href="https://kmclt.ca" target="_blank">
                    <div
                        style="width:90px; height:auto; overflow:hidden; display:inline-block;"
                    >
                        <img
                            src={kmcltImage}
                            alt="Kensington Market"
                            style="height:80px; width:auto; object-fit:cover; object-position:left; margin-top:10px;"
                        />
                    </div>
                </a>
                <div style="display: flex; flex-direction: column;">
                    <h1 class="main-title">Kensington Market</h1>
                    <h2 class="subtitle">
                        Mapping the loss of fresh and raw food vendors
                    </h2>
                </div>
            </div>
        </div>
        <div class="dashboard-body" id="text">
            <h3>Info</h3>
            <p style="margin-top:18px; color:#444;">
                This interactive map and timeline show the change of fresh and
                raw food vendors in Kensington Market in favour of other types
                of businesses, such as cannabis stores, from 2007 to 2025.
            </p>
            <h3>Instructions</h3>
            <p>On the map:</p>
            <ul>
                <li><b>Click and drag</b> to move</li>
                <li><b>Scroll</b> to zoom</li>
                <li>
                    <b>Use the year dropdown</b> on the map to jump to any specific
                    year
                </li>
            </ul>
            <p>On the timeline:</p>
            <ul>
                <li>
                    <b>Click and drag</b> the slider
                    <span style="font-size:0.8em;">▼</span> to see the change over
                    time
                </li>
            </ul>
            <p>On both:</p>
            <ul>
                <li>
                    <b>Hover</b> over the icons
                    <span style="display:inline-block; vertical-align:1px;">
                        <svg
                            width="16"
                            height="16"
                            style="vertical-align:middle;"
                        >
                            <circle
                                cx="8"
                                cy="8"
                                r="5"
                                stroke="#333"
                                stroke-width="1"
                                fill="#fff"
                            />
                        </svg>
                    </span> to see more details
                </li>
            </ul>
        </div>
        <div class="timeline-container">
            <Timeline bind:sliderYear bind:hoveredAddress />
        </div>
    </div>
    <div class="map-container">
        <MapTimeline bind:sliderYear bind:hoveredAddress />
    </div>
</div>

<style>
    .side-by-side {
        display: flex;
        gap: 0px;
        justify-content: center;
        align-items: flex-start;
    }

    .dashboard-header {
        position: sticky;
        top: 0;
        border-bottom: 1px solid #000;
        font-size: 0.8em;
    }

    .dashboard-container {
        display: flex;
        flex-direction: column;
        width: 40vw;
        min-width: 420px;
        max-width: 620px;
        height: 100vh;
        position: relative;
    }

    .main-title {
        margin: 5px;
        font-size: 2em;
    }

    .subtitle {
        margin: 5px;
        font-size: 1.1em;
        font-weight: normal;
        color: #555;
    }

    #text {
        padding: 0 20px;
        background: #fff;
    }

    .dashboard-body {
        overflow-y: auto;
        font-size: 0.9em;
        min-height: 150px;
    }

    .timeline-container {
        width: 100%;
        height: auto;
        margin-top: auto;
    }

    .map-container {
        height: 100vh;
        height: 100dvh;
        overflow: hidden;
        flex: 1;
        margin: 0;
        border-left: 1px solid #000;
    }

    /* Mobile styles for screens under 840px */
    @media (max-width: 839px) {
        .side-by-side {
            flex-direction: column;
            height: 100vh;
            height: 100dvh;
            overflow: hidden;
        }

        .dashboard-container {
            width: 100vw;
            min-width: unset;
            max-width: unset;
            height: auto;
            max-height: 50vh;
            flex-shrink: 0;
            order: 1;
        }

        .dashboard-header {
            position: static;
            padding: 10px 0;
        }

        .dashboard-header div {
            gap: 12px !important;
        }

        .dashboard-header img {
            height: 60px !important;
            margin-top: 5px !important;
        }

        .main-title {
            font-size: 1.5em !important;
            margin: 2px !important;
        }

        .subtitle {
            font-size: 1em !important;
            margin: 2px !important;
        }

        #text {
            padding: 0 15px;
        }

        .dashboard-body {
            padding-bottom: 10px;
            font-size: 0.85em;
            min-height: unset;
            max-height: 25vh;
            overflow-y: auto;
        }

        .dashboard-body h3 {
            margin: 10px 0 5px 0;
            font-size: 1.1em;
        }

        .dashboard-body p {
            margin: 8px 0;
        }

        .dashboard-body ul {
            margin: 5px 0;
            padding-left: 20px;
        }

        .dashboard-body li {
            margin: 3px 0;
        }

        .timeline-container {
            margin-top: 0;
            border-top: 1px solid #000;
        }

        .map-container {
            width: 100vw;
            height: 50vh;
            height: 50dvh;
            order: 2;
            flex: 1;
            min-height: 300px;
            border-left: none;
            border-top: 1px solid #000;
        }

        .dashboard-container,
        .map-container {
            flex-shrink: 0;
        }
    }

    /* Extra small screens (phones in portrait) */
    @media (max-width: 480px) {
        .dashboard-header div {
            gap: 8px !important;
        }

        .dashboard-header img {
            height: 50px !important;
        }

        .main-title {
            font-size: 1.3em !important;
        }

        .subtitle {
            font-size: 0.9em !important;
        }

        #text {
            padding: 0 12px;
        }

        .dashboard-body {
            font-size: 0.8em;
            max-height: 20vh;
        }

        .dashboard-body h3 {
            font-size: 1em;
        }

        .map-container {
            height: 55vh;
            height: 55dvh;
        }
    }
</style>
