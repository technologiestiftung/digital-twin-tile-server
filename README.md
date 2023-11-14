# Digital Twin Tile Server

Super basic tile server for .pbf tiles. Using nginx as server.

## Prerequisites

- Docker
- Docker Hub Account
- Mapbox Account and token

## Build

```bash
# Enable buildx
docker buildx create --use
# Building for multiple platforms
# Pushes directly to docker hub
 docker buildx build --platform linux/amd64,linux/arm64 --push -t technologiestiftung/digital-twin-tile-server .
```

## Usage

```bash
 docker run --rm -p 8080:80  technologiestiftung/digital-twin-tile-server
```

In your html page

```html
<!DOCTYPE html>
<html>
	<head>
		<title>Mapbox GL JS</title>
		<meta charset="utf-8" />
		<meta
			name="viewport"
			content="initial-scale=1,maximum-scale=1,user-scalable=no"
		/>
		<script src="https://api.mapbox.com/mapbox-gl-js/v3.0.0-beta.1/mapbox-gl.js"></script>
		<link
			href="https://api.mapbox.com/mapbox-gl-js/v3.0.0-beta.1/mapbox-gl.css"
			rel="stylesheet"
		/>
		<style>
			body {
				margin: 0;
				padding: 0;
			}
			#map {
				position: absolute;
				top: 0;
				bottom: 0;
				width: 100%;
			}
		</style>
	</head>
	<body>
		<div id="map"></div>
		<script>
			mapboxgl.accessToken = "YOUR MAPBOX TOKEN";
			const map = new mapboxgl.Map({
				container: "map",
				style: "mapbox://styles/mapbox/streets-v11",
				center: [13.405, 52.52],
				zoom: 16,
			});

			map.on("load", function () {
				map.addSource("alkis", {
					type: "vector",
					tiles: [`${"http://localhost:8080"}/tiles/{z}/{x}/{y}.pbf`],
					minzoom: 15,
					maxzoom: 17,
					promoteId: "UUID",
				});

				map.addLayer({
					id: "building-floors",
					type: "fill",
					source: "alkis",
					"source-layer": "alkis",
					paint: {
						"fill-color": "#088",
						"fill-opacity": 1,
					},
				});
			});
			map.on("sourcedata", function (e) {
				console.log("Source data:", e);
				if (e.sourceId === "alkis" && map.isSourceLoaded("alkis")) {
					var features = map.querySourceFeatures("alkis");
					console.log("Is source loaded:", map.isSourceLoaded("alkis"));
					console.log("Loaded features:", features);
					var features = map.querySourceFeatures("alkis");
					console.log("Features:", features);
					var tileData = map.getSource("alkis")._tiles;
					console.log("Tile data:", tileData);
				}
			});

			map.on("error", function (e) {
				console.error("Map error", e.error);
			});
		</script>
	</body>
</html>
```

## Development

Download the "ALKIS Berlin Gebäude" from the FIS Broker https://fbinter.stadt-berlin.de/fb/index.jsp
Direkt link https://datenbox.stadt-berlin.de/filr/public-link/file-download/8a8ae3ab7d6bf5e5017e2f19c3fc5dc2/14254/8799702476865788292/SHP_BE_ALKIS.7z and extract it.

Copy flowing files from the archive to your `/shp` folder

```plain
Gebaeude_Bauteile_Flaechen.cpg
Gebaeude_Bauteile_Flaechen.dbf
Gebaeude_Bauteile_Flaechen.prj
Gebaeude_Bauteile_Flaechen.sbn
Gebaeude_Bauteile_Flaechen.sbx
Gebaeude_Bauteile_Flaechen.shp
Gebaeude_Bauteile_Flaechen.shp.xml
Gebaeude_Bauteile_Flaechen.shx
```

Build the image

```bash
 docker build -t technologiestiftung/digital-twin-tile-server .
```

Run the image

```bash
 docker run --rm -p 8080:80  technologiestiftung/digital-twin-tile-server
```

## Gotchas

- When building the tiles with tippicanoe you need to name the layer using the `--layer` flag. This is the name that has to be used as `source-layer` value when adding the layer with Mapbox.
- Never forget CORS headers

## Todo

- [ ] Download/extract/discard shapefiles in Docker build stage
- [ ] Build on CI
- [ ] Research better ways to serve the tiles then nginx
- [ ] tbd
