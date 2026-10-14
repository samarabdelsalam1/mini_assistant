#!/bin/bash
set -e

rm -f /app/tmp/pids/server.pid

# Check if gems are installed; if not, install them automatically
bundle check || bundle install

exec "$@"