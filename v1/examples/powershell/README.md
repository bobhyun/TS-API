# TS-API v1 PowerShell Examples

**English** | [한국어](README.ko.md)

PowerShell examples for the TS-API v1 RESTful API. Each example authenticates via **API Key** (`X-API-Key` header) and can be run independently.

> **API Reference**: [tsapi-v1.md](../../tsapi-v1.md)

## Prerequisites

- **PowerShell 7+** (recommended) or Windows PowerShell 5.1
- No external modules required (uses built-in `Invoke-RestMethod` and `System.Net.WebSockets.ClientWebSocket`)

### Install PowerShell 7

```powershell
# Windows (winget)
winget install Microsoft.PowerShell

# Or download from: https://github.com/PowerShell/PowerShell/releases
```

## API Key Setup

All examples (except `01-login.ps1`) require an API Key. Issue one using `curl` or PowerShell:

```powershell
# 1. Login as admin to get a JWT token
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('admin:1234'))
$r = Invoke-RestMethod -Uri 'https://SERVER/api/v1/auth/login' `
  -Method Post -ContentType 'application/json' `
  -Body (@{ auth = $auth } | ConvertTo-Json) -SkipCertificateCheck
# $r.accessToken contains the JWT

# 2. Create an API Key (use the accessToken from step 1)
$r2 = Invoke-RestMethod -Uri 'https://SERVER/api/v1/auth/apikey' `
  -Method Post -ContentType 'application/json' `
  -Headers @{ Authorization = "Bearer $($r.accessToken)" } `
  -Body (@{ name = 'dev-test'; permissions = @('*') } | ConvertTo-Json) `
  -SkipCertificateCheck
# $r2.key contains the API Key (shown only once!)

# 3. Set the API Key as an environment variable
$env:NVR_API_KEY = $r2.key
```

> Replace `SERVER`, `admin`, and `1234` with your actual server address, username, and password.
>
> The API Key is shown only once at creation. Store it securely.

## Environment Variables

| Variable       | Default     | Description                      |
|----------------|-------------|----------------------------------|
| `NVR_API_KEY`  | *(required)* | API Key for authentication      |
| `NVR_HOST`     | `localhost` | Server hostname                  |
| `NVR_SCHEME`   | `https`     | Protocol (`http` or `https`)     |
| `NVR_PORT`     | `443`/`80`  | Server port (default by scheme)  |

## Quick Start

```powershell
# Set environment
$env:NVR_HOST = '192.168.0.100'
$env:NVR_API_KEY = 'tsapi_key_...'

# Run any example
pwsh 02-channels.ps1
pwsh 08-system-info.ps1
pwsh 12-websocket-events.ps1
```

## Examples

| File | Description |
|------|-------------|
| [`config.ps1`](config.ps1) | Shared configuration (env vars, URL build, SSL) |
| [`http.ps1`](http.ps1) | HTTP helper functions (Get/Post/Put/Delete, JWT) |
| [`01-login.ps1`](01-login.ps1) | JWT authentication, refresh, logout, API Key CRUD |
| [`02-channels.ps1`](02-channels.ps1) | Channel list, status, capabilities, info |
| [`03-ptz-control.ps1`](03-ptz-control.ps1) | PTZ home/move/stop/zoom/focus/iris/preset |
| [`04-recording-search.ps1`](04-recording-search.ps1) | Recording days and minutes search |
| [`05-event-log.ps1`](05-event-log.ps1) | Event types and log search with pagination |
| [`06-lpr-search.ps1`](06-lpr-search.ps1) | LPR sources, log, keyword, similar plate search |
| [`07-vod-stream.ps1`](07-vod-stream.ps1) | Live/recording stream URLs |
| [`08-system-info.ps1`](08-system-info.ps1) | Server/system info, health, HDD SMART |
| [`09-push.ps1`](09-push.ps1) | LPR push, emergency call push |
| [`10-parking.ps1`](10-parking.ps1) | Parking lot/spot management |
| [`11-emergency.ps1`](11-emergency.ps1) | Emergency call device list |
| [`12-websocket-events.ps1`](12-websocket-events.ps1) | WS real-time event subscription |
| [`13-websocket-parking-lot.ps1`](13-websocket-parking-lot.ps1) | WS parking lot count monitoring |
| [`14-websocket-parking-spot.ps1`](14-websocket-parking-spot.ps1) | WS parking spot monitoring |
| [`15-websocket-export.ps1`](15-websocket-export.ps1) | WS recording data export |

## Notes

- **SSL**: PowerShell 7+ uses `-SkipCertificateCheck` splatting. Windows PowerShell 5.1 uses `TrustAllCertsPolicy` for self-signed certificates.
- **WebSocket**: Uses `System.Net.WebSockets.ClientWebSocket` (built-in .NET class, no external dependencies).
- **Korean text**: Console encoding is set to UTF-8 automatically in `config.ps1`.
- **Authentication**: `01-login.ps1` uses JWT (username/password). All other examples use API Key.
- Channel IDs are **1-based** (e.g., channel 1, 2, 3...).
- Time format: **ISO 8601** (e.g., `2026-01-15T10:30:00`).
