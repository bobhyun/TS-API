# TS-API v1 Swift Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Swift 5.5+ (macOS 12+ / Linux with Swift toolchain)
- No external dependencies (Foundation only)

## API Key Setup

```bash
# 1. Login as admin
curl -sk -X POST https://SERVER/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'

# 2. Create API Key (use accessToken from step 1)
curl -sk -X POST https://SERVER/api/v1/auth/apikey \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"dev-test","permissions":["*"]}'

# 3. Set environment variable
export NVR_API_KEY=tsapi_key_...
```

> Replace `SERVER`, `admin`, and `1234` with your actual server address, username, and password.

## Environment Variables

| Variable     | Default     | Description                  |
|--------------|-------------|------------------------------|
| `NVR_API_KEY`| *(required)*| API Key for authentication   |
| `NVR_HOST`   | `localhost` | Server hostname              |
| `NVR_SCHEME` | `https`     | Protocol (http/https)        |
| `NVR_PORT`   | `443`/`80`  | Server port                  |

## Build & Run

```bash
# Compile (include NvrClient.swift with every example)
swiftc -o example NvrClient.swift 02-channels.swift

# Run
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./example
```

## Files

| File | Topic |
|------|-------|
| [`NvrClient.swift`](NvrClient.swift) | Shared HTTP/WebSocket client |
| [`01-login.swift`](01-login.swift) | JWT authentication demo |
| [`02-channels.swift`](02-channels.swift) | Channel list and query |
| [`03-ptz-control.swift`](03-ptz-control.swift) | PTZ camera control |
| [`04-recording-search.swift`](04-recording-search.swift) | Recording segment search |
| [`05-event-log.swift`](05-event-log.swift) | Event log query |
| [`06-lpr-search.swift`](06-lpr-search.swift) | LPR data search |
| [`07-vod-stream.swift`](07-vod-stream.swift) | VOD stream URLs (RTMP, FLV) |
| [`08-system-info.swift`](08-system-info.swift) | System status |
| [`09-push.swift`](09-push.swift) | External event push |
| [`10-parking.swift`](10-parking.swift) | Parking management |
| [`11-emergency.swift`](11-emergency.swift) | Emergency call management |
| [`12-websocket-events.swift`](12-websocket-events.swift) | WS event subscription |
| [`13-websocket-parking-lot.swift`](13-websocket-parking-lot.swift) | WS parking lot monitoring |
| [`14-websocket-parking-spot.swift`](14-websocket-parking-spot.swift) | WS parking spot monitoring |
| [`15-websocket-export.swift`](15-websocket-export.swift) | WS recording export |
