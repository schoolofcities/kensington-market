import PropertyBoundaries from "../data/km-property-boundaries.geo.json";
let MASSING_URL = "./3DMassingToronto.pmtiles";

// SOURCES
export const sources = {

    Massing: {
        type: 'vector',
        url: `pmtiles://${MASSING_URL}`
    },

    propertyBoundaries: {
        type: "geojson",
        data: PropertyBoundaries,
    },
};

// LAYERS
export const layers = {

    propertyBoundaries: {
        id: "property-boundaries",
        type: "line",
        source: "propertyBoundaries",
        paint: {
            "line-color": "black",
            "line-width": 0.5,
            "line-dasharray": [3, 2],
        },
    },

        massing: {
        id: "massing",
        type: "fill-extrusion",
        source: "Massing",
        "source-layer": "3DMassingToronto",
        paint: {
            "fill-extrusion-color": "lightgray",
            "fill-extrusion-opacity": 0.7,
            "fill-extrusion-height": ["get", "height"],
        },
    },
};