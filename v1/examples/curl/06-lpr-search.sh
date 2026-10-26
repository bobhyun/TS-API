#!/usr/bin/env bash
# Example 06: LPR (License Plate Recognition) Search
#
# Demonstrates:
#   - LPR source list
#   - License plate log search (keyword, time range, pagination)
#   - Similar plate search
#   - CSV export
#   - Plate correction history (GET /api/v1/lpr/log/{id}/plate/history)
#   - Plate correction (POST /api/v1/lpr/log/{id}/plate, Control permission, not executed)
#
# NOTE: timeBegin and timeEnd are required for LPR log searches.
#
# WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
#   Narrow the time range or page with at/maxCount.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 06-lpr-search.sh

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

# Time range: last 7 days
TIME_END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TIME_BEGIN=$(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || echo "2025-01-01T00:00:00Z")

# ─────────────────────────────────────────────────
# 1. LPR Source List
#    Each source represents a recognition point (entrance, exit, etc.)
#    Response: [{ id, code, name, linkedChannel }, ...]
# ─────────────────────────────────────────────────
echo "=== LPR Sources ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/lpr/source" | jqf

# ─────────────────────────────────────────────────
# 2. Recent LPR Logs
#    Response: { totalCount, data: [{ id, plateNo, score, srcName, direction, timeRange, vod }, ...] }
#    plateNo is null when no plate was read; direction is "entry"/"exit" or absent.
#    Corrected records carry plateEdited: true and originalPlateNo.
# ─────────────────────────────────────────────────
echo ""
echo "=== Recent LPR Logs (last 7 days, max 10) ==="
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/log?timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}&maxCount=10" | jqf

# ─────────────────────────────────────────────────
# 3. Search by Keyword (partial plate match)
# ─────────────────────────────────────────────────
echo ""
echo "=== Search by Keyword ==="
KEYWORD="1234"
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/log?keyword=${KEYWORD}&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}&maxCount=5" | jqf

# ─────────────────────────────────────────────────
# 4. Similar Plate Search
#    Returns every plate containing the keyword, most recent first
#    Useful for partial or misrecognized plates
# ─────────────────────────────────────────────────
echo ""
echo "=== Similar Plate Search ==="
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/similar?keyword=${KEYWORD}&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}" | jqf

# ─────────────────────────────────────────────────
# 5. Plate Correction History (one record, by id)
#    plateNo in the log is always the current value.
#    edits[] lists corrections in recorded order; it is empty if the record was never corrected.
# ─────────────────────────────────────────────────
echo ""
echo "=== Plate Correction History ==="
LPR_ID=$("${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/log?timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}&maxCount=1" \
  | jq -r '.data[0].id // empty' 2>/dev/null || true)
if [ -n "${LPR_ID:-}" ]; then
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/lpr/log/${LPR_ID}/plate/history" | jqf
else
  echo "  (no records, or jq not installed)"
fi

# ─────────────────────────────────────────────────
# 6. Plate Correction (Control permission)
#    Changes the stored record, so it is not executed here. The target is always
#    one record id - from data[].id above, or the id a realtime LPR event carries
#    next to each plateNo. 409 when plateNo equals the current plate.
# ─────────────────────────────────────────────────
# Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
# Uncomment it to try it against a test record.
# "${CURL[@]}" "${AUTH[@]}" -X POST -H "Content-Type: application/json" \
#   -d '{"plateNo":"12가3456","reason":"misread at night"}' \
#   "${BASE}/api/v1/lpr/log/${LPR_ID}/plate" | jqf

# ─────────────────────────────────────────────────
# 7. CSV Export
#    Returns LPR data in CSV format for spreadsheet import
#    ?export=true switches response format to CSV
# ─────────────────────────────────────────────────
echo ""
echo "=== CSV Export ==="
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/log?export=true&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}&maxCount=5"
