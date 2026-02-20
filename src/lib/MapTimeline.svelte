<script>
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "maplibre-gl/dist/maplibre-gl.css";
    import "../assets/styles.css";
    import { typeColors, getColor } from "./typeColors.js";
    import Businesses from "../data/businesses.geo.json";
    import Boundary from "../data/km-boundary-skinny.geo.json";

    let map;
    let mapContainer;

    let geojson = Businesses;
    export let sliderYear = 2025;
    export let hoveredAddress = null; // Bind to parent's hover state
    export let enabledTypes = {}; // Filter state from legend

    // Generate available years from the data
    const years = Array.from({ length: 2025 - 2007 + 1 }, (_, i) => 2007 + i);
    let selectedYear = Math.floor(sliderYear); // For dropdown selection
    let isDropdownOpen = false;

    // Watch for changes in sliderYear to update dropdown
    $: selectedYear = Math.floor(sliderYear);

    // Handle dropdown year selection
    function handleYearSelect(year) {
        selectedYear = year;
        sliderYear = year + 0.5; // Set to middle of year for consistency
        isDropdownOpen = false;
    }

    // Toggle dropdown
    function toggleDropdown() {
        isDropdownOpen = !isDropdownOpen;
    }

    // Close dropdown when clicking outside
    function handleClickOutside(event) {
        if (!event.target.closest(".year-dropdown-container")) {
            isDropdownOpen = false;
        }
    }

    let scale = new maplibregl.ScaleControl({
        maxWidth: 100,
        unit: "metric",
    });

    let activePopup = null;
    let currentlyHighlighted = null; // Cache currently highlighted address
    let mapHoveredFeatureId = null; // Track map hover state
    let hoverTimeout = null; // Debounce hover operations

    // Fixed reactive statement - always clear first, then set new highlight
    $: if (map) {
        if (hoveredAddress !== currentlyHighlighted) {
            // Always clear first, then set new highlight
            clearMapHighlight();
            if (hoveredAddress) {
                highlightMapPoint(hoveredAddress);
            }
        }
    }

    function highlightMapPoint(address) {
        // Don't debounce timeline hover - only debounce internal map hover
        // Check if this is from timeline (hoveredAddress matches) or from map hover
        if (hoveredAddress === address) {
            // This is from timeline hover - perform immediately
            performHighlight(address);
        } else {
            // This is likely from map hover, so debounce
            if (hoverTimeout) {
                clearTimeout(hoverTimeout);
            }
            hoverTimeout = setTimeout(() => performHighlight(address), 50);
        }
    }

    function performHighlight(address) {
        console.log("Setting highlight for:", address);
        if (!map || currentlyHighlighted === address) return;

        // Clear previous highlight first
        clearMapHighlight();

        // Find the feature with matching address
        const feature = geojson.features.find(
            (f) => f.properties.address === address,
        );
        if (!feature) return;

        currentlyHighlighted = address;

        // Use feature-state based highlighting for better performance
        const matchingFeatures = map.querySourceFeatures("businesses-points", {
            filter: ["==", ["get", "address"], address],
        });

        if (matchingFeatures.length > 0) {
            const featureId = matchingFeatures[0].id;
            if (featureId !== undefined) {
                map.setFeatureState(
                    { source: "businesses-points", id: featureId },
                    { highlighted: true },
                );
            }
        }

        // Show popup for the hovered address
        showPopupForAddress(address);
    }

    function clearMapHighlight() {
        if (!map) return;

        // Clear any pending operations first
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }

        // Clear feature state for previously highlighted feature
        if (currentlyHighlighted) {
            const matchingFeatures = map.querySourceFeatures(
                "businesses-points",
                {
                    filter: ["==", ["get", "address"], currentlyHighlighted],
                },
            );

            matchingFeatures.forEach((feature) => {
                if (feature.id !== undefined) {
                    map.setFeatureState(
                        { source: "businesses-points", id: feature.id },
                        { highlighted: false },
                    );
                }
            });
        }

        // Reset tracking variables
        currentlyHighlighted = null;

        // Clear popup
        if (activePopup) {
            activePopup.remove();
            activePopup = null;
        }
    }

    function showPopupForAddress(address) {
        // Always clear existing popup first to prevent duplicates
        if (activePopup) {
            activePopup.remove();
            activePopup = null;
        }

        const feature = geojson.features.find(
            (f) => f.properties.address === address,
        );
        if (!feature) return;

        const { history } = feature.properties;
        let sortedHistory = [];
        try {
            sortedHistory = JSON.parse(history);
        } catch {
            sortedHistory = history;
        }
        if (!Array.isArray(sortedHistory)) sortedHistory = [];
        sortedHistory = [...sortedHistory].sort((a, b) => b.year - a.year);

        // Build timeline HTML
        let timelineHtml = `<div style='font-weight:bold;margin-bottom:4px;text-align:center;'>${address}</div>`;
        timelineHtml += `<div style='display:flex;flex-direction:column;align-items:center;position:relative;'>`;

        // Add continuous vertical line behind all circles (only if there are multiple entries)
        if (sortedHistory.length > 1) {
            timelineHtml += `<div style='position:absolute;left:64px;top:30px;bottom:25px;width:2px;background:repeating-linear-gradient(to bottom, #ddd 0px, #ddd 2px, transparent 2px, transparent 4px);z-index:0;'></div>`;
        }

        sortedHistory.forEach((h, i) => {
            // Calculate years for this business entry
            const startYear = h.year;
            const endYear = i > 0 ? sortedHistory[i - 1].year : 2025;
            const yearsActive = Math.max(1, endYear - startYear);
            const isMostRecent = i === 0;
            const yearsText = isMostRecent
                ? `${yearsActive}+ year${yearsActive !== 1 ? "s" : ""}`
                : `${yearsActive} year${yearsActive !== 1 ? "s" : ""}`;

            timelineHtml += `<div style='display:flex;flex-direction:row;align-items:center;justify-content:center;width:180px;position:relative;z-index:1;'>`;
            timelineHtml += `<span style='font-size:12px;width:50px;text-align:right;'>${h.year}</span>`;
            timelineHtml += `<span style='width:30px;display:flex;justify-content:center;align-items:center;'>`;
            timelineHtml += `<svg width='14' height='14'><circle cx='7' cy='7' r='6' fill='${typeColors[h.type] || "#888"}' stroke='#333' stroke-width='0.5'/></svg>`;
            timelineHtml += `</span>`;
            timelineHtml += `<span style='font-size:12px;width:100px;text-align:left;display:flex;flex-direction:column;'>${h.name}<span style='font-size:10px;color:#999;'>${yearsText}</span></span>`;
            timelineHtml += `</div>`;
        });
        timelineHtml += `</div>`;

        // Determine popup anchor based on screen position
        const screenPos = map.project(feature.geometry.coordinates);
        const canvasWidth = map.getCanvas().clientWidth;
        const midpoint = canvasWidth / 2;
        const anchor = screenPos.x < midpoint ? 'left' : 'right';

        activePopup = new maplibregl.Popup({
            closeButton: false,
            closeOnClick: false, // Don't close on click to allow timeline hover
            closeOnMove: false, // Don't close when map moves
            anchor: anchor,
        })
            .setLngLat(feature.geometry.coordinates)
            .setHTML(timelineHtml)
            .addTo(map);
    }

    // Fixed data update with highlight persistence
    $: if (map && geojson && sliderYear) {
        const filtered = {
            ...geojson,
            features: geojson.features.map((f) => {
                const history = Array.isArray(f.properties.history)
                    ? f.properties.history
                    : [];
                // Find all entries up to sliderYear
                const validEntries = history.filter(
                    (h) => h.year <= sliderYear,
                );
                // Get the latest entry, or null if none
                let latest = validEntries.length
                    ? validEntries.reduce((a, b) => (a.year > b.year ? a : b))
                    : null;
                return {
                    ...f,
                    properties: {
                        ...f.properties,
                        mostRecentType: latest ? latest.type : "Other",
                    },
                };
            }),
        };

        // Store current highlight before data update
        const wasHighlighted = currentlyHighlighted;

        map.getSource("businesses-points").setData(filtered);

        // Restore highlight after data update
        if (wasHighlighted && hoveredAddress === wasHighlighted) {
            // Use requestAnimationFrame to ensure data is updated
            requestAnimationFrame(() => {
                const tempHighlighted = wasHighlighted;
                currentlyHighlighted = null; // Reset to force re-highlight
                performHighlight(tempHighlighted);
            });
        }
    }

    // Update layer opacity based on enabled types filter
    $: if (
        map &&
        map.getLayer &&
        map.getLayer("businesses-points-layer") &&
        enabledTypes &&
        Object.keys(enabledTypes).length > 0
    ) {
        // Create opacity expression based on enabled types
        const opacityExpression = ["case"];

        // Add conditions for each type
        Object.entries(enabledTypes).forEach(([type, isEnabled]) => {
            opacityExpression.push(
                ["==", ["get", "mostRecentType"], type],
                isEnabled ? 1 : 0.1, // Show at 10% opacity if disabled, full opacity if enabled
            );
        });

        // Default opacity for unknown types
        opacityExpression.push(0.8);

        // Apply opacity to both fill and stroke
        map.setPaintProperty(
            "businesses-points-layer",
            "circle-opacity",
            opacityExpression,
        );
        map.setPaintProperty(
            "businesses-points-layer",
            "circle-stroke-opacity",
            opacityExpression,
        );
    }

    onMount(async () => {
        map = new maplibregl.Map({
            container: mapContainer,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [-79.40282183709127, 43.65487176137049],
            bearing: -15.5,
            zoom: 15,
            projection: "globe",
            maxPitch: 0,
            maxZoom: 20,
            minZoom: 14,
            scrollZoom: true,
            attributionControl: true,
            maxBounds: [
                [-79.5, 43.64],
                [-79.3, 43.67],
            ],
            dragRotate: false,
            touchRotate: false,
        });

        // Log initial map position
        map.on("load", () => {
            map.setZoom(15);
            console.log("Map loaded:", {
                center: map.getCenter(),
                bearing: map.getBearing()
            });
        });

        // Log map position on move
        map.on("moveend", () => {
            console.log("Map moved:", {
                center: map.getCenter(),
                bearing: map.getBearing()
            });
        });

        // Define the Kensington Market bounds
        const kmBounds = [
            [-79.408, 43.651], // Southwest corner
            [-79.398, 43.658], // Northeast corner
        ];

        // Fit to bounds on map load
        map.on("load", () => {
            // Optionally resize map if needed
            map.resize();
        });

        map.addControl(scale, "bottom-left");
        map.addControl(
            new maplibregl.NavigationControl({
                showCompass: true,
                visualizePitch: false,
            }),
            "top-right",
        );

        map.on("load", async () => {
            map.getCanvas().style.cursor = "crosshair";

            map.addSource("boundary", {
                type: "geojson",
                data: Boundary,
            });
            map.addLayer({
                id: "boundary-line",
                type: "line",
                source: "boundary",
                paint: {
                    "line-color": "#000",
                    "line-width": 1.5,
                    "line-dasharray": [1, 0],
                },
            });

            geojson = Businesses;
            map.addSource("businesses-points", {
                type: "geojson",
                data: geojson,
                generateId: true, // Important: enables feature.id for feature state
            });

            // Add mostRecentType property to each feature
            geojson.features.forEach((f) => {
                if (f.properties.history && f.properties.history.length) {
                    let latest = f.properties.history.reduce((a, b) =>
                        a.year > b.year ? a : b,
                    );
                    f.properties.mostRecentType = latest.type;
                } else {
                    f.properties.mostRecentType = "Other";
                }
            });
            map.getSource("businesses-points").setData(geojson);

            // Build match expression for MapLibre
            const colorMatch = ["match", ["get", "mostRecentType"]];
            Object.entries(typeColors).forEach(([type, color]) => {
                colorMatch.push(type, color);
            });
            colorMatch.push("#888");

            map.addLayer({
                id: "businesses-points-layer",
                type: "circle",
                source: "businesses-points",
                paint: {
                    "circle-radius": [
                        "case",
                        ["boolean", ["feature-state", "highlighted"], false],
                        8, // Larger radius for highlighted
                        ["boolean", ["feature-state", "hover"], false],
                        7, // Medium radius for hovered
                        5, // Default radius
                    ],
                    "circle-color": colorMatch,
                    "circle-stroke-width": [
                        "case",
                        ["boolean", ["feature-state", "highlighted"], false],
                        1, // Bold stroke for highlighted
                        ["boolean", ["feature-state", "hover"], false],
                        1, // Medium stroke for hovered
                        0.5, // Default stroke
                    ],
                    "circle-stroke-color": "#000",
                },
            });

            // Optimized map hover handlers
            map.on("mouseenter", "businesses-points-layer", (e) => {
                map.getCanvas().style.cursor = "pointer";
                const feature = e.features[0];
                const address = feature.properties.address;

                // Clear previous map hover state
                if (mapHoveredFeatureId !== null) {
                    map.setFeatureState(
                        {
                            source: "businesses-points",
                            id: mapHoveredFeatureId,
                        },
                        { hover: false },
                    );
                }

                // Set new hover state only if feature has an id
                if (feature.id !== undefined) {
                    mapHoveredFeatureId = feature.id;
                    map.setFeatureState(
                        { source: "businesses-points", id: feature.id },
                        { hover: true },
                    );
                }

                // Set hovered address to trigger timeline highlight
                hoveredAddress = address;
            });

            map.on("mouseleave", "businesses-points-layer", () => {
                map.getCanvas().style.cursor = "crosshair"; // Reset to crosshair, not default

                // Clear map hover state
                if (mapHoveredFeatureId !== null) {
                    map.setFeatureState(
                        {
                            source: "businesses-points",
                            id: mapHoveredFeatureId,
                        },
                        { hover: false },
                    );
                    mapHoveredFeatureId = null;
                }

                // Clear hovered address
                hoveredAddress = null;
            });
        });

        // Add global click listener to close dropdown
        document.addEventListener("click", handleClickOutside);
    });

    onDestroy(() => {
        // Clean up timeouts and map
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
        }
        if (activePopup) {
            activePopup.remove();
        }
        if (map) {
            map.remove();
        }
        // Remove global click listener
        document.removeEventListener("click", handleClickOutside);
    });
