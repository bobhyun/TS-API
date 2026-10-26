<#
.SYNOPSIS
  10-parking.ps1 - TS-API v1 Parking

.DESCRIPTION
  Endpoints:
    GET /api/v1/parking/lot           - List parking lots
    GET /api/v1/parking/lot/status    - Parking lot occupancy status
    GET /api/v1/parking/spot          - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
    GET /api/v1/parking/spot/status   - Status of each parking spot
    GET /api/v1/info?license          - License check (parkingHistory extension token)
    GET /api/v1/parking/session        - Parking session history
    GET /api/v1/parking/session/{id}   - One session with its payment history
    GET /api/v1/parking/session/{id}/plate/history - Plate correction history of one session
    POST /api/v1/parking/session/{id}/plate        - Correct the session plate (not executed here)
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- Parking Lots ---
Write-Host '=== Parking Lots ==='
$lots = Invoke-NvrGet '/api/v1/parking/lot'
if ($lots) {
    Write-Host "  $($lots.Count) lots found"
    foreach ($lot in $lots) {
        $info = "  [$($lot.id)] $($lot.name) (type=$($lot.type), max=$($lot.maxCount))"
        if ($lot.parkingSpots) { $info += " spots=$($lot.parkingSpots)" }
        if ($lot.member)       { $info += " member=$($lot.member)" }
        Write-Host $info
    }
}

# --- Parking Lot Status (occupancy) ---
Write-Host "`n=== Parking Lot Status ==="
$statuses = Invoke-NvrGet '/api/v1/parking/lot/status'
if ($statuses) {
    foreach ($s in $statuses) {
        Write-Host "  $($s | ConvertTo-Json -Depth 3 -Compress)"
    }
}

# --- Recognition Zones (all types: spot, entrance, exit, noParking, recognition) ---
Write-Host "`n=== Recognition Zones ==="
$zones = Invoke-NvrGet '/api/v1/parking/spot'
if ($zones) {
    $types = @{}
    foreach ($z in $zones) {
        $t = if ($z.type) { $z.type } else { 'unknown' }
        $prev = if ($types.ContainsKey($t)) { $types[$t] } else { 0 }
        $types[$t] = $prev + 1
    }
    $summary = ($types.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join ', '
    Write-Host "  $($zones.Count) zones found ($summary)"
    $show = [Math]::Min(10, $zones.Count)
    for ($i = 0; $i -lt $show; $i++) {
        Write-Host "  $($zones[$i] | ConvertTo-Json -Depth 3 -Compress)"
    }
    if ($zones.Count -gt 10) {
        Write-Host "  ... and $($zones.Count - 10) more zones"
    }
}

# --- Parking Spot Status ---
Write-Host "`n=== Parking Spot Status ==="
$statuses = Invoke-NvrGet '/api/v1/parking/spot/status'
if ($statuses) {
    $show = [Math]::Min(10, $statuses.Count)
    for ($i = 0; $i -lt $show; $i++) {
        Write-Host "  $($statuses[$i] | ConvertTo-Json -Depth 3 -Compress)"
    }
    if ($statuses.Count -gt 10) {
        Write-Host "  ... and $($statuses.Count - 10) more spots"
    }
}

# --- Parking Session History ---
# A session opens when a vehicle is confirmed present and closes when it
# leaves. Requires the parking history license (403 without it).
# Check /api/v1/info first: the `parkingHistory` extension token tells
# whether the session endpoints are available. license.extension is
# omitted when no extension is active.
$info = Invoke-NvrGet '/api/v1/info?license'
if (-not ($info.license.extension -contains 'parkingHistory')) {
    Write-Host "`nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples"
    return
}

Write-Host "`n=== Currently Parked ==="
$open = Invoke-NvrGet '/api/v1/parking/session?open=true&maxCount=10'
if ($open) {
    Write-Host "  total=$($open.totalCount) asOf=$($open.asOf)"
    foreach ($row in $open.data) {
        $mins = [Math]::Floor($row.durationMs / 60000)
        $plate = if ($row.plateNo) { $row.plateNo } else { '(no plate)' }
        $edited = if ($row.plateEdited) { ' (corrected)' } else { '' }
        Write-Host "  [$($row.id)] $($row.src.name) $plate$edited ${mins}m"
    }
}

# --- Session Detail ---
# outKind / outTimeMeans tell how the exit time was determined.
# Only "observed" is a measurement; the others are estimates that can err
# in different directions, so bill from the basis, not from the time alone.
#
# inKind / inTimeMeans do the same for the entry, but err the opposite way:
# firstSeen is an upper bound on the real entry (the vehicle was already
# there when observation started). Unlike the exit basis, it is present
# on open sessions too.
Write-Host "`n=== Session Detail ==="
$one = Invoke-NvrGet '/api/v1/parking/session?maxCount=1'
if ($one -and $one.data.Count -gt 0) {
    $detail = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)"
    if ($detail) {
        Write-Host "  $($detail | ConvertTo-Json -Depth 4 -Compress)"
        Write-Host "  entry basis: $($detail.inKind) ($($detail.inTimeMeans))"
        if (-not $detail.open) {
            Write-Host "  exit basis: $($detail.outKind) ($($detail.outTimeMeans))"
        }
    }
} else {
    Write-Host "  (no sessions yet)"
}

