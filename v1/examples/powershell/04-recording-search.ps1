<#
.SYNOPSIS
  04-recording-search.ps1 - TS-API v1 Recording Search

.DESCRIPTION
  Endpoints:
    GET /api/v1/recording/days?ch=1&timeBegin=2026-01-01&timeEnd=2026-02-01
        - Returns which days have recordings in the given time range
        - Response: { "data": [{ "year": 2026, "month": 1, "days": [1, 5, 10, ...] }] }

    GET /api/v1/recording/minutes?ch=1&timeBegin=2026-01-15&timeEnd=2026-01-16
        - Returns minute-level recording timeline as JSON
        - Response: { "data": [...] }

  Use these endpoints to build a recording timeline calendar UI.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY

$ch        = 1
$timeBegin = '2026-01-01'
$timeEnd   = '2026-02-01'

# --- Days with recordings ---
Write-Host "=== Recording Days (ch=$ch, $timeBegin ~ $timeEnd) ==="
$r = Invoke-NvrGet "/api/v1/recording/days?ch=$ch&timeBegin=$timeBegin&timeEnd=$timeEnd"
if ($r) {
    $data = $r.data
    foreach ($entry in $data) {
        # When ch= filter is used, response wraps per-channel: {chid, data: [{year,month,days}]}
        $months = if ($entry.data) { $entry.data } else { @($entry) }
        foreach ($m in $months) {
            if ($null -ne $m.year -and $null -ne $m.month) {
                $daysCount = if ($m.days) { $m.days.Count } else { 0 }
                Write-Host ("  {0}-{1:D2}: {2} days with recordings" -f $m.year, $m.month, $daysCount)
                Write-Host "    Days: $($m.days -join ', ')"
            }
        }
    }
}

# --- Minute-level timeline ---
$minuteBegin = '2026-01-15'
$minuteEnd   = '2026-01-16'
Write-Host "`n=== Recording Minutes (ch=$ch, $minuteBegin ~ $minuteEnd) ==="
$r = Invoke-NvrGet "/api/v1/recording/minutes?ch=$ch&timeBegin=$minuteBegin&timeEnd=$minuteEnd"
if ($r) {
    $data = $r.data
    Write-Host "  $($data.Count) entries returned"
    $show = [Math]::Min(10, $data.Count)
    for ($i = 0; $i -lt $show; $i++) {
        Write-Host "    $($data[$i] | ConvertTo-Json -Depth 3 -Compress)"
    }
}
