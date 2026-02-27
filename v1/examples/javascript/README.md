# TS-API v1 JavaScript Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Node.js 18+
- `ws` package (for WebSocket examples only): `npm install`

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
# Install WebSocket dependency (first time only)
npm install

# Run examples
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... node 02-channels.js
```

## Files

| File | Topic |
|------|-------|
| [`config.js`](config.js) | Shared configuration |
| [`http.js`](http.js) | Shared HTTP client |
| [`01-login.js`](01-login.js) | JWT authentication demo |
| [`02-channels.js`](02-channels.js) | Channel list and query |
| [`03-ptz-control.js`](03-ptz-control.js) | PTZ camera control |
| [`04-recording-search.js`](04-recording-search.js) | Recording segment search |
| [`05-event-log.js`](05-event-log.js) | Event log query |
| [`06-lpr-search.js`](06-lpr-search.js) | LPR data search |
| [`07-vod-stream.js`](07-vod-stream.js) | VOD stream URLs (RTMP, FLV) |
| [`08-system-info.js`](08-system-info.js) | System status |
| [`09-push-notification.js`](09-push-notification.js) | External event push |
| [`10-parking.js`](10-parking.js) | Parking management |
| [`11-emergency.js`](11-emergency.js) | Emergency call management |
| [`12-websocket-events.js`](12-websocket-events.js) | WS event subscription |
| [`13-websocket-parking-lot.js`](13-websocket-parking-lot.js) | WS parking lot monitoring |
| [`14-websocket-parking-spot.js`](14-websocket-parking-spot.js) | WS parking spot monitoring |
| [`15-websocket-export.js`](15-websocket-export.js) | WS recording export |
