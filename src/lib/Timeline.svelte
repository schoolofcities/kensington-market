<script>
    // bold legend items with counts and percentages reactive to year "Grocer: 12 (30%) --> Grocer: 5 (15%)"

    import { onMount } from "svelte";

    let businesses = [];
    const years = Array.from({ length: 2025 - 2007 + 1 }, (_, i) => 2007 + i);
    import { typeColors, getColor } from "./typeColors.js";
    import Businesses from "../data/businesses.geo.json";

    // Hover popup state
    let hoveredCircle = null;
    let popupPosition = { x: 0, y: 0 };
    let popupVisible = false;
    let hoverTimeout = null;

    function buildSegments(history, containerWidth = 800) {
        // Sort history by year
        history = [...history].sort((a, b) => a.year - b.year);

        const totalYears = years.length;
        const pixelsPerYear = containerWidth / totalYears;

        // Build segments with pixel positioning - circles centered on year labels
        let segments = [];
        for (let i = 0; i < history.length; i++) {
            let start = history[i].year;
            let end = i < history.length - 1 ? history[i + 1].year - 1 : 2025;

            // Clamp to timeline range
            let displayStart = Math.max(start, 2007);
            let displayEnd = Math.min(end, 2025);

            // Calculate pixel positions - center circles on year labels
            let startIndex = years.indexOf(displayStart);
            let endIndex = years.indexOf(displayEnd);

            if (startIndex !== -1 && endIndex !== -1) {
                // Center the circle on the year label
                let centerPixels = (startIndex + 0.5) * pixelsPerYear;

                segments.push({
                    start: displayStart,
                    end: displayEnd,
                    type: history[i].type,
                    name: history[i].name,
                    trueStart: start,
                    trueEnd: end,
                    centerPixels: centerPixels,
                    startIndex: startIndex,
                    endIndex: endIndex,
                });
            }
        }

        return segments;
    }

    // Pre-calculate counts for all years
    let yearlyTypeCounts = {};

    function preCalculateYearlyCounts() {
        yearlyTypeCounts = {};

        // Initialize all years with empty counts
        years.forEach((year) => {
            yearlyTypeCounts[year] = {};
        });

        // For each business, determine what type it was in each year
        businesses.forEach((business) => {
            const sortedHistory = [...business.history].sort(
                (a, b) => a.year - b.year,
            );

            years.forEach((year) => {
                // Find which segment was active in this year
                let activeType = null;

                for (let i = 0; i < sortedHistory.length; i++) {
                    const segment = sortedHistory[i];
                    const nextSegment = sortedHistory[i + 1];
                    const segmentEnd = nextSegment ? nextSegment.year : 2026;

                    if (segment.year <= year && year < segmentEnd) {
                        activeType = segment.type;
                        break;
                    }
                }

                if (activeType) {
                    if (!yearlyTypeCounts[year][activeType]) {
                        yearlyTypeCounts[year][activeType] = 0;
                    }
                    yearlyTypeCounts[year][activeType]++;
                }
            });
        });
    }

    // Reactive variables for legend display
    $: currentCounts = yearlyTypeCounts[Math.floor(sliderYear)] || {};
    $: baselineCounts = yearlyTypeCounts[2007] || {};

    // Function to get change info for a type
    function getChangeInfo(type, currentCount, baselineCount) {
        const current = currentCount || 0;
        const baseline = baselineCount || 0;
        const change = current - baseline;

        return {
            current,
            change,
            hasChange: Math.floor(sliderYear) > 2007 && change !== 0,
        };
    }

    // Hover handlers for circles
    function handleCircleHover(event, segment, address) {
        clearTimeout(hoverTimeout);

        const rect = timelineContainer.getBoundingClientRect();
        const circleRect = event.target.getBoundingClientRect();

        hoveredCircle = {
            ...segment,
            address: address,
            duration:
                segment.trueEnd === 2025
                    ? `${segment.trueStart} - Present`
                    : `${segment.trueStart} - ${segment.trueEnd}`,
            yearCount:
                segment.trueEnd === 2025
                    ? Math.max(1, 2025 - segment.trueStart)
                    : Math.max(1, segment.trueEnd - segment.trueStart),
        };

        // Calculate popup width estimate (rough approximation)
        const popupWidthEstimate =
            Math.max(
                hoveredCircle.name.length * 7, // Name line
                (hoveredCircle.duration.length +
                    hoveredCircle.yearCount.toString().length +
                    10) *
                    6, // Duration line
            ) + 0; // Add padding

        // Default position (to the right)
        let x = circleRect.left - rect.left + circleRect.width + 8;
        let anchorRight = false;

        // Check if popup would overflow on the right side
        if (x + popupWidthEstimate > rect.width) {
            // Position to the left of the circle instead
            x = circleRect.left - rect.left - 8;
            anchorRight = true;
        }

        popupPosition = {
            x: x,
            y: circleRect.top - rect.top + circleRect.height / 2 - 20,
            anchorRight: anchorRight,
        };

        popupVisible = true;
    }

    function handleCircleLeave() {
        hoverTimeout = setTimeout(() => {
            popupVisible = false;
            hoveredCircle = null;
        }, 100); // Small delay to prevent flickering
    }

    function handlePopupEnter() {
        clearTimeout(hoverTimeout);
    }

    function handlePopupLeave() {
        popupVisible = false;
        hoveredCircle = null;
    }

    // Get container width dynamically
    let timelineContainer;
    let containerWidth = "100%"; // default fallback
    let useAbbreviatedYears = false;

    // Resize functionality
    let containerHeight = 260; // Initial height (20vh equivalent)
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
                maxHeight =
                    (rowCount - 1) * rowHeight +
                    sliderAreaHeight +
                    headerHeight +
                    0; // Add some padding
            }
        }
    }

    function formatYear(year, index) {
        // Special case for the first year
        if (index === 0) {
            return useAbbreviatedYears ? "≤'07" : "≤ 2007";
        }

        if (useAbbreviatedYears) {
            return `'${year.toString().slice(-2)}`;
        }
        return year.toString();
    }

    export let sliderYear = 2025.5;
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

    onMount(() => {
        businesses = Businesses.features.map((f) => ({
            address: f.properties.address,
            history: f.properties.history,
        }));

        preCalculateYearlyCounts();

        setTimeout(() => {
            updateContainerWidth();
            updateThumbPosition();
            calculateMaxHeight();
        }, 100);
    });

    // Update width on window resize
    function handleResize() {
        updateContainerWidth();
        calculateMaxHeight();
    }
