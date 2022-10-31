#!/usr/bin/env bash
#shellcheck disable=SC2039

yarn install
yarn gulp release

ls -al

#rm wwwroot/config.json
#cp /etc/config/client/config.json wwwwroot/config.json
cp /app/devserverconfig.json serverconfig.json
export NODE_ENV=production
node ./node_modules/terriajs-server/lib/app.js --config-file serverconfig.json

ls -al
