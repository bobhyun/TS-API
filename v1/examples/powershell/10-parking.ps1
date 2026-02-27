<#
.SYNOPSIS
  10-parking.ps1 - TS-API v1 Parking

.DESCRIPTION
  Endpoints:
    GET /api/v1/parking/lot           - List parking lots
    GET /api/v1/parking/lot/status    - Parking lot occupancy status
    GET /api/v1/parking/spot          - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
    GET /api/v1/parking/spot/status   - Status of each parking spot
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
