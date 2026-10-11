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
#    A session opens when a vehicle is confirmed present and closes when it is gone.
#    Response: { totalCount, at, asOf, summary, data: [ ... ] }
#    Needs the parking history license (403 without it). Ask /api/v1/info first —
#    the `parkingHistory` extension token says whether the session endpoints will
#    answer (the array is omitted when no extension is active).
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
#    timeField=out puts the period on the exit time (default is the entry time).
# ─────────────────────────────────────────────────
echo ""
echo "=== Left Today ==="
TODAY=$(date +%Y-%m-%d)
"${CURL[@]}" "${AUTH[@]}"   "${BASE}/api/v1/parking/session?timeField=out&timeBegin=${TODAY}T00:00:00&timeEnd=${TODAY}T23:59:59&maxCount=10" | jqf

# ─────────────────────────────────────────────────
# 9. One session with its payment history
#    outKind/outTimeMeans tell how the exit time was decided — only "observed"
#    is a measurement, the rest are estimates (see the guide, 16.5).
#    inKind/inTimeMeans do the same for the entry and lean the OTHER way:
#    firstSeen is an UPPER bound (already there when observation started), and it
#    is present on OPEN sessions too.
# ─────────────────────────────────────────────────
echo ""
echo "=== Session Detail ==="
SESSION_ID=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session?maxCount=1"   | jq -r '.data[0].id // empty' 2>/dev/null || true)
if [ -n "${SESSION_ID:-}" ]; then
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" | jqf
  # 두 경계의 근거만 따로 뽑아 본다 — 입차 쪽은 열린 세션에도 있다.
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/parking/session/${SESSION_ID}" \
    | jq -r '"  entry basis: \(.inKind) (\(.inTimeMeans))",
             "  exit  basis: \(.outKind // "-") (\(.outTimeMeans // "-"))"' 2>/dev/null || true
else
  echo "  (no sessions yet)"
fi

# ─────────────────────────────────────────────────
# 9b. Scope — what the query is scoped to
#     Items omitted means "the whole scope", which is NOT the same as no filter:
#     scope=lot with no lot returns only sessions that belong to a parking lot,
#     so no-parking-zone history is excluded (it belongs to no lot).
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
#     A parked car does not move, so motion-triggered recording may have stopped
#     while it was still there. The car is in the same place, so the preceding
#     footage still shows the situation — ask for it with otherwise=nearBefore.
#     Use this for parking history only. If nothing comes back, there is no
#     usable recording at all (never recorded, or already recycled); the
#     session snapshots are stored independently and remain available.
# ─────────────────────────────────────────────────
echo ""
echo "=== Video at entry time (nearest earlier if none) ==="
if [ -n "${SESSION_ID:-}" ]; then
  # snapshots 는 시각 오름차순 배열이고 각 항목이 tags 를 든다 — 키로 꺼내지 않는다.
  # 같은 뜻이 여러 장일 수 있어(베스트샷) 태그로 찾고 첫 항목(가장 이른 것)을 쓴다.
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
#     snapshots is time-ordered; each entry carries tags. `bestshot` means recognition was
#     attempted, `plate` means it succeeded — a failed attempt keeps the picture but has
#     plateNo: null and no `plate` tag, so a person can still check it later.
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
#     A snapshot can hold several cars. `box` points at the one this session is
#     about. It is YOLO-style: center based, all four values 0..1 (see 1.2), so
#     you multiply by the size of whatever you draw on — there is no need to know
#     the internal coordinate space.
#     Entrance/exit sessions carry no vehicle box (a single plate read), so the
#     value is null. The key is always present.
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
    # 그릴 대상 크기에 곱한다. 여기서는 1920x1080 을 예로 든다.
    W=1920; H=1080
    echo "${BOX}" | jq -r --argjson w "$W" --argjson h "$H" \
      '"  on \($w)x\($h) -> left=\(((.cx - .w/2) * $w) | floor) top=\(((.cy - .h/2) * $h) | floor) width=\((.w * $w) | floor) height=\((.h * $h) | floor)"'
  fi
fi

# ─────────────────────────────────────────────────
# 10. Writing history — payment and manual close
#     Both need Control permission and both change stored history, so they are
#     Payment state (16.7): commit settles it, exempt records a decision not to
#     collect, undo reverts the most recent change (the response says which one).
#     Records are appended, never deleted.
#    
#     close (16.8) is a different axis: it clears the lingering "parked" state left
#     when an exit was never observed. Exempt takes a session out of billing and may
#     leave it parked; close ends the session. Do not conflate the two.
# ─────────────────────────────────────────────────
# "${CURL[@]}" "${AUTH[@]}" -X POST \
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/commit?ref=POS-0042" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/exempt" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/payment/undo" | jqf
#   "${BASE}/api/v1/parking/session/${SESSION_ID}/close" | jqf
#
# "${CURL[@]}" "${AUTH[@]}" -X POST \
