import PropertyBoundaries from "../data/km-property-boundaries.geo.json";
import KmBuildings from "../data/km-buildings.geo.json";
let MASSING_URL = "./3DMassingContext.pmtiles";

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

    kmBuildings: {
        type: "geojson",
        data: KmBuildings,
    },

};

// LAYERS
export const layers = {

    propertyBoundaries: {
        id: "property-boundaries",
        type: "line",
        source: "propertyBoundaries",
        paint: {
            "line-color": "grey",
            "line-width": 0.1,
            // "line-dasharray": [3, 2],
        },
    },

    massing: {
        id: "massing",
        type: "fill-extrusion",
        source: "Massing",
        "source-layer": "otherbuildings",
        paint: {
            "fill-extrusion-color": "white",
            "fill-extrusion-opacity": 0.5,
            "fill-extrusion-height": ["get", "height"],
        },
    },

    kmBuildings: {
        id: "km-buildings",
        type: "fill-extrusion",
        source: "kmBuildings",
        paint: {
            "fill-extrusion-color": [
                "match",
                ["get", "Class_name"],
                "Neighbourhoods", "#1f77b4",
                "MixedUse", "#ff7f0e",
                "Institutional", "#2ca02c",
            /* other */ "#000000"
            ],
            "fill-extrusion-opacity": 0.7,
            "fill-extrusion-height": ["get", "height"],
        },
    },
};