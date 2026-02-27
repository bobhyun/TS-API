#!/usr/bin/env bash
# Example 15: WebSocket - Recording Data Export
#
# Demonstrates recording data backup/export via WebSocket.
#
# Endpoint:
#   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
#
# Auth:
#   Header: X-API-Key: {apiKey}                  (primary for CLI)
#   Header: Authorization: Bearer {accessToken}  (alternative)
#   Query:  ?apikey={apiKey}                     (browser fallback)
#   Query:  ?token={accessToken}                 (browser fallback)
#
# Flow:
#   Client ──connect──> Server
#   Client <──ready──── Server   { stage:"ready", task:{id}, channel:{...} }
#   Client <──fileEnd── Server   { stage:"fileEnd", channel:{file:{download}} }
#   Client ──{cmd:"next"}──> Server
#   Client <──end────── Server   { stage:"end" }
#   (on error) Client <──error── Server   { stage:"error", message }
#   (to cancel) Client ──{cmd:"cancel"}──> Server
#
# REQUIRES: websocat (https://github.com/nickel-org/websocat)
#   brew install websocat  OR  cargo install websocat
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 15-websocket-export.sh

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

# Time range: yesterday 00:00 ~ 00:10
YESTERDAY=$(date -u -d "yesterday" +%Y-%m-%d 2>/dev/null \
  || date -u -v-1d +%Y-%m-%d 2>/dev/null \
  || echo "2025-01-01")
TIME_BEGIN="${YESTERDAY}T00:00:00"
TIME_END="${YESTERDAY}T00:10:00"
CHANNEL="${NVR_CHANNEL:-1}"

# ─────────────────────────────────────────────────
# Recording Export via WebSocket
#
# Interactive protocol:
#   1. Connect with ch, timeBegin, timeEnd params
#   2. Receive "ready" stage with task ID
#   3. Receive "fileEnd" stages with download URLs
#   4. Send {"task":"<id>","cmd":"next"} to request next file
#   5. Receive "end" when all files are done
#   6. Send {"task":"<id>","cmd":"cancel"} to abort
# ─────────────────────────────────────────────────
echo "=== WebSocket Recording Export ==="
echo "Channel: ${CHANNEL},  ${TIME_BEGIN} ~ ${TIME_END}"
echo ""

URL="${WS_BASE}/wsapi/v1/export?ch=${CHANNEL}&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}"
echo "Connecting to ${URL}"
echo "Watch for 'stage' messages. Send {\"cmd\":\"next\"} to continue after fileEnd."
echo "Press Ctrl+C to disconnect"
echo ""

# Simple monitoring mode (read-only):
# websocat -k -E \
#   --header="X-API-Key: ${API_KEY}" \
#   "${URL}"

# Interactive mode with auto-next:
# This script automatically sends "next" after each fileEnd.
# For production use, parse the JSON and extract download URLs.
{
  # Initial wait for ready stage
  sleep 2
  # The task ID will be in the first "ready" message
  # For simplicity, we send a generic next command
  # In production, parse the task ID from the ready message
  while true; do
    sleep 3
    echo '{"cmd":"next"}'
  done
} | websocat -k \
  --header="X-API-Key: ${API_KEY}" \
  "${URL}"
