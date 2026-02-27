<#
.SYNOPSIS
  05-event-log.ps1 - TS-API v1 Event Log

.DESCRIPTION
  Endpoints:
    GET /api/v1/event/type
        - List event types with nested codes
        - Response: [{ "id": 1, "name": "Motion", "code": [{"id": 1, "name": "Start"}, ...] }, ...]
        - Note: field is 'id' (NOT 'type'), nested array is 'code'

    GET /api/v1/event/log?timeBegin=...&timeEnd=...&at=0&maxCount=50
        - Query event log with time range and pagination
        - Response: { "data": [{ "timeRange": "...", "chid": ..., "typeName": "...", "codeName": "..." }, ...] }
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- Event Types ---
Write-Host '=== Event Types ==='
$types = Invoke-NvrGet '/api/v1/event/type'
if ($types) {
    foreach ($t in $types) {
        # Each type has 'id', 'name', and nested 'code' array
        Write-Host "  id=$($t.id)  name=$($t.name)"
        foreach ($code in $t.code) {
            Write-Host "    code id=$($code.id)  name=$($code.name)"
        }
    }
}

# --- Event Log (last 24 hours, paginated) ---
Write-Host "`n=== Event Log (last 24h) ==="
$now       = Get-Date
$timeEnd   = $now.ToString('yyyy-MM-dd HH:mm:ss')
$timeBegin = $now.AddHours(-24).ToString('yyyy-MM-dd HH:mm:ss')

$at       = 0
$maxCount = 20  # Page size

$r = Invoke-NvrGet "/api/v1/event/log?timeBegin=$timeBegin&timeEnd=$timeEnd&at=$at&maxCount=$maxCount"
if ($r) {
    $events = $r.data
    if (-not $events -or $events.Count -eq 0) {
        Write-Host '  No events found'
    } else {
        foreach ($ev in $events) {
            Write-Host "  [$($ev.timeRange)] ch=$($ev.chid) type=$($ev.typeName) code=$($ev.codeName)"
        }
        Write-Host "`n  Fetched $($events.Count) events (at=$at)"
    }

    # To fetch next page:
    # $at += $maxCount
}
