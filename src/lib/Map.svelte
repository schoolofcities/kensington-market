<script>
    // Packages
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "maplibre-gl/dist/maplibre-gl.css";

    import Papa from "papaparse";

    // Basemap
    import * as pmtiles from "pmtiles";
    import BaseLayer from "../data/toronto.json";
    import { sources, layers } from "$lib/mapLayers.js";

    // import MapPoints from "$lib/MapPoints.svelte";

    // Base map tiles
    let PMTILES_URL = "./toronto.pmtiles";
    let map;
    let mapContainer;

    let protoLayers = BaseLayer;
    let scale = new maplibregl.ScaleControl({
        maxWidth: 100,
        unit: "metric",
    });

    onMount(async () => {
        let protocol = new pmtiles.Protocol();
        maplibregl.addProtocol("pmtiles", protocol.tile);

        map = new maplibregl.Map({
            container: mapContainer,
            style: {
                version: 8,
                name: "Empty",
                glyphs: "https://schoolofcities.github.io/fonts/fonts/{fontstack}/{range}.pbf",
                sources: {},
                layers: [
                    {
                        id: "background",
                        type: "background",
                        paint: {
                            "background-color": "rgba(0,0,0,0)",
                        },
                    },
                ],
            },
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
        });

        map.addControl(scale, "bottom-left");
        map.addControl(
            new maplibregl.NavigationControl({
                showCompass: true,
                visualizePitch: false,
            }),
            "top-right",
        );

        function csvToGeoJSON(data) {
            return {
                type: "FeatureCollection",
                features: data.map((row) => ({
                    type: "Feature",
                    geometry: {
                        type: "Point",
                        coordinates: [
                            parseFloat(row.long) || parseFloat(row.longitude),
                            parseFloat(row.lat) || parseFloat(row.latitude),
                        ],
                    },
                    properties: row,
                })),
            };
        }

        async function addCsvPointsLayer(map) {
            const csvUrl = "/kmclt/2025_complete.csv";
            const response = await fetch(csvUrl);
            const csvText = await response.text();
            const parsed = Papa.parse(csvText, { header: true });
            const geojson = csvToGeoJSON(parsed.data);

            map.addSource("csv-points", {
                type: "geojson",
                data: geojson,
            });

            map.addLayer({
                id: "csv-points-layer",
                type: "circle",
                source: "csv-points",
                paint: {
                    "circle-radius": 3,
                    "circle-color": [
                        "match",
                        ["get", "category_original"],
                        "RETAIL",
                        "#e74c3c",
                        "FOODSTUFFS",
                        "#f1c40f",
                        "SERVICES",
                        "#3498db",
                        "SOCIAL/COMMUNITY",
                        "#2ecc71",
                        "ARTS & PERFORMANCE",
                        "#9b59b6",
                        "RESTAURANT AND BARS",
                        "#e67e22",
                        "MEDICAL",
                        "#1abc9c",
                        "OFFICES",
                        "#34495e",
                        "LODGING",
                        "#7f8c8d",
                        "RESIDENTIAL",
                        "#95a5a6",
                        /* other */ "#bdc3c7",
                    ],
                    "circle-stroke-width": 1,
                    "circle-stroke-color": "#fff",
                },
            });
        }

        map.on("load", () => {
            map.getCanvas().style.cursor = "crosshair";

            // BASE MAP STYLES
            map.addSource("protomaps", {
                type: "vector",
                url: "pmtiles://" + PMTILES_URL,
                attributionControl: false,
            });
            protoLayers.forEach((e) => {
                map.addLayer(e);
            });

            addCsvPointsLayer(map);

            // Add hover popups for csv-points-layer
            let popup;
            map.on("mousemove", "csv-points-layer", (e) => {
                // map.getCanvas().style.cursor = "pointer";
                const feature = e.features[0];
                const props = feature.properties;
                    function toTitleCaseWithAnd(str) {
                        return (str || "")
                            .toLowerCase()
                            .replace(/\b\w/g, c => c.toUpperCase())
                            .replace(/\bAnd\b/g, "and");
                    }
                    const html = `
                        <div class="popup-content">
                            <h4>${props.name || ""}</h4>
                            <div class="popup-row"><strong>Address:</strong> ${props.address || ""}</div>
                            <div class="popup-row"><strong>Category:</strong> ${toTitleCaseWithAnd(props.category_original)}</div>
                            <div class="popup-row"><strong>Subcategory:</strong> ${toTitleCaseWithAnd(props.subcategory_original)}</div>
                        </div>
                    `;
                if (popup) popup.remove();
                popup = new maplibregl.Popup({
                    closeButton: false,
                    closeOnClick: false,
                    className: "building-popup",
                })
                    .setLngLat(feature.geometry.coordinates)
                    .setHTML(html)
                    .addTo(map);
            });

            map.on("mouseleave", "csv-points-layer", () => {
                // map.getCanvas().style.cursor = "";
                if (popup) popup.remove();
                popup = null;
            });
        });
    });
</script>

<div bind:this={mapContainer} class="map-container"></div>

<style>
    .map-container {
        position: fixed;
        top: 0;
        /* left: 0; */
        right: 0;
        bottom: 0;
        width: 75vw;
        height: 100vh;
        z-index: -9999;
    }

    /* Popup styling */
    :global(.building-popup .maplibregl-popup-content) {
        padding: 0;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        border: 1px solid rgba(0, 0, 0, 0.1);
        min-width: 200px;
    }

    :global(.building-popup .maplibregl-popup-tip) {
        border-top-color: #ffffff;
    }

    :global(.popup-content) {
        padding: 12px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
            "Helvetica Neue", Arial, sans-serif;
    }

    :global(.popup-content h4) {
        margin: 0 0 0px 0;
        font-size: 14px;
        font-weight: 600;
        color: #2c3e50;
        border-bottom: 1px solid #ecf0f1;
        padding-bottom: 6px;
    }

    :global(.popup-row) {
        margin: 0px 0;
        font-size: 12px;
        line-height: 1.4;
        color: #34495e;
    }

    :global(.popup-row strong) {
        color: #2c3e50;
        font-weight: 600;
    }
</style>