</script>

<!-- Resize handle -->
<button
    class="resize-handle"
    style="bottom: {containerHeight}px;"
    on:mousedown={handleResizeStart}
    role="separator"
    aria-orientation="horizontal"
    aria-label="Resize timeline"
></button>

<div
    class="timeline-container"
    bind:this={timelineContainer}
    style="height: {containerHeight}px;"
>
    <!-- Hover Popup -->
    {#if popupVisible && hoveredCircle}
        <div
            class="hover-popup"
            class:anchor-right={popupPosition.anchorRight}
            style="left: {popupPosition.x}px; top: {popupPosition.y}px;"
            role="tooltip"
            on:mouseenter={handlePopupEnter}
            on:mouseleave={handlePopupLeave}
        >
            <div class="popup-content">
                <div class="popup-name">{hoveredCircle.name}</div>
                <div class="popup-duration">
                    {hoveredCircle.duration} ({hoveredCircle.yearCount} year{hoveredCircle.yearCount !==
                    1
                        ? "s"
                        : ""})
                </div>
            </div>
        </div>
    {/if}

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
                {@const changeInfo = getChangeInfo(
                    type,
                    currentCounts[type],
                    baselineCounts[type],
                )}
                <div class="legend-item">
                    <div
                        class="legend-color"
                        style="background-color: {color};"
                    ></div>
                    <span class="legend-text">
                        {type}: {changeInfo.current}
                        {#if changeInfo.hasChange}
                            <span
                                class="change-indicator"
                                class:positive={changeInfo.change > 0}
                                class:negative={changeInfo.change < 0}
                            >
                                ({changeInfo.change > 0
                                    ? "+"
                                    : ""}{changeInfo.change})
                            </span>
                        {/if}
                    </span>
                </div>
            {/each}
        </div>
    </div>

    <div class="timeline-list">
        {#each businesses as biz}
            <div class="timeline-row">
                <div class="timeline-address">{biz.address}</div>
                <div class="timeline-bar">
                    <!-- Vertical grid lines for year divisions -->
                    <div class="year-grid-lines">
                        {#each years as year, i}
                            <div
                                class="year-grid-line"
                                style="left: {(i + 0) *
                                    (containerWidth / years.length)}px;"
                            ></div>
                        {/each}
                    </div>

                    <!-- Continuous dashed line across entire timeline -->
                    <div class="continuous-dashed-line"></div>

                    <!-- Circles positioned at center of year labels -->
                    {#each buildSegments(biz.history, containerWidth) as seg}
                        <div
                            class="timeline-circle"
                            role="img"
                            aria-label="{seg.name} ({seg.type})"
                            style="left:{seg.centerPixels}px; background-color: {getColor(
                                seg.type,
                            )};"
                            on:mouseenter={(e) =>
                                handleCircleHover(e, seg, biz.address)}
                            on:mouseleave={handleCircleLeave}
                        ></div>
                    {/each}
                </div>
            </div>
        {/each}
    </div>
    <div class="timeline-bottom">
        <div class="year-slider">
            <div class="year-labels">
                {#each years as year, i}
                    <span
                        class="year-label"
                        class:abbreviated={useAbbreviatedYears}
                    >
                        {formatYear(year, i)}
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
    /* Hover Popup Styles */
    .hover-popup {
        position: absolute;
        background: white;
        border: 1px solid #333;
        padding: 6px 8px;
        z-index: 1001;
        font-size: 11px;
        line-height: 1.3;
        white-space: nowrap;
    }

    .hover-popup.anchor-right {
        transform: translateX(-100%);
    }

    .popup-content {
        display: flex;
        flex-direction: column;
        gap: 1px;
    }

    .popup-name {
        font-weight: bold;
        margin: 0;
    }

    .popup-duration {
        margin: 0;
        color: #000;
    }

    .timeline-circle {
        position: absolute;
        top: 50%;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        border: 0.5px solid #000;
        transform: translate(-50%, -50%);
        cursor: pointer;
        z-index: 10;
    }

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
        /* width: 900px;
        height: 600px;
        margin: 0 auto; */

        position: fixed;
        bottom: 0;
        right: 0;
        width: 100vw;
        width: 100dvw;
        /* min-height: 200px; */
        overflow: hidden;
        background: #fff;
        border-top: 1px solid #666;
    }

    .vertical-indicator-line {
        position: absolute;
        top: 40px; /* Start below the header */
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
        height: 40px;
        position: relative;
        z-index: 600;
        background-color: #f8f8f8;
        border-bottom: 1px solid #666;
        border-right: 1px solid #ccc;
    }

    .timeline-header-address {
        width: 100px;
        height: 100%;
        font-weight: bold;
        font-size: 12px;
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
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
        gap: 10px 8px;
        padding: 0px 18px;
        width: 100%;
        height: 100%;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        color: #333;
    }

    .legend-color {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        border: 0.5px solid #000;
    }

    .change-indicator {
        font-weight: bold;
        margin-left: 2px;
    }

    .change-indicator.positive {
        color: #22c55e;
    }

    .change-indicator.negative {
        color: #ef4444;
    }

    .timeline-list {
        width: 100%;
        position: relative;
        overflow-y: auto;
        height: calc(100% - 80px); /* Adjusted to account for header */
        overflow-y: scroll;
        border-bottom: 1px solid #ccc;
    }
    .timeline-row {
        display: flex;
        align-items: center;
        height: 17px;
    }
    .timeline-address {
        width: 100px;
        font-weight: regular;
        font-size: 12px;
        background-color: #fff;
        padding: 0px 8px;
        border-radius: 0px;
        margin-right: 0px;
        flex-shrink: 0;
        border-bottom: 0.5px solid #ccc;
    }
    .timeline-bar {
        position: relative;
        height: 20px;
        width: 100%;
        border-radius: 0px;
        overflow: visible;
        opacity: 1;
    }

    .year-grid-lines {
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        pointer-events: none;
        z-index: 0;
    }

    .year-grid-line {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 1px;
        background-color: #e0e0e0;
        opacity: 0.5;
    }

    .continuous-dashed-line {
        position: absolute;
        top: 50%;
        left: 0;
        right: 0;
        height: 0;
        border-top: 1px dashed #ccc;
        transform: translateY(-50%);
        z-index: 1;
    }

    .timeline-bottom {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        width: calc(100% - 100px);
        position: absolute;
        bottom: 0;
        right: auto;
        left: 84px;
        min-width: 0;
        z-index: -1;
    }
    .year-slider {
        width: calc(100% - 32px);
        flex: 1 1 0;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .year-labels {
        display: flex;
        width: 100%;
        height: 20px;
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
        font-size: 10px;
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
