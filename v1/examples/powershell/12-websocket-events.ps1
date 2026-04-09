<#
.SYNOPSIS
  12-websocket-events.ps1 - TS-API v1 WebSocket Real-time Event Subscription

.DESCRIPTION
  Subscribes to real-time events (LPR, channelStatus, etc.) via WebSocket.

  Two subscription modes:
    1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
    2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)

  Endpoint:
    ws://host:port/wsapi/v1/events

  Auth:
    Header: Authorization: Bearer {accessToken}  (primary)
    Header: X-API-Key: {apiKey}                  (alternative)
    Query:  ?token={accessToken}                 (browser fallback)
    Query:  ?apikey={apiKey}                     (browser fallback)

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

function New-WsClient([string]$Url) {
    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    $ws.Options.SetRequestHeader('X-API-Key', $NVR_API_KEY)

    # SSL bypass
    if ($NVR_SCHEME -eq 'https') {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $ws.Options.RemoteCertificateValidationCallback = { $true }
        }
        # PS5.1: relies on TrustAllCertsPolicy set in config.ps1
    }

    $ws.ConnectAsync([Uri]$Url, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
    return $ws
}


# ── Method 1: Subscribe via URL query params (classic) ──
Write-Host '=== Method 1: Subscribe via URL (10 seconds) ==='

$wsUrl = "$WS_URL/wsapi/v1/events?topics=LPR,channelStatus&apikey=$NVR_API_KEY"
$msgCount = 0

try {
    $ws = New-WsClient $wsUrl
    Write-Host '  Connected!'

    $deadline = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $deadline -and $ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $raw = Receive-WsMessage $ws 2000
        if ($null -eq $raw) { continue }
        $msg = $raw | ConvertFrom-Json
        $msgCount++
        $topic = if ($msg.topic) { $msg.topic } elseif ($msg.type) { $msg.type } else { '?' }
        Write-Host "  [$topic] $raw"
    }
    Write-Host "  Received $msgCount events"
    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, '',
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
} catch {
    Write-Host "  Failed: $_"
} finally {
    if ($ws) { $ws.Dispose() }
}


# ── Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) ──
Write-Host "`n=== Method 2: Dynamic Subscribe (10 seconds) ==="

$wsUrl2 = "$WS_URL/wsapi/v1/events"
$msgCount2 = 0

try {
    $ws = New-WsClient $wsUrl2
    Write-Host '  Connected (no topics yet)'

    # Phase 1: Subscribe to initial topics with per-topic filters
    Write-Host '  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)'
    Send-WsMessage $ws '{"subscribe":"channelStatus"}'
    Send-WsMessage $ws '{"subscribe":"LPR","ch":[1,2]}'

    $start = Get-Date
    $phase = 1
    while (((Get-Date) - $start).TotalSeconds -lt 10 -and $ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $elapsed = ((Get-Date) - $start).TotalSeconds

        # Phase 2 (3s): Add new topic + update existing filter
        if ($phase -eq 1 -and $elapsed -ge 3) {
            $phase = 2
            Write-Host '  [Phase 2] Add object topic + expand LPR to ch 1-4'
            Send-WsMessage $ws '{"subscribe":"object","objectTypes":["human","vehicle"]}'
            Send-WsMessage $ws '{"subscribe":"LPR","ch":[1,2,3,4]}'
        }

        # Phase 3 (6s): Unsubscribe + subscribe new + reduce channels
        if ($phase -eq 2 -and $elapsed -ge 6) {
            $phase = 3
            Write-Host '  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3'
            Send-WsMessage $ws '{"unsubscribe":"channelStatus"}'
            Send-WsMessage $ws '{"subscribe":"motionChanges","ch":[1]}'
            Send-WsMessage $ws '{"subscribe":"LPR","ch":[1,3]}'
        }

        $raw = Receive-WsMessage $ws 1000
        if ($null -eq $raw) { continue }
        $msg = $raw | ConvertFrom-Json
        $msgCount2++

        # Handle control responses
        if ($msg.type -eq 'subscribed')   { Write-Host "  Subscribed to: $($msg.topic)"; continue }
        if ($msg.type -eq 'unsubscribed') { Write-Host "  Unsubscribed from: $($msg.topic)"; continue }
        if ($msg.type -eq 'error')        { Write-Host "  Error: $($msg.message) (topic: $($msg.topic))"; continue }

        # Handle event data
        $topic = if ($msg.topic) { $msg.topic } else { '?' }
        Write-Host "  [$topic] $raw"
    }
    Write-Host "  Received $msgCount2 messages"
    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, '',
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
} catch {
    Write-Host "  Failed: $_"
} finally {
    if ($ws) { $ws.Dispose() }
}

# ─────────────────────────────────────────────────
# LPR Event Compatibility
# ─────────────────────────────────────────────────
#
# LPR events may arrive in two formats:
#
#   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
#   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
#
# To handle both formats transparently:
#
#   $msg = $raw | ConvertFrom-Json
#   if ($msg.topic -eq 'LPR') {
#       $plates = if ($msg.plates) { $msg.plates } else { @($msg) }
#       foreach ($p in $plates) {
#           Write-Host "Plate: $($p.plateNo)  Score: $($p.score)"
#       }
#   }
#
