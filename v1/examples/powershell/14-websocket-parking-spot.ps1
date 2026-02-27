<#
.SYNOPSIS
  14-websocket-parking-spot.ps1 - TS-API v1 WebSocket Parking Spot Monitoring

.DESCRIPTION
  Subscribes to parkingSpot topic for individual spot status changes.

  Endpoint:
    ws://host:port/wsapi/v1/events?topics=parkingSpot&token={accessToken}

  Auth:
    Header: Authorization: Bearer {accessToken}  (primary)
    Header: X-API-Key: {apiKey}                  (alternative)
    Query:  ?token={accessToken}                 (browser fallback)
    Query:  ?apikey={apiKey}                     (browser fallback)

  Optional filters (OR logic):
    &ch=1,2       - spots belonging to channels 1, 2
    &lot=1,2      - spots belonging to parking lots 1, 2
    &spot=100,200 - specific spot IDs

  Events:
    currentStatus  - initial full state on connect (all zone types)
    statusChanged  - only changed spots after initial (type="spot" only)

  Zone types (in currentStatus):
    spot         - parking space (has occupied, vehicle, category)
    entrance     - entry gate (category=null, no occupied field)
    exit         - exit gate
    noParking    - no-parking zone
    recognition  - recognition-only zone

  Note: statusChanged events only fire for type="spot"
  Note: chid is 1-based

  See also: 13-websocket-parking-lot.ps1 for lot-level count monitoring.

  Uses System.Net.WebSockets.ClientWebSocket (no external dependencies).
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"

if (-not $NVR_API_KEY) {
    Write-Host 'Error: NVR_API_KEY environment variable is required'
    exit 1
}


function Send-WsMessage([System.Net.WebSockets.ClientWebSocket]$Ws, [string]$Message) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
    $segment = [ArraySegment[byte]]::new($bytes)
    $Ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true,
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
}

function Receive-WsMessage([System.Net.WebSockets.ClientWebSocket]$Ws, [int]$TimeoutMs = 5000) {
    $buffer = [byte[]]::new(8192)
    $ms = [System.IO.MemoryStream]::new()
    $cts = [System.Threading.CancellationTokenSource]::new($TimeoutMs)
    try {
        do {
            $segment = [ArraySegment[byte]]::new($buffer)
            $result = $Ws.ReceiveAsync($segment, $cts.Token).GetAwaiter().GetResult()
            if ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
                return $null
            }
            $ms.Write($buffer, 0, $result.Count)
        } while (-not $result.EndOfMessage)
        return [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
    } catch [System.OperationCanceledException] {
        return $null
    } finally {
        $ms.Dispose()
        $cts.Dispose()
    }
}


Write-Host '=== WebSocket Parking Spot Monitoring (30 seconds) ==='

# Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
$url = "$WS_URL/wsapi/v1/events?topics=parkingSpot&apikey=$NVR_API_KEY"
$msgCount = 0
$ws = $null

try {
    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    $ws.Options.SetRequestHeader('X-API-Key', $NVR_API_KEY)
    if ($NVR_SCHEME -eq 'https' -and $PSVersionTable.PSVersion.Major -ge 7) {
        $ws.Options.RemoteCertificateValidationCallback = { $true }
    }

    $ws.ConnectAsync([Uri]$url, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
    Write-Host "  Connected! Waiting for spot events...`n"

    $deadline = (Get-Date).AddSeconds(30)
    while ((Get-Date) -lt $deadline -and $ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $raw = Receive-WsMessage $ws 3000
        if ($null -eq $raw) { continue }

        $msg = $raw | ConvertFrom-Json
        $msgCount++
        $event = $msg.event
        $spots = $msg.spots

        if ($event -eq 'currentStatus') {
            Write-Host "  [currentStatus] $($spots.Count) zones"
            foreach ($s in $spots) {
                $zoneType = if ($s.type) { $s.type } else { 'spot' }
                if ($zoneType -eq 'spot') {
                    if ($s.occupied) {
                        $v = if ($s.vehicle) { $s.vehicle } else { @{} }
                        $plateNo = if ($v.plateNo) { $v.plateNo } else { '' }
                        $score   = if ($v.score)   { '{0:F1}' -f $v.score } else { '0.0' }
                        Write-Host "    [$($s.id)] $($s.name) ($($s.category)): occupied [$plateNo ${score}%]"
                    } else {
                        Write-Host "    [$($s.id)] $($s.name) ($($s.category)): empty"
                    }
                } else {
                    Write-Host "    [$($s.id)] $($s.name) (type=$zoneType)"
                }
            }
        }
        elseif ($event -eq 'statusChanged') {
            # statusChanged only fires for type="spot"
            foreach ($s in $spots) {
                $status = if ($s.occupied) { 'occupied' } else { 'empty' }
                Write-Host "  [statusChanged] spot $($s.id) -> $status"
                if ($s.occupied -and $s.vehicle) {
                    $v = $s.vehicle
                    Write-Host "    plate: $($v.plateNo)  score: $($v.score)%"
                }
            }
        }
    }

    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, '',
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
} catch {
    Write-Host "  Failed: $_"
} finally {
    if ($ws) { $ws.Dispose() }
}

Write-Host "`n  Received $msgCount events"
