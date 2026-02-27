#!/usr/bin/env bash
# Example 09: Push Notification - External Event Input
#
# Demonstrates:
#   - LPR push (external plate recognition data)
#   - Emergency call push (alarm start/stop)
#
# REQUIRES: Push license enabled on the server.
#           Returns 404 if not enabled.
#
# WARNING: Emergency call 'callStart' triggers actual alarm hardware!
#          Always send 'callEnd' to stop the alarm.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 09-push.sh

set -euo pipefail

HOST="${NVR_HOST:-localhost}"
SCHEME="${NVR_SCHEME:-https}"
PORT="${NVR_PORT:-$([ "$SCHEME" = "https" ] && echo 443 || echo 80)}"
API_KEY="${NVR_API_KEY:?NVR_API_KEY environment variable is required}"

DEFAULT_PORT=$([ "$SCHEME" = "https" ] && echo 443 || echo 80)
[ "$PORT" = "$DEFAULT_PORT" ] && BASE="${SCHEME}://${HOST}" || BASE="${SCHEME}://${HOST}:${PORT}"
AUTH=(-H "X-API-Key: ${API_KEY}")
CURL=(curl -sk)

jqf() { jq . 2>/dev/null || cat; }

NOW=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# ─────────────────────────────────────────────────
# 1. LPR Push
#    External LPR camera sends recognized plate number
#    POST /api/v1/push with topic: "LPR"
# ─────────────────────────────────────────────────
echo "=== LPR Push ==="
"${CURL[@]}" "${AUTH[@]}" -X POST "${BASE}/api/v1/push" \
  -H "Content-Type: application/json" \
  -d "{
    \"topic\": \"LPR\",
    \"src\": \"1\",
    \"plateNo\": \"12가3456\",
    \"when\": \"${NOW}\"
  }" | jqf

# ─────────────────────────────────────────────────
# 2. Emergency Call Push
#    Sends alarm start/stop events from emergency call device
#
#    IMPORTANT:
#    - callStart triggers actual alarm bell
#    - Always send callEnd to stop the alarm
#    - camera field links to NVR channels for popup
# ─────────────────────────────────────────────────
echo ""
echo "=== Emergency Call Push ==="

# Start emergency alarm
echo "--- callStart ---"
"${CURL[@]}" "${AUTH[@]}" -X POST "${BASE}/api/v1/push" \
  -H "Content-Type: application/json" \
  -d "{
    \"topic\": \"emergencyCall\",
    \"device\": \"intercom-01\",
    \"src\": \"1\",
    \"event\": \"callStart\",
    \"camera\": \"1,2\",
    \"when\": \"${NOW}\"
  }" | jqf

# ALWAYS stop the alarm!
echo ""
echo "--- callEnd ---"
"${CURL[@]}" "${AUTH[@]}" -X POST "${BASE}/api/v1/push" \
  -H "Content-Type: application/json" \
  -d "{
    \"topic\": \"emergencyCall\",
    \"device\": \"intercom-01\",
    \"src\": \"1\",
    \"event\": \"callEnd\",
    \"camera\": \"1,2\",
    \"when\": \"${NOW}\"
  }" | jqf
