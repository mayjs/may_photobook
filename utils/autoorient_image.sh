#!/usr/bin/env bash

rotation=$(exiftool -Orientation -n "$1" | tr -d -c 0-9)
rotationnumber=${rotation:-1} # Default orientation is 1
if [ $rotationnumber -ne 1 ]; then
	echo "Fixing orientation for '$1'"
	mogrify -auto-orient $1
fi
