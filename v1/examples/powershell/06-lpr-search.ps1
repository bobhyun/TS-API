<#
.SYNOPSIS
  06-lpr-search.ps1 - TS-API v1 LPR (License Plate Recognition)

.DESCRIPTION
  Endpoints:
    GET /api/v1/lpr/source
        - List LPR-enabled sources (cameras)

    GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
        - Search LPR recognition log (timeBegin and timeEnd are required)

    GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
        - Search for similar plate numbers (fuzzy match)

    GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
        - Export LPR log as downloadable file (CSV/Excel)

  WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
    errors. For bulk exports, narrow the time range or use pagination
    (at/maxCount) to keep each request under a manageable size.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- LPR Sources ---
Write-Host '=== LPR Sources ==='
$sources = Invoke-NvrGet '/api/v1/lpr/source'
if ($sources) {
    foreach ($s in $sources) {
        Write-Host "  $($s | ConvertTo-Json -Depth 3 -Compress)"
    }
}

# --- LPR Log (last 24 hours) ---
# timeBegin and timeEnd are REQUIRED parameters
$now       = Get-Date
$timeEnd   = $now.ToString('yyyy-MM-dd HH:mm:ss')
$timeBegin = $now.AddHours(-24).ToString('yyyy-MM-dd HH:mm:ss')

Write-Host "`n=== LPR Log ($timeBegin ~ $timeEnd) ==="
$r = Invoke-NvrGet "/api/v1/lpr/log?timeBegin=$timeBegin&timeEnd=$timeEnd"
if ($r) {
    $records = $r.data
    Write-Host "  $($records.Count) records found"
    $show = [Math]::Min(5, $records.Count)
    for ($i = 0; $i -lt $show; $i++) {
        $rec = $records[$i]
        Write-Host "  [$($rec.timeRange)] plateNo=$($rec.plateNo) ch=$($rec.chid)"
    }
}

# --- Similar Plate Search ---
$plateQuery = '1234'  # Partial or similar plate number
Write-Host "`n=== Similar Plate Search (keyword=$plateQuery) ==="
$r = Invoke-NvrGet "/api/v1/lpr/similar?keyword=$plateQuery&timeBegin=$timeBegin&timeEnd=$timeEnd"
if ($r) {
    $results = if ($r.data) { $r.data } else { $r }
    $count = if ($results -is [array]) { $results.Count } else { 1 }
    Write-Host "  $count similar plates found"
    $show = [Math]::Min(10, $count)
    for ($i = 0; $i -lt $show; $i++) {
        $rec = $results[$i]
        if ($rec -is [string]) {
            Write-Host "    $rec"
        } else {
            Write-Host "  [$($rec.timeRange)] plateNo=$($rec.plateNo)"
        }
    }
}

# --- Export LPR Log ---
Write-Host "`n=== Export LPR Log ==="
$resp = Invoke-NvrGetRaw "/api/v1/lpr/log?timeBegin=$timeBegin&timeEnd=$timeEnd&export=true"
if ($resp -and $resp.StatusCode -eq 200) {
    Write-Host "  Content-Type: $($resp.Headers['Content-Type'])"
    Write-Host "  Size: $($resp.Content.Length) bytes"
    # Save to file:
    # [System.IO.File]::WriteAllBytes('lpr_export.csv', $resp.Content)
}
