#!/usr/bin/env bash
#shellcheck disable=SC2039

set -euo pipefail

apt-get install python3
yarn install --no-progress --frozen-lock
yarn gulp release
