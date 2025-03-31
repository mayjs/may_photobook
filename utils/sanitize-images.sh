#!/usr/bin/env bash

find images -type f | parallel "$(dirname "${BASH_SOURCE[0]}")"/autoorient_image.sh "{}"
