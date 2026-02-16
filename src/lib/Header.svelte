<script>
    import socSvg from "../assets/soc.svg";
    import kmcltImage from "../assets/kmclt.png";
</script>

<header>
    <a href="https://schoolofcities.utoronto.ca/" class="logo-link" target="_blank" rel="noopener noreferrer">
        <img src={socSvg} alt="SOC" class="logo" />
    </a>
    <a href="https://kmclt.ca/" class="logo-link" target="_blank" rel="noopener noreferrer">
        <img src={kmcltImage} alt="Kensington Market" class="logo" />
    </a>
</header>

<style>
    header {
        background-color: #fff;
        padding: 0.5rem;
        border-bottom: 1px solid #cecece;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 1rem;
        position: sticky;
        top: 0;
        z-index: 9999;
    }

    .logo-link {
        display: inline-flex;
        align-items: center;
        text-decoration: none;
    }

    .logo {
        max-height: clamp(30px, 8vw, 50px);
        width: auto;
    }

    @media (max-width: 768px) {
        header {
            gap: clamp(0.5rem, 2vw, 0.75rem);
        }
    }
</style>
