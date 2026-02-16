// Differentiate between Produce, Raw foods, Dry goods, ?Supermarket.... all shades of the same color to signify common category of "Grocer"

export const typeColors = {
    "Produce": "#26a69a",
    "Raw foods": "#4dd0e1",
    "Dry goods": "#00a697",
    "Supermarket": "#00d7c2",
    "Retail": "#635ba8",
    "Cannabis store": "#e1c542",
    "Restaurant": "#e74c3c",
    "Service": "#879ed1",
    "Vacant": "#cccccc",
};

export function getColor(type) {
    return typeColors[type] || "#888";
}
