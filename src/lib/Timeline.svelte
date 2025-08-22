<script>
    import { onMount } from "svelte";

    let businesses = [];
    const years = Array.from({ length: 2025 - 2007 + 1 }, (_, i) => 2007 + i);
    import { typeColors, getColor } from "./typeColors.js";

    function buildSegments(history, containerWidth = 800) {
        // Sort history by year
        history = [...history].sort((a, b) => a.year - b.year);

        const totalYears = years.length;
        const pixelsPerYear = containerWidth / totalYears;

        // Build segments with pixel positioning
        let segments = [];
        for (let i = 0; i < history.length; i++) {
            let start = history[i].year;
            let end = i < history.length - 1 ? history[i + 1].year - 1 : 2025;

            // Clamp to timeline range
            let displayStart = Math.max(start, 2007);
            let displayEnd = Math.min(end, 2025);

            // Calculate pixel positions
            let startIndex = years.indexOf(displayStart);
            let endIndex = years.indexOf(displayEnd);

            if (startIndex !== -1 && endIndex !== -1) {
                let leftPixels = startIndex * pixelsPerYear;
                let widthPixels = (endIndex - startIndex + 1) * pixelsPerYear;

                segments.push({
                    start: displayStart,
                    end: displayEnd,
                    type: history[i].type,
                    name: history[i].name,
                    trueStart: start,
                    trueEnd: end,
                    leftPixels: leftPixels,
                    widthPixels: widthPixels,
                });
            }
        }

        return segments;
    }

    // Get container width dynamically
    let timelineContainer;
    let containerWidth = 800; // default fallback
    let useAbbreviatedYears = false;

    // Resize functionality
    let containerHeight = 300; // Initial height (20vh equivalent)
    let isDragging = false;
    let dragStartY = 0;
    let dragStartHeight = 0;
    let maxHeight = 600; // Will be calculated based on timeline-list content

    function updateContainerWidth() {
        if (timelineContainer) {
            const yearLabels = timelineContainer.querySelector(".year-labels");
            if (yearLabels) {
                containerWidth = yearLabels.offsetWidth;

                // Calculate if we need abbreviated years
                // Assume each full year needs about 32px, abbreviated needs about 20px
                const pixelsPerYear = containerWidth / years.length;
                useAbbreviatedYears = pixelsPerYear < 32;

                updateThumbPosition(); // Update thumb position when container width changes
            }
        }
    }

    function calculateMaxHeight() {
        if (timelineContainer) {
            const timelineList =
                timelineContainer.querySelector(".timeline-list");
            if (timelineList) {
                // Calculate the total height needed for all business rows
                const rowCount = businesses.length;
                const rowHeight = 20; // Height of each timeline-row
                const sliderAreaHeight = 40; // Height reserved for slider
                const headerHeight = 20; // Height of the frozen header
                maxHeight = (rowCount - 1) * rowHeight + sliderAreaHeight + headerHeight + 20; // Add some padding
            }
        }
    }

    function formatYear(year) {
        if (useAbbreviatedYears) {
            return `'${year.toString().slice(-2)}`;
        }
        return year.toString();
    }

    export let sliderYear = 2025;
    let sliderThumbPosition = 0;

    function handleSliderChange() {
        console.log("Slider year:", sliderYear);
        updateThumbPosition();
    }

    function updateThumbPosition() {
        if (containerWidth > 0) {
            const pixelsPerYear = containerWidth / years.length;
            // Calculate position based on exact slider value (not just year index)
            const yearProgress = parseFloat(sliderYear) - 2007; // Years since start
            sliderThumbPosition = yearProgress * pixelsPerYear;
        }
    }

    // Resize drag handlers
    function handleResizeStart(event) {
        isDragging = true;
        dragStartY = event.clientY;
        dragStartHeight = containerHeight;
        document.addEventListener("mousemove", handleResizeDrag);
        document.addEventListener("mouseup", handleResizeEnd);
        event.preventDefault();
    }

    function handleResizeDrag(event) {
        if (!isDragging) return;

        const deltaY = dragStartY - event.clientY; // Inverted because we're dragging from top
        let newHeight = dragStartHeight + deltaY;

        // Constrain height between minimum and maximum
        const minHeight = 200;
        newHeight = Math.max(minHeight, Math.min(newHeight, maxHeight));

        containerHeight = newHeight;
    }

    function handleResizeEnd() {
        isDragging = false;
        document.removeEventListener("mousemove", handleResizeDrag);
        document.removeEventListener("mouseup", handleResizeEnd);
    }

    onMount(async () => {
        const response = await fetch("/kmclt/src/data/businesses.geo.json");
        const data = await response.json();
        businesses = data.features.map((f) => ({
            address: f.properties.address,
            history: f.properties.history,
        }));

        // Update container width and calculate max height after mount
        setTimeout(() => {
            updateContainerWidth();
            updateThumbPosition(); // Initial thumb position
            calculateMaxHeight(); // Calculate max height based on content
        }, 100);
    });

    // Update width on window resize
    function handleResize() {
        updateContainerWidth();
        calculateMaxHeight();
    }
