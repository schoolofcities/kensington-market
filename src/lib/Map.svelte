<script>
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "maplibre-gl/dist/maplibre-gl.css";


    import * as pmtiles from "pmtiles";
    import BaseLayer from "../data/toronto.json";
    import { sources, layers } from "$lib/mapLayers.js";

    import Legend from "$lib/Legend.svelte";

    // BASE MAP TILES
    let PMTILES_URL = "./toronto.pmtiles";
    let map;

    let mapContainer;
    let protoLayers = BaseLayer;
    let scale = new maplibregl.ScaleControl({
        maxWidth: 100,
        unit: "metric",
    });

    onMount(() => {
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

        map.on("load", () => {
            map.getCanvas().style.cursor = "crosshair";

            // BASE MAP STYLES
            map.addSource("protomaps", {
                type: "vector",
                url: "pmtiles://" + PMTILES_URL,
                // attribution: attributionString,
                attributionControl: false,
            });
            protoLayers.forEach((e) => {
                map.addLayer(e);
            });

            //ADD DATA SOURCES AND LAYERS
            for (const [key, source] of Object.entries(sources)) {
                console.log(`Adding source: ${key}`, source);
                map.addSource(key, source);
            }

            for (const layer of Object.values(layers)) {
                console.log(`Adding layer: ${layer.id}`, layer);
                map.addLayer(layer);
            }

            const popup = new maplibregl.Popup({
                closeButton: false,
                closeOnClick: false,
                className: "building-popup",
            });

            map.on("mouseenter", "building-info", (e) => {

                const coordinates = e.features[0].geometry.coordinates.slice();
                const properties = e.features[0].properties;

                const address = properties.primary_ad || properties.address || "No address";
                const ownership = properties.ownership || "Unknown";
                const buildingType = properties.fcode_des || properties.building_type || "Unknown";

                const popupContent = `
                    <div class="popup-content">
                        <h4>${address}</h4>
                        <div class="popup-row">
                            <strong>Ownership:</strong> ${ownership}
                        </div>
                        <div class="popup-row">
                            <strong>Building Type:</strong> ${buildingType}
                        </div>
                    </div>
                `;

                popup.setLngLat(coordinates).setHTML(popupContent).addTo(map);
            });

            map.on("mouseleave", "building-info", () => {
                map.getCanvas().style.cursor = "crosshair";
                popup.remove();
            });
        });
    });

    onDestroy(() => {
        if (map) map.remove();
    });

    const ownershipLegend = [
        { label: "Corporate", color: "#e74c3c", type: "circle", strokeColor: "#000", size: 11 },
        { label: "Individual", color: "#3498db", type: "circle", strokeColor: "#000", size: 11 },
        { label: "Nonprofit", color: "#2ecc71", type: "circle", strokeColor: "#000", size: 11 },
        { label: "Public", color: "#f39c12", type: "circle", strokeColor: "#000", size: 11 },
        { label: "No Data", color: "#fff", type: "circle", strokeColor: "#000", size: 11 },
    ];
</script>

<div bind:this={mapContainer} class="map-container"></div>

<!-- Legend -->
<Legend
    legendItems={ownershipLegend}
    position="top-left"
/>

<style>
    .map-container {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        width: 100vw;
        height: 100vh;
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
