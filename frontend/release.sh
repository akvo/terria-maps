#!/usr/bin/env bash
#shellcheck disable=SC2039

set -euo pipefail

apk add --no-cache python3 py3-pip
yarn install --no-progress --frozen-lock
yarn gulp release
