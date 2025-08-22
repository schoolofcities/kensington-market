// src/lib/typeColors.js

export const typeColors = {
    Grocer: "#26a69a",
    Vacant: "#cccccc",
    "Cannabis store": "#e1c542",
    "Retail": "#5dade2",
    "Take-out restaurant": "#f5b041",
    Restaurant: "#ec7063",
    "Place of worship": "rgba(86, 116, 188, 1)",
    "Service": "#e67eb7",
};

export function getColor(type) {
    return typeColors[type] || "#888";
}
