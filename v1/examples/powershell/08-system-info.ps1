<#
.SYNOPSIS
  08-system-info.ps1 - TS-API v1 System Information

.DESCRIPTION
  Endpoints:
    GET /api/v1/info?all
        - All NVR info (version, license, etc.)

    GET /api/v1/system/info?item=os       - OS information
    GET /api/v1/system/info?item=cpu      - CPU usage
    GET /api/v1/system/info?item=storage  - Disk info (response field is 'disk')
    GET /api/v1/system/info?item=network  - Network interfaces

    GET /api/v1/system/health             - System health status
    GET /api/v1/system/hddsmart           - HDD S.M.A.R.T. data

  Note: The 'storage' query returns data with the response field named 'disk'.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}
Set-NvrApiKey $NVR_API_KEY


# --- NVR Info (all) ---
Write-Host '=== NVR Info ==='
$info = Invoke-NvrGet '/api/v1/info?all'
if ($info) {
    Write-Host "  $($info | ConvertTo-Json -Depth 5)"
}

# --- System Info: OS ---
Write-Host "`n=== OS Info ==="
$r = Invoke-NvrGet '/api/v1/system/info?item=os'
if ($r) { Write-Host "  $($r | ConvertTo-Json -Depth 3 -Compress)" }

# --- System Info: CPU ---
Write-Host "`n=== CPU Info ==="
$r = Invoke-NvrGet '/api/v1/system/info?item=cpu'
if ($r) { Write-Host "  $($r | ConvertTo-Json -Depth 3 -Compress)" }

# --- System Info: Storage ---
# NOTE: query param is 'storage' but response field is 'disk'
Write-Host "`n=== Storage Info ==="
$r = Invoke-NvrGet '/api/v1/system/info?item=storage'
if ($r) {
    # Access via 'disk' field in response
    $disks = if ($r.disk) { $r.disk } else { $r }
    Write-Host "  $($disks | ConvertTo-Json -Depth 5)"
}

# --- System Info: Network ---
Write-Host "`n=== Network Info ==="
$r = Invoke-NvrGet '/api/v1/system/info?item=network'
if ($r) { Write-Host "  $($r | ConvertTo-Json -Depth 5)" }

# --- System Health ---
Write-Host "`n=== System Health ==="
$r = Invoke-NvrGet '/api/v1/system/health'
if ($r) { Write-Host "  $($r | ConvertTo-Json -Depth 5)" }

# --- HDD S.M.A.R.T. ---
Write-Host "`n=== HDD S.M.A.R.T. ==="
$r = Invoke-NvrGet '/api/v1/system/hddsmart'
if ($r) {
    Write-Host "  $($r | ConvertTo-Json -Depth 5)"
} else {
    Write-Host '  S.M.A.R.T. may not be available'
}
