#!/usr/bin/env bash
# Example 08: System & Server Information
#
# Demonstrates:
#   - Server info (API version, product, license, timezone)
#   - System info (OS, CPU, disk, network)
#   - System health (CPU usage, memory, disk usage)
#   - HDD S.M.A.R.T status
#
# NOTE: System info 'storage' parameter returns response field named 'disk'.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 08-system-info.sh

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
# 1. Server Info (all at once)
#    ?all returns: apiVersion, siteName, product, timezone, license, whoAmI
# ─────────────────────────────────────────────────
echo "=== Server Info ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/info?all" | jqf

# ─────────────────────────────────────────────────
# 2. System Info (individual items)
#    Available items: os, cpu, storage, network
#    NOTE: 'storage' request returns 'disk' field in response
# ─────────────────────────────────────────────────
echo ""
echo "=== System Info (OS) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/info?item=os" | jqf

echo ""
echo "=== System Info (CPU) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/info?item=cpu" | jqf

echo ""
echo "=== System Info (Storage) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/info?item=storage" | jqf

echo ""
echo "=== System Info (Network) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/info?item=network" | jqf

# Multiple items at once
echo ""
echo "=== System Info (OS + CPU) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/info?item=os,cpu" | jqf

# ─────────────────────────────────────────────────
# 3. System Health (real-time usage)
#    Available items: cpu, memory, disk
# ─────────────────────────────────────────────────
echo ""
echo "=== System Health ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/health" | jqf

# ─────────────────────────────────────────────────
# 4. HDD S.M.A.R.T Status
# ─────────────────────────────────────────────────
echo ""
echo "=== HDD S.M.A.R.T ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/hddsmart" | jqf
