<script>
    import MapTimeline from "$lib/MapTimeline.svelte";
    import Timeline from "$lib/Timeline.svelte";
    import Dashboard from "$lib/DashboardTimeline.svelte";
    import kmcltImage from "../../assets/kmclt.png";

    let sliderYear = 2025.5;
    let hoveredAddress = null; // Shared hover state
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
                    <h1 style="margin:5px; font-size:2em;">
                        Kensington Market
                    </h1>
                    <h2
                        style="margin:5px; font-size:1.1em; font-weight:normal; color:#555;"
                    >
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
        <MapTimeline {sliderYear} bind:hoveredAddress />
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
        height: 100vh;
        position: relative;
    }

    #text {
        padding: 0 20px;
        background: #fff;
    }

    .dashboard-body {
        overflow-y: auto;
        font-size: 0.9em;
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
        width: 60vw;
        margin: 0;
    }
</style>
