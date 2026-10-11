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
# A session opens when a vehicle is confirmed present and closes when it is gone.
# Needs the parking history license - 403 without it. Ask /api/v1/info first: the
# 'parkingHistory' extension token says whether the session endpoints will answer
# (the array is omitted when no extension is active).
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
        Write-Host "  [$($row.id)] $($row.src.name) $plate ${mins}m"
    }
}

# --- Session Detail ---
# outKind / outTimeMeans say HOW the exit time was decided. Only "observed" is a
# measurement; the others are estimates whose error leans in different directions,
# so bill from the basis, not from the number alone.
#
# inKind / inTimeMeans do the same for the entry, and the error leans the OTHER way:
# firstSeen is an UPPER bound on the real entry (already there when observation
# started). Unlike the exit basis it is present on OPEN sessions too.
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
# Items omitted means "the whole scope", which is NOT the same as no filter:
# scope=lot with no lot returns only sessions that belong to a parking lot, so
# no-parking-zone history is excluded (it belongs to no lot).
Write-Host "`n=== Scope ==="
foreach ($qs in @('scope=channel&ch=1,2', 'scope=lot', 'scope=noparking')) {
    $r = Invoke-NvrGet "/api/v1/parking/session?$qs&maxCount=5"
    $n = if ($r) { $r.totalCount } else { -1 }
    Write-Host "  $qs => totalCount=$n"
}

# --- Video for a session: otherwise=nearBefore ---
# A parked car does not move, so motion-triggered recording may have stopped
# while it was still there. The car is in the same place, so the preceding
# footage still shows the situation. Use this for parking history only.
# An empty result means there is no usable recording at all (never recorded, or
# already recycled) — the session snapshots remain available either way.
Write-Host "`n=== Video at entry time (nearest earlier if none) ==="
if ($one -and $one.data.Count -gt 0) {
    $d = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)"
    # snapshots 는 시각 오름차순 배열이고 각 항목이 tags 를 든다 — 키로 꺼내지 않는다.
    # 같은 뜻이 여러 장일 수 있어(베스트샷) 태그로 찾고 첫 항목을 쓴다.
    $snaps = if ($d) { @($d.snapshots) } else { @() }
    $shot = $snaps | Where-Object { $_.tags -contains 'in' } | Select-Object -First 1

    # 어느 샷이 번호를 읽어냈나. bestshot = 시도, plate = 성공.
    # 실패한 샷도 사진은 남는다(plateNo 는 null) — 나중에 사람이 확인할 수 있다.
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
# A snapshot can hold several cars. `box` points at the one this session is about.
# YOLO style: center based, all four values 0..1 (see 1.2), so you multiply by the
# size of whatever you draw on. Entrance/exit sessions carry no vehicle box
# (a single plate read) and the value is null; the key is always present.
Write-Host "`n=== Bounding box of the session vehicle ==="
if ($one -and $one.data.Count -gt 0) {
    $s = Invoke-NvrGet "/api/v1/parking/session/$($one.data[0].id)"
    if ($s -and $s.box) {
        $W = 1920; $H = 1080        # 그릴 대상 크기
        $left = [int](($s.box.cx - $s.box.w / 2) * $W)
        $top = [int](($s.box.cy - $s.box.h / 2) * $H)
        Write-Host "  box = cx=$($s.box.cx) cy=$($s.box.cy) w=$($s.box.w) h=$($s.box.h)"
        Write-Host "  on ${W}x${H} -> left=$left top=$top width=$([int]($s.box.w * $W)) height=$([int]($s.box.h * $H))"
    }
    else { Write-Host "  (no box for this session)" }
}

# --- Writing history (Control permission) ---
# Both change stored history, so they are not executed here.
# Payment state (16.7): commit settles it, exempt records a decision not to
# collect, undo reverts the most recent change (the response says which one).
# Records are appended, never deleted.
#
# close (16.8) is a different axis: it clears the lingering "parked" state left
# when an exit was never observed. Exempt takes a session out of billing and may
# leave it parked; close ends the session. Do not conflate the two.
#
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/commit?ref=POS-0042"
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/exempt"
#   Invoke-NvrPost "/api/v1/parking/session/$id/payment/undo"
#   Invoke-NvrPost "/api/v1/parking/session/$id/close"
