<#
.SYNOPSIS
  09-push.ps1 - TS-API v1 Push Event

.DESCRIPTION
  Endpoint:
    POST /api/v1/push
        - Push external events into the NVR
        - Requires Push license enabled on the NVR

  Event Types:
    1. LPR - Push a license plate recognition result
    2. emergencyCall - Trigger emergency call alarm

    WARNING: emergencyCall with event=callStart triggers a REAL alarm on the NVR.
             The alarm persists until callEnd is sent. Always send callEnd after callStart.

    IMPORTANT: For emergencyCall, you MUST send callEnd to stop the alarm.
               Forgetting callEnd leaves the NVR in alarm state.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- Push LPR Event ---
Write-Host '=== Push LPR Event ==='
$payload = @{
    topic   = 'LPR'
    plateNo = '12AB3456'
    src     = 'booth-01'             # Source booth code (string)
    when    = '2026-01-15 10:30:00'
}
$r = Invoke-NvrPost '/api/v1/push' -Body $payload
if ($r) {
    Write-Host "  Response: $($r | ConvertTo-Json -Depth 3 -Compress)"
} else {
    Write-Host '  Ensure Push license is enabled'
}


# --- Push Emergency Call ---
Write-Host "`n=== Push Emergency Call ==="
Write-Host '  WARNING: This triggers a REAL alarm on the NVR!'

# Uncomment the lines below to actually trigger the alarm.
# Make sure you always send callEnd after callStart.

# --- Start the emergency call ---
# Write-Host '  Sending callStart...'
# $r = Invoke-NvrPost '/api/v1/push' -Body @{
#     topic  = 'emergencyCall'
#     event  = 'callStart'
#     device = 'intercom-01'   # Device identifier
#     src    = 'lobby-entrance' # Source identifier
# }
# Write-Host "  callStart -> $(if ($r) { 'OK' } else { 'FAILED' })"
#
# Start-Sleep -Seconds 3  # Alarm is active for 3 seconds
#
# --- MUST send callEnd to stop the alarm ---
# Write-Host '  Sending callEnd...'
# $r = Invoke-NvrPost '/api/v1/push' -Body @{
#     topic  = 'emergencyCall'
#     event  = 'callEnd'
#     device = 'intercom-01'   # Device identifier
#     src    = 'lobby-entrance' # Source identifier
# }
# Write-Host "  callEnd -> $(if ($r) { 'OK' } else { 'FAILED' })"

Write-Host '  (Commented out for safety - uncomment to test)'
Write-Host '  IMPORTANT: Always send callEnd after callStart!'
