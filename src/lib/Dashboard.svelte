<script>
    const legendItems = [
        { label: "Retail", color: "#e74c3c" },
        { label: "Foodstuffs", color: "#f1c40f" },
        { label: "Services", color: "#3498db" },
        { label: "Social/Community", color: "#2ecc71" },
        { label: "Arts & Performance", color: "#9b59b6" },
        { label: "Restaurant and Bars", color: "#e67e22" },
        { label: "Medical", color: "#1abc9c" },
        { label: "Offices", color: "#34495e" },
        { label: "Lodging", color: "#7f8c8d" },
        { label: "Residential", color: "#95a5a6" },
        { label: "Other", color: "#bdc3c7" },
    ];
</script>

<div class="dashboard-container">
    <div class="dashboard-title">Kensington Market Businesses Map</div>
    <div class="dashboard-legend">
        <div class="legend-title">Uses</div>
        <div class="legend-items">
            {#each legendItems as item}
                <div class="legend-item">
                    <span class="legend-color" style="background: {item.color}"
                    ></span>
                    <span class="legend-label">{item.label}</span>
                </div>
            {/each}
        </div>
    </div>
</div>

<style>
    .dashboard-container {
        background: rgb(255, 255, 255);
        height: 100dvh;
        height: 100vh;
        color: white;
        font-family: Arial, sans-serif;
        position: fixed;
        bottom: 0;
        left: 0;
        width: 25vw;
        border-right: 1px solid #ccc;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        justify-content: flex-start;
    }
    .dashboard-title {
        font-size: 2rem;
        color: #333;
        /* text-align: center; */
        margin-top: 0.5rem;
        padding: 1rem 1.5rem;
    }
    .dashboard-legend {
        left: 0;
        margin-top: 1rem;
        padding: 1rem 1.5rem;
        color: #333;
        /* min-width: 260px;
        max-width: 400px; */
    }
    .legend-title {
        font-size: 1.2rem;
        font-weight: bold;
        margin-bottom: 1rem;
        text-align: left;
    }
    .legend-items {
        /* display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 0.5rem 3rem; */
    }
    .legend-item {
        display: flex;
        align-items: center;
        margin-bottom: 1rem;
        /* border: 1px solid #ddd; */
    }
    .legend-color {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        display: inline-block;
        margin-right: 0.5rem;
        border: 2px solid #fff;
    }
    .legend-label {
        font-size: 12px;
    }
</style>
