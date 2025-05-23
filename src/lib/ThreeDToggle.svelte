<script>
    export let map;
    let is3D = false;

    function toggle3D() {
        is3D = !is3D;
        if (!map) return;

        if (map.getLayer("massing")) {
            map.setPaintProperty(
                "massing",
                "fill-extrusion-height",
                is3D ? ["get", "height"] : 0,
            );
        }
        if (map.getLayer("km-buildings")) {
            map.setPaintProperty(
                "km-buildings",
                "fill-extrusion-height",
                is3D ? ["get", "height"] : 0,
            );
        }

        if (is3D) {
            map.easeTo({ pitch: 60, duration: 800 });
        } else {
            map.easeTo({ pitch: 0, duration: 800 });
        }
    }
</script>

<button
    on:click={toggle3D}
    style="position: absolute; top: 1rem; left: 1rem; z-index: 10;"
>
    {is3D ? "Switch to 2D" : "Switch to 3D"}
</button>