</script>

<div bind:this={mapContainer} class="map-container">
    <!-- Year dropdown positioned in top left -->
    <div class="year-dropdown-container">
        <div class="year-dropdown" class:open={isDropdownOpen}>
            <button class="year-dropdown-button" on:click={toggleDropdown}>
                <span style="font-weight: bold;">Year:</span>
                {selectedYear}
                <span class="dropdown-arrow" class:rotated={isDropdownOpen}
                    >▼</span
                >
            </button>

            {#if isDropdownOpen}
                <div class="year-dropdown-menu">
                    {#each years.slice().reverse() as year}
                        <button
                            class="year-option"
                            class:selected={year === selectedYear}
                            on:click={() => handleYearSelect(year)}
                        >
                            {year}
                        </button>
                    {/each}
                </div>
            {/if}
        </div>
    </div>
</div>

<style>
    .map-container {
        height: 100%;
        width: 100%;
        position: relative;
        right: 0;
        min-height: 350px;
        box-sizing: border-box;
    }

    .year-dropdown-container {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 1000;
        pointer-events: auto;
    }

    .year-dropdown {
        position: relative;
        display: inline-block;
    }

    .year-dropdown-button {
        background: white;
        border: 1px solid #ccc;
        padding: 4px 8px;
        font-size: 14px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        min-width: 80px;
        justify-content: space-between;
        transition: all 0.2s ease;
    }

    .year-dropdown-button:hover {
        background: #f5f5f5;
        border-color: #999;
    }

    .dropdown-arrow {
        font-size: 10px;
        transition: transform 0.2s ease;
        color: #666;
    }

    .dropdown-arrow.rotated {
        transform: rotate(180deg);
    }

    .year-dropdown-menu {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: white;
        border: 1px solid #ccc;
        border-top: none;
        max-height: 200px;
        overflow-y: auto;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        z-index: 1001;
    }

    .year-option {
        width: 100%;
        padding: 6px 8px;
        border: none;
        background: white;
        text-align: left;
        cursor: pointer;
        font-size: 14px;
        transition: background-color 0.15s ease;
    }

    .year-option:hover {
        background: #f0f0f0;
    }

    .year-option.selected {
        background: #e3f2fd;
        font-weight: bold;
    }

    .year-option.selected:hover {
        background: #bbdefb;
    }

    /* Custom scrollbar for dropdown menu */
    .year-dropdown-menu::-webkit-scrollbar {
        width: 6px;
    }

    .year-dropdown-menu::-webkit-scrollbar-track {
        background: #f1f1f1;
    }

    .year-dropdown-menu::-webkit-scrollbar-thumb {
        background: #c1c1c1;
        border-radius: 3px;
    }

    .year-dropdown-menu::-webkit-scrollbar-thumb:hover {
        background: #a8a8a8;
    }
</style>
