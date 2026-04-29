#!/usr/bin/env bash
set -euo pipefail

ROUTER_URL="${ROUTER_URL:-http://127.0.0.1:8402}"
EXAMPLE_FILE="${1:-examples/simple-request.json}"

if [ ! -f "$EXAMPLE_FILE" ]; then
  echo "Example file not found: $EXAMPLE_FILE"
  exit 1
fi

echo "Testing router: $ROUTER_URL"
echo "Using payload: $EXAMPLE_FILE"

curl -s "$ROUTER_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: passthrough" \
  -H "anthropic-version: 2023-06-01" \
  -d @"$EXAMPLE_FILE"

echo ""
echo "Stats:"
curl -s "$ROUTER_URL/stats"
echo ""
