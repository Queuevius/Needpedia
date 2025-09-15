#!/bin/bash
set -euo pipefail

rm -f /app/tmp/pids/server.pid || true

if [ "${RAILS_ENV:-development}" != "production" ]; then
  bundle exec rails db:create db:migrate || true
fi

exec "$@"


