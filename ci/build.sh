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

FRONTEND_CHANGES=0
COMMIT_CONTENT=$(git diff --name-only "${CI_COMMIT_RANGE}")

if grep -q "frontend" <<< "${COMMIT_CONTENT}"
then
    FRONTEND_CHANGES=1
fi

if [[ "${CI_BRANCH}" ==  "main" || "${CI_BRANCH}" ==  "develop" && "${CI_PULL_REQUEST}" !=  "true" ]];
then
    FRONTEND_CHANGES=1
fi

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

    dc -f docker-compose.yml run \
       --rm \
       --no-deps \
       frontend \
       sh release.sh

    docker build \
           --tag "${image_prefix}/frontend:latest" \
           --tag "${image_prefix}/frontend:${CI_COMMIT}" frontend

}

if [[ ${FRONTEND_CHANGES} == 1 ]];
then
    echo "================== * FRONTEND BUILD * =================="
    frontend_build
    if ! dci run -T ci ./basic.sh; then
        dci logs
        echo "Build failed when running basic.sh"
        exit 1
    fi
else
    echo "No Changes detected for frontend -- SKIP BUILD"
fi
