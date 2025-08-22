<script>
    import kmcltLogo from "../assets/kmclt.png";
</script>

<div class="dashboard-timeline-container">
    <div class="dashboard-timeline-title">
        Kensington Market Business Change Map
    </div>
    <a href="https://kmclt.ca/" target="_blank">
        <img src={kmcltLogo} alt="Kensington Market Logo" class="dashboard-logo" />
    </a>
</div>

<style>
    .dashboard-timeline-container {
        position: fixed;
        left: 0;
        top: 0;
        width: 30vw;
        width: 30dvw;
        /* min-width: 300px; */
        height: 100vh;
        height: 100dvh;
        background: #fff;
        border-right: 1px solid #ccc;
        /* box-shadow: 2px 0 8px rgba(0, 0, 0, 0.04); */
        /* z-index: 1000; */
        display: flex;
        flex-direction: column;
        /* align-items: flex-start; */
        /* padding: 2rem 2rem 1rem 2rem; */
        overflow: hidden;
        position: relative;
        z-index: 1000;
    }
    .dashboard-timeline-title {
        font-size: 1.5rem;
        font-weight: bold;
        color: #333;
        margin-bottom: 2rem;
        letter-spacing: 0.02em;
        padding: 10px 10px;
        border-bottom: 1px solid #ccc;
    }
    .dashboard-logo {
        position: absolute;
        padding: 5px 0 5px 5px;
        bottom: 0;
        max-height: 90px;
        right: 20px;
        height: 80px;
        object-fit: contain;
        width: calc(100% - 30px);
    }
</style>
