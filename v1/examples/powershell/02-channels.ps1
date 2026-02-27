<#
.SYNOPSIS
  02-channels.ps1 - TS-API v1 Channel

.DESCRIPTION
  Endpoints:
    GET /api/v1/channel              - List all channels
    GET /api/v1/channel?staticSrc    - Include static stream source URLs
    GET /api/v1/channel?caps         - Include channel capabilities
    GET /api/v1/channel/status?recordingStatus - Recording status per channel
    GET /api/v1/channel/{chid}/info?caps       - Single channel capabilities

  Channel fields: chid, title, displayName (NOT 'name')
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- List all channels ---
$channels = Invoke-NvrGet '/api/v1/channel'
Write-Host "=== Channels ($($channels.Count)) ==="
foreach ($ch in $channels) {
    Write-Host "  chid=$($ch.chid)  title=$($ch.title)  displayName=$($ch.displayName)"
}

# --- Static source URLs (RTMP/FLV addresses for each channel) ---
$r = Invoke-NvrGet '/api/v1/channel?staticSrc'
Write-Host "`n=== Channels with staticSrc ==="
foreach ($ch in $r) {
    Write-Host "  chid=$($ch.chid)  staticSrc=$($ch.staticSrc)"
}

# --- Channel capabilities ---
$r = Invoke-NvrGet '/api/v1/channel?caps'
Write-Host "`n=== Channels with caps ==="
foreach ($ch in $r) {
    Write-Host "  chid=$($ch.chid)  caps=$($ch.caps)"
}

# --- Recording status ---
$r = Invoke-NvrGet '/api/v1/channel/status?recordingStatus'
Write-Host "`n=== Recording Status ==="
foreach ($s in $r) {
    Write-Host "  chid=$($s.chid)  recording=$($s.recordingStatus)"
}

# --- Single channel capabilities (channel 1) ---
if ($channels -and $channels.Count -gt 0) {
    $chid = $channels[0].chid
    $r = Invoke-NvrGet "/api/v1/channel/$chid/info?caps"
    Write-Host "`n=== Channel $chid Capabilities ==="
    Write-Host "  $($r | ConvertTo-Json -Depth 5 -Compress)"
}
