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
    GET /api/v1/system/health?item=systemDisk
                                          - System disk (database and logs) status
    GET /api/v1/system/hddsmart           - HDD S.M.A.R.T. data
    GET /api/v1/system/notices?lang=ko-KR - Notices currently in effect

  Note: item=storage returns its data in the 'disk' field (NOT 'storage').
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

# --- System Disk ---
# Holds the database and logs (normally C:), separate from the recording disks.
# When it is full, records stop being saved even if the recording disks have room.
# Watch status here, not only disk[].
Write-Host "`n=== System Disk ==="
$r = Invoke-NvrGet '/api/v1/system/health?item=systemDisk'
if ($r) {
    $sd = $r.systemDisk
    Write-Host "  drive=$($sd.drive) free=$($sd.freeSpace)/$($sd.totalSpace) status=$($sd.status) dataWriteFailed=$($sd.dataWriteFailed)"
}

# --- System Notices ---
# Conditions in effect right now (raised, updated, cleared).
# message is keyed by language code: en-US is always present,
# plus the requested lang when it is not English.
Write-Host "`n=== System Notices ==="
$lang = 'ko-KR'
$notices = @(Invoke-NvrGet "/api/v1/system/notices?lang=$lang")
if ($notices.Count -eq 0) {
    Write-Host '  (no notices)'
}
foreach ($n in $notices) {
    $text = $n.message.$lang
    if (-not $text) { $text = $n.message.'en-US' }
    Write-Host "  [$($n.severity)] $($n.kind): $text"
}

# --- HDD S.M.A.R.T. ---
Write-Host "`n=== HDD S.M.A.R.T. ==="
$r = Invoke-NvrGet '/api/v1/system/hddsmart'
if ($r) {
    Write-Host "  $($r | ConvertTo-Json -Depth 5)"
} else {
    Write-Host '  S.M.A.R.T. may not be available'
}
