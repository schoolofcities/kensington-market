<script>
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "../assets/maplibre-gl.css";
    // import "../assets/styles.css";

    import * as pmtiles from "pmtiles";
    import BaseLayer from "../assets/kmclt.json";
    import { sources, layers } from "$lib/mapLayers.js";
    import ThreeDToggle from "$lib/ThreeDToggle.svelte";

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
            bearing: -16,
            projection: "globe",
            maxPitch: 85,
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

            // MOVE LABELS TO TOP
            // const allLayers = map.getStyle().layers;
            // const symbolLayers = allLayers
            //     .filter((l) => l.type === "symbol")
            //     .map((l) => l.id);

            // symbolLayers.forEach((id) => {
            //     map.moveLayer(id);
            // });
        });
    });

    onDestroy(() => {
        if (map) map.remove();
    });
</script>

<div bind:this={mapContainer} class="map-container"></div>
<ThreeDToggle {map} />

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
</style>
