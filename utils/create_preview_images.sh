#!/usr/bin/env bash

cd images || exit
# Copy directory structure from images to images_preview
find . -type d -exec mkdir -p ../images_preview/{} ';'
# Create thumbnails for jpg images
find . -type f -name "*.jpg" -print0 | parallel -0 epeg --max=600 {} ../images_preview/{}
# Copy all other files as-is
find . -type f -exec cp -u {} ../images_preview/{} ';'
