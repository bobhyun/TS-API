#!/usr/bin/env bash
# Example 02: Channel Management
#
# Demonstrates:
#   - List channels (basic info, static source, capabilities)
#   - Channel status (connection state, recording status)
#   - Channel detailed info
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 02-channels.sh

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
# 1. List Channels (basic info)
#    Response: [{ chid, title, displayName }, ...]
# ─────────────────────────────────────────────────
echo "=== Channel List ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel" | jqf

# ─────────────────────────────────────────────────
# 2. List Channels with static source URLs
#    ?staticSrc includes camera source configuration
# ─────────────────────────────────────────────────
echo ""
echo "=== Channel List with Sources ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel?staticSrc" | jqf

# ─────────────────────────────────────────────────
# 3. List Channels with capabilities
#    ?caps includes PTZ capabilities (pantilt, zoom, relay)
# ─────────────────────────────────────────────────
echo ""
echo "=== Channel Capabilities ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel?caps" | jqf

# ─────────────────────────────────────────────────
# 4. Channel Status
#    ?recordingStatus includes recording state
#    Status codes: 0=Connected, -1=Disconnected, -2=Connecting, -3=Auth Failed
# ─────────────────────────────────────────────────
echo ""
echo "=== Channel Status ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/status?recordingStatus" | jqf

# ─────────────────────────────────────────────────
# 5. Specific Channel Info
#    GET /api/v1/channel/{id}/info?caps
# ─────────────────────────────────────────────────
echo ""
echo "=== Channel 1 Detailed Info ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/1/info?caps" | jqf
