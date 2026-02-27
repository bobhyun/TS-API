#!/usr/bin/env bash
# Example 06: LPR (License Plate Recognition) Search
#
# Demonstrates:
#   - LPR source list
#   - License plate log search (keyword, time range, pagination)
#   - Similar plate search
#   - CSV export
#
# NOTE: timeBegin and timeEnd are required for LPR log searches.
#
# WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
#   errors. For bulk exports, narrow the time range or use pagination
#   (at/maxCount) to keep each request under a manageable size.
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
TIME_END=$(date -u +%Y-%m-%dT%H:%M:%S)
TIME_BEGIN=$(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%S 2>/dev/null \
  || date -u -v-7d +%Y-%m-%dT%H:%M:%S 2>/dev/null \
  || echo "2025-01-01T00:00:00")

# ─────────────────────────────────────────────────
# 1. LPR Source List
#    Each source represents a recognition point (entrance, exit, etc.)
#    Response: [{ id, code, name, linkedChannel }, ...]
# ─────────────────────────────────────────────────
echo "=== LPR Sources ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/lpr/source" | jqf

# ─────────────────────────────────────────────────
# 2. Recent LPR Logs
#    Response: { totalCount, data: [{ plateNo, score, srcName, timeRange, vod }, ...] }
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
#    Finds plates similar to the keyword (edit distance based)
#    Useful for partial or misrecognized plates
# ─────────────────────────────────────────────────
echo ""
echo "=== Similar Plate Search ==="
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/similar?keyword=${KEYWORD}&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}" | jqf

# ─────────────────────────────────────────────────
# 5. CSV Export
#    Returns LPR data in CSV format for spreadsheet import
#    ?export=true switches response format to CSV
# ─────────────────────────────────────────────────
echo ""
echo "=== CSV Export ==="
"${CURL[@]}" "${AUTH[@]}" \
  "${BASE}/api/v1/lpr/log?export=true&timeBegin=${TIME_BEGIN}&timeEnd=${TIME_END}&maxCount=5"
