<script>

	import { onMount } from "svelte";
	import maplibregl from "maplibre-gl";
	
	import roads from "../../data/road-kensington.geo.json";
	import roadLabels from "../../data/road-labels-kensington.geo.json";
	import sidewalks from "../../data/sidewalk-kensington.geo.json";
	import buildings from "../../data/buildings-kensington.geo.json";
	import parcels from "../../data/parcels-kensington.geo.json";
	import marketBoundary from "../../data/kensington-4st-boundary.geo.json";
	import parks from "../../data/parks-kensington.geo.json";
	import trees from "../../data/trees-kensington.geo.json";
	
	import "../../assets/styles.css";
	
	import * as pmtiles from "pmtiles";
	import torontoStyle from "../../assets/toronto.json";
	let pmtilesToronto = "/kensington-market/toronto.pmtiles";
	
	let map;
	
	onMount(() => {
	
		let protocol = new pmtiles.Protocol();
		maplibregl.addProtocol("pmtiles", protocol.tile);
	
		map = new maplibregl.Map({
			container: "map",
			style: {
					version: 8,
					name: "Empty",
					glyphs: "https://schoolofcities.github.io/fonts/fonts/{fontstack}/{range}.pbf",
					sources: {},
					layers: [
						{
							id: "background",
							type: "background",
							paint: {
								"background-color": "#F4FFF8",
							},
						},
					],
				},
			center: [-79.40264, 43.65481], 
			zoom: 16, 
			minZoom: 15,
			maxZoom: 19,
			bearing: -15.8,
			// scrollZoom: false,
			// attributionControl: false
		});
	
		
		map.addControl(new maplibregl.ScaleControl(), "bottom-right");
		map.addControl(new maplibregl.NavigationControl(), "top-right");
		// map.addControl(new maplibregl.AttributionControl(), "bottom-right");
	
		// map.touchZoomRotate.disable();
		// map.doubleClickZoom.disable();
	
		map.on("load", function () {
	
			// map.addSource("protomaps", {
			// 	type: "vector",
			// 	url: "pmtiles://" + pmtilesToronto,
			// 	attribution: "OpenStreetMap | <a href='https://jamaps.github.io/' target='_blank'>Jeff Allen</a>, <a href='https://schoolofcities.utoronto.ca/' target='_blank'>School of Cities</a>"
			// });
	
			// torontoStyle.forEach((e) => {
			// 	map.addLayer(e);
			// });
	
	
			map.addSource("marketBoundary", {
				type: "geojson",
				data: marketBoundary,
				attribution: "<a href='https://www.openstreetmap.org/#map=17/43.65467/-79.40213' target='_blank'>OpenStreetMap</a>, <a href='https://open.toronto.ca/' target='_blank'>City of Toronto</a> | <a href='https://jamaps.github.io/' target='_blank'>Jeff Allen</a>, <a href='https://schoolofcities.utoronto.ca/' target='_blank'>School of Cities</a> | <a href='https://github.com/schoolofcities/kensington-market' target='_blank'>GitHub</a>"
			});
	
			map.addLayer({
				"id": "marketBoundary",
				"type": "fill",
				"source": "marketBoundary",
				"paint": {
					"fill-color": "#c5d7cc"
				}
			})
	
			map.addSource("parks", {
				type: "geojson",
				data: parks
			});
	
			map.addLayer({
				"id": "parks",
				"type": "fill",
				"source": "parks",
				"paint": {
					"fill-color": "#abd6ba"
				}
			})
	
	
			map.addSource("sidewalks", {
				type: "geojson",
				data: sidewalks
			});
	
			map.addLayer({
				"id": "sidewalks",
				"type": "fill",
				"source": "sidewalks",
				"paint": {
					"fill-color": "#eaedec"
				}
			})
	
			map.addSource("roads", {
				type: "geojson",
				data: roads
			});
	
			map.addLayer({
				"id": "roads",
				"type": "fill",
				"source": "roads",
				"paint": {
					"fill-color": "#cee1de"
				}
			})

			map.addSource("trees", {
				type: "geojson",
				data: trees
			});
	
			map.addLayer({
				"id": "trees",
				"type": "circle",
				"source": "trees",
				"paint": {
					"circle-color": "#0D534D",
					"circle-opacity": 0.08,
					"circle-radius": [
						'interpolate',
						['linear'],
						['zoom'],
						15,  
						5,
						19,
						30
					]
				}
			})
	
			map.addSource("buildings", {
				type: "geojson",
				data: buildings
			});
	
			map.addLayer({
				"id": "buildings",
				"type": "fill",
				"source": "buildings",
				"paint": {
					"fill-color": "#a0b1ab",
				}
			})
	
	
			map.addLayer({
				"id": "massing-layer",
				"type": "fill-extrusion",
				"source": "buildings",
				"paint": {
					"fill-extrusion-color": "#a0b1ab",
					"fill-extrusion-height": ["get", "AVG_HEIGHT"],
					"fill-extrusion-opacity": 0.15
				}
			});
	
			map.addSource("parcels", {
				type: "geojson",
				data: parcels
			});

			map.addLayer({
				"id": "parcels-fill",
				"type": "fill",
				"filter": ['all', ['!=', 'category', 'Corridor'], ['!=', 'category', 'Park']],
				"source": "parcels",
				"paint": {
					"fill-color": [
						'case',
						['==', ['get', 'category'], 'Healthcare'], '#DC4633',
						['==', ['get', 'category'], 'Condo'], '#F1C500',
						['==', ['get', 'category'], 'School'], '#8DBF2E',
						['==', ['get', 'category'], 'KMCLT'], '#00A189',
						'#fff'
					],
					"fill-opacity": [
						'case',
						['==', ['get', 'category'], 'Healthcare'], 0.2,
						['==', ['get', 'category'], 'School'], 0.2,
						['==', ['get', 'category'], 'Condo'], 0.2,
						['==', ['get', 'category'], 'KMCLT'], 0.8,
						0.01
					]
				}
			})
	
			map.addLayer({
				"id": "parcels",
				"type": "line",
				"source": "parcels",
				"filter": ['all', ['!=', 'category', 'Corridor'], ['!=', 'category', 'Park']],
				"paint": {
					"line-width": 0.5,
					"line-color": "#fff",
					"line-opacity": 1
				}
			})
	
			
	
	
	
	
			// labels
	
			map.addSource("roadLabels", {
				type: "geojson",
				data: roadLabels
			});
	
			map.addLayer({
				"id": "roadLabels",
				"type": "symbol",
				"source": "roadLabels",
				"layout": {
					"text-field": "{name}",
					"text-font": [
						"TradeGothic LT Bold"
					],
					"symbol-placement": "line",
					"text-size": 13,
					"text-anchor": "center"
				},
				"paint": {
					"text-color": "#8c999c",
					"text-halo-color": "#ffffff",
					"text-halo-blur": 1,
					"text-halo-width": 1,
				}
			})
	
			map.addLayer({
				"id": "parks-label",
				"type": "symbol",
				"source": "parks",
				"layout": {
					"text-field": "{name}",
					"text-font": [
						"TradeGothic LT Bold"
					],
					"text-size": 13,
					"text-anchor": "center"
				},
				"paint": {
					"text-color": "#3e7b53",
					"text-halo-color": "#ffffff",
					"text-halo-blur": 1,
					"text-halo-width": 1,
				}
			})
	
	
		})
	

		// popup on click
	
		map.on('click', 'parcels-fill', (e) => {
			console.log(e.features[0])
			console.log(e.lngLat)
			const coordinates = e.lngLat;
			const description = "<b>Address</b>:<br>" + e.features[0].properties.ADDRESS13 + " " + e.features[0].properties.LINEAR_15 + "<br><b>Category</b>:<br>" + e.features[0].properties.category;
	
			new maplibregl.Popup()
				.setLngLat(coordinates)
				.setHTML(description)
				.addTo(map);
		});
	
		map.on('mouseenter', 'parcels-fill', () => {
			map.getCanvas().style.cursor = 'pointer';
		});
	
		map.on('mouseleave', 'parcels-fill', () => {
			map.getCanvas().style.cursor = '';
		});
	
	})
	
</script>
	
	
	
<div id="map"></div>
	