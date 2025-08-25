// Differentiate between Produce, Raw foods, Dry goods, ?Supermarket.... all shades of the same color to signify common category of "Grocer"

export const typeColors = {
    "Produce": "#26a69a",         // Teal (base)
    "Raw foods": "#4dd0e1",       // Light cyan
    "Dry goods": "#388e3c",       // Rich green
    "Supermarket": "#00695c",     // Very dark teal
    "Retail": "#6c46eaff",
    "Vintage clothing": "#9b59b6",
    "Cannabis store": "#e1c542",
    "Restaurant": "#e74c3c",         // Red (base)
    "Take-out restaurant": "#ff7961", // Lighter red/orange shade
    "Place of worship": "rgba(214, 37, 173, 1)",
    "Service": "#7ea1e6ff",
    "Vacant": "#cccccc",
};

export function getColor(type) {
    return typeColors[type] || "#888";
}
