#!/usr/bin/env bash
# Example 10: Parking Management
#
# Demonstrates:
#   - Parking lot list and status (counter-based, entry/exit)
#   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
#   - Parking spot status (AI vision-based, per-space occupancy)
#   - Filtering by zone type, channel, ID, category, occupancy
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 10-parking.sh

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
# 1. Parking Lot List
#    Counter-based parking management (entry/exit counting)
#    Response: [{ id, name, type, maxCount, parkingSpots, member }, ...]
# ─────────────────────────────────────────────────
echo "=== Parking Lots ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/lot" | jqf

# ─────────────────────────────────────────────────
# 2. Parking Lot Status (real-time counts)
#    Response: [{ id, name, maxCount, count, available }, ...]
# ─────────────────────────────────────────────────
echo ""
echo "=== Parking Lot Status ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/lot/status" | jqf

# ─────────────────────────────────────────────────
# 3. Recognition Zone List (all types)
#    Returns all zone types: spot, entrance, exit, noParking, recognition
#    Response: [{ id, name, chid, type, category, occupied }, ...]
# ─────────────────────────────────────────────────
echo ""
echo "=== Recognition Zones ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/spot" | jqf

# ─────────────────────────────────────────────────
# 4. Parking Spot Status (real-time occupancy)
#    Only returns zones with type=spot (not entrance/exit/etc.)
#    Response: [{ id, name, occupied, vehicle: { plateNo, score, since } }, ...]
# ─────────────────────────────────────────────────
echo ""
echo "=== Parking Spot Status ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/spot/status" | jqf

# ─────────────────────────────────────────────────
# 5. Filter by Category (disabled parking, etc.)
# ─────────────────────────────────────────────────
echo ""
echo "=== Disabled Parking Spots ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/spot?category=disabled" | jqf

# ─────────────────────────────────────────────────
# 6. Filter by Occupancy
# ─────────────────────────────────────────────────
echo ""
echo "=== Empty Spots Only ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/spot/status?occupied=false" | jqf
