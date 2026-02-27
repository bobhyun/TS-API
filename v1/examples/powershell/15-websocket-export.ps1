<#
.SYNOPSIS
  15-websocket-export.ps1 - TS-API v1 WebSocket Recording Export

.DESCRIPTION
  Recording data backup/export via WebSocket.

  Endpoint:
    ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...&token={accessToken}

  Auth:
    Header: Authorization: Bearer {accessToken}  (primary)
    Header: X-API-Key: {apiKey}                  (alternative)
    Query:  ?token={accessToken}                 (browser fallback)
    Query:  ?apikey={apiKey}                     (browser fallback)

  Flow:
    1. Connect with channel and time range
    2. Receive stage="ready" with task.id
    3. Receive stage="fileEnd" with download URL
    4. Send { task, cmd: "next" } for next file
    5. Receive stage="end" when complete

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


# Time range: yesterday 00:00 ~ 00:10
$yesterday = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
$timeBegin = "${yesterday}T00:00:00"
$timeEnd   = "${yesterday}T00:10:00"

Write-Host '=== WebSocket Recording Export ==='
Write-Host "  Channel: 1,  $timeBegin ~ $timeEnd"

$url = "$WS_URL/wsapi/v1/export?ch=1&timeBegin=$timeBegin&timeEnd=$timeEnd&apikey=$NVR_API_KEY"
$taskId = $null
$ws = $null

try {
    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    $ws.Options.SetRequestHeader('X-API-Key', $NVR_API_KEY)
    if ($NVR_SCHEME -eq 'https' -and $PSVersionTable.PSVersion.Major -ge 7) {
        $ws.Options.RemoteCertificateValidationCallback = { $true }
    }

    $ws.ConnectAsync([Uri]$url, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
    Write-Host '  Connected'

    $deadline = (Get-Date).AddSeconds(60)
    $done = $false

    while (-not $done -and (Get-Date) -lt $deadline -and $ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $raw = Receive-WsMessage $ws 5000
        if ($null -eq $raw) { continue }

        $msg = $raw | ConvertFrom-Json
        $stage = $msg.stage

        switch ($stage) {
            'ready' {
                # Check status code (code:-1 = no recording in range)
                $status = $msg.status
                if ($status -and $status.code -ne 0) {
                    $errMsg = if ($status.message) { $status.message } else { $raw }
                    Write-Host "  Ready - Error: $errMsg"
                    $done = $true
                    break
                }
                $taskId = $msg.task.id
                Write-Host "  Ready - Task ID: $taskId"
            }
            'fileEnd' {
                # download: [{fileName, src}, ...]
                $dlArr = $msg.channel.file.download
                $src = if ($dlArr -and $dlArr.Count -gt 0) { $dlArr[0].src } else { 'N/A' }
                Write-Host "  File ready: $src"
                if ($taskId) {
                    $cmd = @{ task = [string]$taskId; cmd = 'next' } | ConvertTo-Json -Compress
                    Send-WsMessage $ws $cmd
                }
            }
            'end' {
                Write-Host '  Export complete!'
                $done = $true
            }
            'error' {
                $errMsg = if ($msg.message) { $msg.message } else { $raw }
                Write-Host "  Error: $errMsg"
                $done = $true
            }
            default {
                Write-Host "  [$stage] $raw"
            }
        }
    }

    if (-not $done -and $taskId) {
        Write-Host '  Timeout - cancelling...'
        $cmd = @{ task = [string]$taskId; cmd = 'cancel' } | ConvertTo-Json -Compress
        Send-WsMessage $ws $cmd
    }

    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, '',
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
} catch {
    Write-Host "  Failed: $_"
} finally {
    if ($ws) { $ws.Dispose() }
}
