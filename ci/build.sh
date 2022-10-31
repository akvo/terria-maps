!#/bin/bash

set -exuo pipefail

[[ "${CI_BRANCH}" ==  "gh-pages" ]] && { echo "GH Pages update. Skip all"; exit 0; }
[[ -n "${CI_TAG:=}" ]] && { echo "Skip build"; exit 0; }

## RESTORE IMAGE CACHE
IMAGE_CACHE_LIST=$(grep image ./docker-compose.yml \
    | sort -u | sed 's/image\://g' \
    | sed 's/^ *//g')
mkdir -p ./ci/images

while IFS= read -r IMAGE_CACHE; do
    IMAGE_CACHE_LOC="./ci/images/${IMAGE_CACHE//\//-}.tar"
    if [ -f "${IMAGE_CACHE_LOC}" ]; then
        docker load -i "${IMAGE_CACHE_LOC}"
    fi
done <<< "${IMAGE_CACHE_LIST}"

image_prefix="eu.gcr.io/akvo-lumen/terria-maps"

dci () {
    dc -f docker-compose.ci.yml "$@"
}

frontend_build () {

    docker build \
           --tag "${image_prefix}/frontend:latest" \
           --tag "${image_prefix}/frontend:${CI_COMMIT}" frontend

}

frontend_build
if ! dci run -T ci ./basic.sh; then
    dci logs
    echo "Build failed when running basic.sh"
    exit 1
fi
