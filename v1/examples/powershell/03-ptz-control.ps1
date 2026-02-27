<#
.SYNOPSIS
  03-ptz-control.ps1 - TS-API v1 PTZ Control

.DESCRIPTION
  Endpoints:
    GET /api/v1/channel/{chid}/ptz?home         - Move to home position
    GET /api/v1/channel/{chid}/ptz?move=x,y     - Continuous move (x,y: -1.0 to 1.0)
    GET /api/v1/channel/{chid}/ptz?zoom=speed   - Zoom (positive=in, negative=out)
    GET /api/v1/channel/{chid}/ptz?focus=speed  - Focus (positive=far, negative=near)
    GET /api/v1/channel/{chid}/ptz?iris=speed   - Iris (positive=open, negative=close)
    GET /api/v1/channel/{chid}/ptz?stop         - Stop all PTZ movement
    GET /api/v1/channel/{chid}/preset           - List presets
    GET /api/v1/channel/{chid}/preset/{token}/go - Go to preset

  NOTE: PTZ may return HTTP 500 if camera does not support ONVIF PTZ
        or if the ONVIF connection is unavailable.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY

$CHID = 1  # Target channel ID

# --- Go Home ---
Write-Host '=== PTZ Home ==='
$r = Invoke-NvrGet "/api/v1/channel/$CHID/ptz?home"
if ($null -eq $r) {
    Write-Host '  PTZ unavailable (ONVIF not supported or camera offline)'
    exit 0
}
Write-Host '  home -> OK'
Start-Sleep -Seconds 2

# --- Continuous Move (pan right, tilt up) ---
Write-Host "`n=== PTZ Move ==="
# x=0.5 (pan right at half speed), y=0.3 (tilt up at 30% speed)
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?move=0.5,0.3" | Out-Null
Write-Host '  move=0.5,0.3 -> OK'
Start-Sleep -Seconds 1

# --- Stop ---
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?stop" | Out-Null
Write-Host '  stop -> OK'

# --- Zoom In ---
Write-Host "`n=== PTZ Zoom ==="
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?zoom=0.5" | Out-Null
Write-Host '  zoom=0.5 (in) -> OK'
Start-Sleep -Seconds 1
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?stop" | Out-Null

# --- Zoom Out ---
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?zoom=-0.5" | Out-Null
Write-Host '  zoom=-0.5 (out) -> OK'
Start-Sleep -Seconds 1
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?stop" | Out-Null

# --- Focus ---
Write-Host "`n=== PTZ Focus ==="
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?focus=0.5" | Out-Null
Write-Host '  focus=0.5 (far) -> OK'
Start-Sleep -Seconds 1
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?stop" | Out-Null

# --- Iris ---
Write-Host "`n=== PTZ Iris ==="
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?iris=0.5" | Out-Null
Write-Host '  iris=0.5 (open) -> OK'
Start-Sleep -Seconds 1
Invoke-NvrGet "/api/v1/channel/$CHID/ptz?stop" | Out-Null

# --- List Presets ---
Write-Host "`n=== Presets ==="
$presets = Invoke-NvrGet "/api/v1/channel/$CHID/preset"
if ($presets -is [array]) {
    foreach ($p in $presets) {
        if ($p -is [PSCustomObject]) {
            Write-Host "  token=$($p.token)  name=$($p.name)"
        } else {
            Write-Host "  preset: $p"
        }
    }
    # --- Go to first preset ---
    if ($presets.Count -gt 0) {
        $first = $presets[0]
        $token = if ($first -is [PSCustomObject]) { $first.token } else { $first }
        Write-Host "`n=== Go to Preset (token=$token) ==="
        Invoke-NvrGet "/api/v1/channel/$CHID/preset/$token/go" | Out-Null
        Write-Host "  preset/$token/go -> OK"
    }
} elseif ($presets -is [PSCustomObject] -and $presets.code) {
    Write-Host "  No presets (code=$($presets.code))"
} else {
    Write-Host "  $presets"
}
