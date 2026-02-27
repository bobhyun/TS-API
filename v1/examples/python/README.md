# TS-API v1 Python Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Python 3.6+
- `requests` library: `pip install requests`
- `websocket-client` library (for WebSocket examples): `pip install websocket-client`

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
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... python 02_channels.py
```

## Files

| File | Topic |
|------|-------|
| [`config.py`](config.py) | Shared configuration |
| [`http_client.py`](http_client.py) | Shared HTTP client (NvrClient) |
| [`01_login.py`](01_login.py) | JWT authentication demo |
| [`02_channels.py`](02_channels.py) | Channel list and query |
| [`03_ptz_control.py`](03_ptz_control.py) | PTZ camera control |
| [`04_recording_search.py`](04_recording_search.py) | Recording segment search |
| [`05_event_log.py`](05_event_log.py) | Event log query |
| [`06_lpr_search.py`](06_lpr_search.py) | LPR data search |
| [`07_vod_stream.py`](07_vod_stream.py) | VOD stream URLs (RTMP, FLV) |
| [`08_system_info.py`](08_system_info.py) | System status |
| [`09_push.py`](09_push.py) | External event push |
| [`10_parking.py`](10_parking.py) | Parking management |
| [`11_emergency.py`](11_emergency.py) | Emergency call management |
| [`12_websocket_events.py`](12_websocket_events.py) | WS event subscription |
| [`13_websocket_parking_lot.py`](13_websocket_parking_lot.py) | WS parking lot monitoring |
| [`14_websocket_parking_spot.py`](14_websocket_parking_spot.py) | WS parking spot monitoring |
| [`15_websocket_export.py`](15_websocket_export.py) | WS recording export |
