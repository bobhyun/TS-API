<#
.SYNOPSIS
  11-emergency.ps1 - TS-API v1 Emergency Call Device List

.DESCRIPTION
  Endpoint:
    GET /api/v1/emergency  - Emergency call device list

  Response:
    [
      {
        "id": 1,
        "code": "EM-001",
        "name": "Fire Alarm",
        "linkedChannel": [1, 2, 3]
      }
    ]

  Note: Requires Emergency Call license. Returns 404 if not supported.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- Emergency Call Device List ---
$devices = Invoke-NvrGet '/api/v1/emergency'
Write-Host '=== Emergency Devices ==='

if ($devices) {
    Write-Host "  Total: $($devices.Count) device(s)"
    foreach ($dev in $devices) {
        $chans = if ($dev.linkedChannel) { $dev.linkedChannel -join ',' } else { '' }
        Write-Host "  id=$($dev.id)  code=$($dev.code)  name=$($dev.name)  linkedChannel=[$chans]"
    }
} else {
    Write-Host '  Emergency Call not enabled on this server (license required)'
}
