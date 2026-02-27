**English** | [한국어](README.ko.md)

# TS-API v1 curl Examples

Shell script examples for the TS-NVR REST API using `curl` and `websocat`.

## Prerequisites

- **curl** (included on most systems)
- **jq** (optional, for JSON pretty-printing) - [https://jqlang.github.io/jq/](https://jqlang.github.io/jq/)
- **websocat** (required for WebSocket examples 12-15) - [https://github.com/nickel-org/websocat](https://github.com/nickel-org/websocat)

## Quick Start

```bash
# Set environment variables
export NVR_HOST=192.168.0.100
export NVR_API_KEY=tsapi_key_...

# Run an example
bash 02-channels.sh
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NVR_HOST` | `localhost` | NVR server hostname or IP |
| `NVR_SCHEME` | `https` | Protocol (`http` or `https`) |
| `NVR_PORT` | `443` (https) / `80` (http) | Server port |
| `NVR_USER` | `admin` | Login username (01-login.sh only) |
| `NVR_PASS` | `1234` | Login password (01-login.sh only) |
| `NVR_API_KEY` | *(required)* | API Key for v1 endpoints (02-15) |
| `NVR_CHANNEL` | `1` | Target camera channel (03, 15) |

## Examples

### Authentication

| File | Description |
|------|-------------|
| [01-login.sh](01-login.sh) | JWT login/refresh/logout + API Key CRUD |

### REST API (API Key auth)

| File | Description | Endpoints |
|------|-------------|-----------|
| [02-channels.sh](02-channels.sh) | Channel list, status, capabilities | `GET channel`, `channel/status`, `channel/{id}/info` |
| [03-ptz-control.sh](03-ptz-control.sh) | PTZ camera control | `GET channel/{id}/ptz`, `channel/{id}/preset` |
| [04-recording-search.sh](04-recording-search.sh) | Recording calendar & timeline | `GET recording/days`, `recording/minutes` |
| [05-event-log.sh](05-event-log.sh) | Event search & filtering | `GET event/type`, `event/log` |
| [06-lpr-search.sh](06-lpr-search.sh) | License plate recognition search | `GET lpr/source`, `lpr/log`, `lpr/similar` |
| [07-vod-stream.sh](07-vod-stream.sh) | Live & playback stream URLs | `GET vod` |
| [08-system-info.sh](08-system-info.sh) | System & server information | `GET info`, `system/info`, `system/health`, `system/hddsmart` |
| [09-push.sh](09-push.sh) | External event push (LPR, emergency) | `POST push` |
| [10-parking.sh](10-parking.sh) | Parking lot & spot management | `GET parking/lot`, `parking/spot`, `/status` |
| [11-emergency.sh](11-emergency.sh) | Emergency call devices | `GET emergency` |

### WebSocket (websocat)

| File | Description | Endpoint |
|------|-------------|----------|
| [12-websocket-events.sh](12-websocket-events.sh) | Real-time event subscription | `wsapi/v1/events` |
| [13-websocket-parking-lot.sh](13-websocket-parking-lot.sh) | Parking lot count monitoring | `wsapi/v1/events?topics=parkingCount` |
| [14-websocket-parking-spot.sh](14-websocket-parking-spot.sh) | Parking spot occupancy monitoring | `wsapi/v1/events?topics=parkingSpot` |
| [15-websocket-export.sh](15-websocket-export.sh) | Recording data export | `wsapi/v1/export` |

## Authentication Methods

### API Key (examples 02-15)

```bash
curl -sk -H "X-API-Key: tsapi_key_..." https://nvr-server/api/v1/channel
```

> API Keys only work on `/api/v1/*` endpoints. v0 endpoints (`/api/*`) reject API Keys with 401.

### JWT Bearer Token (example 01)

```bash
# Login
AUTH=$(echo -n "admin:1234" | base64)
RESPONSE=$(curl -sk -X POST https://nvr-server/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"auth\":\"${AUTH}\"}")
TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken')

# Use token
curl -sk -H "Authorization: Bearer ${TOKEN}" https://nvr-server/api/v1/channel
```

### WebSocket Authentication

```bash
# Header auth (websocat)
websocat -k -H "X-API-Key: tsapi_key_..." wss://nvr-server/wsapi/v1/events?topics=LPR

# Query param auth (browser fallback)
# wss://nvr-server/wsapi/v1/events?topics=LPR&apikey=tsapi_key_...
# wss://nvr-server/wsapi/v1/events?topics=LPR&token=jwt_access_token
```

## Notes

- All scripts use `set -euo pipefail` for safe execution
- Self-signed certificates are accepted (`curl -k`, `websocat -k`)
- JSON output is pretty-printed with `jq` when available, raw output otherwise
- Time parameters use ISO 8601 format (e.g., `2025-01-15T09:30:00`)
- Channel IDs are 1-based
