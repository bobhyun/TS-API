<#
.SYNOPSIS
  13-websocket-parking-lot.ps1 - TS-API v1 WebSocket Parking Lot Count Monitoring

.DESCRIPTION
  Subscribes to parkingCount topic for real-time lot occupancy changes.

  Endpoint:
    ws://host:port/wsapi/v1/events?topics=parkingCount&token={accessToken}

  Auth:
    Header: Authorization: Bearer {accessToken}  (primary)
    Header: X-API-Key: {apiKey}                  (alternative)
    Query:  ?token={accessToken}                 (browser fallback)
    Query:  ?apikey={apiKey}                     (browser fallback)

  Optional filter: &lot=1,2 (filter by parking lot ID)

  See also: 14-websocket-parking-spot.ps1 for individual spot monitoring.

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


Write-Host '=== WebSocket Parking Count Monitoring (30 seconds) ==='

# Optional filter: &lot=1,2
$url = "$WS_URL/wsapi/v1/events?topics=parkingCount&apikey=$NVR_API_KEY"
$msgCount = 0
$ws = $null

try {
    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    $ws.Options.SetRequestHeader('X-API-Key', $NVR_API_KEY)
    if ($NVR_SCHEME -eq 'https' -and $PSVersionTable.PSVersion.Major -ge 7) {
        $ws.Options.RemoteCertificateValidationCallback = { $true }
    }

    $ws.ConnectAsync([Uri]$url, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
    Write-Host "  Connected! Waiting for parking count events...`n"

    $deadline = (Get-Date).AddSeconds(30)
    while ((Get-Date) -lt $deadline -and $ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $raw = Receive-WsMessage $ws 3000
        if ($null -eq $raw) { continue }

        $msg = $raw | ConvertFrom-Json
        $msgCount++

        # First message is subscription confirmation
        if ($msg.subscriberId) {
            Write-Host "  Subscribed (id=$($msg.subscriberId))"
            continue
        }

        # parkingCount: {topic, updated: [{id, name, type, maxCount, count}, ...]}
        foreach ($lot in $msg.updated) {
            $maxCount = if ($lot.maxCount) { $lot.maxCount } else { 0 }
            $count    = if ($lot.count)    { $lot.count }    else { 0 }
            $available = $maxCount - $count
            Write-Host "  [$($lot.id)] $($lot.name) ($($lot.type)): $count/$maxCount (available=$available)"
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
