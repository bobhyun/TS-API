#!/usr/bin/env bash
# Example 13: WebSocket - Parking Lot Count Monitoring
#
# Subscribes to parkingCount topic for real-time lot occupancy changes.
#
# Endpoint:
#   ws://host:port/wsapi/v1/events?topics=parkingCount
#
# Auth:
#   Header: X-API-Key: {apiKey}                  (primary for CLI)
#   Header: Authorization: Bearer {accessToken}  (alternative)
#   Query:  ?apikey={apiKey}                     (browser fallback)
#   Query:  ?token={accessToken}                 (browser fallback)
#
# Optional filter: &lot=1,2 (filter by parking lot ID)
#
# Event format:
#   { topic: "parkingCount", updated: [{ id, name, type, maxCount, count }, ...] }
#
# See also: 14-websocket-parking-spot.sh for individual spot monitoring
#
# REQUIRES: websocat (https://github.com/nickel-org/websocat)
#   brew install websocat  OR  cargo install websocat
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 13-websocket-parking-lot.sh

set -euo pipefail

HOST="${NVR_HOST:-localhost}"
SCHEME="${NVR_SCHEME:-https}"
PORT="${NVR_PORT:-$([ "$SCHEME" = "https" ] && echo 443 || echo 80)}"
API_KEY="${NVR_API_KEY:?NVR_API_KEY environment variable is required}"

WS_SCHEME=$([ "$SCHEME" = "https" ] && echo "wss" || echo "ws")
DEFAULT_PORT=$([ "$SCHEME" = "https" ] && echo 443 || echo 80)
[ "$PORT" = "$DEFAULT_PORT" ] && WS_BASE="${WS_SCHEME}://${HOST}" || WS_BASE="${WS_SCHEME}://${HOST}:${PORT}"

if ! command -v websocat &>/dev/null; then
  echo "Error: websocat is required but not installed."
  echo "Install: brew install websocat  OR  cargo install websocat"
  exit 1
fi

# ─────────────────────────────────────────────────
# Subscribe to Parking Count
#   topic: parkingCount
#   optional filter: &lot=1,2 (by lot ID)
#   Press Ctrl+C to disconnect
# ─────────────────────────────────────────────────
echo "=== WebSocket Parking Count Monitoring ==="
echo "Connecting to ${WS_BASE}/wsapi/v1/events?topics=parkingCount"
echo "Press Ctrl+C to disconnect"
echo ""

# Without lot filter (all lots):
websocat -k -E \
  --header="X-API-Key: ${API_KEY}" \
  "${WS_BASE}/wsapi/v1/events?topics=parkingCount"

# With lot filter (lots 1 and 2 only):
# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events?topics=parkingCount&lot=1,2"
