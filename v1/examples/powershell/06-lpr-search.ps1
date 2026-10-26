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
        - Plates containing the keyword (partial or misread plates)

    GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
        - Export the LPR log as CSV

    GET  /api/v1/lpr/log/{id}/plate/history
        - Plate correction history of one record (Playback permission)
    POST /api/v1/lpr/log/{id}/plate   {"plateNo": "...", "reason": "..."}
        - Correct the plate of one record (Control permission, not executed here)

  WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
    Narrow the time range or page with at/maxCount.
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
$records = @()
if ($r) {
    $records = @($r.data)
    Write-Host "  $($records.Count) records found"
    $show = [Math]::Min(5, $records.Count)
    for ($i = 0; $i -lt $show; $i++) {
        $rec = $records[$i]
        # plateNo is null when no plate was read; direction is "entry"/"exit" or absent
        $plate = if ($rec.plateNo) { $rec.plateNo } else { '(unrecognized)' }
        $dir   = if ($rec.direction) { $rec.direction } else { '-' }
        $line  = "  [$($rec.id)] $($rec.timeRange) plateNo=$plate direction=$dir"
        if ($rec.plateEdited) {
            $orig = if ($rec.originalPlateNo) { $rec.originalPlateNo } else { '(unrecognized)' }
            $line += " (corrected, originally $orig)"
        }
        Write-Host $line
    }
}

# --- Similar Plate Search ---
$plateQuery = '1234'  # Partial plate number
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

# --- Plate Correction History (one record, by id) ---
# plateNo in the log is always the current value.
# edits[] lists corrections in recorded order; it is empty if the record was never corrected.
if ($records.Count -gt 0) {
    $recId = $records[0].id
    Write-Host "`n=== Plate Correction History (id=$recId) ==="
    $h = Invoke-NvrGet "/api/v1/lpr/log/$recId/plate/history"
    if ($h) {
        $orig = if ($null -ne $h.originalPlateNo) { $h.originalPlateNo } else { '(never corrected)' }
        Write-Host "  plateNo=$($h.plateNo) original=$orig"
        foreach ($e in $h.edits) {
            Write-Host "    $($e.time) $($e.user): $($e.before) -> $($e.after) $($e.reason)"
        }
    }
}

# --- Plate Correction (Control permission) ---
# Changes the stored record, so it is not executed here. The target is always
# one record id - from data[].id above, or the id a realtime LPR event carries
# next to each plateNo. 409 when plateNo equals the current plate.
#
# Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
# Uncomment it to try it against a test record.
#   Invoke-NvrPost "/api/v1/lpr/log/$recId/plate" @{ plateNo = '12A3456'; reason = 'misread at night' }

# --- Export LPR Log ---
Write-Host "`n=== Export LPR Log ==="
$resp = Invoke-NvrGetRaw "/api/v1/lpr/log?timeBegin=$timeBegin&timeEnd=$timeEnd&export=true"
if ($resp -and $resp.StatusCode -eq 200) {
    Write-Host "  Content-Type: $($resp.Headers['Content-Type'])"
    Write-Host "  Size: $($resp.Content.Length) bytes"
    # Save to file:
    # [System.IO.File]::WriteAllBytes('lpr_export.csv', $resp.Content)
}
