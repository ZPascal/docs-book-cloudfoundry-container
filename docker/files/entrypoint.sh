#!/bin/sh
set -e

# Use the workdir set by the Dockerfile ENV; fall back to the default path
WORKDIR="${DOCS_BOOK_CLOUDFOUNDRY_WORKDIR:-/tmp/docs-book-cloudfoundry}"

# Start bookbinder watch in the background
cd "$WORKDIR"
bundle exec bookbinder watch &
BOOKBINDER_PID=$!

echo "Waiting for bookbinder to start on port 4567..."
RETRIES=0
MAX_RETRIES=40
until wget -qO /dev/null http://127.0.0.1:4567 2>/dev/null; do
    RETRIES=$((RETRIES + 1))
    if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
        echo "ERROR: Bookbinder did not become ready within 120 seconds. Exiting."
        kill "$BOOKBINDER_PID" 2>/dev/null || true
        exit 1
    fi
    sleep 3
done
echo "Bookbinder is ready."

echo "Starting browser-sync proxy on port 4568 with hot reload..."
browser-sync start \
    --proxy "127.0.0.1:4567" \
    --port 4568 \
    --files "/tmp/**/*.md" "/tmp/**/*.erb" "/tmp/**/*.html" "/tmp/**/*.yml" \
    --reload-debounce 1500 \
    --reload-delay 500 \
    --no-open \
    --no-notify &
BROWSERSYNC_PID=$!

# Cleanly shut down both processes on exit
trap 'kill "$BOOKBINDER_PID" "$BROWSERSYNC_PID" 2>/dev/null || true' INT TERM EXIT

# Wait for both background processes
wait "$BOOKBINDER_PID" "$BROWSERSYNC_PID"
