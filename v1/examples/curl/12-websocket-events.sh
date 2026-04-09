#!/usr/bin/env bash
# Example 12: WebSocket - Real-time Event Subscription
#
# Demonstrates subscribing to real-time events via WebSocket.
# Topics: LPR, channelStatus, emergencyCall, object, recording, motionChanges
#
# Two subscription modes:
#   1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
#   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
#
# Endpoint:
#   ws://host:port/wsapi/v1/events
#
# Auth:
#   Header: X-API-Key: {apiKey}                  (primary for CLI)
#   Header: Authorization: Bearer {accessToken}  (alternative)
#   Query:  ?apikey={apiKey}                     (browser fallback)
#   Query:  ?token={accessToken}                 (browser fallback)
#
# REQUIRES: websocat (https://github.com/nickel-org/websocat)
#   brew install websocat  OR  cargo install websocat
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 12-websocket-events.sh

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
# Method 1: Subscribe via URL query params
#   Subscribe to LPR and channelStatus on connect
#   Press Ctrl+C to disconnect
# ─────────────────────────────────────────────────
echo "=== Method 1: Subscribe via URL ==="
echo "Connecting to ${WS_BASE}/wsapi/v1/events?topics=LPR,channelStatus"
echo "Press Ctrl+C to disconnect"
echo ""

# -k: accept self-signed certs
# --ping-interval 30: keep connection alive
# -E: exit on EOF from server
websocat -k -E \
  --header="X-API-Key: ${API_KEY}" \
  "${WS_BASE}/wsapi/v1/events?topics=LPR,channelStatus"

# ─────────────────────────────────────────────────
# Method 2: Dynamic subscribe/unsubscribe via send()
#   Connect WITHOUT topics, then subscribe dynamically.
#
#   Subscribe:   {"subscribe":"LPR","ch":[1,2]}
#   Unsubscribe: {"unsubscribe":"channelStatus"}
#   Re-subscribe to update filters:
#     {"subscribe":"LPR","ch":[1,2,3,4]}
#
#   Per-topic filters:
#     LPR:           ch (array)
#     object:        objectTypes (["human","vehicle"]), ch (array)
#     channelStatus: (none)
#     motionChanges: ch (array)
#     parkingCount:  lot (array)
#     parkingSpot:   ch, lot, spot (arrays)
#
#   Control responses:
#     {"type":"subscribed","topic":"LPR"}
#     {"type":"unsubscribed","topic":"channelStatus"}
#     {"type":"error","message":"...","topic":"..."}
#
#   To use interactively, pipe commands:
# ─────────────────────────────────────────────────

# Example: subscribe, wait for events, then unsubscribe
# echo ""
# echo "=== Method 2: Dynamic Subscribe ==="
# {
#   echo '{"subscribe":"channelStatus"}'
#   echo '{"subscribe":"LPR","ch":[1,2]}'
#   sleep 5
#   echo '{"subscribe":"object","objectTypes":["human","vehicle"]}'
#   echo '{"subscribe":"LPR","ch":[1,2,3,4]}'
#   sleep 5
#   echo '{"unsubscribe":"channelStatus"}'
#   echo '{"subscribe":"motionChanges","ch":[1]}'
#   sleep 5
# } | websocat -k \
#   --header="X-API-Key: ${API_KEY}" \
#   "${WS_BASE}/wsapi/v1/events"

# ─────────────────────────────────────────────────
# LPR Event Compatibility
# ─────────────────────────────────────────────────
#
# LPR events may arrive in two formats:
#
#   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
#   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
#
# To handle both formats with jq:
#
#   websocat ... | while read -r line; do
#     topic=$(echo "$line" | jq -r '.topic // empty')
#     if [ "$topic" = "LPR" ]; then
#       echo "$line" | jq -r '
#         (.plates // [.])[] |
#         "Plate: \(.plateNo)  Score: \(.score)"
#       '
#     fi
#   done
#
