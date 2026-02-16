<script>
    import { typeColors } from "./typeColors.js";
    
    export let sliderYear = 2025.5;
    export let yearlyTypeCounts = {};
    export let enabledTypes = {}; // Track which types are enabled/disabled
    
    // Initialize all types as enabled
    $: if (Object.keys(enabledTypes).length === 0) {
        enabledTypes = Object.keys(typeColors).reduce((acc, type) => {
            acc[type] = true;
            return acc;
        }, {});
    }
    
    $: currentCounts = yearlyTypeCounts[Math.floor(sliderYear)] || {};
    $: baselineCounts = yearlyTypeCounts[2007] || {};
    
    function getChangeInfo(type, currentCount, baselineCount) {
        const current = currentCount || 0;
        const baseline = baselineCount || 0;
        const change = current - baseline;

        return {
            current,
            change,
            hasChange: Math.floor(sliderYear) > 2007 && change !== 0,
        };
    }
    
    function toggleType(type) {
        // Check if we're currently filtering (not all types enabled)
        const allEnabled = Object.keys(typeColors).every(t => enabledTypes[t]);
        const isCurrentlyEnabled = enabledTypes[type];
        
        if (allEnabled) {
            // First click: isolate this type
            enabledTypes = Object.keys(typeColors).reduce((acc, t) => {
                acc[t] = t === type;
                return acc;
            }, {});
        } else if (isCurrentlyEnabled) {
            // Click an enabled type: remove it from selection
            enabledTypes[type] = false;
            
            // If all are now disabled, restore all
            if (Object.keys(typeColors).every(t => !enabledTypes[t])) {
                enabledTypes = Object.keys(typeColors).reduce((acc, t) => {
                    acc[t] = true;
                    return acc;
                }, {});
            } else {
                enabledTypes = { ...enabledTypes };
            }
        } else {
            // Click a disabled type: add it to selection (multi-select)
            enabledTypes[type] = true;
            enabledTypes = { ...enabledTypes };
        }
    }
</script>

<div class="legend-section">
    <div class="legend-container">
        {#each Object.entries(typeColors) as [type, color]}
            {@const changeInfo = getChangeInfo(
                type,
                currentCounts[type],
                baselineCounts[type],
            )}
            {@const isEnabled = enabledTypes[type]}
            <div 
                class="legend-item" 
                class:disabled={!isEnabled}
                class:isolated={!isEnabled}
                on:click={() => toggleType(type)}
                role="button"
                tabindex="0"
                on:keydown={(e) => e.key === 'Enter' && toggleType(type)}
                title="Click to toggle"
            >
                <div
                    class="legend-color"
                    style="background-color: {color}; opacity: {isEnabled ? 1 : 0.3};"
                ></div>
                <span class="legend-text">
                    {type}: {changeInfo.current}
                    {#if changeInfo.hasChange}
                        <span
                            class="change-indicator"
                            class:positive={changeInfo.change > 0}
                            class:negative={changeInfo.change < 0}
                        >
                            ({changeInfo.change > 0
                                ? "+"
                                : ""}{changeInfo.change})
                        </span>
                    {/if}
                </span>
            </div>
        {/each}
    </div>
</div>

<style>
    .legend-section {
        position: static;
        width: 100%;
        min-height: 40px;
        background: #f5f5f5;
        z-index: 1002;
        overflow: hidden;
    }

    .legend-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 8px 12px;
        padding: 8px 18px;
        width: 100%;
        align-items: center;
        box-sizing: border-box;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        color: #333;
        cursor: pointer;
        padding: 4px 6px;
        border-radius: 4px;
        border: 1px solid #ddd;
    }
    
    .legend-item:hover {
        background-color: rgba(0, 0, 0, 0.08);
    }
    
    .legend-item.isolated {
        font-weight: bold;
    }
    
    .legend-item.disabled {
        opacity: 0.5;
    }

    .legend-color {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        border: 0.5px solid #000;
    }

    .change-indicator {
        font-weight: bold;
        margin-left: 2px;
    }

    .change-indicator.positive {
        color: #22c55e;
    }

    .change-indicator.negative {
        color: #ef4444;
    }

    /* Mobile responsive adjustments */
    @media (max-width: 839px) {
        .legend-container {
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 6px 10px;
            padding: 6px 15px;
        }

        .legend-item {
            font-size: 11px;
        }
    }

    /* Extra small screens */
    @media (max-width: 480px) {
        .legend-container {
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 4px 8px;
            padding: 4px 12px;
        }

        .legend-item {
            font-size: 10px;
        }
    }
</style>