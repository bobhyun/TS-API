#!/usr/bin/env bash
# Example 04: Recording Search
#
# Demonstrates:
#   - Recording days (calendar view - which dates have recordings)
#   - Recording minutes (timeline view - minute-by-minute recording status)
#
# These APIs are typically used to build:
#   - Calendar UI: highlight dates that have recorded video
#   - Timeline UI: show recording segments on a time bar
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 04-recording-search.sh

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
# 1. Recording Days (Calendar - All Channels)
#    Returns which dates have recordings
#    Response: { timeBegin, timeEnd, data: [{ year, month, days: [1,2,...] }] }
# ─────────────────────────────────────────────────
echo "=== Recording Days (All Channels) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/recording/days" | jqf

# ─────────────────────────────────────────────────
# 2. Recording Days (Specific Channel)
#    ?ch=1 filters to channel 1 only
# ─────────────────────────────────────────────────
echo ""
echo "=== Recording Days (Channel 1) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/recording/days?ch=1" | jqf

# ─────────────────────────────────────────────────
# 3. Recording Minutes (Timeline)
#    Returns 1440-char string per channel (24h x 60min)
#    '1' = recording exists, '0' = no recording
# ─────────────────────────────────────────────────
echo ""
echo "=== Recording Minutes (Timeline) ==="

# Query today's recordings
TODAY=$(date -u +%Y-%m-%d)
TIME_BEGIN="${TODAY}T00:00:00"
TIME_END="${TODAY}T23:59:59"

echo "Date: ${TODAY}"
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/recording/minutes?ch=1&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}" | jqf
