// import PropertyBoundaries from "../data/km-property-boundaries.geo.json";
// import buildingInfo from "../data/kensington_data_june_2025.geo.json";
import boundary from "../data/km-boundary.geo.json";
// let MASSING_URL = "/kmclt/3DMassingContext.pmtiles";
// import KmBuildings from "../data/km-buildings.geo.json";


// SOURCES
export const sources = {

    // Massing: {
    //     type: 'vector',
    //     url: `pmtiles://${MASSING_URL}`
    // },

    //     kmBuildings: {
    //     type: "geojson",
    //     data: KmBuildings,
    // },

    // propertyBoundaries: {
    //     type: "geojson",
    //     data: PropertyBoundaries,
    // },



    boundary: {
        type: "geojson",
        data: boundary,
    },

    // buildingInfo: {
    //     type: "geojson",
    //     data: buildingInfo,
    // },

};

// LAYERS
export const layers = {

    // propertyBoundaries: {
    //     id: "property-boundaries",
    //     type: "line",
    //     source: "propertyBoundaries",
    //     paint: {
    //         "line-color": "grey",
    //         "line-width": 0,
    //         // "line-dasharray": [3, 2],
    //     },
    // },

    //     massing: {
    //     id: "massing",
    //     type: "fill",
    //     source: "Massing",
    //     "source-layer": "otherbuildings",
    //     paint: {
    //         "fill-color": "#f7f7f7",
    //         "fill-opacity": 1,
    //         "fill-outline-color": "lightgrey"
    //     },
    // }, 

    //     kmBuildings: {
    //     id: "km-buildings",
    //     type: "fill",
    //     source: "kmBuildings",
    //     paint: {
    //         "fill-color": "#f7f7f7",
    //         "fill-opacity": 1,
    //         "fill-outline-color": "lightgrey"
    //     },
    // }, 

    boundary: {
        id: "km-boundary",
        type: "line",
        source: "boundary",
        paint: {
            "line-color": "black",
            "line-width": 0,
            "line-opacity": 1,
        },
    },

    // buildingInfoLayer: {
    //     id: "building-info",
    //     type: "circle",
    //     source: "buildingInfo",
    //     paint: {
    //         "circle-radius": 5,
    //         "circle-color": [
    //             "case",
    //             ["==", ["get", "ownership"], "Corporate"], "#e74c3c",
    //             ["==", ["get", "ownership"], "Individual"], "#3498db",
    //             ["==", ["get", "ownership"], "Nonprofit"], "#2ecc71",
    //             ["==", ["get", "ownership"], "Public"], "#f39c12",
    //             "#fff" // Other/undefined - grey
    //         ],
    //         "circle-stroke-color": "#000",
    //         "circle-stroke-width": 1,
    //         "circle-opacity": 1
    //     }
    // },


    // massing: {
    //     id: "massing",
    //     type: "fill-extrusion",
    //     source: "Massing",
    //     "source-layer": "otherbuildings",
    //     paint: {
    //         "fill-extrusion-color": "white",
    //         "fill-extrusion-opacity": 0.4,
    //         "fill-extrusion-height": ["get", "height"],
    //     },
    // },

    // kmBuildings: {
    //     id: "km-buildings",
    //     type: "fill-extrusion",
    //     source: "kmBuildings",
    //     paint: {
    //         "fill-extrusion-color": "white",
    //         "fill-extrusion-opacity": 1,
    //         "fill-extrusion-height": ["get", "height"],
    //     },
    // },


};