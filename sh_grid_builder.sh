#!/bin/bash
# Example of usage
#./sh_grid_builder.sh -i data/aoi.geojson -r "10,10" -p 3035 -t bounding-box -o output_bbox.gpkg
#./sh_grid_builder.sh -i data/aoi.geojson -r "(300,359)" -p 32632 -t pixelated -o output_pixelated.gpkg
#developed by Maxim Lamare (2026)
###############################
version="0.2.2"
usage()
{
cat << EOF
#usage: $0 options
This utility generates projection grid aligned bounding boxes and pixelated geometries
from AOI (Area of Interest) files for Sentinel Hub Batch V2 API on CDSE.
It wraps the sh-batch-grid-builder Python package.

OPTIONS:
   -p      EPSG code for the output CRS (e.g., 3035 for ETRS89 / LAEA Europe, 4326 for WGS84)
   -h      help message
   -i      path to input AOI file (GeoJSON, GPKG, or other formats supported by GeoPandas)
   -o      path to output file (GPKG format required)
   -r      grid resolution as "(x,y)" or "x,y" in CRS coordinate units (e.g., "10,10" for 10 meters)
   -t      output type: bounding-box or pixelated
   -v      version

EXAMPLES:
   # Generate aligned bounding box with same resolution for x and y
   $0 -i aoi.geojson -r "10,10" -p 3035 -t bounding-box -o output_bbox.gpkg

   # Generate aligned bounding box with different x and y resolutions
   $0 -i aoi.geojson -r "(300,359)" -p 32632 -t bounding-box -o output_bbox.gpkg

   # Generate pixelated geometry
   $0 -i aoi.geojson -r "10,10" -p 3035 -t pixelated -o output_pixelated.gpkg

   # Example with geographic CRS (degrees)
   $0 -i aoi.geojson -r "(0.001,0.001)" -p 4326 -t bounding-box -o output_bbox.gpkg

EOF
}

while getopts "hp:i:o:r:t:v" OPTION; do
	case $OPTION in
		p)
			epsg=$OPTARG
			;;
		h)
			usage
			exit 0
			;;
		i)
			input_aoi=$OPTARG
			;;
		o)
			output=$OPTARG
			;;
		r)
			resolution=$OPTARG
			;;
		t)
			output_type=$OPTARG
			;;
		v)
			echo sh_grid_builder version $version
			exit 0
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $(which sh-grid-builder) ]; then
	echo "ERROR: sh-grid-builder not found. Please install it: pip install sh-batch-grid-builder" && exit 2
fi

if [ -z "$input_aoi" ]; then
	echo "ERROR: Input AOI file not specified" && exit 3
fi

if [ ! -f "$input_aoi" ]; then
	echo "ERROR: Input AOI file '$input_aoi' does not exist" && exit 4
fi

if [ -z "$resolution" ]; then
	echo "ERROR: Resolution not specified" && exit 3
fi

if [ -z "$epsg" ]; then
	echo "ERROR: EPSG code not specified" && exit 3
fi

if [ -z "$output_type" ]; then
	echo "ERROR: Output type not specified" && exit 3
fi

if [ "$output_type" != "bounding-box" -a "$output_type" != "pixelated" ]; then
	echo "ERROR: Output type '$output_type' not valid. Must be 'bounding-box' or 'pixelated'" && exit 3
fi

if [ -z "$output" ]; then
	echo "ERROR: Output file not specified" && exit 3
fi

sh-grid-builder "$input_aoi" --resolution "$resolution" --epsg $epsg --output-type $output_type -o "$output"
