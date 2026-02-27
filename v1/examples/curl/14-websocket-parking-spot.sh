#!/usr/bin/env bash
# Example 14: WebSocket - Parking Spot Monitoring
#
# Subscribes to parkingSpot topic for parking zone monitoring.
# First message: currentStatus (ALL zone types: spot, entrance, exit, noParking, recognition)
#   - Each zone has a `type` field; only type="spot" has `occupied` and `category`
#   - Non-spot zones have `category: null` and no `occupied` field
# Subsequent: statusChanged (only fires for type="spot" zones)
#
# Channel IDs (chid) are 1-based.
#
# Endpoint:
#   ws://host:port/wsapi/v1/events?topics=parkingSpot
#
# Auth:
#   Header: X-API-Key: {apiKey}                  (primary for CLI)
#   Header: Authorization: Bearer {accessToken}  (alternative)
#   Query:  ?apikey={apiKey}                     (browser fallback)
#   Query:  ?token={accessToken}                 (browser fallback)
#
# Optional filters (OR logic):
#   &ch=1,2       - spots belonging to channels 1, 2
#   &lot=1,2      - spots belonging to parking lots 1, 2
#   &spot=100,200 - specific spot IDs
#
# See also: 13-websocket-parking-lot.sh for lot-level count monitoring
#
# REQUIRES: websocat (https://github.com/nickel-org/websocat)
#   brew install websocat  OR  cargo install websocat
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 14-websocket-parking-spot.sh

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
# Subscribe to Parking Spot Status
#   Filters (OR logic, combine as needed):
#     &ch=1,2    - by channel
#     &lot=1,2   - by parking lot
#     &spot=100  - by spot ID
#   Press Ctrl+C to disconnect
# ─────────────────────────────────────────────────
echo "=== WebSocket Parking Spot Monitoring ==="
echo "Connecting to ${WS_BASE}/wsapi/v1/events?topics=parkingSpot"
echo "Press Ctrl+C to disconnect"
echo ""

# Without filters (all spots):
websocat -k -E \
  --header="X-API-Key: ${API_KEY}" \
  "${WS_BASE}/wsapi/v1/events?topics=parkingSpot"

# With filters:
# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events?topics=parkingSpot&ch=1,2"

# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events?topics=parkingSpot&lot=1,2"

# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events?topics=parkingSpot&spot=100,200"

# Combined (OR logic):
# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events?topics=parkingSpot&ch=1&lot=2&spot=300"
