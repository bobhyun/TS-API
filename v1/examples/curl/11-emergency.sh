#!/usr/bin/env bash
# Example 11: Emergency Call Device List
#
# Endpoint:
#   GET /api/v1/emergency  - Emergency call device list
#
# Response: [{ id, code, name, linkedChannel }, ...]
# Note: Requires Emergency Call license. Returns 404 if not supported.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 11-emergency.sh

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

# ─────────────────────────────────────────────────
# Emergency Call Device List
# ─────────────────────────────────────────────────
echo "=== Emergency Call Devices ==="
HTTP_CODE=$("${CURL[@]}" "${AUTH[@]}" -o /tmp/emergency_response.json -w '%{http_code}' \
  "${BASE}/api/v1/emergency")

if [ "$HTTP_CODE" = "200" ]; then
  cat /tmp/emergency_response.json | jqf
elif [ "$HTTP_CODE" = "404" ]; then
  echo "Emergency Call not enabled on this server (license required)"
else
  echo "Unexpected status: ${HTTP_CODE}"
  cat /tmp/emergency_response.json 2>/dev/null
fi

rm -f /tmp/emergency_response.json
