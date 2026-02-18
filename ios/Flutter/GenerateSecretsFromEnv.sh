#!/bin/sh
set -e

ENV_FILE="$SRCROOT/../.env"
OUTPUT_FILE="$SRCROOT/Flutter/Secrets.xcconfig"

if [ -f "$ENV_FILE" ]; then
  MAPBOX_PUBLIC_KEY=$(grep -E '^MAPBOX_PUBLIC_KEY=' "$ENV_FILE" | tail -n 1 | sed -E 's/^MAPBOX_PUBLIC_KEY=//')
  if [ -n "$MAPBOX_PUBLIC_KEY" ]; then
    printf 'MAPBOX_ACCESS_TOKEN=%s\n' "$MAPBOX_PUBLIC_KEY" > "$OUTPUT_FILE"
  else
    printf 'MAPBOX_ACCESS_TOKEN=\n' > "$OUTPUT_FILE"
  fi
else
  printf 'MAPBOX_ACCESS_TOKEN=\n' > "$OUTPUT_FILE"
fi
