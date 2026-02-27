# TS-API Reference

**English** | [한국어](README.ko.md)

**TS-API** is a web API built into the video surveillance product lineup — **TS-CMS**, **TS-NVR**, and **TS-IVR** — by TS Solution Corp.

> TS-API v1 web server is available from TS-IVR, TS-NVR, TS-CMS v3.0.0 and later.
> The RESTful API (`/api/v1`) supports JWT and API Key authentication with a path-based design.

## Table of Contents

1. [API Versions](#1-api-versions)
2. [Quick Start](#2-quick-start)
3. [Documentation](#3-documentation)
4. [Endpoint Summary](#4-endpoint-summary)
5. [Response Format](#5-response-format)
6. [HTTP Status Codes](#6-http-status-codes)
7. [License-dependent Features](#7-license-dependent-features)
8. [WebSocket API](#8-websocket-api)

---

## 1. API Versions

| Version | Style | Base URL | Documentation |
|---------|-------|----------|---------------|
| [v1](v1/tsapi-v1.md) | RESTful Path | `/api/v1`, `/wsapi/v1` | [API Guide](v1/tsapi-v1.md) · [Examples](v1/examples/) |
| [legacy](legacy/en/TS-API.en.md) | Query String | `/api` | [API Guide](legacy/en/TS-API.en.md) · [Examples](legacy/en/examples/) |

---

## 2. Quick Start

### 2.1. Login (JWT)
```bash
# JWT login - returns accessToken
# Note: auth = base64("admin:1234"). Use your actual NVR account credentials.
curl -X POST "http://localhost/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'
# Response: {"accessToken":"eyJ...","refreshToken":"...","expiresIn":3600,"tokenType":"Bearer"}
```

### 2.2. Get Channels
```bash
curl "http://localhost/api/v1/channel" \
  -H "Authorization: Bearer {accessToken}"
```

### 2.3. PTZ Control
```bash
curl "http://localhost/api/v1/channel/1/ptz?home" \
  -H "Authorization: Bearer {accessToken}"
```

### 2.4. Alternative: API Key (for integrations)
```bash
# Create API Key (admin only - JWT authentication required)
curl -X POST "http://localhost/api/v1/auth/apikey" \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{"name":"Monitoring System"}'

# Use API Key (all v1 endpoints accessible, no login required)
curl "http://localhost/api/v1/channel" \
  -H "X-API-Key: tsapi_key_..."
```

---

## 3. Documentation

- [v1 API Guide](v1/tsapi-v1.md) - RESTful path based API
- [v1 Examples](v1/examples/) - Code examples for v1 API (9 languages)
- [Legacy API Guide](legacy/en/TS-API.en.md) - Legacy query-string based API
- [Migration Guide](v1/MIGRATION.md) - Migrating from legacy to v1

---

## 4. Endpoint Summary

### 4.1. v1 REST API Endpoints

#### 4.1.1. Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/login` | POST | JWT login (username, password) |
| `/api/v1/auth/refresh` | POST | Refresh access token (refreshToken) |
| `/api/v1/auth/logout` | POST | Logout (invalidate refreshToken) |
| `/api/v1/auth/apikey` | POST | Create API Key (admin only) |
| `/api/v1/auth/apikey` | GET | List API Keys |
| `/api/v1/auth/apikey/{id}` | DELETE | Delete API Key |
| `/api/v1/auth` | GET | Legacy (blocked: use POST /api/v1/auth/login) |

#### 4.1.2. Server Info
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/info` | GET | Server information (apiVersion, siteName, timezone, product, license) |

#### 4.1.3. System
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/system/info` | GET | System information (OS, CPU, Storage, Network) |
| `/api/v1/system/health` | GET | System health (CPU%, Memory, Disk usage) |
| `/api/v1/system/hddsmart` | GET | HDD S.M.A.R.T information |
| `/api/v1/system/restart` | POST | Server restart |
| `/api/v1/system/reboot` | POST | System reboot |

#### 4.1.4. Channel
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/channel` | GET | Channel (camera) list |
| `/api/v1/channel` | POST | Add channel |
| `/api/v1/channel/{id}` | DELETE | Delete channel |
| `/api/v1/channel/status` | GET | Channel connection/recording status |
| `/api/v1/channel/info` | GET | Channel details |
| `/api/v1/channel/{id}/ptz` | GET | PTZ control (home, move, zoom, focus) |
| `/api/v1/channel/{id}/preset` | GET/POST/PUT/DELETE | Preset management |
| `/api/v1/channel/{id}/relay` | GET/PUT | Relay output control |
| `/api/v1/channel/{id}/reboot` | POST | Remote camera reboot |

#### 4.1.5. Recording
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/recording/days` | GET | Recording days (for calendar) |
| `/api/v1/recording/minutes` | GET | Recording minutes (for timeline) |

#### 4.1.6. Event
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/event/type` | GET | Event type list |
| `/api/v1/event/log` | GET | Event log search |
| `/api/v1/event/trigger` | PUT | Manual event trigger |

#### 4.1.7. LPR (License Plate Recognition)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/lpr/source` | GET | LPR source (recognition point) list |
| `/api/v1/lpr/log` | GET | License plate recognition log search |
| `/api/v1/lpr/similar` | GET | Similar plate search |

#### 4.1.8. Object Detection
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/object/type` | GET | Detectable object types |
| `/api/v1/object/attr` | GET | Object attribute list |
| `/api/v1/object/log` | GET | Detected object search |

#### 4.1.9. Face Search
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/face/search` | POST | Image-based face search |
| `/api/v1/face/search` | GET | Face list by time range |

#### 4.1.10. VOD (Video on Demand)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/vod` | GET | Live/recording stream URL retrieval |

#### 4.1.11. Other
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/emergency` | GET | Emergency call device list |
| `/api/v1/push` | POST | External event reception |
| `/api/v1/parking/lot` | GET | Parking lot list/status |
| `/api/v1/parking/spot` | GET | Parking spot list/status |

### 4.2. v1 WebSocket Endpoints

| Endpoint | Description |
|----------|-------------|
| `/wsapi/v1/events` | Real-time event subscription (LPR, channel status, object detection, etc.) |
| `/wsapi/v1/export` | Recording data export (backup) |

---

## 5. Response Format

Response format varies by endpoint:

### 5.1. Array Response (channels, status, event types, etc.)
```json
[
  {"chid": 1, "title": "Front Door"},
  {"chid": 2, "title": "Parking Lot"}
]
```

### 5.2. Paginated List Response (event logs, LPR logs, object search)
```json
{
  "totalCount": 100,
  "at": 0,
  "data": [ ... ]
}
```

### 5.3. Error Response
```json
{
  "code": -1,
  "message": "Error description"
}
```

---

## 6. HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## 7. License-dependent Features

Some API features require a corresponding license. Returns 404 if the license is not activated.

| Feature | Related Endpoints |
|---------|-------------------|
| LPR (License Plate Recognition) | `/api/v1/lpr/*` |
| Parking guide | `/api/v1/parking/lot`, `/wsapi/v1/events?topics=parkingCount` |
| Parking spot | `/api/v1/parking/spot`, `/wsapi/v1/events?topics=parkingSpot` |
| Object detection | `/api/v1/object/*` |
| Face search | `/api/v1/face/search` |
| Emergency call | `/api/v1/emergency` |
| Push reception | `/api/v1/push` |
| Event backup | `/wsapi/v1/export` |
| Body temperature | `/wsapi/v1/events?topics=bodyTemperature` |
| Vehicle tracking | `/wsapi/v1/events?topics=vehicleTracking` |

---

## 8. WebSocket API

WebSocket API for real-time event subscription and data export.

| Version | Endpoint | Description |
|---------|----------|-------------|
| v1 | `ws://{host}:{port}/wsapi/v1/events` | Real-time event subscription |
| v1 | `ws://{host}:{port}/wsapi/v1/export` | Data export |

### 8.1. WebSocket Authentication (v1)

```javascript
// JWT (query param)
const ws = new WebSocket('ws://server:port/wsapi/v1/events?topics=LPR&token={accessToken}');

// API Key (query param)
const ws = new WebSocket('ws://server:port/wsapi/v1/events?topics=LPR&apikey=tsapi_key_...');
```

### 8.2. Event Subscription Example

```javascript
const ws = new WebSocket('ws://server/wsapi/v1/events?topics=LPR,channelStatus&apikey=tsapi_key_...');

ws.onmessage = (e) => {
  const data = JSON.parse(e.data);
  console.log('Event:', data);
};
```
