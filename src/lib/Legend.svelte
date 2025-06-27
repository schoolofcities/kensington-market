<script>
    export let legendItems = [];
    export let position = "top-left";
</script>

<div class="legend-container {position}">
    <div class="legend">
        <div class="legend-items">
            {#each legendItems as item}
                <div class="legend-item">                <div 
                    class="legend-symbol {item.type || 'circle'}" 
                    style="background-color: {item.color}; border-color: {item.strokeColor || '#ffffff'}; width: {item.size || 12}px; height: {item.size || 12}px;"
                ></div>
                    <span class="legend-label">{item.label}</span>
                </div>
            {/each}
        </div>
    </div>
</div>

<style>
    .legend-container {
        position: absolute;
        pointer-events: none;
        z-index: 1000;
        max-width: 200px;
    }

    .legend-container.top-left {
        top: 20px;
        left: 20px;
    }

    .legend-container.top-right {
        top: 10px;
        right: 10px;
    }

    .legend-container.bottom-left {
        bottom: 10px;
        left: 10px;
    }

    .legend-container.bottom-right {
        bottom: 40px;
        right: 10px;
    }

    .legend {
        background: rgba(255, 255, 255, 0.95);
        border-radius: 6px;
        padding: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        font-size: 12px;
        line-height: 1.4;
        pointer-events: auto;
        backdrop-filter: blur(4px);
        border: 1px solid rgba(0, 0, 0, 0.1);
    }

    .legend-title {
        margin: 0 0 8px 0;
        font-size: 13px;
        font-weight: 600;
        color: #333;
    }

    .legend-items {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .legend-symbol {
        width: 12px;
        height: 12px;
        flex-shrink: 0;
        border-radius: 50%;
        border: 1px solid #ffffff;
    }

    .legend-symbol.circle {
        border-radius: 50%;
    }

    .legend-symbol.square {
        border-radius: 2px;
    }

    .legend-symbol.line {
        height: 3px;
        border-radius: 1px;
        border: none;
    }

    .legend-label {
        color: #444;
        font-size: 11px;
        font-weight: 500;
    }


</style>
