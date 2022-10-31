!#/bin/bash

set -exuo pipefail

[[ "${CI_BRANCH}" ==  "gh-pages" ]] && { echo "GH Pages update. Skip all"; exit 0; }
[[ -n "${CI_TAG:=}" ]] && { echo "Skip build"; exit 0; }

image_prefix="eu.gcr.io/akvo-lumen/terria-maps"

dc () {
    docker-compose \
        --ansi never \
        "$@"
}

dci () {
    dc -f docker-compose.ci.yml "$@"
}

frontend_build () {

    echo "PUBLIC_URL=/" > frontend/.env

    dc -f docker-compose.yml up

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
