#!/usr/bin/env bash
# Example 08: System & Server Information
#
# Demonstrates:
#   - Server info (API version, product, license, timezone)
#   - System info (OS, CPU, disk, network)
#   - System health (CPU usage, memory, disk usage)
#   - System disk status (database and logs disk)
#   - System notices (conditions in effect now)
#   - HDD S.M.A.R.T status
#
# NOTE: item=storage returns its data in the 'disk' field (NOT 'storage').
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
#    NOTE: item=storage returns its data in the 'disk' field
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
# 4. System Disk
#    Holds the database and logs (normally C:), separate from the recording disks.
#    When it is full, records stop being saved even if the recording disks have room.
#    Watch status here, not only disk[].
#    Response: { systemDisk: { drive, totalSpace, freeSpace, status, dataWriteFailed } }
#    status: normal | low | critical
# ─────────────────────────────────────────────────
echo ""
echo "=== System Disk ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/health?item=systemDisk" | jqf

# ─────────────────────────────────────────────────
# 5. System Notices
#    Conditions in effect right now (raised, updated, cleared).
#    message is keyed by language code: en-US is always present,
#    plus the requested lang when it is not English.
#    Response: [{ id, kind, severity, message: { "en-US": "...", "ko-KR": "..." },
#                 messageKey, args, param, timeBegin, timeUpdate }, ...]
# ─────────────────────────────────────────────────
echo ""
echo "=== System Notices ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/notices?lang=ko-KR" | jqf

# ─────────────────────────────────────────────────
# 6. HDD S.M.A.R.T Status
# ─────────────────────────────────────────────────
echo ""
echo "=== HDD S.M.A.R.T ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/system/hddsmart" | jqf
