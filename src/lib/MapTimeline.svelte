<script>
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "maplibre-gl/dist/maplibre-gl.css";
    import "../assets/styles.css";
    import { typeColors, getColor } from "./typeColors.js";

    let map;
    let mapContainer;

    let geojson;
    export let sliderYear = 2025;

    let scale = new maplibregl.ScaleControl({
        maxWidth: 100,
        unit: "metric",
    });

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
    }

    onMount(async () => {
        map = new maplibregl.Map({
            container: mapContainer,
            style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            center: [-79.402961, 43.654747],
            zoom: 15.3,
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

                        const buildingsResponse = await fetch(
                "/kmclt/src/data/buildings.geo.json",
            );
            const buildingsGeojson = await buildingsResponse.json();

            map.addSource("buildings", {
                type: "geojson",
                data: buildingsGeojson,
            });
            map.addLayer({
                id: "buildings-extrusion",
                type: "fill-extrusion",
                source: "buildings",
                paint: {
                    "fill-extrusion-color": "#ccc",
                    "fill-extrusion-height": ["get", "height"],
                    "fill-extrusion-base": 0,
                    "fill-extrusion-opacity": 0,
                },
            });

            const response = await fetch("/kmclt/src/data/businesses.geo.json");
            geojson = await response.json();
            map.addSource("businesses-points", {
                type: "geojson",
                data: geojson,
            });

            // Add mostRecentType property to each feature
            geojson.features.forEach((f) => {
                if (f.properties.history && f.properties.history.length) {
                    // Find the latest year
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
            colorMatch.push("#888"); // default color

            map.addLayer({
                id: "businesses-points-layer",
                type: "circle",
                source: "businesses-points",
                paint: {
                    "circle-radius": 6,
                    "circle-color": colorMatch,
                    "circle-stroke-width": 1,
                    "circle-stroke-color": "#000",
                },
            });

            // Add hover popup for vertical timeline
            let activePopup = null;
            map.on("mouseenter", "businesses-points-layer", (e) => {
                map.getCanvas().style.cursor = "pointer";
                const feature = e.features[0];
                const { address, history } = feature.properties;
                let sortedHistory = [];
                try {
                    sortedHistory = JSON.parse(history);
                } catch {
                    sortedHistory = history;
                }
                if (!Array.isArray(sortedHistory)) sortedHistory = [];
                sortedHistory = [...sortedHistory].sort(
                    (a, b) => b.year - a.year,
                );
                // Build vertical timeline HTML
                let timelineHtml = `<div style='font-weight:bold;margin-bottom:4px;text-align:center;'>${address}</div><div style='display:flex;flex-direction:column;align-items:center;'>`;
                sortedHistory.forEach((h, i) => {
                    timelineHtml += `<div style='display:flex;flex-direction:row;align-items:center;justify-content:center;width:180px;'>`;
                    timelineHtml += `<span style='font-size:12px;width:50px;text-align:right;'>${h.year}</span>`;
                    timelineHtml += `<span style='width:30px;display:flex;justify-content:center;align-items:center;'>`;
                    timelineHtml += `<svg width='14' height='14'><circle cx='7' cy='7' r='6' fill='${typeColors[h.type] || "#888"}' stroke='#333' stroke-width='1'/></svg>`;
                    timelineHtml += `</span>`;
                    timelineHtml += `<span style='font-size:12px;width:100px;text-align:left;display:flex;flex-direction:column;'>${h.name}<span style='font-size:10px;color:#888;'>${h.type}${h.subtype ? " – " + h.subtype : ""}</span></span>`;
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
                if (activePopup) activePopup.remove();
                activePopup = new maplibregl.Popup({
                    closeButton: false,
                    closeOnClick: true,
                })
                    .setLngLat(feature.geometry.coordinates)
                    .setHTML(timelineHtml)
                    .addTo(map);
            });

            map.on("mouseleave", "businesses-points-layer", () => {
                map.getCanvas().style.cursor = "";
                if (activePopup) {
                    activePopup.remove();
                    activePopup = null;
                }
            });
        });
    });
</script>

<div bind:this={mapContainer} class="map-container"></div>

<style>
    .map-container {
        height: 70vh;
        height: 70dvh;
        width: 80vw;
        width: 80dvw;
        position: fixed;
        right: 0;
        border: 1px solid #ccc;
    }
</style>