</script>

<!-- Resize handle -->
<div
    class="resize-handle"
    style="bottom: {containerHeight}px;"
    on:mousedown={handleResizeStart}
></div>

<div
    class="timeline-container"
    bind:this={timelineContainer}
    style="height: {containerHeight}px;"
>
    <!-- White mask overlay -->
    <div
        class="white-mask-overlay"
        style="width: {sliderThumbPosition + 116}px;"
    ></div>

    <!-- Vertical indicator line -->
    <div
        class="vertical-indicator-line"
        style="left: {sliderThumbPosition + 116}px;"
    ></div>

    <!-- Frozen header row -->
    <div class="timeline-header">
        <div class="timeline-header-address">Address</div>
        <div class="timeline-header-legend">
            {#each Object.entries(typeColors) as [type, color]}
                <div class="legend-item">
                    <div class="legend-color" style="background-color: {color};"></div>
                    <span class="legend-text">{type}</span>
                </div>
            {/each}
        </div>
    </div>

    <div class="timeline-list">
        {#each businesses as biz}
            <div class="timeline-row">
                <div class="timeline-address">{biz.address}</div>
                <div class="timeline-bar">
                    {#each buildSegments(biz.history, containerWidth) as seg}
                        <div
                            class="timeline-segment"
                            title={`${seg.name} (${seg.type}) ${seg.trueStart}-${seg.trueEnd}`}
                            style="left:{seg.leftPixels}px;width:{seg.widthPixels}px;background:{getColor(
                                seg.type,
                            )}"
                        ></div>
                    {/each}
                </div>
            </div>
        {/each}
    </div>
    <div class="timeline-bottom">
        <div class="timeline-overlay"></div>
        <div class="year-slider">
            <div class="year-labels">
                {#each years as year, i}
                    <span
                        class="year-label"
                        class:abbreviated={useAbbreviatedYears}
                    >
                        {formatYear(year)}
                    </span>
                {/each}
            </div>
            <div class="slider-container">
                <input
                    type="range"
                    min="2007"
                    max="2025.99"
                    step="0.01"
                    class="year-slider-input"
                    bind:value={sliderYear}
                    on:input={handleSliderChange}
                />
                <div
                    class="custom-slider-thumb"
                    style="left: {sliderThumbPosition}px;"
                ></div>
            </div>
        </div>
    </div>
</div>

<svelte:window on:resize={handleResize} />

<style>
    /* .resize-handle {
        position: fixed;
        right: 0;
        width: 70vw;
        width: 70dvw;
        height: 10px;
        background: transparent;
        cursor: ns-resize;
        z-index: 1001;
        border-top: 2px solid #ccc;
    }

    .resize-handle:hover {
        border-top-color: #007acc;
        background: rgba(0, 122, 204, 0.1);
    } */

    .timeline-container {
        position: fixed;
        bottom: 0;
        right: 0;
        width: 70vw;
        width: 70dvw;
        min-height: 200px;
        overflow: hidden;
        background: #fff;
        border-top: 1px solid #ccc;
        z-index: 1000;
    }

    .white-mask-overlay {
        position: absolute;
        top: 20px; /* Start below the header */
        left: 0;
        bottom: 40px; /* Stop at the slider area */
        background-color: white;
        opacity: 0;
        z-index: 500;
        pointer-events: none;
    }

    .vertical-indicator-line {
        position: absolute;
        top: 20px; /* Start below the header */
        bottom: 40px; /* Stop at the slider area */
        width: 1px;
        background-color: transparent;
        border-left: 1px dashed #000;
        z-index: 999;
        pointer-events: none;
        opacity: 0.7;
    }

    .timeline-header {
        display: flex;
        align-items: center;
        height: 20px;
        position: relative;
        z-index: 600;
        background-color: #fff;
        border-bottom: 1px solid #666;
    }

    .timeline-header-address {
        width: 100px;
        font-weight: bold;
        font-size: 12px;
        background-color: #f8f8f8;
        padding: 2px 8px;
        border-radius: 0px;
        margin-right: 0px;
        flex-shrink: 0;
        border-right: 0.5px solid #ccc;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .timeline-header-legend {
        width: 100%;
        height: 100%;
        background-color: #f8f8f8;
        margin-right: 10px;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 8px;
        padding: 2px 8px;
        overflow: hidden;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 3px;
        font-size: 10px;
        white-space: nowrap;
    }

    .legend-color {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        flex-shrink: 0;
    }

    .legend-text {
        color: #333;
        font-weight: normal;
    }

    .timeline-list {
        width: calc(100%);
        position: relative;
        overflow-y: auto;
        height: calc(100% - 60px); /* Adjusted to account for header */
        overflow-y: scroll;
        border-bottom: 1px solid #ccc;
    }
    .timeline-row {
        display: flex;
        align-items: center;
        height: auto;
    }
    .timeline-address {
        width: 100px;
        font-weight: regular;
        font-size: 12px;
        background-color: #fff;
        padding: 2px 8px;
        border-radius: 0px;
        margin-right: 0px;
        flex-shrink: 0;
        border-right: 0.5px solid #ccc;
        border-bottom: 0.5px solid #ccc;
    }
    .timeline-bar {
        position: relative;
        height: 6px;
        width: 100%;
        margin-right: 10px;
        border-radius: 0px;
        overflow: hidden;
        opacity: 1;
    }
    .timeline-segment {
        position: absolute;
        top: 0;
        height: 100%;
        cursor: pointer;
        border-left: 1px solid #fff;
    }
    .timeline-bottom {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        width: calc(100% - 108px);
        height: 200px;
        position: absolute;
        bottom: 0;
        right: auto;
        left: 84px;
        border-top: 1px solid #eee;
        min-width: 0;
        z-index: -1;
    }
    .timeline-overlay {
        height: calc(100% - 40px);
        background-color: red;
        opacity: 0;
        width: 100%;
    }
    .year-slider {
        width: calc(100% - 32px);
        flex: 1 1 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        /* margin: 0 auto; */
        /* margin-right: 16px; */
    }
    .year-labels {
        display: flex;
        width: 100%;
        height: 20px;
    }

    span {
        overflow: auto;
    }
    .year-label {
        flex: 1 1 0;
        font-size: 12px;
        border-left: 1px solid #ccc;
        border-bottom: 1px solid #ccc;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f5f5f5;
    }

    .year-label.abbreviated {
        font-size: 10px; /* Slightly smaller font for abbreviated years */
    }

    .slider-container {
        position: relative;
        width: 100%;
        height: 20px;
    }

    .year-slider-input {
        width: 100%;
        height: 20px;
        -webkit-appearance: none;
        appearance: none;
        background: transparent;
        cursor: pointer;
        margin: 0;
        padding: 0;
    }

    .year-slider-input::-webkit-slider-track {
        width: 100%;
        height: 20px;
        background: transparent;
        border: none;
    }

    .year-slider-input::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 0;
        height: 0;
        background: transparent;
        border: none;
        cursor: pointer;
    }

    .year-slider-input::-moz-range-track {
        width: 100%;
        height: 20px;
        background: transparent;
        border: none;
    }

    .year-slider-input::-moz-range-thumb {
        width: 0;
        height: 0;
        background: transparent;
        border: none;
        cursor: pointer;
        border-radius: 0;
    }

    .custom-slider-thumb {
        position: absolute;
        width: 0;
        height: 0;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        border-bottom: 12px solid #000;
        transform: translateX(-6px);
        pointer-events: none;
        top: 4px;
    }
</style>