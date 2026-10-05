#!/bin/sh
# Maps the variables Thinkube injects to the names DentalPin reads, then
# runs DentalPin's own entrypoint.
set -eu

: "${DATABASE_URL:?DATABASE_URL is not set: declare the database service in thinkube.yaml}"
case "$DATABASE_URL" in
  postgresql://*)
    # DentalPin's engine is async: SQLAlchemy needs the asyncpg dialect.
    DATABASE_URL="postgresql+asyncpg://${DATABASE_URL#postgresql://}"
    ;;
  *)
    echo "DATABASE_URL does not start with postgresql://" >&2
    exit 1
    ;;
esac
export DATABASE_URL

export SECRET_KEY="${DENTALPIN_SECRET_KEY:?DENTALPIN_SECRET_KEY is not set: add it on the Secrets page of Thinkube Control}"
export BUDGET_PUBLIC_SECRET_KEY="${DENTALPIN_BUDGET_PUBLIC_SECRET_KEY:?DENTALPIN_BUDGET_PUBLIC_SECRET_KEY is not set: add it on the Secrets page of Thinkube Control}"
export AGENDA_PUBLIC_SECRET_KEY="${DENTALPIN_AGENDA_PUBLIC_SECRET_KEY:?DENTALPIN_AGENDA_PUBLIC_SECRET_KEY is not set: add it on the Secrets page of Thinkube Control}"

# The browser reaches the API on the application's own origin.
export ALLOWED_ORIGINS="${APP_URL:?APP_URL is not set by the platform}"

exec /app/docker-entrypoint.sh "$@"
