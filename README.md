# Copernicus Data Space Ecosystem (CDSE) Utilities

This repository contains various utilities for reformatting/(pre)processing of Sentinel data published within the Copernicus Data Space Ecosystem project.

## Build a Docker container

Build the cdse_utilities Docker image:

```
docker build --no-cache https://github.com/eu-cdse/utilities.git -t cdse_utilities
```
## Important Note: Handling of the input/output directories using [Bind Mounts](https://docs.docker.com/storage/bind-mounts/) in Docker
The local storage of your computer can be attached directly to the Docker Container as a Bind Mount. Consequently, you can easily manage ingestion/outputting data directly from/to your local storage. For instance:
```
docker run -it -v /home/JohnLane:/home/ubuntu  
```
maps the content of the local home directory named /home/JohnLane to the /home/ubuntu directory in a Docker container.

## Problem with docker permission

Please click [here](https://betterstack.com/community/questions/how-to-fix-docker-got-permission-denied/) if you encounter the following error while running Docker container:
```
docker: permission denied while trying to connect to the Docker daemon socket at unix
```

## Extract a single Sentinel-1 SLC burst using Docker environment:
```
docker run -it -v /home/ubuntu:/home/ubuntu -e AWS_ACCESS_KEY_ID=YOUR_CDSE_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=YOUR_CDSE_SECRET_KEY cdse_utilities sentinel1_burst_extractor.sh -o /home/ubuntu -n S1A_IW_SLC__1SDH_20240201T085352_20240201T085422_052363_0654EE_5132.SAFE -p hh -s iw1 -r 301345
```
Please replace YOUR_CDSE_ACCESS_KEY and YOUR_CDSE_SECRET_KEY with the corresponding CDSE S3 credentials generated [here](https://eodata-s3keysmanager.dataspace.copernicus.eu/). For more information on the CDSE S3 API please click [here](https://documentation.dataspace.copernicus.eu/APIs/S3.html).

## Extract series of Sentinel-1 SLC bursts over a selected point (x=lon,y=lat) across selected dates using Docker environment:
```
docker run -it -v /home/ubuntu:/home/ubuntu -e AWS_ACCESS_KEY_ID=YOUR_CDSE_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=YOUR_CDSE_SECRET_KEY cdse_utilities sentinel1_burst_extractor_spatiotemporal.sh -o /home/ubuntu -s 2024-08-02 -e 2024-08-08 -x 13.228 -y 52.516 -p vv
```

## Convert Sentinel-1 GRD product from [GeoTIFF](https://gdal.org/drivers/raster/gtiff.html) to [COG](https://gdal.org/drivers/raster/cog.html) format 
```
docker run -it -v /home/ubuntu:/home/ubuntu cdse_utilities GRD2COG.sh -i /home/ubuntu/S1A_IW_GRDH_1SDV_20230206T165050_20230206T165115_047118_05A716_53C5.SAFE.zip -o /home/ubuntu
```

## Convert Sentinel-1 COG GRD product from [COG](https://gdal.org/drivers/raster/cog.html) to [GeoTIFF](https://gdal.org/drivers/raster/gtiff.html) format
```
docker run -it -v /home/ubuntu:/home/ubuntu cdse_utilities COG2COG.sh -i /home/ubuntu/docker_test/S1A_IW_GRDH_1SDV_20230206T165050_20230206T165115_047118_05A716_1A19_COG.SAFE.zip -o /home/ubuntu
```

## Generate a custom grid aligned to the native projection grid for use in Sentinel Hub Batch V2 API

This utility generates aligned geometries (bounding box or a pixelated AOI) following the requirements of [Sentinel Hub Batch V2 API](https://documentation.dataspace.copernicus.eu/APIs/SentinelHub/BatchV2.html) for an input AOI. It wraps the [sh-batch-grid-builder](https://pypi.org/project/sh-batch-grid-builder/) Python package.

### Script Options                                                         

```bash
-i: path to input AOI file (GeoJSON, GPKG, or other formats supported by GeoPandas)

-r: grid resolution as "(x,y)" or "x,y" in CRS coordinate units (e.g., "10,10" for 10 meters)

-p: EPSG code for the output CRS (e.g., 3035 for ETRS89 / LAEA Europe, 4326 for WGS84)

-t: output type: bounding-box or pixelated

-o: path to output file (GPKG format required)

-h: help

-v: version
```
### Usage examples
Generate aligned bounding box with same resolution for x and y:
```
docker run -it -v "$(pwd)":/home/ubuntu cdse_utilities sh_grid_builder.sh -i /home/ubuntu/aoi.geojson -r "10,10" -p 3035 -t bounding-box -o /home/ubuntu/output_bbox.gpkg
```

Generate aligned bounding box with different x and y resolutions:
```
docker run -it -v "$(pwd)":/home/ubuntu cdse_utilities sh_grid_builder.sh -i /home/ubuntu/aoi.geojson -r "(300,359)" -p 32632 -t bounding-box -o /home/ubuntu/output_bbox.gpkg
```

Generate pixelated geometry:
```
docker run -it -v "$(pwd)":/home/ubuntu cdse_utilities sh_grid_builder.sh -i /home/ubuntu/aoi.geojson -r "10,10" -p 3035 -t pixelated -o /home/ubuntu/output_pixelated.gpkg
```

Example with geographic CRS (degrees):
```
docker run -it -v "$(pwd)":/home/ubuntu cdse_utilities sh_grid_builder.sh -i /home/ubuntu/aoi.geojson -r "(0.001,0.001)" -p 4326 -t bounding-box -o /home/ubuntu/output_bbox.gpkg
```
