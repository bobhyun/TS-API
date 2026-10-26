#!/usr/bin/env bash
# Example 10: Parking Management
#
# Demonstrates:
#   - Parking lot list and status (counter-based, entry/exit)
#   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
#   - Parking spot status (AI vision-based, per-space occupancy)
#   - Filtering by zone type, channel, ID, category, occupancy
#   - Parking session history (who parked where, for how long)
#   - License check via /api/v1/info extension token (parkingHistory)
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

# ─────────────────────────────────────────────────
# 7. Parking Session History — vehicles still parked
#    A session opens when a vehicle is confirmed present and closes when it
#    leaves. Requires the parking history license (403 without it).
#    Check /api/v1/info first: the `parkingHistory` extension token tells
#    whether the session endpoints are available. license.extension is
#    omitted when no extension is active.
# ─────────────────────────────────────────────────
HAS_HISTORY=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/info?license" \
  | jq -r '(.license.extension // []) | any(. == "parkingHistory")' 2>/dev/null || true)
if [ "${HAS_HISTORY}" != "true" ]; then
  echo ""
  echo "parking history license not found (no 'parkingHistory' in license.extension) - skipping session examples"
  exit 0
fi

echo ""
echo "=== Currently Parked ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?open=true&maxCount=10" | jqf

# ─────────────────────────────────────────────────
# 8. Vehicles that left today
#    timeField=out applies the time range to the exit time (default: entry time).
# ─────────────────────────────────────────────────
echo ""
echo "=== Left Today ==="
TODAY=$(date +%Y-%m-%d)
"${CURL[@]}" "${AUTH[@]}"   "${BASE}/api/v1/parking/session?timeField=out&timeBegin=${TODAY}T00:00:00&timeEnd=${TODAY}T23:59:59&maxCount=10" | jqf

# ─────────────────────────────────────────────────
# 9. One session with its payment history
#    outKind / outTimeMeans tell how the exit time was determined.
#    Only "observed" is a measurement; the others are estimates (see the guide, 16.5).
#    inKind / inTimeMeans do the same for the entry, but err the opposite way:
#    firstSeen is an upper bound on the real entry (the vehicle was already
#    there when observation started). Unlike the exit basis, it is present
#    on open sessions too.
# ─────────────────────────────────────────────────
echo ""
echo "=== Session Detail ==="
SESSION_ID=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?maxCount=1"   | jq -r '.data[0].id // empty' 2>/dev/null || true)
if [ -n "${SESSION_ID:-}" ]; then
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" | jqf
  # Print just the entry and exit basis; the entry basis is present on open sessions too.
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -r '"  entry basis: \(.inKind) (\(.inTimeMeans))",
             "  exit  basis: \(.outKind // "-") (\(.outTimeMeans // "-"))"' 2>/dev/null || true
else
  echo "  (no sessions yet)"
fi

# ─────────────────────────────────────────────────
# 9b. Scope — what the query is scoped to
#     Omitting the items means "the whole scope", not "no filter":
#     scope=lot without a lot list returns only sessions that belong to a
#     parking lot, so no-parking-zone sessions (which belong to no lot) are
#     excluded.
# ─────────────────────────────────────────────────
echo ""
echo "=== By channel ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?scope=channel&ch=1,2&maxCount=5" | jqf

echo ""
echo "=== Whole parking-lot scope (no lot listed) ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?scope=lot&maxCount=5" | jqf

echo ""
echo "=== No-parking zones only ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?scope=noparking&maxCount=5" | jqf

# ─────────────────────────────────────────────────
# 9c. Video for a session — otherwise=nearBefore
#     A parked car does not move, so motion-triggered recording may stop
#     while it is still there. Because the car stays in place, earlier
#     footage still shows it. Use otherwise=nearBefore for parking history only.
#     An empty result means no usable recording exists (never recorded, or
#     already recycled); the session snapshots are still available.
# ─────────────────────────────────────────────────
echo ""
echo "=== Video at entry time (nearest earlier if none) ==="
if [ -n "${SESSION_ID:-}" ]; then
  # snapshots is a time-ordered array, not a map; each entry carries tags.
  # Several shots can share a tag (best shots), so find by tag and use the first (earliest).
  S_CH=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -r '[.snapshots[] | select(.tags | index("in"))][0].chid // empty' 2>/dev/null || true)
  S_AT=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -r '[.snapshots[] | select(.tags | index("in"))][0].time // empty' 2>/dev/null || true)
  if [ -n "${S_CH:-}" ] && [ -n "${S_AT:-}" ]; then
    "${CURL[@]}" "${AUTH[@]}" \
      "${BASE}/api/v1/vod?ch=${S_CH}&when=${S_AT}&otherwise=nearBefore" | jqf
  fi
fi

# ─────────────────────────────────────────────────
# 9c-2. Which shots read a plate?
#     snapshots is a time-ordered array; each entry carries tags.
#     bestshot = attempted, plate = succeeded.
#     A failed shot keeps its image (plateNo is null) so a person can review it later.
# ─────────────────────────────────────────────────
echo ""
echo "=== Snapshots (time order) ==="
if [ -n "${SESSION_ID:-}" ]; then
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -r '.snapshots[] | "  \(.time // "now")  tags=\(.tags|join(","))  plate=\(.plateNo // "-")"' \
    2>/dev/null || true
fi

# ─────────────────────────────────────────────────
# 9d. Which car is it? — the bounding box
#     A snapshot can contain several cars; `box` marks the one this session
#     is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
#     Multiply by the size of the surface you draw on; the internal
#     coordinate space does not matter.
#     Entrance/exit sessions have no vehicle box (a single plate read):
#     the value is null, but the key is always present.
# ─────────────────────────────────────────────────
echo ""
echo "=== Bounding box of the session vehicle ==="
if [ -n "${SESSION_ID:-}" ]; then
  BOX=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -c '.box' 2>/dev/null || true)
  if [ -z "${BOX:-}" ] || [ "${BOX}" = "null" ]; then
    echo "  (no box for this session)"
  else
    echo "  box = ${BOX}"
    # Multiply by the drawing surface size (1920x1080 here as an example).
    W=1920; H=1080
    echo "${BOX}" | jq -r --argjson w "$W" --argjson h "$H" \
      '"  on \($w)x\($h) -> left=\(((.cx - .w/2) * $w) | floor) top=\(((.cy - .h/2) * $h) | floor) width=\((.w * $w) | floor) height=\((.h * $h) | floor)"'
  fi
fi

# ─────────────────────────────────────────────────
# 10. Writing history — payment and manual close
#     These calls need Control permission and change stored history, so they
#     are not executed here.
#     Payment state (16.7): commit settles it, exempt records a decision not to
#     collect, and undo reverts the most recent change (the response says which).
#     Records are appended, never deleted.
#
#     close (16.8) is separate: it ends a session whose exit was never observed
#     and would otherwise stay "parked". exempt removes a session from billing
#     but may leave it parked; close ends it. Do not confuse the two.
# ─────────────────────────────────────────────────
# "${CURL[@]}" "${AUTH[@]}" -X POST \
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/commit?ref=POS-0042" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/exempt" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/undo" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/close" | jqf
#
#     Plate correction (16.9): one session by id; no bulk correction or merging.
#     Payments stay with the session. Returns 409 when plateNo equals the current plate.
#
#     Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
#     Uncomment it to try it against a test record.
# "${CURL[@]}" "${AUTH[@]}" -X POST -H "Content-Type: application/json" \
#   -d '{"plateNo":"12가3456","reason":"misread at night"}' \
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/plate" | jqf
