<script>
    import Header from "$lib/Header.svelte";
</script>

<Header />

<slot />

<style>
    :global(body) {
        margin: 0;
        padding: 0;
    }
</style>
