# TS-API v1 Go Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Go 1.21+
- `gorilla/websocket` (for WebSocket examples): `go mod tidy`

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

## Run

```bash
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... go run ./02_channels
```

## Directory Structure

| Directory | Topic |
|-----------|-------|
| [`tsapi/`](tsapi/) | Shared client library |
| [`01_login/`](01_login/) | JWT authentication demo |
| [`02_channels/`](02_channels/) | Channel list and query |
| [`03_ptz/`](03_ptz/) | PTZ camera control |
| [`04_recording/`](04_recording/) | Recording segment search |
| [`05_events/`](05_events/) | Event log query |
| [`06_lpr/`](06_lpr/) | LPR data search |
| [`07_vod/`](07_vod/) | VOD stream URLs (RTMP, FLV) |
| [`08_system/`](08_system/) | System status |
| [`09_push/`](09_push/) | External event push |
| [`10_parking/`](10_parking/) | Parking management |
| [`11_emergency/`](11_emergency/) | Emergency call management |
| [`12_ws_events/`](12_ws_events/) | WS event subscription |
| [`13_ws_parking_lot/`](13_ws_parking_lot/) | WS parking lot monitoring |
| [`14_ws_parking_spot/`](14_ws_parking_spot/) | WS parking spot monitoring |
| [`15_ws_export/`](15_ws_export/) | WS recording export |
