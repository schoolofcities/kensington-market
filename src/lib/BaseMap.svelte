<script>
  import { onMount } from 'svelte';
  import maplibregl from 'maplibre-gl';
  import * as pmtiles from 'pmtiles';
  import { layers, namedFlavor } from '@protomaps/basemaps';

  import 'maplibre-gl/dist/maplibre-gl.css';

  let map;
  let mapContainer;

  // Point to your local or remote .pmtiles file
  const pmtilesURL = './toronto.pmtiles';

  onMount(() => {
    // Register PMTiles protocol
    const protocol = new pmtiles.Protocol();
    maplibregl.addProtocol('pmtiles', protocol.tile);

    // Initialize the map
    map = new maplibregl.Map({
      container: mapContainer,
      style: {
        version: 8,
        glyphs: "https://protomaps.github.io/basemaps-assets/fonts/{fontstack}/{range}.pbf",
        sources: {
          protomaps: {
            type: 'vector',
            url: `pmtiles://${pmtilesURL}`,
            attribution:
              '<a href="https://protomaps.com">Protomaps</a> © <a href="https://openstreetmap.org">OpenStreetMap</a>',
          },
        },
        layers: layers('protomaps', namedFlavor('light'), { lang: 'en' }),
      },
      center: [-79.402961, 43.654747],
      zoom: 14,
      pitch: 0,
      bearing: 0,
      projection: 'globe'
    });

    return () => map.remove();
  });
</script>

<div bind:this={mapContainer} class="map-container" style="height: 100vh;" />
