// Differentiate between Produce, Raw foods, Dry goods, ?Supermarket.... all shades of the same color to signify common category of "Grocer"

export const typeColors = {
    "Grocer": "#26a69a",         // Teal (base)
    "Raw foods": "#4dd0e1",       // Light cyan
    "Retail": "#6c46eaff",
    "Cannabis store": "#e1c542",
    "Restaurant": "#e74c3c",         // Red (base)
    "Service": "#7ea1e6ff",
    "Vacant": "#cccccc",
};

export function getColor(type) {
    return typeColors[type] || "#888";
}
