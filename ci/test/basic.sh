#!/usr/bin/env bash
#shellcheck disable=SC2039

set -euo pipefail

http_get() {
    url="${1}"
    shift
    code="${1}"
    shift
    curl --verbose --url "${url}" "$@" 2>&1 | grep "< HTTP.*${code}"
}

curl "http://localhost"
http_get "http://localhost" 200
