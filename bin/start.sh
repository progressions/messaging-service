#!/usr/bin/env bash
set -e

export RAILS_ENV="${RAILS_ENV:-development}"
export PORT="${PORT:-8080}"

echo "Starting Rails (env: ${RAILS_ENV}) on port ${PORT}..."
exec bundle exec rails s -p "${PORT}" -b 0.0.0.0
