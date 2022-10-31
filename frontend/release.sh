#!/usr/bin/env bash
#shellcheck disable=SC2039

yarn install
yarn gulp release

ls -al

#rm wwwroot/config.json
#cp /etc/config/client/config.json wwwwroot/config.json
cp /app/devserverconfig.json serverconfig.json
