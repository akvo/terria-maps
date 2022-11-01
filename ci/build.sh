#!/bin/bash

set -exuo pipefail

[[ "${CI_BRANCH}" ==  "gh-pages" ]] && { echo "GH Pages update. Skip all"; exit 0; }
[[ -n "${CI_TAG:=}" ]] && { echo "Skip build"; exit 0; }

image_prefix="eu.gcr.io/akvo-lumen/terria-maps"

docker build --rm=false \
       --tag "${image_prefix}/frontend:latest" \
       --tag "${image_prefix}/frontend:${CI_COMMIT}" frontend
