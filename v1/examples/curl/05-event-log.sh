#!/usr/bin/env bash
# Example 05: Event Log Search
#
# Demonstrates:
#   - Event type enumeration
#   - Event log search with filters (time, type, channel)
#   - Pagination (at, maxCount)
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 05-event-log.sh

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
# 1. List Event Types
#    Response: [{ id, name, code: [{ id, name }, ...] }, ...]
# ─────────────────────────────────────────────────
echo "=== Event Types ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/type" | jqf

# ─────────────────────────────────────────────────
# 2. List Event Types in English
# ─────────────────────────────────────────────────
echo ""
echo "=== Event Types (English) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/type?lang=en-US" | jqf

# ─────────────────────────────────────────────────
# 3. Search Recent Events (latest 10)
#    ?sort=desc for newest first
# ─────────────────────────────────────────────────
echo ""
echo "=== Recent Events (latest 10) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/log?maxCount=10&sort=desc" | jqf

# ─────────────────────────────────────────────────
# 4. Search Events with Time Range
# ─────────────────────────────────────────────────
echo ""
echo "=== Events from Today ==="
TODAY=$(date -u +%Y-%m-%d)
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/event/log?timeBegin=${TODAY}T00:00:00&timeEnd=${TODAY}T23:59:59&maxCount=5" | jqf

# ─────────────────────────────────────────────────
# 5. Pagination
#    at=0 (start index), maxCount=5 (page size)
# ─────────────────────────────────────────────────
echo ""
echo "=== Pagination ==="
echo "--- Page 1 (at=0) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/log?at=0&maxCount=5" | jqf

echo "--- Page 2 (at=5) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/log?at=5&maxCount=5" | jqf

# ─────────────────────────────────────────────────
# 6. Filter by Channel
# ─────────────────────────────────────────────────
echo ""
echo "=== Events for Channel 1 ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/event/log?ch=1&maxCount=5" | jqf
