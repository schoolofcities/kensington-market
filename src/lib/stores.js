// src/lib/stores.js
import { writable, derived } from 'svelte/store';

export const selectedYear = writable(2025);
export const secondYear = writable(2020);
