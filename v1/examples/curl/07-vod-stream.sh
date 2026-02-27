#!/usr/bin/env bash
# Example 07: VOD (Video on Demand) - Live & Playback Stream URLs
#
# Demonstrates:
#   - Get live stream URLs (RTMP, FLV)
#   - Get playback URLs for recorded video
#   - Navigate between recording segments (next/prev)
#   - Filter by protocol and stream quality
#
# NOTE: X-Host header is required. When using nginx reverse proxy, X-Host is
#       set by the proxy. For direct access, set it manually.
#
# Response src format:
#   src: [
#     { protocol: "rtmp", profile: "main", src: "rtmp://...", label: "1080p", size: [1920, 1080] },
#     { protocol: "flv", profile: "main", src: "http://.../.flv", label: "1080p", size: [1920, 1080] }
#   ]
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 07-vod-stream.sh

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
# 1. Get All Live Stream URLs
#    Response: [{ chid, title, src: [{ protocol, src, ... }] }]
# ─────────────────────────────────────────────────
echo "=== All Live Streams ==="
"${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod" | jqf

# ─────────────────────────────────────────────────
# 2. Get Specific Channel Stream
#    ?ch=1 filters to channel 1
# ─────────────────────────────────────────────────
echo ""
echo "=== Channel 1 Live Stream ==="
"${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod?ch=1" | jqf

# ─────────────────────────────────────────────────
# 3. Filter by Protocol
#    protocol=rtmp - RTMP only
#    protocol=flv  - FLV only (HTTP-FLV)
# ─────────────────────────────────────────────────
echo ""
echo "=== RTMP Only ==="
"${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod?ch=1&protocol=rtmp" | jqf

# ─────────────────────────────────────────────────
# 4. Filter by Stream Quality
#    stream=main - Main stream (high resolution)
#    stream=sub  - Sub stream (low resolution, less bandwidth)
# ─────────────────────────────────────────────────
echo ""
echo "=== Sub Stream (Low Resolution) ==="
"${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod?ch=1&stream=sub" | jqf

# ─────────────────────────────────────────────────
# 5. Playback (Recorded Video)
#    when=<ISO 8601 datetime> to play recorded video
# ─────────────────────────────────────────────────
echo ""
echo "=== Playback URL ==="
YESTERDAY=$(date -u -d "yesterday" +%Y-%m-%dT%H:%M:%S 2>/dev/null \
  || date -u -v-1d +%Y-%m-%dT%H:%M:%S 2>/dev/null \
  || echo "2025-01-01T12:00:00")

PLAY_RESPONSE=$("${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod?ch=1&when=${YESTERDAY}")
echo "$PLAY_RESPONSE" | jqf

# Navigate to next segment using fileId
FILE_ID=$(echo "$PLAY_RESPONSE" | jq -r '.[0].fileId // empty' 2>/dev/null)
if [ -n "$FILE_ID" ]; then
  echo ""
  echo "=== Next Segment (fileId: ${FILE_ID}) ==="
  "${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
    "${BASE}/api/v1/vod?id=${FILE_ID}&next" | jqf
fi

# ─────────────────────────────────────────────────
# 6. Multiple Channels at Once
# ─────────────────────────────────────────────────
echo ""
echo "=== Multiple Channels ==="
"${CURL[@]}" "${AUTH[@]}" -H "X-Host: ${HOST}:${PORT}" \
  "${BASE}/api/v1/vod?ch=1,2,3,4" | jqf
