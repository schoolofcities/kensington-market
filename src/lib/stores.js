// src/lib/stores.js
import { writable, derived } from 'svelte/store';

export const selectedYear = writable(2025);
export const secondYear = writable(2020);

// export const visibleCategories = writable(new Set(['Category A', 'Category B']));
// export const swipingEnabled = writable(false);
