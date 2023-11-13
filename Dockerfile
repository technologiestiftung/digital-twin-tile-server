FROM golang:1.19.5-bullseye as builder

# SHELL ["/bin/bash", "--login", "-c"]

ARG TIPPICANOE_TAG=1.36.0
# ARG NODE_VERSION=v18.3.0
# ARG GDAL_VERSION=3.2.2+dfsg-2+deb11u1
# ARG PYTHON3_GDAL_VERSION=3.2.2+dfsg-2+deb11u1
ARG TILESET_DIR=/tileset
ARG TMP_DIR=/tmp

ENV WORK_DIR /usr/app
# ENV NODE_VERSION $NODE_VERSION


RUN apt-get update -yq && apt-get install -yq \
	ca-certificates \
	openssl \
	curl \
	jq \
	zip \
	awscli \
	unzip \
	git \
	build-essential \
	libsqlite3-dev \
	zlib1g-dev \
	gnupg \
	gdal-bin \
	bash

WORKDIR ${WORK_DIR}
RUN mkdir -p json
RUN git clone --depth 1 --branch ${TIPPICANOE_TAG} https://github.com/mapbox/tippecanoe.git && \
	cd tippecanoe && \
	make -j && \
	make install && \
	cd .. && \
	rm -rf tippecanoe

COPY shp shp
RUN ogr2ogr --debug ON  -f "GeoJSON" -s_srs EPSG:25833 -t_srs EPSG:4326 json/output.geojson shp/Gebaeude_Bauteile_Flaechen.shp
RUN tippecanoe --output-to-directory /tiles '--use-attribute-for-id=id' --layer 'alkis' --no-tile-compression --force -B 13 '--minimum-zoom=10' '--maximum-zoom=17' json/output.geojson

# Start a new stage for Nginx
FROM nginx:1.25-alpine-slim

# Copy 'tiles' directory from builder stage to Nginx html directory
COPY --from=builder /tiles /usr/share/nginx/html/tiles
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# COPY demo/index.html /usr/share/nginx/html/demo/index.html
# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]