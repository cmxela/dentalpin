#!/bin/sh
# Points the browser at the application's own origin, where /api is routed
# to the backend, then starts the Nuxt server.
set -eu

export NUXT_PUBLIC_API_BASE_URL="${APP_URL:?APP_URL is not set by the platform}"

exec node .output/server/index.mjs
