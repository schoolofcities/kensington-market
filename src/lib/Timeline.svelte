<script>
    import { onMount } from "svelte";

    let businesses = [];
    const years = Array.from({ length: 2025 - 2007 + 1 }, (_, i) => 2007 + i);
    import { typeColors, getColor } from "./typeColors.js";
    import Businesses from "../data/businesses.geo.json";

    export let hoveredAddress = null;

    // Hover popup state
    let hoveredCircle = null;
    let popupPosition = { x: 0, y: 0 };
    let popupVisible = false;
    let hoverTimeout = null;

    // Define consistent widths
    const ADDRESS_COLUMN_WIDTH = 115;
    const ADDRESS_BORDER_WIDTH = 1;
    const TOTAL_ADDRESS_WIDTH = ADDRESS_COLUMN_WIDTH + ADDRESS_BORDER_WIDTH;
    const SCROLLBAR_WIDTH = 16;

    function buildSegments(history, containerWidth = 800) {
        history = [...history].sort((a, b) => a.year - b.year);

        const totalYears = years.length;
        const timelineWidth = containerWidth - TOTAL_ADDRESS_WIDTH - SCROLLBAR_WIDTH;
        const pixelsPerYear = timelineWidth / totalYears;

        let segments = [];
        for (let i = 0; i < history.length; i++) {
            let start = history[i].year;
            let end = i < history.length - 1 ? history[i + 1].year - 1 : 2025;

            let displayStart = Math.max(start, 2007);
            let displayEnd = Math.min(end, 2025);

            let startIndex = years.indexOf(displayStart);
            let endIndex = years.indexOf(displayEnd);

            if (startIndex !== -1 && endIndex !== -1) {
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

    let yearlyTypeCounts = {};

    function preCalculateYearlyCounts() {
        yearlyTypeCounts = {};

        years.forEach((year) => {
            yearlyTypeCounts[year] = {};
        });

        businesses.forEach((business) => {
            const sortedHistory = [...business.history].sort(
                (a, b) => a.year - b.year,
            );

            years.forEach((year) => {
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

    $: currentCounts = yearlyTypeCounts[Math.floor(sliderYear)] || {};
    $: baselineCounts = yearlyTypeCounts[2007] || {};

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

    // Improved address hover handlers with immediate clearing
    function handleAddressHover(address) {
        console.log('Timeline address hover:', address);
        // Clear any pending timeouts first
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
        // Set immediately for timeline hover
        hoveredAddress = address;
    }

    function handleAddressLeave() {
        console.log('Timeline address leave');
        // Clear any pending timeouts first
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
        // Clear immediately for timeline hover
        hoveredAddress = null;
    }

    // Improved circle hover handlers
    function handleCircleHover(event, segment, address) {
        console.log('Timeline circle hover:', address);
        // Clear any pending timeouts first
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }

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

        const popupWidthEstimate =
            Math.max(
                hoveredCircle.name.length * 7,
                (hoveredCircle.duration.length +
                    hoveredCircle.yearCount.toString().length +
                    10) *
                    6,
            ) + 0;

        let x = circleRect.left - rect.left + circleRect.width + 8;
        let anchorRight = false;

        if (x + popupWidthEstimate > rect.width) {
            x = circleRect.left - rect.left - 8;
            anchorRight = true;
        }

        popupPosition = {
            x: x,
            y: circleRect.top - rect.top + circleRect.height / 2 - 20,
            anchorRight: anchorRight,
        };

        popupVisible = true;

        // Set hovered address immediately for map highlighting
        hoveredAddress = address;
    }

    function handleCircleLeave() {
        console.log('Timeline circle leave');
        // Use shorter timeout and ensure cleanup
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
        }
        hoverTimeout = setTimeout(() => {
            popupVisible = false;
            hoveredCircle = null;
            hoveredAddress = null;
        }, 50); // Reduced from 100ms to 50ms
    }

    function handlePopupEnter() {
        console.log('Timeline popup enter');
        // Cancel any pending clear operations
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
    }

    function handlePopupLeave() {
        console.log('Timeline popup leave');
        // Clear any pending timeouts
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
        // Clear immediately when leaving popup
        popupVisible = false;
        hoveredCircle = null;
        hoveredAddress = null;
    }

    let timelineContainer;
    let containerWidth = 800;
    let timelineWidth = 0;
    let useAbbreviatedYears = false;

    // Dynamic container height - responsive to screen size
    let containerHeight = 400;
    let isMobile = false;

    function updateContainerWidth() {
        if (timelineContainer) {
            containerWidth = timelineContainer.offsetWidth;
            timelineWidth = containerWidth - TOTAL_ADDRESS_WIDTH - SCROLLBAR_WIDTH; // Account for scrollbar

            const pixelsPerYear = timelineWidth / years.length;
            useAbbreviatedYears = pixelsPerYear < 32;

            updateThumbPosition();
        }
    }

    function updateResponsiveHeight() {
        // Check if we're in mobile view
        isMobile = window.innerWidth <= 839;
        
        if (isMobile) {
            // In mobile, calculate available height more carefully
            // Account for header, dashboard body, and some padding
            const viewportHeight = window.innerHeight;
            const headerHeight = 100; // Approximate header height in mobile
            const dashboardBodyHeight = 150; // Approximate dashboard body height in mobile
            const padding = 20; // Some padding
            
            containerHeight = Math.max(200, Math.min(300, viewportHeight - headerHeight - dashboardBodyHeight - padding));
        } else {
            containerHeight = 400; // Desktop height
        }
    }

    function formatYear(year, index) {
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

    // Watch for external changes to sliderYear (from dropdown)
    $: if (sliderYear !== undefined) {
        updateThumbPosition();
    }

    function handleSliderChange() {
        updateThumbPosition();
    }

    function updateThumbPosition() {
        if (timelineWidth > 0) {
            const pixelsPerYear = timelineWidth / years.length;
            const yearProgress = parseFloat(sliderYear) - 2007;
            sliderThumbPosition = yearProgress * pixelsPerYear;
        }
    }

    onMount(() => {
        businesses = Businesses.features.map((f) => ({
            address: f.properties.address,
            history: f.properties.history,
        }));

        preCalculateYearlyCounts();
        updateResponsiveHeight();

        setTimeout(() => {
            updateContainerWidth();
            updateThumbPosition();
        }, 100);
    });

    function handleResize() {
        updateResponsiveHeight();
        updateContainerWidth();
    }

    // Cleanup function to ensure no stuck timeouts
    function cleanup() {
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
        hoveredAddress = null;
        popupVisible = false;
        hoveredCircle = null;
    }

    // Add cleanup on component destroy
    import { onDestroy } from "svelte";
    onDestroy(() => {
        cleanup();
    });
</script>

<!-- Legend Section -->
<div class="legend-section" style="bottom: {containerHeight}px;">
    <div class="legend-container">
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

<div
    class="timeline-container"
    class:mobile={isMobile}
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
        style="left: {sliderThumbPosition + TOTAL_ADDRESS_WIDTH + 16}px;"
    ></div>

    <!-- Header -->
    <div class="timeline-header">
        <div class="timeline-header-address" style="width: {ADDRESS_COLUMN_WIDTH}px;">
            Timeline
        </div>
        <div class="year-slider" style="width: {timelineWidth}px;">
            <div class="slider-container">
                <input
                    type="range"
                    min="2007.5"
                    max="2025.5"
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
            <div class="year-labels">
                {#each years as year, i}
                    <span
                        class="year-label"
                        class:abbreviated={useAbbreviatedYears}
                        style="width: {timelineWidth / years.length}px;"
                    >
                        {formatYear(year, i)}
                    </span>
                {/each}
            </div>
        </div>
    </div>

    <div class="timeline-list">
        {#each businesses as biz}
            <div class="timeline-row">
                <div 
                    class="timeline-address" 
                    class:hovered={hoveredAddress === biz.address}
                    style="width: {ADDRESS_COLUMN_WIDTH}px; flex: 0 0 {ADDRESS_COLUMN_WIDTH}px; max-width: {ADDRESS_COLUMN_WIDTH}px;"
                    on:mouseenter={() => handleAddressHover(biz.address)}
                    on:mouseleave={handleAddressLeave}
                >
                    {biz.address}
                </div>
                <div class="timeline-bar" style="width: {timelineWidth}px; flex: 0 0 {timelineWidth}px; max-width: {timelineWidth}px;">
                    <!-- Year grid lines -->
                    <div class="year-grid-lines">
                        {#each years as year, i}
                            <div
                                class="year-grid-line"
                                style="left: {(i + 0) * (timelineWidth / years.length)}px;"
                            ></div>
                        {/each}
                    </div>

                    <!-- Continuous dashed line -->
                    <div class="continuous-dashed-line"></div>

                    <!-- Timeline circles -->
                    {#each buildSegments(biz.history, containerWidth) as seg}
                        <div
                            class="timeline-circle"
                            class:hovered={hoveredAddress === biz.address}
                            role="img"
                            aria-label="{seg.name} ({seg.type})"
                            style="left:{seg.centerPixels}px; background-color: {getColor(seg.type)};"
                            on:mouseenter={(e) => handleCircleHover(e, seg, biz.address)}
                            on:mouseleave={handleCircleLeave}
                        ></div>
                    {/each}
                </div>
            </div>
        {/each}
    </div>
</div>

<svelte:window on:resize={handleResize} />

<style>
    /* Legend Section Styles */
    .legend-section {
        position: static;
        width: 100%;
        min-height: 40px;
        background: #f5f5f5;
        border-top: 1px solid #666;
        z-index: 1002;
    }

    .legend-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 8px 12px;
        padding: 8px 18px;
        width: 100%;
        align-items: center;
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
        transition: all 0.1s ease;
    }

    .timeline-circle.hovered {
        width: 12px;
        height: 12px;
        border-width: 1px;
        z-index: 15;
    }

    .timeline-container {
        position: relative;
        bottom: 0;
        right: 0;
        overflow: hidden;
        background: #fff;
        border-top: 1px solid #000;
        flex-shrink: 0; /* Prevent shrinking */
    }

    /* Mobile-specific styling */
    .timeline-container.mobile {
        min-height: 200px; /* Minimum height for mobile */
        max-height: 300px; /* Maximum height for mobile */
    }

    .vertical-indicator-line {
        position: absolute;
        top: 40px;
        bottom: 0;
        width: 1px;
        background-color: transparent;
        border-left: 1px dashed #000;
        z-index: 999;
        pointer-events: none;
        opacity: 0.7;
    }

    .timeline-header {
        display: flex;
        align-items: stretch;
        height: 40px;
        position: relative;
        z-index: 600;
        background-color: #f5f5f5;
        border-bottom: 1px solid #000;
        flex-shrink: 0; /* Prevent header from shrinking */
    }

    .timeline-header-address {
        height: 100%;
        font-weight: bold;
        font-size: 12px;
        padding: 0px 8px;
        border-radius: 0px;
        margin-right: 0px;
        flex-shrink: 0;
        border-right: 1px solid #000;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .timeline-list {
        position: relative;
        overflow-y: auto;
        height: calc(100% - 40px);
        /* Add padding to account for scrollbar visually */
        padding-right: 32px;
        margin-right: -32px;
        flex: 1; /* Allow to take remaining space */
    }
    
    .timeline-row {
        display: flex;
        align-items: center;
        height: 17px;
        flex-shrink: 0; /* Prevent rows from shrinking */
    }
    
    .timeline-address {
        font-weight: regular;
        font-size: 12px;
        background-color: #fff;
        padding: 0px 8px;
        border-radius: 0px;
        margin-right: 0px;
        flex-shrink: 0;
        border-bottom: 0.5px solid #ccc;
        border-right: 1px solid #000;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .timeline-address.hovered {
        font-weight: bold;
        background-color: #f5f5f5;
    }
    
    .timeline-bar {
        position: relative;
        height: 20px;
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

    .year-slider {
        flex: none;
        display: flex;
        flex-direction: column;
        align-items: center;
        height: 100%;
    }
    
    .year-labels {
        display: flex;
        width: 100%;
        height: 20px;
    }

    .year-label {
        font-size: 12px;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f5f5f5;
        flex-shrink: 0;
    }

    .year-label.abbreviated {
        font-size: 10px;
    }

    .slider-container {
        position: relative;
        width: 100%;
        height: 20px;
        box-sizing: border-box;
        overflow: hidden;
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
        border-top: 12px solid #000;
        transform: translateX(-6px);
        pointer-events: none;
        top: 4px;
    }

    /* Mobile responsive adjustments */
    @media (max-width: 839px) {
        .legend-container {
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 6px 10px;
            padding: 6px 15px;
        }

        .legend-item {
            font-size: 11px;
        }

        .timeline-header-address {
            font-size: 11px;
            padding: 0px 6px;
        }

        .timeline-address {
            font-size: 11px;
            padding: 0px 6px;
        }

        .year-label {
            font-size: 11px;
        }

        .year-label.abbreviated {
            font-size: 9px;
        }

        .timeline-row {
            height: 16px;
        }

        .timeline-circle {
            width: 7px;
            height: 7px;
        }

        .timeline-circle.hovered {
            width: 10px;
            height: 10px;
        }

        .hover-popup {
            font-size: 10px;
            padding: 4px 6px;
        }
    }

    /* Extra small screens */
    @media (max-width: 480px) {
        .legend-container {
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 4px 8px;
            padding: 4px 12px;
        }

        .legend-item {
            font-size: 10px;
        }

        .timeline-header-address {
            font-size: 10px;
            padding: 0px 4px;
        }

        .timeline-address {
            font-size: 10px;
            padding: 0px 4px;
        }

        .year-label {
            font-size: 10px;
        }

        .year-label.abbreviated {
            font-size: 8px;
        }

        .timeline-row {
            height: 15px;
        }

        .timeline-circle {
            width: 6px;
            height: 6px;
        }

        .timeline-circle.hovered {
            width: 9px;
            height: 9px;
        }
    }
</style>