# --- Scope: what the query is scoped to ---
# Omitting the items means "the whole scope", not "no filter":
# scope=lot without a lot list returns only sessions that belong to a
# parking lot, so no-parking-zone sessions (which belong to no lot) are
# excluded.
Write-Host "`n=== Scope ==="
foreach ($qs in @('scope=channel&ch=1,2', 'scope=lot', 'scope=noparking')) {
    $r = Invoke-NvrGet "/api/v1/parking/session?$qs&maxCount=5"
    $n = if ($r) { $r.totalCount } else { -1 }
    Write-Host "  $qs => totalCount=$n"
}

# --- Video for a session: otherwise=nearBefore ---
# A parked car does not move, so motion-triggered recording may stop
# while it is still there. Because the car stays in place, earlier
# footage still shows it. Use otherwise=nearBefore for parking history only.
# An empty result means no usable recording exists (never recorded, or
# already recycled); the session snapshots are still available.
Write-Host "`n=== Video at entry time (nearest earlier if none) ==="
if ($one -and $one.data.Count -gt 0) {
    $d = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)"
    # snapshots is a time-ordered array, not a map; each entry carries tags.
    # Several shots can share a tag (best shots), so find by tag and use the first (earliest).
    $snaps = if ($d) { @($d.snapshots) } else { @() }
    $shot = $snaps | Where-Object { $_.tags -contains 'in' } | Select-Object -First 1

    # Which shots read the plate: bestshot = attempted, plate = succeeded.
    # A failed shot keeps its image (plateNo is null) so a person can review it later.
    Write-Host "  snapshots:"
    foreach ($x in $snaps) {
        $t = if ($x.time) { $x.time } else { 'now' }
        $p = if ($x.plateNo) { $x.plateNo } else { '-' }
        Write-Host "    $t  tags=$($x.tags -join ',')  plate=$p"
    }
    if ($shot) {
        $v = Invoke-NvrGet "/api/v1/vod?ch=$($shot.chid)&when=$($shot.time)&otherwise=nearBefore"
        $cnt = if ($v) { @($v).Count } else { 0 }
        Write-Host "  ch=$($shot.chid) when=$($shot.time) -> $cnt channel(s)"
        if ($cnt -eq 0) { Write-Host "  (no recorded video at or before this time)" }
    }
}

# --- Which car is it? the bounding box ---
# A snapshot can contain several cars; `box` marks the one this session
# is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
# Multiply by the size of the surface you draw on; the internal
# coordinate space does not matter.
# Entrance/exit sessions have no vehicle box (a single plate read):
# the value is null, but the key is always present.
Write-Host "`n=== Bounding box of the session vehicle ==="
if ($one -and $one.data.Count -gt 0) {
    $s = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)"
    if ($s -and $s.box) {
        $W = 1920; $H = 1080        # drawing surface size
        $left = [int](($s.box.cx - $s.box.w / 2) * $W)
        $top = [int](($s.box.cy - $s.box.h / 2) * $H)
        Write-Host "  box = cx=$($s.box.cx) cy=$($s.box.cy) w=$($s.box.w) h=$($s.box.h)"
        Write-Host "  on ${W}x${H} -> left=$left top=$top width=$([int]($s.box.w * $W)) height=$([int]($s.box.h * $H))"
    }
    else { Write-Host "  (no box for this session)" }
}

# --- Plate correction history ---
# Only the session's representative plate (plateNo) is corrected; per-shot
# readings (snapshots[].plateNo) are kept as evidence.
# Reading requires Playback permission.
Write-Host "`n=== Plate correction history ==="
if ($one -and $one.data.Count -gt 0) {
    $h = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)/plate/history"
    if ($h) {
        $orig = if ($null -ne $h.originalPlateNo) { $h.originalPlateNo } else { '(never corrected)' }
        Write-Host "  session=$($h.id) plateNo=$($h.plateNo) original=$orig"
        foreach ($e in $h.edits) {
            Write-Host "    $($e.time) $($e.user): $($e.before) -> $($e.after) $($e.reason)"
        }
    }
}

# --- Writing history (Control permission) ---
# These calls change stored history, so they are not executed here.
# Payment state (16.7): commit settles it, exempt records a decision not to
# collect, and undo reverts the most recent change (the response says which).
# Records are appended, never deleted.
#
# close (16.8) is separate: it ends a session whose exit was never observed
# and would otherwise stay "parked". exempt removes a session from billing
# but may leave it parked; close ends it. Do not confuse the two.
#
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/commit?ref=POS-0042"
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/exempt"
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/undo"
#   Invoke-NvrPost "/api/v1/parking/session/$id/close"
#
# Plate correction (16.9): one session by id; no bulk correction or merging.
# Payments stay with the session. Returns 409 when plateNo equals the current plate.
#
# Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
# Uncomment it to try it against a test record.
#   Invoke-NvrPost "/api/v1/parking/session/$id/plate" @{ plateNo = '12A3456'; reason = 'misread at night' }
