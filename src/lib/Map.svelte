<script>
    import { onMount, onDestroy } from "svelte";
    import maplibregl from "maplibre-gl";
    import "../assets/maplibre-gl.css";
    import "../assets/styles.css";

    import * as pmtiles from "pmtiles";
    import BaseLayer from "../assets/kmclt.json";

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
            scrollZoom: true,
            attributionControl: true,
            // maxBounds: [
            //     [-80.0, 43.5],
            //     [-78.5, 44.0],
            // ],
        });

        //MAP INTERACTIONS
        // map.scrollZoom.disable();
        // map.boxZoom.disable();
        // map.dragRotate.disable();
        // map.dragPan.disable();
        // map.keyboard.disable();
        // map.doubleClickZoom.disable();
        // map.touchZoomRotate.disable();
        map.addControl(scale, "bottom-left");

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
        });

        //CONSOLE LOG MAP POSITION
        map.on("move", () => {
            const center = map.getCenter();
            const zoom = map.getZoom();
            const bearing = map.getBearing();
            const pitch = map.getPitch();

            console.log("Map position:", {
                center: {
                    lng: center.lng.toFixed(6),
                    lat: center.lat.toFixed(6),
                },
                zoom: zoom.toFixed(2),
                bearing: bearing.toFixed(2),
                pitch: pitch.toFixed(2),
            });
        });
    });

    onDestroy(() => {
        if (map) map.remove();
    });
</script>

<div bind:this={mapContainer} class="map-container"></div>

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
