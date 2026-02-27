<#
.SYNOPSIS
  07-vod-stream.ps1 - TS-API v1 VOD (Video on Demand)

.DESCRIPTION
  Endpoints:
    GET /api/v1/vod
        - List available VOD streams
        - Response: [{ "chid": 1, "title": "Camera 1", "src": [{"protocol": "rtmp", "src": "..."}, ...] }, ...]
        - Note: 'src' is an array of objects with 'protocol' and 'src' fields

    GET /api/v1/vod?protocol=rtmp
        - Filter by protocol (rtmp, flv)

    GET /api/v1/vod?stream=sub
        - Filter by stream type (main, sub)

  VOD playback requires specifying a time range via the stream URL parameters.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- List all VOD streams ---
Write-Host '=== VOD Streams ==='
$vods = Invoke-NvrGet '/api/v1/vod'
if ($vods) {
    foreach ($v in $vods) {
        # Fields: chid, title, src (array of {protocol, src} objects)
        Write-Host "  chid=$($v.chid)  title=$($v.title)"
        $rtmpUrl = ($v.src | Where-Object { $_.protocol -eq 'rtmp' } | Select-Object -First 1).src
        $flvUrl  = ($v.src | Where-Object { $_.protocol -eq 'flv' }  | Select-Object -First 1).src
        if ($rtmpUrl) { Write-Host "    RTMP: $rtmpUrl" }
        if ($flvUrl)  { Write-Host "    FLV:  $flvUrl" }
    }
}

# --- Filter by protocol (RTMP only) ---
Write-Host "`n=== VOD - RTMP only ==="
$r = Invoke-NvrGet '/api/v1/vod?protocol=rtmp'
if ($r) {
    foreach ($v in $r) {
        $rtmpUrl = ($v.src | Where-Object { $_.protocol -eq 'rtmp' } | Select-Object -First 1).src
        Write-Host "  chid=$($v.chid)  rtmp=$rtmpUrl"
    }
}

# --- Filter by stream type (sub stream) ---
Write-Host "`n=== VOD - Sub stream ==="
$r = Invoke-NvrGet '/api/v1/vod?stream=sub'
if ($r) {
    foreach ($v in $r) {
        Write-Host "  chid=$($v.chid)  src=$($v.src | ConvertTo-Json -Depth 3 -Compress)"
    }
}

# --- Playback example ---
# To play back a specific time range, append time parameters to the stream URL.
# Example RTMP playback URL:
#   rtmp://host:port/live/1?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
# Example FLV playback URL:
#   http://host:port/live/1.flv?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
Write-Host "`n=== Playback URL Example ==="
if ($r -and $r.Count -gt 0) {
    $v = $r[0]
    $rtmp = ($v.src | Where-Object { $_.protocol -eq 'rtmp' } | Select-Object -First 1).src
    if ($rtmp) {
        Write-Host "  Base URL: $rtmp"
        Write-Host "  With time: ${rtmp}?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00"
    }
}
