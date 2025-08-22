<script>
    import MapPoints from "./MapPoints.svelte";
    export let map;
    let geojson2025 = null;

    import { onMount } from "svelte";

    onMount(async () => {
        await fetchAndPrepare();
    });

    async function fetchAndPrepare() {
        const csvUrl = "https://docs.google.com/spreadsheets/d/1QEkdUa5BbwLp0YpTHWP7p9Yo7pQHcDB111A1c3cUkHY/edit?gid=854973006#gid=854973006";
        const res = await fetch(csvUrl);
        const csvText = await res.text();
        geojson2025 = csvToGeoJSON2025(csvText);
        updateMapPoints();
    }

    // Update map points whenever map or geojson2025 changes
    $: if (map && geojson2025) {
        updateMapPoints();
    }

    function updateMapPoints() {
        if (!map || !geojson2025) return;

        // nocategory points
        if (!map.getSource("points-nocategory")) {
            map.addSource("points-nocategory", {
                type: "geojson",
                data: {
                    type: "FeatureCollection",
                    features: geojson2025.features.filter(
                        (f) => !f.properties.category,
                    ),
                },
            });
            map.addLayer({
                id: "points-nocategory-layer",
                type: "circle",
                source: "points-nocategory",
                paint: {
                    "circle-radius": 3,
                    "circle-color": "rgba(255, 0, 0, 1)",
                    "circle-stroke-width": 2,
                    "circle-stroke-color": "rgba(255, 255, 255, 1)",
                },
            });
        } else {
            map.getSource("points-nocategory").setData({
                type: "FeatureCollection",
                features: geojson2025.features.filter(
                    (f) => !f.properties.category,
                ),
            });
        }

        // Name points
        if (!map.getSource("points-category")) {
            map.addSource("points-category", {
                type: "geojson",
                data: {
                    type: "FeatureCollection",
                    features: geojson2025.features.filter(
                        (f) => f.properties.category,
                    ),
                },
            });
            map.addLayer({
                id: "points-category-layer",
                type: "circle",
                source: "points-category",
                paint: {
                    "circle-radius": 3,
                    "circle-color": [
                        "match",
                        ["get", "category"],
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
                        /* default */ "#FF0000",
                    ],
                    "circle-stroke-width": 2,
                    "circle-stroke-color": "#fff",
                },
            });
        } else {
            map.getSource("points-category").setData({
                type: "FeatureCollection",
                features: geojson2025.features.filter(
                    (f) => f.properties.category,
                ),
            });
        }
    }

    function csvToGeoJSON2025(csvText) {
        const lines = csvText.trim().split("\n");
        const headers = lines[0].split(",");
        const geojson = {
            type: "FeatureCollection",
            features: [],
        };

        lines.slice(1).forEach((line) => {
            const values = line.split(",");
            const obj = {};
            headers.forEach((h, i) => {
                obj[h.trim()] = values[i]?.trim();
            });

            const lon = parseFloat(obj.long);
            const lat = parseFloat(obj.lat);

            if (isNaN(lat) || isNaN(lon)) return;

            geojson.features.push({
                type: "Feature",
                geometry: {
                    type: "Point",
                    coordinates: [lon, lat],
                },
                properties: {
                    name: obj[`name_2025`] || "",
                    category: obj[`category_2025`] || "",
                    sub_category: obj[`sub_category_2025`] || "",
                    long: lon,
                    lat: lat,
                },
            });
        });

        return geojson;
    }
</script>
