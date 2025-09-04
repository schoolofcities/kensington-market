<script>

    //add current year in top left of map

    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "maplibre-gl/dist/maplibre-gl.css";
    import "../assets/styles.css";
    import { typeColors, getColor } from "./typeColors.js";
    import Businesses from "../data/businesses.geo.json";
    import Boundary from "../data/km-boundary.geo.json";

    let map;
    let mapContainer;

    let geojson = Businesses;
    export let sliderYear = 2025;
    export let hoveredAddress = null; // Bind to parent's hover state

    let scale = new maplibregl.ScaleControl({
        maxWidth: 100,
        unit: "metric",
    });

    let activePopup = null;
    let currentlyHighlighted = null; // Cache currently highlighted address
    let mapHoveredFeatureId = null; // Track map hover state
    let hoverTimeout = null; // Debounce hover operations

    // Watch for hover changes from timeline with optimization
    $: if (map && hoveredAddress !== currentlyHighlighted) {
        if (hoveredAddress) {
            highlightMapPoint(hoveredAddress);
        } else {
            clearMapHighlight();
        }
    }

    function highlightMapPoint(address) {
        // Clear any pending hover timeout
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
        }

        // Debounce the highlight operation
        hoverTimeout = setTimeout(() => {
            if (!map || currentlyHighlighted === address) return;
            
            // Clear previous highlight first
            clearMapHighlight();
            
            // Find the feature with matching address
            const feature = geojson.features.find(f => f.properties.address === address);
            if (!feature) return;

            currentlyHighlighted = address;

            // Use feature-state based highlighting for better performance
            const matchingFeatures = map.querySourceFeatures('businesses-points', {
                filter: ['==', ['get', 'address'], address]
            });

            if (matchingFeatures.length > 0) {
                const featureId = matchingFeatures[0].id;
                if (featureId !== undefined) {
                    map.setFeatureState(
                        { source: 'businesses-points', id: featureId },
                        { highlighted: true }
                    );
                }
            }

            // Show popup for the hovered address
            showPopupForAddress(address);
        }, 50); // Small debounce delay
    }

    function clearMapHighlight() {
        if (!map) return;
        
        // Clear any pending hover timeout
        if (hoverTimeout) {
            clearTimeout(hoverTimeout);
            hoverTimeout = null;
        }
        
        // Clear feature state for previously highlighted feature
        if (currentlyHighlighted) {
            const matchingFeatures = map.querySourceFeatures('businesses-points', {
                filter: ['==', ['get', 'address'], currentlyHighlighted]
            });

            if (matchingFeatures.length > 0) {
                const featureId = matchingFeatures[0].id;
                if (featureId !== undefined) {
                    map.setFeatureState(
                        { source: 'businesses-points', id: featureId },
                        { highlighted: false }
                    );
                }
            }
        }
        
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

        const feature = geojson.features.find(f => f.properties.address === address);
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
        let timelineHtml = `<div style='font-weight:bold;margin-bottom:4px;text-align:center;'>${address}</div><div style='display:flex;flex-direction:column;align-items:center;'>`;
        sortedHistory.forEach((h, i) => {
            timelineHtml += `<div style='display:flex;flex-direction:row;align-items:center;justify-content:center;width:180px;'>`;
            timelineHtml += `<span style='font-size:12px;width:50px;text-align:right;'>${h.year}</span>`;
            timelineHtml += `<span style='width:30px;display:flex;justify-content:center;align-items:center;'>`;
            timelineHtml += `<svg width='14' height='14'><circle cx='7' cy='7' r='6' fill='${typeColors[h.type] || "#888"}' stroke='#333' stroke-width='0.5'/></svg>`;
            timelineHtml += `</span>`;
            timelineHtml += `<span style='font-size:12px;width:100px;text-align:left;display:flex;flex-direction:column;'>${h.name}<span style='font-size:10px;color:#888;'>${h.type}${h.subtype ? " — " + h.subtype : ""}</span></span>`;
            timelineHtml += `</div>`;
            if (i < sortedHistory.length - 1) {
                timelineHtml += `<div style='height:16px;display:flex;flex-direction:row;align-items:center;justify-content:center;width:180px;'>`;
                timelineHtml += `<span style='width:50px;'></span>`;
                timelineHtml += `<span style='width:30px;display:flex;justify-content:center;align-items:center;'>`;
                timelineHtml += `<svg width='2' height='16'><line x1='1' y1='0' x2='1' y2='16' stroke='#888' stroke-width='2' stroke-dasharray='2,2'/></svg>`;
                timelineHtml += `</span>`;
                timelineHtml += `<span style='width:100px;'></span>`;
                timelineHtml += `</div>`;
            }
        });
        timelineHtml += `</div>`;

        activePopup = new maplibregl.Popup({
            closeButton: false,
            closeOnClick: false, // Don't close on click to allow timeline hover
            closeOnMove: false,   // Don't close when map moves
        })
            .setLngLat(feature.geometry.coordinates)
            .setHTML(timelineHtml)
            .addTo(map);
    }

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
        map.getSource("businesses-points").setData(filtered);
        
        // Maintain highlight after data update if there's a hovered address
        if (currentlyHighlighted && hoveredAddress === currentlyHighlighted) {
            // Re-highlight after a brief delay to ensure the data is updated
            setTimeout(() => {
                if (currentlyHighlighted) {
                    const tempHighlighted = currentlyHighlighted;
                    currentlyHighlighted = null; // Reset to force re-highlight
                    highlightMapPoint(tempHighlighted);
                }
            }, 100);
        }
    }

    onMount(async () => {
        map = new maplibregl.Map({
            container: mapContainer,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [-79.402961, 43.654747],
            zoom: 16,
            bearing: -15.5,
            projection: "globe",
            maxPitch: 0,
            scrollZoom: true,
            attributionControl: true,
            maxBounds: [
                [-79.412961, 43.644747],
                [-79.392961, 43.664747],
            ],
            dragRotate: false,
            touchRotate: false,
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
                    "line-color": "#666",
                    "line-width": 1,
                    "line-dasharray": [2, 0],
                },
            });

            geojson = Businesses;
            map.addSource("businesses-points", {
                type: "geojson",
                data: geojson,
                generateId: true // Important: enables feature.id for feature state
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
                        5  // Default radius
                    ],
                    "circle-color": colorMatch,
                    "circle-stroke-width": [
                        "case",
                        ["boolean", ["feature-state", "highlighted"], false],
                        3, // Bold stroke for highlighted
                        ["boolean", ["feature-state", "hover"], false],
                        2, // Medium stroke for hovered
                        0.5 // Default stroke
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
                        { source: 'businesses-points', id: mapHoveredFeatureId },
                        { hover: false }
                    );
                }
                
                // Set new hover state only if feature has an id
                if (feature.id !== undefined) {
                    mapHoveredFeatureId = feature.id;
                    map.setFeatureState(
                        { source: 'businesses-points', id: feature.id },
                        { hover: true }
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
                        { source: 'businesses-points', id: mapHoveredFeatureId },
                        { hover: false }
                    );
                    mapHoveredFeatureId = null;
                }
                
                // Clear hovered address
                hoveredAddress = null;
            });
        });
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
    });
</script>

<div bind:this={mapContainer} class="map-container">
    <!-- Year label positioned in top left -->
    <div class="year-label">
        <span style="font-weight: bold;">Year:</span> {Math.floor(sliderYear)}
    </div>
</div>

<style>
    .map-container {
        height: 100%;
        width: 100%;
        position: relative;
        right: 0;
        border-left: 1px solid #000;
    }
    
    .year-label {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 1000;
        background: white;
        padding: 4px 8px;
        font-size: 14px;
        border: 1px solid #ccc;
        pointer-events: none; /* Allows map interactions through the label */
    }
</style>