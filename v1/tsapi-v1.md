# TS-API v1 Programming Guide

**English** | [한국어](tsapi-v1.ko.md)

> **See also:** [Migration Guide](MIGRATION.md) · [Changelog](CHANGELOG.md)

## Table of Contents

1. [Overview](#1-overview)
   - [1.1. Time Notation](#11-time-notation)
   - [1.2. Box Coordinates](#12-box-coordinates)
   - [1.3. Language (`lang`)](#13-language-lang)
2. [API Call Flow](#2-api-call-flow)
   - [2.1. Basic Flow (JWT Authentication)](#21-basic-flow-jwt-authentication)
   - [2.2. Recording Search and Playback Flow](#22-recording-search-and-playback-flow)
   - [2.3. Token Refresh Flow](#23-token-refresh-flow)
   - [2.4. API Key Flow (No Login Required)](#24-api-key-flow-no-login-required)
3. [Authentication](#3-authentication)
   - [3.1. Authentication Scope by Method](#31-authentication-scope-by-method)
   - [3.2. API Key Permission Model](#32-api-key-permission-model)
   - [3.3. JWT Authentication](#33-jwt-authentication)
   - [3.4. Storage / Media File Authentication](#34-storage--media-file-authentication)
   - [3.5. API Key Authentication](#35-api-key-authentication)
4. [Server Info](#4-server-info)
5. [System](#5-system)
   - [5.1. System Info](#51-system-info)
   - [5.2. System Health](#52-system-health)
   - [5.3. HDD S.M.A.R.T](#53-hdd-smart)
   - [5.4. System Control](#54-system-control)
   - [5.5. System Notices](#55-system-notices)
6. [Channel](#6-channel)
   - [6.1. List Channels](#61-list-channels)
   - [6.2. Channel Status](#62-channel-status)
   - [6.3. Channel Info](#63-channel-info)
   - [6.4. Add Channel](#64-add-channel)
   - [6.5. Delete Channel](#65-delete-channel)
7. [Channel Control](#7-channel-control)
   - [7.1. PTZ Control](#71-ptz-control)
   - [7.2. Preset Control](#72-preset-control)
   - [7.3. Relay Output](#73-relay-output)
   - [7.4. Auxiliary Output](#74-auxiliary-output)
   - [7.5. Reboot Camera](#75-reboot-camera)
8. [Recording](#8-recording)
   - [8.1. Recording Days](#81-recording-days)
   - [8.2. Recording Minutes](#82-recording-minutes)
9. [Event](#9-event)
   - [9.1. Event Types](#91-event-types)
   - [9.2. Realtime Event Topics](#92-realtime-event-topics)
   - [9.3. Event Log](#93-event-log)
   - [9.4. Event Trigger (Event Backup)](#94-event-trigger-event-backup)
10. [LPR (License Plate Recognition)](#10-lpr-license-plate-recognition)
    - [10.1. LPR Source List (Recognition Point/Zone)](#101-lpr-source-list-recognition-pointzone)
    - [10.2. LPR Log](#102-lpr-log)
    - [10.3. Similar Plate Search](#103-similar-plate-search)
    - [10.4. Vehicle Number Correction](#104-vehicle-number-correction)
11. [Object Detection](#11-object-detection)
    - [11.1. Object Types](#111-object-types)
    - [11.2. Object Attributes](#112-object-attributes)
    - [11.3. Object Search](#113-object-search)
12. [Face Search](#12-face-search)
    - [12.1. Search by Image](#121-search-by-image)
    - [12.2. Search by Time](#122-search-by-time)
13. [VOD](#13-vod)
    - [13.1. Stream URLs](#131-stream-urls)
    - [13.2. Playback URLs](#132-playback-urls)
    - [13.3. Watch Page (Embeddable Player)](#133-watch-page-embeddable-player)
14. [Emergency](#14-emergency)
    - [14.1. Emergency Call List](#141-emergency-call-list)
15. [Push](#15-push-lpr-camera-emergency-bell-integration)
    - [15.1. Send Push Event](#151-send-push-event)
16. [Parking](#16-parking)
    - [16.1. Parking Lot](#161-parking-lot)
    - [16.2. Parking Lot Status](#162-parking-lot-status)
    - [16.3. Parking Spot (LPR Zone)](#163-parking-spot-lpr-zone)
    - [16.4. Parking Spot Status](#164-parking-spot-status)
    - [16.5. Parking Session History](#165-parking-session-history)
    - [16.6. Parking Session Detail](#166-parking-session-detail)
    - [16.7. Change Payment State](#167-change-payment-state)
    - [16.8. No-exit Cleanup](#168-no-exit-cleanup)
    - [16.9. Vehicle Number Correction](#169-vehicle-number-correction)
17. [Realtime Event Subscription (WebSocket API)](#17-realtime-event-subscription-websocket-api)
    - [17.1. Connection Flow](#171-connection-flow)
    - [17.2. Endpoints](#172-endpoints)
    - [17.3. Authentication](#173-authentication)
    - [17.4. Event Subscription](#174-event-subscription)
18. [Data Export — Recording Backup (WebSocket API)](#18-data-export--recording-backup-websocket-api)
    - [18.1. Export Flow](#181-export-flow)
    - [18.2. Endpoint](#182-endpoint)

**Appendix**
- [A. Error Codes](#a-error-codes)
- [B. Time Format](#b-time-format)
- [C. Code Examples](#c-code-examples)
  - [curl](#curl)
  - [JavaScript](#javascript)
  - [Python](#python)
  - [C#](#c-sharp)
  - [Go](#go)
  - [Java](#java)
  - [Kotlin](#kotlin)
  - [Swift](#swift)
  - [PowerShell](#powershell)
- [D. Supported Languages](#d-supported-languages)

---

## 1. Overview

TS-API v1 is a RESTful path-based API.

**Base URL**: `http://{host}:{port}/api/v1`

**Content-Type**: `application/json`

> **Note**: Channel numbers (`ch`, `chid`) are 1-based throughout the API.

### 1.1. Time Notation

**The response uses the time notation of the request.**

| Time sent in the request | Interpreted as | Response notation for that request |
|--------------------------|----------------|------------------------------------|
| `2026-10-07T09:30:00Z` | UTC | `...Z` (UTC) |
| `2026-10-07T09:30:00+09:00` | that offset | `...+09:00` (server local) |
| `2026-10-07T09:30:00` (no offset) | **the server's local time zone** | `...+09:00` (server local) |
| `today` · `yesterday` | midnight, server local | `...+09:00` (server local) |
| (no time parameter) | — | `...+09:00` (server local) |

**Response times always include an offset (or `Z`).** If you send a time without an offset,
the response returns the same digits followed by the offset the server assumed. If your
time zone differs from the server's, this offset shows the difference.

Sending an explicit offset is recommended but not required. The response states how the
server interpreted the time, so clients that do not handle time zones still work.

Times are stored internally in UTC with microsecond precision. Responses use millisecond
precision.

**Times sent by a billing app** (the `time` parameter in
[16.7](#167-change-payment-state) and [16.8](#168-no-exit-cleanup)) are **stored separately**
as that app's clock reading. The time the NVR records **always comes from the server clock**.
This keeps parking durations and video positions consistent when the two systems' clocks
differ.

On servers that support NTP (TS-IVR, TS-LPR4), you can synchronize the clocks. The NVR
runs a standard NTP server (UDP 123). Point the integrating system's time synchronization
at the NVR address to keep both clocks in agreement.

### 1.2. Box Coordinates

Bounding boxes use the **YOLO coordinate system** — center-based, all four values
normalized to `0..1`.

```json
{ "cx": 0.394, "cy": 0.556, "w": 0.164, "h": 0.201 }
```

| Value | Meaning |
|-------|---------|
| `cx` · `cy` | **Center** of the box (0 = left/top, 1 = right/bottom) |
| `w` · `h` | **Size** of the box |

To draw a box, multiply its values by the dimensions of the target image or video. The
internal coordinate space is not needed.

```
left = (cx - w/2) * displayWidth      top = (cy - h/2) * displayHeight
```

| Rule | Detail |
|------|--------|
| Range | `cx ± w/2` and `cy ± h/2` never leave `0..1` — the server clamps before sending |
| When absent | `null`. The key is not omitted, so "no box" can be distinguished from "this version does not send boxes" |
| Reference frame | The **image or video** the box came with. A box on a cropped image is relative to that crop |

> **A parking-history box is a single observation taken when the session opened.** It is
> not tracked and is valid only for that moment. **Draw it on the stillcut and remove it
> when video playback starts.** Entrance/exit sessions come from a single plate read and
> have no vehicle box, so the value is `null`.

**Exception — `vehicle.plate` in [16.4](#164-parking-spot-status).** This field uses
**absolute pixels** (`left`, `top`, `right`, `bottom`). It is kept unchanged for
compatibility with deployed partner applications.

These pixels are **not** relative to the whole frame. They are relative to the
`vehicle.image` crop in the same response, whose dimensions are `vehicle.imageSize`
(all three fields come only with `image=true`). To normalize, divide by
`imageSize.width` / `imageSize.height`.

```
cx = (left + right) / 2 / imageSize.width
cy = (top + bottom) / 2 / imageSize.height
w  = (right - left)     / imageSize.width
h  = (bottom - top)     / imageSize.height
```

**New box fields use YOLO.**

### 1.3. Language (`lang`)

Text meant for people — event type and code names, status messages, notice text — is
translated into the language named by `lang`. It is a query parameter on REST calls and a
parameter of the WebSocket URL ([17.4](#174-event-subscription), [18.2](#182-endpoint)). The
same rule applies wherever it is accepted.

`lang` is a language code such as `ko-KR` or `zh-TW` ([D. Supported Languages](#d-supported-languages)).
A code that is not in the list is resolved to the closest supported language, in this order:

| Step | Rule | Example |
|------|------|---------|
| 1 | Exact match, ignoring case | `ko-kr` → `ko-KR` |
| 2 | Default region of a language with several files | `zh`, `zh-Hans`, `zh-SG` → `zh-CN` · `zh-Hant`, `zh-HK`, `zh-MO` → `zh-TW` · `pt` → `pt-BR` · `pt-AO`, `pt-MZ`, `pt-CV`, `pt-GW`, `pt-ST`, `pt-TL`, `pt-MO` → `pt-PT` |
| 3 | Drop the last subtag and repeat steps 1–2 | `zh-Hant-HK` → `zh-Hant` → `zh-TW` |
| 4 | The only file of the same language | `ar-SA` → `ar-AE` · `ko` → `ko-KR` · `sw-TZ` → `sw-KE` |
| 5 | None of the above | Not translated — the text stays in English |

Without `lang`, text is in the language the NVR itself is set to. Notices
([5.5](#55-system-notices)) are the exception: without `lang` they carry English only.

When a response includes a language code (the keys of a notice `message`), it uses the
resolved code, not the value that was sent. For example, `lang=zh-HK` returns `zh-TW`.

Codes are interpreted by their standard meaning. Codes that referred to a different language
before v1.3.0 (`ru-KG`, `sr-Latn`, `nso-ZA`, `swc-CD`, `ku-Arab-IR`, and `pt-PT`, whose text
was Brazilian Portuguese) are not mapped to the corrected codes. See the
[Changelog](CHANGELOG.md#v130).


---

## 2. API Call Flow

### 2.1. Basic Flow (JWT Authentication)

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Camera

    Note over Client,Server: 1. Authentication
    Client->>Server: POST /api/v1/auth/login
    Server-->>Client: accessToken, refreshToken

    Note over Client,Server: 2. Channel Info Query
    Client->>Server: GET /api/v1/channel
    Note right of Client: Authorization: Bearer {token}
    Server-->>Client: Channel list

    Note over Client,Server: 3. Live Stream Request
    Client->>Server: GET /api/v1/vod?ch=1&when=now
    Server-->>Client: RTMP/FLV Stream URL

    Note over Client,Server: 4. Real-time Event Subscription
    Client->>Server: WS /wsapi/v1/events?topics=LPR
    Server-->>Client: Event stream (LPR, status, etc.)

    Note over Client,Server: 5. PTZ Control
    Client->>Server: GET /api/v1/channel/1/ptz?move=0.5,0.5
    Server->>Camera: ONVIF PTZ Command
    Camera-->>Server: OK
    Server-->>Client: OK
```

**Step-by-step description:**

| Step | Description |
|------|-------------|
| **1. Authentication** | Log in with user ID and password. The server returns an `accessToken` (for API calls) and a `refreshToken` (for token renewal). |
| **2. Channel Info Query** | Retrieve the list of registered camera channels with the `Authorization: Bearer {accessToken}` header. |
| **3. Live Stream Request** | Request a live video stream URL for a specific channel via the VOD API. Play the returned URL in an FLV/RTMP player. |
| **4. Real-time Event Subscription** | Receive real-time events (LPR, status changes, etc.) via WebSocket. Specify events to subscribe using the `topics` parameter at connection time. |
| **5. PTZ Control** | Control the camera's pan/tilt/zoom. The server forwards commands to the camera via the ONVIF protocol. |

### 2.2. Recording Search and Playback Flow

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. Recording Days Query
    Client->>Server: GET /api/v1/recording/days?ch=1
    Server-->>Client: [2024-01-01, 2024-01-02, ...]

    Note over Client,Server: 2. Event Log Search
    Client->>Server: GET /api/v1/event/log?timeBegin=2024-01-01
    Server-->>Client: Event list

    Note over Client,Server: 3. Playback at Specific Time
    Client->>Server: GET /api/v1/vod?ch=1&when=2024-01-01T10:30:00
    Server-->>Client: Playback URL
```

**Step-by-step description:**

| Step | Description |
|------|-------------|
| **1. Recording Days Query** | Retrieve the list of dates with recorded footage for a specific channel. Useful for displaying recording availability in a calendar UI. |
| **2. Event Log Search** | Search for events (motion, LPR, etc.) within a specified time range. Use the timestamps in the results to play back specific moments. |
| **3. Playback at Specific Time** | Specify the playback start time in ISO 8601 format via the `when` parameter. The server returns a playback URL for the recording at that time. |

### 2.3. Token Refresh Flow

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Client->>Server: API Request
    Server-->>Client: 401 Unauthorized (Token expired)

    Client->>Server: POST /api/v1/auth/refresh
    Note right of Client: Send refreshToken
    Server-->>Client: New accessToken

    Client->>Server: API Request (New token)
    Server-->>Client: 200 OK
```

**Step-by-step description:**

| Step | Description |
|------|-------------|
| **Token Expiry** | When the `accessToken` expires, the server returns `401 Unauthorized`. |
| **Token Refresh** | Use the `refreshToken` to obtain a new `accessToken` without re-logging in. |
| **Retry Request** | Retry the failed API call with the newly issued `accessToken`. |

> **Note**: `accessToken` is valid for 1 hour and `refreshToken` for 7 days. If the `refreshToken` has also expired, a new login is required.

### 2.4. API Key Flow (No Login Required)

Suitable for server-to-server integration, VMS, monitoring centers, and long-running services.

```mermaid
sequenceDiagram
    participant Client
    participant NVR
    participant Camera

    Note over Client: X-API-Key: tsapi_key_...

    rect rgb(255, 248, 240)
        Note over Client,NVR: Channel Query
        Client->>NVR: GET /api/v1/channel
        NVR-->>Client: Channel list
    end

    rect rgb(240, 255, 240)
        Note over Client,Camera: Live Video
        Client->>NVR: GET /api/v1/vod?ch=1
        NVR-->>Client: Stream URL
        Client->>Camera: Stream request
    end

    rect rgb(255, 240, 245)
        Note over Client,NVR: Real-time Events
        Client->>NVR: WS /wsapi/v1/events?apikey=...
        loop On event
            NVR-->>Client: Event data
        end
    end
```

**Step-by-step description:**

| Step | Description |
|------|-------------|
| **API Key** | Include the `X-API-Key` header or `?apikey=` query parameter in all requests. No login or token refresh required, making it ideal for server-to-server integration. |
| **Channel Query** | Retrieve the channel list via REST API. Uses the same endpoints as JWT authentication. |
| **Live Video** | Obtain a stream URL via the VOD API and receive the video stream directly from the camera. |
| **Real-time Events** | Connect via WebSocket to receive events in real-time. Authenticate using the `apikey` query parameter. |

---

## 3. Authentication

v1 API supports two authentication methods:
1. **JWT** - For web browsers and mobile apps (with token expiration)
2. **API Key** - For external system integration (long-term/permanent token)

| Method | Use Case | Expiration | Token Management |
|--------|----------|------------|------------------|
| API Key | External integration (VMS, monitoring center, IoT) | None (permanent until revoked) | No management needed |
| JWT Login | Web dashboard, mobile app, interactive client | Access: 1h, Refresh: 7d | Must refresh before expiry |

### 3.1. Authentication Scope by Method

| Auth Method | v1 Data Endpoints | v1 WebSocket | Storage/Media | v0 Endpoints |
|-------------|:-----------------:|:------------:|:-------------:|:------------:|
| JWT (Bearer Token) | ✅ | ✅ | ✅ | ✅ |
| API Key (X-API-Key) | ✅ | ✅ | ✅ | ❌ |
| Session Cookie | ✅ | ❌ | ❌ | ✅ |

> **Note**: All **v1** endpoints accept both JWT Bearer Token and API Key authentication.
>
> ⚠️ **v0 endpoints reject API Key**: API Key authentication (`X-API-Key` header) is **not accepted** on v0 endpoints (`/api/info`, `/api/enum`, `/api/system`, `/api/find`, etc.). v0 endpoints only accept session cookie authentication. Use v1 endpoints with API Key for external integrations.
>
> **API Key** is recommended for external system integration. **JWT** is recommended for web/mobile clients.
>
> ⚠️ **Deprecated**: `GET /api/v1/auth?login=...` (credentials in URL) is **deprecated and blocked** in v1 for security reasons (credentials exposed in URL/logs). Only `POST /api/v1/auth/login` is supported.

### 3.2. API Key Permission Model

API Key permissions determine which endpoints are accessible:

| Permission | Endpoints |
|------------|-----------|
| Remote | Channel, VOD, Event (realtime/type), LPR (source), Parking, System, Info |
| Playback | Recording, Event (log), LPR (log), Object (log) |
| Settings | API Key CRUD (`/api/v1/auth/apikey`) |
| Control | PTZ control, relay output, event trigger |
| DataExport | Recording data export |

> Endpoints return `403 Forbidden` if the API Key does not have the required permission.

---

### 3.3. JWT Authentication

#### 3.3.1. Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{"auth": "YWRtaW46MTIzNA=="}
```
> **Note:** The `auth` field is Base64-encoded `username:password`. Example: `base64("admin:1234")` = `"YWRtaW46MTIzNA=="`

**Response:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "user": {
    "username": "admin",
    "role": "admin"
  }
}
```

**Sign-in attempt limit:**
- After a failed password authentication, the same client address cannot retry for 3 seconds.
- After 3 failures within 1 minute, password authentication from that address is blocked for 1 minute. The block remains for its remaining time when the server restarts.
- A password authentication request received while a retry wait or block is active is not authenticated. The server returns `429 Too Many Requests`, and the `Retry-After` header gives the seconds until the next attempt is allowed.
- Token (JWT) and API Key authentication are not affected.
- A deactivated account is not authenticated even with the correct password, and the attempt counts as a failure.

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 54
Content-Type: application/json

{"error": "Too Many Requests", "message": "Too many login attempts. Please try again later."}
```

#### 3.3.2. API Call
```http
GET /api/v1/channel
Authorization: Bearer eyJhbGc...
```

#### 3.3.3. Token Refresh
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{"refreshToken": "eyJhbGc..."}
```

**Response:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

> ⚠️ **Token Rotation**: Each refresh request invalidates the old refresh token and returns a new one. Always store the new `refreshToken` from the response.

#### 3.3.4. Logout
```http
POST /api/v1/auth/logout
Content-Type: application/json

{"refreshToken": "eyJhbGc..."}
```

---

### 3.4. Storage / Media File Authentication

Media file paths (`/storage`, `/event-storage`, `/download`) require authentication via URL query parameter.

**Supported methods:**
- `?token={accessToken}` — JWT access token
- `?apikey={apiKey}` — API Key

> ⚠️ `Authorization` header cannot be used for direct `<img>`, `<video>` src attributes. Use URL query parameters instead.

**Examples:**
```
GET /storage/r/0/0/0/31/31103.mp4?token=eyJhbGc...
GET /storage/snapshot/1/latest.jpg?apikey=tsapi_key_a1b2c3d4...
GET /event-storage/lpr/2024/01/01/event001.jpg?token=eyJhbGc...
GET /download/export_20240101.mp4?token=eyJhbGc...
```

| Path | Description |
|------|-------------|
| `/storage/r/{path}` | Recorded video files |
| `/storage/snapshot/{ch}/latest.jpg` | Latest snapshot image |
| `/event-storage/{path}` | Event-related media (LPR images, etc.) |
| `/download/{file}` | Exported files |

> **URL format**: v1 returns **relative URLs** (paths starting with `/`) in response fields such as `image`, `videoSrc`, `src`. Clients should prepend their own base URL (`http://{host}:{port}`) when constructing absolute requests. v0 (legacy) returns absolute URLs instead. See [Migration Guide](MIGRATION.md#5-key-changes) for details.

---

### 3.5. API Key Authentication

API Keys are suitable for external system integration (monitoring center, VMS, etc.).
An API Key can be used indefinitely, and administrators can revoke it at any time.

> ⚠️ API Key authentication is supported on **v1 endpoints only**. v0 endpoints (`/api/*`) reject `X-API-Key` with `401 Unauthorized`.

#### 3.5.1. Issue API Key (admin only)

> **Note**: You can also issue API Keys through the web interface by logging in as an administrator and navigating to the **"API Key"** page.

```http
POST /api/v1/auth/apikey
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "name": "Monitoring Center",
  "permissions": ["remote", "playback"],
  "channels": [1, 2, 3, 4],
  "ipWhitelist": ["192.168.1.0/24"],
  "expiresAt": null
}
```

**Permission Values:**

| Value | Description |
|-------|-------------|
| `remote` | Basic access (channel, VOD, event type/realtime, LPR source, parking, system, info) |
| `playback` | Recording search, event/LPR/object logs |
| `settings` | API Key CRUD, system settings |
| `control` | PTZ control, relay output, event trigger |
| `dataExport` | Recording data export |
| `*` | All permissions (super) |

> `channel:read` and `vod:read` are aliases for `remote`. `admin` is an alias for `settings`.

**Response:**
```json
{
  "id": "key_abc123",
  "key": "tsapi_key_a1b2c3d4e5f6...",
  "name": "Monitoring Center",
  "message": "Store this API key securely. It will not be shown again."
}
```

#### 3.5.2. Using API Key

**Header method:**
```http
GET /api/v1/channel
X-API-Key: tsapi_key_a1b2c3d4e5f6...
```

**URL parameter method (for video streams):**
```
http://server/api/v1/vod?ch=1&apikey=tsapi_key_a1b2c3d4...
```

#### 3.5.3. List API Keys
```http
GET /api/v1/auth/apikey
Authorization: Bearer {admin_token}
```

#### 3.5.4. Revoke API Key
```http
DELETE /api/v1/auth/apikey/{keyId}
Authorization: Bearer {admin_token}
```

> **Examples:** [JavaScript](examples/javascript/01-login.js) · [Python](examples/python/01_login.py) · [C#](examples/csharp/01_Login.cs) · [Go](examples/go/01_login/) · [Java](examples/java/V1_01_Login.java) · [Kotlin](examples/kotlin/V1_01_Login.kt) · [Swift](examples/swift/01-login.swift) · [PowerShell](examples/powershell/01-login.ps1) · [curl](examples/curl/01-login.sh)

---

## 4. Server Info

Retrieves server and product information.

> **No authentication required.** This endpoint can be called without authentication, except for the `whoAmI` parameter, which requires JWT or session authentication.

| Endpoint | Auth | Description |
|----------|:----:|-------------|
| `GET /api/v1/info?apiVersion` | - | API version query (e.g., "TS-API@1.4.0") |
| `GET /api/v1/info?siteName` | - | Site name query |
| `GET /api/v1/info?timezone` | - | Server timezone query (name, bias) |
| `GET /api/v1/info?product` | - | Product info query (name, version) |
| `GET /api/v1/info?license` | - | License info query (type, maxChannels) |
| `GET /api/v1/info?whoAmI` | ✅ | Current logged-in user info |
| `GET /api/v1/info?all` | ✅* | Retrieve all info at once |

> \* `?all` includes `whoAmI`, so authentication is required to get user info. If unauthenticated, `whoAmI` is omitted from the response and returns HTTP 401 status.

**Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `all` | Flag | Include all info |
| `apiVersion` | Flag | API version |
| `siteName` | Flag | Site name |
| `product` | Flag | Product info |
| `license` | Flag | License info |
| `whoAmI` | Flag | Authenticated user info |
| `timezone` | Flag | Timezone info |

**Example** (no auth needed):
```bash
curl "http://localhost/api/v1/info?apiVersion&product&license"
```

**Example** (with auth for whoAmI):
```bash
curl "http://localhost/api/v1/info?all" -H "Authorization: Bearer eyJhbGc..."
```

**Response** (genuine license with ANPR / object detection / parking guidance enabled):
```json
{
  "apiVersion": "TS-API@1.4.0",
  "siteName": "Main Office",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  },
  "product": {
    "name": "TS-NVR",
    "version": "2.14.1"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 64,
    "nLprZone": 36,
    "nChObjDetection": 36,
    "nChFaceRecognition": 10,
    "nChTrafficCount": 10,
    "nChSpeedometer": 10,
    "nChPeopleCount": 10,
    "fisheyeCamSupports": true,
    "mediaType": "USB dongle",
    "extension": ["lprExt", "objectDetection", "parkingGuide"]
  }
}
```

**Response** (trial example):
```json
{
  "license": {
    "type": "trial",
    "maxChannels": 16,
    "trialDays": 30,
    "leftDays": 15,
    "mediaType": "Software"
  }
}
```

**Response Fields**:

| Field | Type | When | Description |
|-------|------|------|-------------|
| `apiVersion` | String | Always | API version |
| `siteName` | String | Always | NVR site name |
| `timezone.name` | String | Always | Timezone name |
| `timezone.bias` | String | Always | Timezone offset |
| `product.name` | String | Always | Product name |
| `product.version` | String | Always | Product version |
| `license.type` | String | Always | `freeware`, `genuine`, `limited`, `trial` |
| `license.maxChannels` | Int | Always | Maximum channel count |
| `license.expire` | String | `type=limited` | Expiration timestamp (ISO 8601) |
| `license.trialDays` | Int | `type=trial` | Trial total days |
| `license.leftDays` | Int | `type=trial` | Trial days remaining |
| `license.nLprZone` | Int | LPR-capable build | Number of LPR recognition zones |
| `license.nDevEmCall` | Int | Emergency-call build | Emergency call devices (backward-compat — always returns `0`) |
| `license.nChObjDetection` | Int | Object detection license active | Object detection channels |
| `license.nChFaceRecognition` | Int | Face recognition license active | Face recognition channels |
| `license.nChTrafficCount` | Int | Traffic count license active | Traffic count channels |
| `license.nChSpeedometer` | Int | Vehicle speed license active | Vehicle speedometer channels |
| `license.nChPeopleCount` | Int | People count license active | People count channels |
| `license.fisheyeCamSupports` | Boolean | Fisheye dewarping license active | `true` when active; omitted otherwise |
| `license.maxVehicles` | Int | ANPR + non-default value | Concurrent LPR vehicle tracking count |
| `license.mediaType` | String | Always | `"USB dongle"` or `"Software"` |
| `license.extension` | Array | At least one extension active | Extension feature tokens (see table below) |
| `whoAmI.uid` | String | whoAmI requested | User ID |
| `whoAmI.name` | String | whoAmI requested | User name |
| `whoAmI.accessRights` | Object | whoAmI requested | Access rights |

**`license.extension` tokens**:

| Token | Description |
|-------|-------------|
| `lprExt` | License plate recognition (ANPR/LPR support) |
| `emergencyCall` | Emergency call device integration |
| `packing` | Packing (SEMES Lot Search, etc.) |
| `objectDetection` | Object detection |
| `faceRecognition` | Face recognition (external FR server integration) |
| `sharedFrameBuffer` | Shared frame buffer |
| `vehicleTracking` | Vehicle tracking |
| `parkingGuide` | Parking guidance |
| `parkingSpot` | Parking spot occupancy detection |
| `parkingHistory` | Parking session history — the endpoints in [16.5–16.8](#165-parking-session-history) are available only when this token is present |

---

## 5. System

System information and control API.

### 5.1. System Info

Retrieves system hardware and software information.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/system/info` | Full system information |
| `GET /api/v1/system/info?item=os` | OS info (name, version, architecture) |
| `GET /api/v1/system/info?item=cpu` | CPU info (model, core count, clock) |
| `GET /api/v1/system/info?item=storage` | Storage info (disk list, capacity) |
| `GET /api/v1/system/info?item=network` | Network info (interface, IP) |
| `GET /api/v1/system/info?item=storage,network` | Query multiple items |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `item` | String | N | All | Items to query (comma-separated: `os`, `cpu`, `storage`, `network`) |

> **Note**: Storage info is requested with `item=storage` but returned in the `disk` field. When requesting network info, the `lastUpdate` field is also included.

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `os` | Object | OS information (name, version, architecture) |
| `cpu` | Object | CPU information (model, cores, clock) |
| `mainboard` | Object | Mainboard information |
| `memory` | Object | Memory information |
| `graphicAdapter` | Object | Graphics adapter information |
| `monitor` | Object | Monitor information |
| `storage` | Object | Storage information |
| `networkAdapter` | Object | Network adapter information |

### 5.2. System Health

Retrieves real-time system status.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/system/health` | Full system status |
| `GET /api/v1/system/health?item=cpu` | CPU usage (%) |
| `GET /api/v1/system/health?item=memory` | Memory usage (total, used, free) |
| `GET /api/v1/system/health?item=disk` | Disk usage (total, used, free) |
| `GET /api/v1/system/health?item=memory,disk` | Query multiple items |
| `GET /api/v1/system/health?item=systemDisk` | System disk status (the disk holding the database and logs) |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `item` | String | N | Items to query (comma-separated): `cpu`, `memory`, `disk`, `systemDisk`, `recording`, `network`, `all`, `supported` |

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `lastUpdate` | String | Last update time (ISO 8601) |
| `cpu` | Array | CPU status list (when `item` includes `cpu`) |
| `cpu[].usage.total` | Int | Total CPU usage (%) |
| `cpu[].usage.threads` | Array | Per-core usage (%) |
| `cpu[].temperatureKelvin.current` | Float | Current temperature (K) |
| `cpu[].temperatureKelvin.critical` | Float | Critical temperature (K) |
| `memory` | Object | Memory status (when `item` includes `memory`) |
| `memory.totalPhysical` | Int | Total physical memory (bytes) |
| `memory.freePhysical` | Int | Free physical memory (bytes) |
| `memory.totalVirtual` | Int | Total virtual memory (bytes) |
| `memory.freeVirtual` | Int | Free virtual memory (bytes) |
| `disk` | Array | Disk (partition) status list (when `item` includes `disk`) |
| `disk[].mount` | String | Mount path (e.g., `"C:"`) |
| `disk[].fileSystem` | String | File system (e.g., `"NTFS"`) |
| `disk[].volumeName` | String | Volume name |
| `disk[].totalSpace` | Int | Total capacity (bytes) |
| `disk[].freeSpace` | Int | Free capacity (bytes) |
| `disk[].totalTimePercent` | Int | Total disk busy time (%) |
| `disk[].readTimePercent` | Int | Read time (%) |
| `disk[].writeTimePercent` | Int | Write time (%) |
| `disk[].totalBytesPerSec` | Int | Total transfer rate (bytes/sec) |
| `disk[].readBytesPerSec` | Int | Read rate (bytes/sec) |
| `disk[].writeBytesPerSec` | Int | Write rate (bytes/sec) |
| `recording` | Object | Recording storage status (when `item` includes `recording`) |
| `recording.current` | String | Current recording path |
| `recording.storage` | Array | Recording storage list |
| `recording.storage[].path` | String | Storage path |
| `recording.storage[].usage` | String | `overwrite`, `write-once`, `read-only`, `event-backup`, `disabled` or `unknown` |
| `network` | Array | Network interface status (when `item` includes `network`) |
| `network[].name` | String | Interface name |
| `network[].totalBytesPerSec` | Int | Total transfer rate (bytes/sec) |
| `network[].recvBytesPerSec` | Int | Receive rate (bytes/sec) |
| `network[].sendBytesPerSec` | Int | Send rate (bytes/sec) |
| `network[].curBandwidth` | Int | Current bandwidth (bps) |
| `systemDisk` | Object | System disk status (when `item` includes `systemDisk`) |
| `systemDisk.drive` | String | Volume (e.g., `"C:"`) |
| `systemDisk.totalSpace` | Int | Total capacity (bytes), `-1` before the first measurement |
| `systemDisk.freeSpace` | Int | Free capacity (bytes), `-1` before the first measurement |
| `systemDisk.status` | String | `normal`, `low` (under 1 GB free) or `critical` (under 200 MB free, or a recent write failure) |
| `systemDisk.dataWriteFailed` | Boolean | A record could not be written for lack of space or an I/O error within the last 60 seconds |

The *system disk* holds the product's database and logs. It is normally the Windows drive `C:`,
separate from the recording disks. When it is full, new recordings cannot be indexed and
recognition records are not saved, even if the recording disks have free space. Monitor
`systemDisk.status` in addition to `disk[]`. To be notified of changes, use the `notice` channel
([5.5. System Notices](#55-system-notices)).

### 5.3. HDD S.M.A.R.T

Retrieves disk health status.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/system/hddsmart` | All/Specific disk S.M.A.R.T information |
| `GET /api/v1/system/hddsmart?disk=1` | Specific disk S.M.A.R.T information |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `disk` | Int | N | Disk number (all disks if omitted) |
| `lang` | String | N | Language of `[].message` ([1.3](#13-language-lang)) |

**Response**: Returns an array with one entry per fixed disk.

An empty array means the server found no fixed disks. A disk whose attributes have not
been read yet is still listed, with `code` = `-1`. S.M.A.R.T. data is read in the background
and cached for one hour, so an entry may report `-1` briefly after startup.

| Field | Type | Description |
|-------|------|-------------|
| `[].name` | String | Disk name (e.g., `"PhysicalDrive0"`) |
| `[].model` | String | Disk model name |
| `[].code` | Int | S.M.A.R.T status (see the table below) |
| `[].message` | String | Status message for `code`, in the requested language |
| `[].protocol` | String | How the attributes were read: `"ATA"` or `"NVMe"`. The attribute ID scheme differs between the two |
| `[].smart` | Array | S.M.A.R.T attribute list (only included when attributes were read) |
| `[].smart[].id` | Int | Attribute ID |
| `[].smart[].attribute` | String | Attribute name |
| `[].smart[].critical` | Boolean | Whether this is a critical attribute |
| `[].smart[].value` | Int | Current value |
| `[].smart[].worst` | Int | Worst value |
| `[].smart[].threshold` | Int | Threshold value |
| `[].smart[].raw` | Int | Raw value |
| `[].smart[].rawHex` | String | Raw value (hexadecimal string) |

`[].code` values:

| Code | Meaning |
|------|---------|
| `-1` | Not read yet |
| `0` | The drive does not support S.M.A.R.T. |
| `1` | Supported - attributes are in `[].smart` |
| `2` | Could not open the drive; administrator rights are required |
| `3` | The storage controller does not pass S.M.A.R.T. through (disks behind a RAID controller) |
| `4` | The drive supports S.M.A.R.T. but reading the attributes failed |

### 5.4. System Control

System control commands. **Admin privileges required**

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/system/restart` | Restart NVR server process |
| `POST /api/v1/system/reboot` | Reboot system (OS) |

**Response**:

| Field | Type | Description |
|-------|------|-------------|
| `code` | Int | Result code (0: success) |
| `message` | String | Result message |

> **Examples:** [JavaScript](examples/javascript/08-system-info.js) · [Python](examples/python/08_system_info.py) · [C#](examples/csharp/08_SystemInfo.cs) · [Go](examples/go/08_system/) · [Java](examples/java/V1_08_SystemInfo.java) · [Kotlin](examples/kotlin/V1_08_SystemInfo.kt) · [Swift](examples/swift/08-system-info.swift) · [PowerShell](examples/powershell/08-system-info.ps1) · [curl](examples/curl/08-system-info.sh)

---

### 5.5. System Notices

Notices describe conditions that are **currently in effect** and need attention. A notice is
raised, updated, and cleared. Events (§9) record what happened; notices show the current state.
Notices are kept in memory only, so they remain available when the system disk is full.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/system/notices` | Notices currently in effect |
| `GET /api/v1/system/notices?lang=ko-KR` | Same, with the `ko-KR` text added to `message` |
| `GET /api/v1/system/notices?lang=zh-HK` | Same, with the text added under `zh-TW` (see *Language* below) |

Any signed-in user can read notices. For live updates, subscribe to the `notice` topic
([17.4. Event Subscription](#174-event-subscription)). It sends the current list when you
subscribe, and then each change.

**Language** — `message` is an object keyed by language code. `en-US` is always present and is the
canonical text. When `lang` (a query parameter of the REST call or the WebSocket URL) names a
language other than English, the translation is added under the resolved language code
([1.3. Language](#13-language-lang)), not the value that was sent. For example, `lang=ko` or
`lang=ko-kr` adds `ko-KR`, and `lang=zh-HK` adds `zh-TW`. If the server cannot translate the
language, no translation is added. Without `lang`, only `en-US` is sent. Clients that translate
text themselves can use `messageKey` and `args` instead, and do not need to reconnect when the user
changes language.

**Response** — an array, most severe first, then oldest first:
```json
[
  {
    "id": "systemDisk",
    "kind": "systemDisk",
    "severity": "critical",
    "message": {
      "en-US": "Disk C: is almost full: 150MB left",
      "ko-KR": "C: 디스크 거의 가득 참: 150MB 남음"
    },
    "messageKey": "Disk %1% is almost full: %2% left",
    "args": ["C:", "150MB"],
    "param": {"drive": "C:", "totalSpace": 119387713536, "freeSpace": 157286400, "status": "critical", "dataWriteFailed": false},
    "timeBegin": "2026-10-23T08:40:12.000+09:00",
    "timeUpdate": "2026-10-23T08:51:07.000+09:00"
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Identifies one notice. A notice with the same `id` is updated in place, never duplicated |
| `kind` | String | Source of the notice. Currently `systemDisk` |
| `severity` | String | `info`, `warning` or `critical`. Show `critical` prominently — it needs immediate action |
| `message` | Object | Text by language code, placeholders filled |
| `message.en-US` | String | English — always present |
| `message.{code}` | String | The translation, under the server's code for the requested language (e.g. `ko-KR`; `zh-TW` for `lang=zh-HK`). Only when `lang` names a language other than English that the server can translate |
| `messageKey` | String | English text with `%1%`, `%2%` … placeholders — the translation key, for clients that translate themselves |
| `args` | Array | Placeholder values, in order (not translated) |
| `param` | Object | `kind`-specific detail. Omitted when there is none. Treat as open-ended |
| `timeBegin` | String | Time the notice was first raised. Does not change when the notice is updated |
| `timeUpdate` | String | Time of the last change |

**`notice` topic messages:**

| `action` | Body | When |
|----------|------|------|
| `snapshot` | `notices`: array as above | Once, right after subscribing |
| `raised` | `notice`: one notice | A new notice |
| `updated` | `notice`: one notice | The notice content changed (for `systemDisk`, each change in free space, about every 5 seconds while the notice is active) |
| `cleared` | `notice`: the last content | The condition no longer applies |

```json
{"topic": "notice", "action": "updated", "notice": {"id": "systemDisk", "severity": "critical", "message": {"en-US": "Disk C: is almost full: 140MB left"}, "...": "..."}}
```

#### System disk notice (`kind: systemDisk`)

The *system disk* holds the product's database and logs. It is normally the Windows drive `C:`,
separate from the recording disks. When it is full, new recordings cannot be indexed and
recognition records are not saved, even if the recording disks have free space.

| `severity` | Condition | `messageKey` |
|----------|------|------|
| `warning` | Under 1 GB free | `Low disk space on %1%: %2% left` |
| `critical` | Under 200 MB free | `Disk %1% is almost full: %2% left` |
| `critical` | A record could not be written for lack of space or an I/O error within the last 60 seconds | `Disk %1% is full. Data is not being saved.` |

The notice is cleared when the disk returns to normal. `param` contains the same fields as
`systemDisk` in [5.2. System Health](#52-system-health). Each level change is also recorded as a
`systemEvent` (see [System disk warning](#system-disk-warning)). If the disk is too full to record
the event, only the notice is available.

## 6. Channel

Channel (camera) list and management API.

### 6.1. List Channels

Retrieves registered channel list.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel` | Channel list (basic info) |
| `GET /api/v1/channel?staticSrc` | Include static source info (RTSP URL, etc.) |
| `GET /api/v1/channel?caps` | Include camera capabilities (PTZ, relay, etc.) |

**Response**:
```json
[
  {
    "chid": 1,
    "displayName": "CH1. Front Door",
    "title": "Front Door",
    "caps": {
      "pantilt": true,
      "zoom": true
    }
  },
  {
    "chid": 2,
    "displayName": "CH2. Parking Lot",
    "title": "Parking Lot"
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `chid` | Int | Channel ID (starts from 1) |
| `title` | String | Channel name (user-configured or camera address) |
| `displayName` | String | Display name (`"CH{N}. {title}"` format) |
| `src` | Object | Static source URL (only included with `staticSrc`) |
| `caps` | Object | Camera capabilities (only included with `caps`) |

**`caps` Object Fields** (with `?caps`):

| Field | Type | Description |
|-------|------|-------------|
| `caps.pantilt` | Boolean | Pan/tilt support |
| `caps.zoom` | Boolean | Zoom support |
| `caps.focus` | Boolean | Focus support |
| `caps.iris` | Boolean | Iris support |
| `caps.home` | Boolean | Home position support |
| `caps.maxPreset` | Int | Maximum preset count |
| `caps.aux` | Int | Auxiliary output count |
| `caps.relayOutputs` | Int | Relay output count |
| `caps.reboot` | Boolean | Remote reboot support |

**`src` Array Item Fields** (with `?staticSrc`):

| Field | Type | Description |
|-------|------|-------------|
| `src[].protocol` | String | Protocol (`rtmp`, `flv`, etc.) |
| `src[].profile` | String | Profile (`main`, `sub`) |
| `src[].src` | String | Stream URL |
| `src[].type` | String | Stream type |
| `src[].label` | String | Resolution label |
| `src[].size` | Array | `[width, height]` |

### 6.2. Channel Status

Retrieves channel connection status.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel/status` | All channel status |
| `GET /api/v1/channel/status?ch=1,2,3` | Specific channels only |
| `GET /api/v1/channel/status?verbose=true` | Include detailed status (error messages, etc.) |
| `GET /api/v1/channel/status?recordingStatus` | Include recording status |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ch` | String | N | All | Channel numbers (comma-separated, e.g., `"1,2,3"`) |
| `verbose` | Boolean | N | false | Include detailed status (error messages, etc.) |
| `recordingStatus` | Flag | N | - | Include recording status (pass key only without value) |

**Response**:
```json
[
  {
    "chid": 1,
    "status": {
      "code": 0,
      "message": "Connected"
    },
    "recording": true
  },
  {
    "chid": 2,
    "status": {
      "code": -1,
      "message": "Disconnected"
    },
    "recording": false
  }
]
```

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `chid` | Int | Channel number |
| `title` | String | Channel name |
| `displayName` | String | Display name |
| `status.code` | Int | Status code |
| `status.message` | String | Status message |

**Status Codes**:

| code | Description |
|------|-------------|
| 0 | Connected |
| -1 | Disconnected |
| -2 | Connecting |
| -3 | Authentication Failed |

### 6.3. Channel Info

Retrieves channel details and camera capabilities.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel/info` | All channel details |
| `GET /api/v1/channel/info?caps` | Include camera capabilities |
| `GET /api/v1/channel/info?caps&reload` | Re-query capabilities from camera |
| `GET /api/v1/channel/{id}/info?caps` | Specific channel details |

**Example**:
```bash
curl "http://localhost/api/v1/channel/1/info?caps"
```

### 6.4. Add Channel

Registers a new channel. **Admin privileges required**

```http
POST /api/v1/channel
Content-Type: application/json

{
  "name": "New Camera",
  "source": "rtsp://192.168.1.100/stream"
}
```

### 6.5. Delete Channel

Deletes channel. **Admin privileges required**

| Endpoint | Description |
|----------|-------------|
| `DELETE /api/v1/channel/{id}` | Delete single channel |
| `DELETE /api/v1/channel/1,2,3` | Delete multiple channels |

> **Examples:** [JavaScript](examples/javascript/02-channels.js) · [Python](examples/python/02_channels.py) · [C#](examples/csharp/02_Channels.cs) · [Go](examples/go/02_channels/) · [Java](examples/java/V1_02_Channels.java) · [Kotlin](examples/kotlin/V1_02_Channels.kt) · [Swift](examples/swift/02-channels.swift) · [PowerShell](examples/powershell/02-channels.ps1) · [curl](examples/curl/02-channels.sh)

---

## 7. Channel Control

Camera PTZ, preset, and relay control API.

### 7.1. PTZ Control

Controls camera Pan/Tilt/Zoom.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel/{id}/ptz?home` | Move to home position |
| `GET /api/v1/channel/{id}/ptz?move=x,y` | Pan/Tilt movement (x,y: -1.0 ~ 1.0) |
| `GET /api/v1/channel/{id}/ptz?zoom=z` | Zoom control (z: -1.0=zoom out, 1.0=zoom in) |
| `GET /api/v1/channel/{id}/ptz?focus=f` | Focus control (f: -1.0=near, 1.0=far) |
| `GET /api/v1/channel/{id}/ptz?iris=i` | Iris control (i: -1.0=close, 1.0=open) |
| `GET /api/v1/channel/{id}/ptz?stop` | Stop PTZ movement |

**Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `home` | Flag | Move to home position (pass key only without value) |
| `move` | String | Pan/Tilt movement (format: `"x,y"`, range: -1.0 to 1.0) |
| `zoom` | Float | Zoom control (-1.0=zoom out, 0=stop, 1.0=zoom in) |
| `focus` | Float | Focus control (-1.0=near, 0=stop, 1.0=far) |
| `iris` | Float | Iris control (-1.0=close, 0=stop, 1.0=open) |
| `stop` | Flag | Stop all PTZ movement (pass key only without value) |

```
              0,-1
               ↑
               |
   -1,0 ←── (0,0) ──→ 1,0        -1 ←──── 0 ────→ 1
               |                         zoom
               ↓                         focus
              0,1                         iris
             move
```

> **Note**: PTZ commands are executed through the camera's ONVIF service. The request may return a 500 error if the camera does not support ONVIF or the connection is unstable.

**Example**:
```bash
# Move camera 1 to home position
curl "http://localhost/api/v1/channel/1/ptz?home"

# Pan/Tilt (Move upper right)
curl "http://localhost/api/v1/channel/1/ptz?move=0.3,-0.2"

# Zoom in
curl "http://localhost/api/v1/channel/1/ptz?zoom=0.5"

# Stop all PTZ movement
curl "http://localhost/api/v1/channel/1/ptz?stop"
```

**Response:**

| Field | Type | Description |
|-------|------|-------------|
| `code` | Int | Result code (0: success) |
| `message` | String | Error message |

### 7.2. Preset Control

Manages camera presets (saved positions).

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel/{id}/preset` | Preset list |
| `GET /api/v1/channel/{id}/preset?reload` | Re-query from camera |
| `POST /api/v1/channel/{id}/preset?name=xxx` | Save current position as preset |
| `PUT /api/v1/channel/{id}/preset/{token}` | Update preset (to current position) |
| `DELETE /api/v1/channel/{id}/preset/{token}` | Delete preset |
| `GET /api/v1/channel/{id}/preset/{token}/go` | Move to preset |

**GET Response:**

| Field | Type | Description |
|-------|------|-------------|
| `chid` | Int | Channel number |
| `preset` | Array | Preset list |
| `preset[].token` | String | Preset token |
| `preset[].name` | String | User-defined name |
| `preset[].devName` | String | Device-defined name |

**POST Parameter:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | String | Y | Preset name (query parameter) |

**PUT Parameter:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | String | Y | New preset name (query parameter) |

**Example**:
```bash
# List presets of channel 1
curl "http://localhost/api/v1/channel/1/preset"

# Go to preset
curl "http://localhost/api/v1/channel/1/preset/preset1/go"
```

### 7.3. Relay Output

Controls camera relay output (door lock, warning light, etc.).

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/channel/{id}/relay` | Relay output list |
| `PUT /api/v1/channel/{id}/relay/{uuid}?state=on` | Relay ON |
| `PUT /api/v1/channel/{id}/relay/{uuid}?state=off` | Relay OFF |

**GET Response:**

| Field | Type | Description |
|-------|------|-------------|
| `chid` | Int | Channel number |
| `relay` | Array | Relay list |
| `relay[].token` | String | Relay token |
| `relay[].name` | String | Relay name |

**PUT Parameter:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `state` | String | Y | `on` or `off` |

### 7.4. Auxiliary Output

Controls camera auxiliary output.

| Endpoint | Description |
|----------|-------------|
| `PUT /api/v1/channel/{id}/aux/{port}?state=on` | Auxiliary output ON |
| `PUT /api/v1/channel/{id}/aux/{port}?state=off` | Auxiliary output OFF |

**Parameter:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `state` | String | Y | `on` or `off` |

### 7.5. Reboot Camera

Remotely reboots camera. **Admin privileges required**

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/channel/{id}/reboot` | Reboot camera (ONVIF) |

**Response:**

| Field | Type | Description |
|-------|------|-------------|
| `code` | Int | Result code (0: success) |
| `message` | String | Result message |

> **Examples:** [JavaScript](examples/javascript/03-ptz-control.js) · [Python](examples/python/03_ptz_control.py) · [C#](examples/csharp/03_PtzControl.cs) · [Go](examples/go/03_ptz/) · [Java](examples/java/V1_03_PtzControl.java) · [Kotlin](examples/kotlin/V1_03_PtzControl.kt) · [Swift](examples/swift/03-ptz-control.swift) · [PowerShell](examples/powershell/03-ptz-control.ps1) · [curl](examples/curl/03-ptz-control.sh)

---

## 8. Recording

Recording data search API, used to build calendar UIs.

### 8.1. Recording Days

Retrieves dates with recording data.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/recording/days` | Recording days for all channels |
| `GET /api/v1/recording/days?ch=1` | Recording days for specific channel |
| `GET /api/v1/recording/days?ch=1,2,3` | Recording days for multiple channels |
| `GET /api/v1/recording/days?timeBegin=...&timeEnd=...` | Recording days within specific period |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ch` | String | N | All | Channel numbers (comma-separated, e.g., `"1,2,3"`) |
| `timeBegin` | DateTime | N | - | Search start time (ISO 8601) |
| `timeEnd` | DateTime | N | - | Search end time (ISO 8601) |

> **Note**: The `X-Host` header is required. It is set automatically on standard web browser requests.

**Response**:
```json
{
  "timeBegin": "2024-01-01T00:00:00",
  "timeEnd": "2024-01-31T23:59:59",
  "data": [
    {
      "year": 2024,
      "month": 1,
      "days": [1, 2, 3, 5, 8, 10]
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `timeBegin` | DateTime | Query start time |
| `timeEnd` | DateTime | Query end time |
| `data` | Array | Per-channel recording data |
| `data[].chid` | Int | Channel number |
| `data[].data[].year` | Int | Year |
| `data[].data[].month` | Int | Month |
| `data[].data[].days` | Array\<Int\> | Days with recordings |

### 8.2. Recording Minutes

Retrieves minute-level recording data. Used for timeline UI.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/recording/minutes?timeBegin=...&timeEnd=...` | Recording segments (minute-level) |
| `GET /api/v1/recording/minutes?ch=1&timeBegin=...&timeEnd=...` | Recording segments for specific channel |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ch` | String | N | All | Channel numbers (comma-separated) |
| `timeBegin` | DateTime | Y | - | Search start time (ISO 8601) |
| `timeEnd` | DateTime | Y | - | Search end time (ISO 8601) |

**Response**:
```json
{
  "timeBegin": "2024-01-01T00:00:00",
  "timeEnd": "2024-01-01T23:59:59",
  "data": [
    {
      "chid": 1,
      "minutes": "111111110000..."
    }
  ]
}
```

`minutes` is a string where each character represents one minute of the queried period.
- The first character (index 0) corresponds to the `timeBegin` minute, the second character to the next minute, and so on.
- `'1'` = recording exists for that minute, `'0'` = no recording
- For a full day (24 hours), the string length is 1440 characters (24 × 60 minutes)

For example, if `timeBegin` is `2024-01-01T00:00:00` and `minutes` is `"111111110000..."`:

| Index | Time | Value | Meaning |
|-------|------|-------|---------|
| 0 | 00:00 | `1` | Recording exists |
| 1 | 00:01 | `1` | Recording exists |
| ... | ... | `1` | ... |
| 7 | 00:07 | `1` | Recording exists |
| 8 | 00:08 | `0` | No recording |
| ... | ... | `0` | ... |
| 1439 | 23:59 | `0` | No recording |

In this example, channel 1 has recordings only during the 00:00–00:07 interval.

| Field | Type | Description |
|-------|------|-------------|
| `timeBegin` | DateTime | Query start time |
| `timeEnd` | DateTime | Query end time |
| `data` | Array | Per-channel recording data |
| `data[].chid` | Int | Channel number |
| `data[].minutes` | String | Minute-level recording bitmap string (`'1'`=recording exists, `'0'`=none) |

> **Examples:** [JavaScript](examples/javascript/04-recording-search.js) · [Python](examples/python/04_recording_search.py) · [C#](examples/csharp/04_RecordingSearch.cs) · [Go](examples/go/04_recording/) · [Java](examples/java/V1_04_RecordingSearch.java) · [Kotlin](examples/kotlin/V1_04_RecordingSearch.kt) · [Swift](examples/swift/04-recording-search.swift) · [PowerShell](examples/powershell/04-recording-search.ps1) · [curl](examples/curl/04-recording-search.sh)

---

## 9. Event

Event query, subscription, and trigger API.

### 9.1. Event Types

Retrieves event types supported by the system.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/event/type` | Event type list (default language) |
| `GET /api/v1/event/type?lang=en-US` | Event types in specific language |
| `GET /api/v1/event/type?lang=ko-KR` | Event types in Korean |

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lang` | String | N | Language code ([1.3](#13-language-lang)). Without it, the NVR's own language |

**Response**:
```json
[
  {
    "id": 0,
    "name": "시스템 로그",
    "code": [
      {
        "id": 1,
        "name": "시스템 시작"
      },
      {
        "id": 2,
        "name": "시스템 종료"
      }
    ]
  },
  {
    "id": 1,
    "name": "카메라",
    "code": [
      {
        "id": 100,
        "name": "연결됨"
      },
      {
        "id": 101,
        "name": "연결 끊김"
      }
    ]
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | Int | Event type ID |
| `name` | String | Event type name (by language) |
| `code` | Array | Sub-event code list for this type |
| `code[].id` | Int | Event code ID |
| `code[].name` | String | Event code name (by language) |

### 9.2. Realtime Event Topics

Retrieves available topics for real-time event subscription.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/event/realtime` | Available subscription topics |

**Response**:
```json
[
  "channelStatus",
  "emergencyCall",
  "LPR",
  "systemEvent",
  "notice",
  "motionChanges",
  "recordingStatus",
  "parkingCount",
  "parkingSpot",
  "object",
  "bodyTemperature",
  "vehicleTracking"
]
```

> **Note**: The response is a string array of available topic names. Use these values in the `topics` parameter when connecting to the WebSocket event subscription endpoint (`/wsapi/v1/events?topics=...`).

### 9.3. Event Log

Searches stored event logs.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/event/log` | Recent events |
| `GET /api/v1/event/log?timeBegin=...&timeEnd=...` | Events in specific period |
| `GET /api/v1/event/log?at=10&maxCount=20` | Pagination (20 from index 10) |
| `GET /api/v1/event/log?sort=asc` | Sort ascending (default: desc) |
| `GET /api/v1/event/log?type=0` | Specific event type only |
| `GET /api/v1/event/log?ch=1,2` | Specific channels only |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `timeBegin` | DateTime | N | - | Search start time (ISO 8601) |
| `timeEnd` | DateTime | N | - | Search end time (ISO 8601) |
| `at` | Int | N | 0 | Start index (pagination) |
| `maxCount` | Int | N | 50 | Maximum results |
| `sort` | String | N | `"desc"` | Sort order (`"asc"` or `"desc"`) |
| `type` | Int | N | - | Event type ID filter |
| `ch` | String | N | - | Channel filter (comma-separated, e.g., `"1,2,3"`) |

**Response**:
```json
{
  "totalCount": 100,
  "at": 0,
  "data": [
    {
      "id": 1,
      "type": 1,
      "typeName": "Camera",
      "code": 100,
      "codeName": "Connected",
      "chid": 1,
      "timeRange": ["2024-01-01T10:00:00"]
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `totalCount` | Int | Total search results |
| `at` | Int | Current start index |
| `data[].id` | Int | Event ID |
| `data[].type` | Int | Event type ID |
| `data[].typeName` | String | Event type name |
| `data[].code` | Int | Event code |
| `data[].codeName` | String | Event code name |
| `data[].chid` | Int | Related channel ID. `null` when the event is not tied to a single channel. For an incident that spans several channels, the channels are listed in `param` (see below) |
| `data[].timeRange` | Array | Event time range |
| `data[].param` | Object | Event-specific detail, as stored. Its structure depends on `code`. Treat it as open-ended and ignore keys you do not handle. Unlike `typeName` / `codeName`, it is **not** localized. |

#### Storage failure detail

Recording events with `codeName` `"Storage error"` / `"Storage ready"` carry `param.statusCode`:

| `statusCode` | Meaning |
|-----:|---------|
| `0` | Normal |
| `-1` | Not exist |
| `-2` | Write only |
| `-4` | Read only |
| `-6` | Read write denied |
| `-8` | Storage cleanup stopped. Recording continues, but deferred deletion and orphaned-file cleanup are not running |
| `-9` | Storage write stalled. The storage accepted no writes while data was waiting to be written |
| `-100` | Unknown error |

`-9` is emitted in two cases:

| Emitted when | Payload |
|---|---|
| Disk I/O calls repeatedly took over 10 seconds — three or more within a rolling 1-hour window | `stallCount`, `stalledSec`, `chid` |
| The storage accepted no writes at all while data was queued | `stalledSec` |

The first is an **incident row**. It is created as soon as the condition is met, not after the problem ends. It is updated about once a minute while the condition lasts (`ongoing: true`) and is finalized when the count in the window falls below the threshold. `data[].timeRange` extends as the incident continues, so the same `data[].id` can return a wider range on a later poll. The second is emitted once, after the stall ends.

Both include a **loss summary** when video was lost: `lostSec`, `channels`, `channelList` and `droppedFrames`, measured from the start of the incident. The loss is expressed in seconds of video and number of channels rather than in frames.

**When no video was lost, these four keys are omitted.** This is the normal case: the write queue absorbed the stall. Treat their absence as "no loss", not as missing data. Do not default them to zero and report a loss of 0.

| Field | Type | Description |
|-------|------|-------------|
| `storagePath` | String | Recording storage that stalled |
| `stalledSec` | Int | Longest single unresponsive stretch in the incident, in seconds |
| `stallCount` | Int | How many disk I/O calls took over 10 seconds during the incident |
| `chid` | Int | Channel that saw the longest of those calls. **0-based**, unlike `data[].chid` |
| `lostSec` | Int | Video actually lost during the incident, in seconds, all channels combined. Absent when nothing was lost |
| `channels` | Int | Number of channels that lost video. Absent when nothing was lost |
| `channelList` | Array | Those channel IDs. **0-based**. Absent when nothing was lost |
| `droppedFrames` | Int | Frames lost, all channels combined. Diagnostic detail behind `lostSec`. Absent when nothing was lost |
| `ongoing` | Bool | Present and `true` while the incident is still open |

Stall with no loss (the common case):

```json
{
  "storagePath": "G:\\recData",
  "statusCode": -9,
  "stalledSec": 20
}
```

Stall with video loss:

```json
{
  "storagePath": "G:\\recData",
  "statusCode": -9,
  "stalledSec": 67,
  "stallCount": 19,
  "chid": 3,
  "lostSec": 200,
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

`lostSec` is the **total missing video**, not the duration of the incident. A `-9` incident lasting two hours may have lost only three minutes of video. The `period` of the `"Recording frame drop"` event gives the duration, and `lostSec` gives the amount lost.

#### Recording frame drop detail

`"Recording frame drop"` reports video that was lost and cannot be recovered.

**One event covers one incident, not one channel.** Frames dropped on multiple channels during the same period are recorded in a single row, so `data[].chid` is `null` and the affected channels are listed in `param`. An incident ends after 60 seconds without further drops. As with `-9` above, the row is created immediately and updated while the incident lasts. Both `data[].timeRange` and `param.period` extend with it.

A `-9` event at the same time is the usual **cause**: the storage could not keep up and the write queue rejected frames. A drop limited to one or two channels has a different cause, because disk latency affects all channels.

| Field | Type | Description |
|-------|------|-------------|
| `period` | Array | Missing period — two ISO 8601 timestamps, start and end |
| `channels` | Int | Number of affected channels |
| `channelList` | Array | Affected channel IDs. **0-based**, unlike `data[].chid` |
| `droppedFrames` | Int | Frames lost in the incident, all channels combined |
| `ongoing` | Bool | Present and `true` while the incident is still open |

```json
{
  "period": ["2026-08-31T19:36:41", "2026-08-31T20:22:30"],
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

#### Missing recording detail

`"Missing recording"` is reported per channel, so `data[].chid` identifies the channel. The recording watchdog detected that nothing was written for the channel and restarted its stream. The other fields describe the state at that moment and help distinguish a storage problem from a stream problem.

| Field | Type | Description |
|-------|------|-------------|
| `secs` | Int | How long recording had been failing before the restart, in seconds |
| `streamFps` | Int | Stream frame rate at that moment. `0` indicates a camera or network problem rather than a storage problem |
| `storage` | Int | ID of the recording storage in use |
| `freeMB` | Int | Free space on it, in MB. `-1` if it could not be read |
| `anchorAge` | Int | Seconds since the last successful free-space reading. A large value means the volume stopped responding. `-1` if it was never read |
| `queuePct` | Int | Write queue occupancy, in percent. A low value while recording is failing rules out a full write queue as the cause. `-1` if unavailable |

```json
{
  "secs": 30,
  "streamFps": 15,
  "storage": 2,
  "freeMB": 10240,
  "anchorAge": -1,
  "queuePct": 0
}
```

#### System disk warning

System log events record each change in the system disk level (see `systemDisk` in
[5.2. System Health](#52-system-health)). For the current state, use the `notice` channel
([5.5. System Notices](#55-system-notices)). One event is emitted for each level change:

| `code` | `codeName` | When |
|-----:|---------|------|
| `51` | `"System disk space is low"` | Free space fell under 1 GB |
| `52` | `"System disk is full"` | Free space fell under 200 MB, or a record could not be written for lack of space or an I/O error |
| `53` | `"System disk space has been restored."` | Back to normal |

`codeName` is localized to the requested language. `param` carries `drive`, `totalSpace`,
`freeSpace`, `status` and `dataWriteFailed` — the same fields as `systemDisk` in the health response.

If the disk is too full to store the event, the event is still delivered to `systemEvent`
subscribers with `id` `-1`, but it does not appear in the event log. Clients that must not miss
it should subscribe instead of polling the log.

#### Sign-in failure

Privacy events (`type` `1`) with `code` `6` (`"Failure to sign in"`) record sign-in failures,
including password authentication failures from the local screen, the API and live streams.
`param` has the following fields:

| Field | Description |
|------|------|
| `uid` | User ID that was entered |
| `addr` | Client address. `"local"` for a connection from the server PC |
| `lockedUntil` | Time the sign-in block ends (ISO 8601), when this failure started a block. Omitted otherwise. |

### 9.4. Event Trigger (Event Backup)

Triggers PTZ preset movement and/or event backup recording on specified channels. Used for external system integration (e.g., access control, fire alarm, intrusion detection).

> Requires the **Event Backup** license. Returns `404` if the license is not installed.

| Endpoint | Description | Permission |
|----------|-------------|------------|
| `PUT /api/v1/event/trigger` | Trigger PTZ preset and/or event backup | `Control` |

**Request**:

```http
PUT /api/v1/event/trigger
Content-Type: application/json

{
  "chid": 1,
  "timestamp": "2024-01-15T14:30:00",
  "tasks": [
    {
      "command": "presetGo",
      "token": "preset_token_1"
    },
    {
      "command": "eventBackup",
      "preAlarm": "30s",
      "postAlarm": "2m",
      "chids": [1, 2, 3]
    }
  ]
}
```

**Request Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `chid` | Int | Y | Primary channel ID (1-based) |
| `timestamp` | DateTime | N | Event time (ISO 8601). Defaults to current server time |
| `tasks` | Array | Y | Array of task objects to execute |

**Task Commands**:

| Command | Description |
|---------|-------------|
| `presetGo` | Move camera to a PTZ preset position |
| `eventBackup` | Start recording and schedule backup to event storage |

**`presetGo` Request Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | String | Y | `"presetGo"` |
| `token` | String | Y | PTZ preset token (from ONVIF preset list) |

**`eventBackup` Request Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | String | Y | `"eventBackup"` |
| `preAlarm` | String/Int | N | Pre-event duration. String (`"30s"`, `"5m"`) or seconds. Default: 5 min, max: 1 hour |
| `postAlarm` | String/Int | N | Post-event duration. String (`"30s"`, `"5m"`) or seconds. Default: 60 min, max: 1 hour |
| `chids` | Array\<Int\> | N | Channel IDs to backup (1-based). Defaults to `[chid]` |

> Duration format: numeric value (seconds) or string with suffix — `s` (seconds), `m` (minutes), `h` (hours). Examples: `30`, `"30s"`, `"5m"`, `"1h"`.

**Response**:

```json
{
  "eventId": 12345,
  "videoURLs": [
    "/event-storage/c/20240115/143000/ch1-20240115-143000.mp4",
    "/event-storage/c/20240115/143000/ch2-20240115-143000.mp4",
    "/event-storage/c/20240115/143000/ch3-20240115-143000.mp4"
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `eventId` | Int | Event log ID |
| `videoURLs` | Array\<String\> | Backup video URLs (available after post-alarm recording completes) |

> The backup runs asynchronously. `videoURLs` are returned immediately, but the files become available only after the post-alarm period ends and the backup completes.

> **Examples:** [JavaScript](examples/javascript/05-event-log.js) · [Python](examples/python/05_event_log.py) · [C#](examples/csharp/05_EventLog.cs) · [Go](examples/go/05_events/) · [Java](examples/java/V1_05_EventLog.java) · [Kotlin](examples/kotlin/V1_05_EventLog.kt) · [Swift](examples/swift/05-event-log.swift) · [PowerShell](examples/powershell/05-event-log.ps1) · [curl](examples/curl/05-event-log.sh)

---

## 10. LPR (License Plate Recognition)

License plate recognition API.

### 10.1. LPR Source List (Recognition Point/Zone)

Retrieves LPR source (recognition point/zone) list.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/lpr/source` | LPR source list |

**Response**:
```json
[
  {
    "id": 1,
    "code": "GATE-IN",
    "name": "Entrance Gate",
    "linkedChannel": [1, 2],
    "tag": "Normal"
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | Int | Source ID |
| `code` | String | Source code |
| `name` | String | Source name |
| `linkedChannel` | Array\<Int\> | Linked channel list |
| `tag` | String | Status tag (`Normal`, `ReadOnly`, `NotUsed`) |

### 10.2. LPR Log

Searches license plate recognition logs.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/lpr/log` | Recent records |
| `GET /api/v1/lpr/log?keyword=1234` | Plate search (partial match) |
| `GET /api/v1/lpr/log?timeBegin=...&timeEnd=...` | Specific period search |
| `GET /api/v1/lpr/log?src=1,2` | Specific LPR source search |
| `GET /api/v1/lpr/log?at=0&maxCount=50` | Pagination |
| `GET /api/v1/lpr/log?sort=asc` | Sort ascending |
| `GET /api/v1/lpr/log?export=true` | CSV export format |
| `GET /api/v1/lpr/log?unrecognized=true` | Only records where no plate was read |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `keyword` | String | N | - | Plate keyword (partial match) |
| `unrecognized` | Boolean | N | false | Only records where **no plate was read**. This cannot be expressed with `keyword` |
| `timeBegin` | DateTime | Y | - | Search start time (ISO 8601) |
| `timeEnd` | DateTime | Y | - | Search end time (ISO 8601) |
| `src` | String | N | - | LPR source filter (comma-separated) |
| `at` | Int | N | 0 | Start index (pagination) |
| `maxCount` | Int | N | 50 | Maximum results |
| `sort` | String | N | `"desc"` | Sort order (`"asc"` or `"desc"`) |
| `export` | Boolean | N | false | When true, returns CSV format |

> **Records with no plate.** `plateNo` is `null`. Earlier versions stored a placeholder string
> (`xxxx`) that looked like a real plate. Those records now also return `null`. A keyword
> cannot match them, so use `unrecognized=true`.

> **Note**: `timeBegin` and `timeEnd` are required. `export=true` requests may take a long time on large datasets, so set an appropriate timeout.

**Response**:
```json
{
  "totalCount": 50,
  "at": 0,
  "data": [
    {
      "id": 1,
      "plateNo": "12가3456",
      "score": 95.5,
      "timeRange": ["2024-01-01T10:00:00"],
      "srcCode": "GATE-IN",
      "srcName": "Entrance Gate",
      "direction": "entry",
      "image": ["/lpr/image1.jpg"],
      "vod": [
        {
          "chid": 1,
          "videoSrc": "/watch?ch=1&when=..."
        }
      ]
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `totalCount` | Int | Total result count |
| `at` | Int | Current offset |
| `data` | Array | Recognition result list |
| `data[].id` | Int | Record ID |
| `data[].plateNo` | String | License plate number. Always the **current** value. After a correction ([10.4](#104-vehicle-number-correction)), this is the corrected plate |
| `data[].plateEdited` | Boolean | `true` if a person corrected the plate |
| `data[].originalPlateNo` | String | (only when `plateEdited`) The plate as first recognized (`""` if none was read) |
| `data[].score` | Float | Recognition confidence |
| `data[].timeRange` | Array | `[startTime, endTime]` (ISO 8601) |
| `data[].srcCode` | String | LPR source code |
| `data[].srcName` | String | LPR source name |
| `data[].direction` | String | Direction (`entry`, `exit`) |
| `data[].image` | Array\<String\> | Image URL list |
| `data[].vod` | Array | Linked video info |
| `data[].vod[].chid` | Int | Channel number |
| `data[].vod[].videoSrc` | String | Video URL |

### 10.3. Similar Plate Search

Searches plates by partial or full keyword. Returns all plates containing the keyword. This is useful for looking up a partial number or finding misrecognized plates.

For example, if you only know the four-digit number `1234`, searching with `keyword=1234` returns all recognized plates containing that number, such as `"12가1234"`, `"56나1234"`, etc.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/lpr/similar?keyword=1234` | Search plates containing `1234` |
| `GET /api/v1/lpr/similar?keyword=12가` | Search plates containing `12가` |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keyword` | String | Y | Plate keyword (partial or full). Returns all plates containing this string. |

**Response:** Array of plate number strings containing the keyword (ordered by most recent)
```json
["12가1234", "56나1234", "78다1234", ...]
```

### 10.4. Vehicle Number Correction

Corrects the plate number of **one** recognition record when it was misread. For parking
billing, correct the session's representative plate instead ([16.9](#169-vehicle-number-correction)).

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/lpr/log/{id}/plate` | Correct the plate of record `{id}` |
| `GET /api/v1/lpr/log/{id}/plate/history` | Correction history of record `{id}` |

**Rules**

| Item | Rule |
|---|---|
| Target | Exactly **one** record, by its `id`. There is no bulk correction and no correction by plate value |
| Where the `id` comes from | `data[].id` of [10.2](#102-lpr-log), or the `id` that the realtime `LPR` event carries next to each `plateNo` |
| History | Each correction adds a new row. Earlier rows are not changed. An incorrect correction remains in the history; fix it by submitting another correction |
| Format | Not checked (plates differ by country). 1–32 characters after trimming |
| Effect | Changes the stored record only. Events already sent (push, registered-vehicle matching, signboard) are not re-evaluated |
| Permission | **Control** |

**Parameters** (query, form, or a JSON body):

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `plateNo` | String | Y | New plate number (1–32 characters) |
| `reason` | String | N | Reason for the change (up to 200 characters) |

**Response**:
```json
{
  "id": 91234,
  "plateNo": "12가3456",
  "previousPlateNo": "12가3458",
  "originalPlateNo": "12가3458",
  "editCount": 1,
  "edit": {
    "id": 57,
    "time": "2026-10-22T14:03:11.000+09:00",
    "user": "admin",
    "reason": "misread at night"
  }
}
```

| Field | Description |
|-------|-------------|
| `previousPlateNo` | Value just before this correction (`""` for an unrecognized record) |
| `originalPlateNo` | Value as first recognized |
| `editCount` | Number of corrections so far, including this one |
| `edit.user` | Account that made the correction (for an API key, the account that issued it) |

**History response**:
```json
{
  "target": "lpr",
  "id": 91234,
  "plateNo": "12가3456",
  "originalPlateNo": "12가3458",
  "edits": [
    { "id": 41, "time": "2026-10-22T13:58:02.000+09:00", "user": "admin",
      "before": "12가3458", "after": "12가3486", "reason": "" },
    { "id": 57, "time": "2026-10-22T14:03:11.000+09:00", "user": "admin",
      "before": "12가3486", "after": "12가3456", "reason": "misread at night" }
  ]
}
```

`edits` is listed in the order recorded. It is empty (and `originalPlateNo` is omitted) when the
record was never corrected. Reading the history requires **Playback** permission.

| Status | Meaning |
|--------|---------|
| `400` | Invalid ID, `plateNo` missing / empty / longer than 32, or `reason` longer than 200 |
| `403` | Needs **Control** permission (history: **Playback**) |
| `404` | No record with that ID |
| `409` | `plateNo` equals the current plate |

> **Examples:** [JavaScript](examples/javascript/06-lpr-search.js) · [Python](examples/python/06_lpr_search.py) · [C#](examples/csharp/06_LprSearch.cs) · [Go](examples/go/06_lpr/) · [Java](examples/java/V1_06_LprSearch.java) · [Kotlin](examples/kotlin/V1_06_LprSearch.kt) · [Swift](examples/swift/06-lpr-search.swift) · [PowerShell](examples/powershell/06-lpr-search.ps1) · [curl](examples/curl/06-lpr-search.sh)

---

## 11. Object Detection

API for querying stored object detection metadata from AI cameras. An AI camera that supports object detection must be connected to use this feature.

> **Note**: The Object Detection API requires a license. Returns 404 if the license is not activated.

### 11.1. Object Types

Retrieves detectable object types.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/object/type` | Detectable object type list |

**Response**:
```json
["face", "human", "vehicle"]
```

### 11.2. Object Attributes

Retrieves searchable attributes per object type.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/object/attr` | All object attributes |
| `GET /api/v1/object/attr?type=face` | Face object attributes |
| `GET /api/v1/object/attr?type=human` | Human object attributes |
| `GET /api/v1/object/attr?type=vehicle` | Vehicle object attributes |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | String | N | Object type filter (`face`, `human`, `vehicle`). All types if omitted. |

**Response**:
```json
{
  "face": {
    "gender": ["female", "male"],
    "age": ["young", "adult", "middle", "senior"],
    "hat": [true, false],
    "glasses": [true, false],
    "mask": [true, false]
  }
}
```

### 11.3. Object Search

Searches detected objects by attributes.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/object/log` | All objects |
| `GET /api/v1/object/log?objectType=face` | Face only |
| `GET /api/v1/object/log?objectType=human&gender=male` | Male only |
| `GET /api/v1/object/log?objectType=human&upper=red` | Red upper clothing |
| `GET /api/v1/object/log?objectType=vehicle&vehicleType=car` | Cars only |
| `GET /api/v1/object/log?objectType=vehicle&color=white` | White vehicle |
| `GET /api/v1/object/log?timeBegin=...&timeEnd=...` | Specific period |
| `GET /api/v1/object/log?ch=1,2` | Specific channels only |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `timeBegin` | DateTime | N | - | Search start time (ISO 8601) |
| `timeEnd` | DateTime | N | - | Search end time (ISO 8601) |
| `ch` | String | N | All | Channel numbers (comma-separated) |
| `objectType` | String | N | All | `human`, `face`, `vehicle` |
| `gender` | String | N | - | `male`, `female` |
| `vehicleType` | String | N | - | `car`, `truck`, `bus`, `bicycle`, `motorcycle` |
| `at` | Int | N | 0 | Page offset |
| `maxCount` | Int | N | 100 | Maximum results |
| `sort` | String | N | `desc` | `asc` or `desc` |

**Response**:

| Field | Type | Description |
|-------|------|-------------|
| `totalCount` | Int | Total result count |
| `at` | Int | Current offset |
| `data` | Array | Object list |
| `data[].timestamp` | DateTime | Detection time |
| `data[].chid` | Int | Channel number |
| `data[].type` | String | Object type |
| `data[].attributes` | Object | Object attributes |
| `data[].image` | String | Image URL |

---

## 12. Face Search

API for finding a person in recorded video using a photo. It compares facial feature vectors from a deep learning model to find similar faces. An AI camera with object detection capabilities must be connected to use this feature.

> **Note**: Face Search requires a license. Returns 404 if the license is not activated.

### 12.1. Search by Image

Searches for faces similar to the uploaded image.

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/face/search` | Image-based face search |

```http
POST /api/v1/face/search
Content-Type: multipart/form-data

file: <image_file>
threshold: 0.7
timeBegin: 2024-01-01
timeEnd: 2024-01-31
ch: 1,2,3
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `file` | File | Face image to search (JPEG, PNG) |
| `threshold` | Float | Similarity threshold (0.0~1.0, default 0.7) |
| `timeBegin` | DateTime | Search start time |
| `timeEnd` | DateTime | Search end time |
| `ch` | String | Channel filter (comma-separated) |
| `maxCount` | Int | Maximum results |

**Response**:

| Field | Type | Description |
|-------|------|-------------|
| `totalCount` | Int | Result count |
| `code` | Int | Result code |
| `data` | Array | Search result list |
| `data[].chid` | Int | Channel number |
| `data[].timestamp` | DateTime | Detection time |
| `data[].threshold` | Float | Similarity score |
| `data[].faceImg` | String | Face image URL |
| `data[].orgImg` | String | Original image URL |

### 12.2. Search by Time

Retrieves all faces detected in a specific period.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/face/search?timeBegin=...&timeEnd=...` | Face list by period |
| `GET /api/v1/face/search?ch=1&timeBegin=...&timeEnd=...` | Face list for specific channel |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ch` | String | N | Channel numbers (comma-separated) |
| `timeBegin` | DateTime | Y | Search start time |
| `timeEnd` | DateTime | Y | Search end time |

---

## 13. VOD

Retrieves live stream and recording playback URLs.

### 13.1. Stream URLs

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/vod` | All channel live stream URLs |
| `GET /api/v1/vod?when=now` | Live stream (explicit) |
| `GET /api/v1/vod?ch=1` | Specific channel stream |
| `GET /api/v1/vod?ch=1,2,3` | Multiple channel streams |
| `GET /api/v1/vod?protocol=rtmp` | RTMP streams only |
| `GET /api/v1/vod?protocol=flv` | HTTP-FLV streams only |
| `GET /api/v1/vod?protocol=websocket-flv` | WebSocket-FLV streams only |
| `GET /api/v1/vod?protocol=rtsp` | RTSP streams only |
| `GET /api/v1/vod?stream=sub` | Substream (low resolution) |
| `GET /api/v1/vod?stream=main` | Main stream (high resolution) |

### 13.2. Playback URLs

Retrieves recording playback URLs.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/vod?ch=1&when=2024-01-08T09:30:00` | Playback at specific time |
| `GET /api/v1/vod?id=1304&next` | Next recording segment |
| `GET /api/v1/vod?id=1304&prev` | Previous recording segment |
| `GET /api/v1/vod?ch=1&when=...&otherwise=nearBefore` | Playback at that time, or the nearest **earlier** recording if there is none |

**`otherwise` — behavior when no recording exists at the requested time**

| Value | Behavior |
|-------|----------|
| (omitted) | Nothing is returned for that channel |
| `nearBefore` | The nearest recording **before** the requested time |
| `nearAfter` | The nearest recording **after** the requested time |

`nearBefore` is intended for parking history. A parked vehicle does not move, so
motion-triggered recording may stop while the vehicle is still present. Because the vehicle is
in the same place, the preceding footage still shows the situation at that moment. Use it for
requests from parking history (section 16.5+). Do not use it for event, LPR, or object searches.
Those searches concern a specific moment, and earlier footage would show a different moment.

**Response**:
```json
[
  {
    "chid": 1,
    "title": "Front Door",
    "displayName": "CH1. Front Door",
    "src": [
      {
        "protocol": "rtmp",
        "profile": "main",
        "src": "rtmp://host/live/ch1main",
        "type": "rtmp/mp4",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "flv",
        "profile": "main",
        "src": "https://host/live?app=live&stream=ch1main",
        "type": "video/x-flv",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "websocket-flv",
        "profile": "main",
        "src": "wss://host/live?app=live&stream=ch1main",
        "type": "video/x-flv",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "rtsp",
        "profile": "main",
        "src": "rtsp://host/live/ch1main",
        "type": "application/x-rtsp",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "rtmp",
        "profile": "sub",
        "src": "rtmp://host/live/ch1sub",
        "type": "rtmp/mp4",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "flv",
        "profile": "sub",
        "src": "https://host/live?app=live&stream=ch1sub",
        "type": "video/x-flv",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "websocket-flv",
        "profile": "sub",
        "src": "wss://host/live?app=live&stream=ch1sub",
        "type": "video/x-flv",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "rtsp",
        "profile": "sub",
        "src": "rtsp://host/live/ch1sub",
        "type": "application/x-rtsp",
        "label": "VGA",
        "size": [640, 480]
      }
    ]
  }
]
```

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ch` | String | N | All | Channel numbers (comma-separated, e.g., `"1,2,3"`) |
| `when` | String | N | `"now"` | `"now"`=live, ISO 8601=recording playback |
| `protocol` | String | N | All | Protocol filter (see table below) |
| `stream` | String | N | All | Stream type (`"main"`=high resolution, `"sub"`=low resolution) |
| `id` | Int | N | - | VOD segment ID (for recording navigation) |
| `next` | Flag | N | - | Next recording segment (used with `id`) |
| `prev` | Flag | N | - | Previous recording segment (used with `id`) |
| `otherwise` | String | N | - | Fallback when nothing was recorded at that time (`nearBefore` / `nearAfter`, see table above) |
| `duration` | String | N | `"1m"` | Window to search from `when`. A bare number means seconds; suffixes `m`, `h`, `d`, `w` |
| `limit` | Int | N | `10` | Maximum segments per channel |
| `nolive` | Boolean | N | false | Disable the live fallback (see note below) |

| Response Field | Type | Description |
|----------------|------|-------------|
| `chid` | Int | Channel ID |
| `title` | String | Channel name |
| `src` | Array | Stream URL list |
| `src[].protocol` | String | Protocol name |
| `src[].profile` | String | Stream profile (`"main"`, `"sub"`) |
| `src[].src` | String | Stream URL |
| `src[].type` | String | MIME type |
| `src[].label` | String | Resolution label (e.g., `"1080p"`) |
| `src[].size` | number[] | Resolution `[width, height]` |

**The recording-playback response** (when `when` specifies a time) has a different structure.
`protocol` and `profile` are returned only for live streams. Instead, each segment is identified
by `fileId` and includes the `timeRange` it covers.

```json
[
  {
    "chid": 1,
    "title": "Front Door",
    "fileId": 1304,
    "src": [
      {
        "src": "https://host/storage/f/00/13/1304.mp4",
        "type": "video/mp4",
        "label": "1080p",
        "size": [1920, 1080],
        "timeRange": ["2024-01-08T09:28:11+09:00", "2024-01-08T09:33:04+09:00"]
      }
    ]
  }
]
```

| Response Field (recording) | Type | Description |
|----------------------------|------|-------------|
| `fileId` | Int | Segment ID. Use `?id=<fileId>&next` / `&prev` to navigate to adjacent segments |
| `src[].timeRange` | String[] | `[start, end]` of that segment (see [1.1](#11-time-notation)) |

> **Live fallback.** When the query finds nothing **and the requested time is now or later**,
> the server returns that channel's live stream instead, in the live format shown above. For
> this reason, a future timestamp does not return an empty result. Pass `nolive=true` to get
> recordings only.

> **Deleted files are omitted.** Segments removed by the retention policy are excluded even if
> their records still exist. An `otherwise` lookup can therefore return an **empty array**. This
> is most likely with `nearAfter`: when the requested time is earlier than every remaining
> recording, it selects the oldest one, and the oldest recordings are the first to be deleted.
> An empty array is not an error.

**Available Protocols**:
| Protocol | Description | Condition |
|----------|-------------|-----------|
| `rtmp` | RTMP stream | Always |
| `flv` | HTTP-FLV stream (`http`/`https`) | HTTP-FLV enabled |
| `websocket-flv` | WebSocket-FLV stream (`ws`/`wss`) | HTTP-FLV enabled |
| `rtsp` | RTSP re-stream (`rtsp`), TCP only | RTSP re-streaming enabled |

> **`flv` vs `websocket-flv`**: Both use the same stream and endpoint; only the transport differs. `flv` uses HTTP chunked transfer. `websocket-flv` upgrades the connection to WebSocket and sends each FLV tag as one binary frame. The scheme matches the request scheme (`http`→`ws`, `https`→`wss`). Both work with players such as flv.js / mpegts.js.

> **Use `websocket-flv` when displaying several channels at once.** A live stream keeps its connection open during playback, so the number of open connections equals the number of channels on screen. Browsers limit **HTTP/1.1 connections to about 6 per origin**. This endpoint does not support HTTP/2 or HTTP/3, so each `flv` stream uses one of those 6 connections. Additional channels wait for a free connection, and other requests to the same origin (REST calls, thumbnails) are queued behind them. WebSocket connections do not count toward this limit, so `websocket-flv` has no practical concurrency limit for a video wall. For a single channel, either protocol works.

> **`rtsp`**: The server re-sends the same RTMP stream over RTP. **Only TCP interleaved transport is supported.** A UDP `SETUP` request returns `461 Unsupported Transport`, so configure clients that default to UDP to use TCP (`vlc --rtsp-tcp`, `ffplay -rtsp_transport tcp`). Basic authentication is required and cannot be disabled. Include the credentials in the URL (`rtsp://user:pass@host/live/ch1main`) and percent-encode reserved characters (`@` becomes `%40`). Video is **H.264 only**. Browsers cannot play RTSP. Use it for external players, VMS integrations, and FFmpeg-based pipelines, not for web pages.

> **Embedding video in a web page?** You usually do not need these URLs. The server provides a ready-made player at [`GET /watch`](#133-watch-page-embeddable-player). Place it in an `<iframe>`; it handles protocol selection, authentication (`token` / `apikey`), and recorded playback. Build your own player on `flv` / `websocket-flv` only if you need features the Watch Page does not provide.

> **Note**: The `X-Host` header is required. It is set automatically on standard web browser requests. When calling directly, include the `X-Host: {host}:{port}` header.

> **Examples:** [JavaScript](examples/javascript/07-vod-stream.js) · [Python](examples/python/07_vod_stream.py) · [C#](examples/csharp/07_VodStream.cs) · [Go](examples/go/07_vod/) · [Java](examples/java/V1_07_VodStream.java) · [Kotlin](examples/kotlin/V1_07_VodStream.kt) · [Swift](examples/swift/07-vod-stream.swift) · [PowerShell](examples/powershell/07-vod-stream.ps1) · [curl](examples/curl/07-vod-stream.sh)

### 13.3. Watch Page (Embeddable Player)

Returns an HTML page with an embedded video player. Useful for embedding live or recorded video in external systems (iframe, notification links, etc.).

| Endpoint | Description |
|----------|-------------|
| `GET /watch?ch=1` | Live video of channel 1 |
| `GET /watch?ch=1&when=2024-01-01T10:30:00` | Recorded video at specific time |
| `GET /watch?ch=1&id=1304` | Recorded video by segment ID |

**Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ch` | String | N | `"1"` | Channel number (1-based) |
| `when` | DateTime | N | - | ISO 8601 timestamp for recorded playback (omit for live) |
| `id` | String | N | - | VOD segment ID for recorded playback |
| `duration` | String | N | `"1h"` | Recording search window duration |
| `showTitle` | Boolean | N | false | Show video title overlay |
| `showPlaytime` | Boolean | N | false | Show current playback time overlay |
| `noContextMenu` | Boolean | N | false | Disable right-click context menu |
| `token` | String | N | - | JWT access token for authentication |
| `apikey` | String | N | - | API Key for authentication |

> **Note**: Authentication is optional when opening the URL. If no valid session exists, a login dialog is displayed. The `token` or `apikey` parameter can pre-authenticate the session.

**Response**: `text/html` — HTML page with embedded video player.

**Example** (iframe embedding):
```html
<iframe src="http://nvr-host/watch?ch=1&showTitle=true&noContextMenu=true&apikey=tsapi_key_..."
        width="640" height="360" frameborder="0"></iframe>
```

---

## 14. Emergency

Emergency call API.

> **Note**: The Emergency API requires a license. Returns 404 if the license is not activated.

### 14.1. Emergency Call List

Retrieves registered emergency call device list.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/emergency` | Emergency call device list |

**Response**:
```json
[
  {
    "id": 1,
    "code": "EM-001",
    "name": "Fire Alarm",
    "linkedChannel": [1, 2, 3]
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | Int | Device ID |
| `code` | String | Device code |
| `name` | String | Device name |
| `linkedChannel` | Array | Linked camera channel ID list |

> **Examples:** [JavaScript](examples/javascript/11-emergency.js) · [Python](examples/python/11_emergency.py) · [C#](examples/csharp/11_Emergency.cs) · [Go](examples/go/11_emergency/) · [Java](examples/java/V1_11_Emergency.java) · [Kotlin](examples/kotlin/V1_11_Emergency.kt) · [Swift](examples/swift/11-emergency.swift) · [PowerShell](examples/powershell/11-emergency.ps1) · [curl](examples/curl/11-emergency.sh)

---

## 15. Push (LPR Camera, Emergency Bell Integration)

Sends events to the NVR from external sources. Used for LPR camera and emergency bell integration.

> **Note**: The Push API requires a license. Returns 404 if the license is not activated.

### 15.1. Send Push Event

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/push` | Send event data |

**Supported Topics**:
| Topic | Description |
|-------|-------------|
| `LPR` | License plate recognition data |
| `emergencyCall` | Emergency call event (alarm start/stop) |

#### 15.1.1. LPR Push

Sends license plate data from external LPR cameras.

```http
POST /api/v1/push
Content-Type: application/json

{
  "topic": "LPR",
  "src": "1",
  "plateNo": "12가3456",
  "when": "2024-01-01T12:00:00"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | String | Y | Fixed as `"LPR"` |
| `src` | String | Y | LPR source ID |
| `plateNo` | String | Y | Recognized plate |
| `when` | DateTime | Y | Recognition time (ISO 8601) |

#### 15.1.2. Emergency Call Push

Sends emergency call device status.

```http
POST /api/v1/push
Content-Type: application/json

{
  "topic": "emergencyCall",
  "device": "dev1",
  "src": "1",
  "event": "callStart",
  "camera": "1,2",
  "when": "2024-01-01T10:00:00"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | String | Y | Fixed as `"emergencyCall"` |
| `device` | String | Y | Device identifier |
| `src` | String | Y | Source ID |
| `event` | String | Y | `"callStart"` (alarm start) or `"callEnd"` (alarm stop) |
| `camera` | String | Y | Linked camera channels (comma-separated, e.g., `"1,2"`) |
| `when` | DateTime | Y | Event time (ISO 8601) |

> ⚠️ **Warning**: Sending `callStart` triggers the actual emergency alarm. Always send `callEnd` to stop the alarm.

> **Examples:** [JavaScript](examples/javascript/09-push-notification.js) · [Python](examples/python/09_push.py) · [C#](examples/csharp/09_Push.cs) · [Go](examples/go/09_push/) · [Java](examples/java/V1_09_Push.java) · [Kotlin](examples/kotlin/V1_09_Push.kt) · [Swift](examples/swift/09-push.swift) · [PowerShell](examples/powershell/09-push.ps1) · [curl](examples/curl/09-push.sh)

---

## 16. Parking

Parking management API. Supports two concepts: parking lot and parking spot.

### 16.1. Parking Lot

Counter-based entry/exit management per parking lot.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/lot` | Parking lot list |

**Response**:
```json
[
  {
    "id": 1,
    "name": "Main Lot",
    "type": "counter",
    "maxCount": 100,
    "parkingSpots": [101, 102, 103]
  },
  {
    "id": 2,
    "name": "All",
    "type": "group",
    "maxCount": 300,
    "member": [1, 3]
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Parking lot ID |
| `name` | string | Parking lot name |
| `type` | string | `"counter"` (entry/exit counting) or `"group"` (aggregated from members) |
| `maxCount` | number | Maximum parking capacity |
| `member` | number[] | (group only) Member parking lot IDs |
| `parkingSpots` | number[] | (optional) Associated parking spot IDs (LPR source IDs, used when the lot is counted by spot occupancy) |

### 16.2. Parking Lot Status

Returns parking occupancy status per lot.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/lot/status` | All lot status |
| `GET /api/v1/parking/lot/status?id=1,2` | Specific lot status |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | String | N | Parking lot IDs (comma-separated, all if omitted) |

**Response**:
```json
[
  {
    "id": 1,
    "name": "Main Lot",
    "maxCount": 100,
    "count": 45,
    "available": 55
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | Int | Parking lot ID |
| `name` | String | Parking lot name |
| `maxCount` | Int | Maximum parking capacity |
| `count` | Int | Current parked count |
| `available` | Int | Available spots |

### 16.3. Parking Spot (LPR Zone)

Lists all LPR (license plate recognition) zones configured in the system. Returns all zone types including parking spots, entrances, exits, no-parking zones, and recognition-only zones.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/spot` | All LPR zones (all types) |
| `GET /api/v1/parking/spot?ch=1` | Zones for specific channel |
| `GET /api/v1/parking/spot?id=1,2,3` | Specific zone query |
| `GET /api/v1/parking/spot?category=disabled` | Filter by category |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ch` | String | N | Channel numbers (comma-separated) |
| `id` | String | N | Zone IDs (comma-separated) |

**Response**:
```json
[
  {
    "id": 1,
    "chid": 1,
    "name": "A-001",
    "type": "spot",
    "category": "normal",
    "occupied": true,
    "vehicle": {
      "plateNo": "12가3456",
      "score": 95
    }
  },
  {
    "id": 2,
    "chid": 1,
    "name": "Main Gate",
    "type": "entrance",
    "category": null
  }
]
```

> For parking spots (`type:"spot"`), occupancy status and vehicle plate number are also returned. For more detailed occupancy info (parking start time, vehicle image, etc.), use the [Parking Spot Status](#164-parking-spot-status) API.

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Zone ID |
| `chid` | number | Channel ID |
| `name` | string | Zone name |
| `type` | string | Zone type (see table below) |
| `category` | string\|null | Spot category (only for `type:"spot"`, see table below). `null` for non-spot types. |
| `occupied` | boolean | (spot only) Whether the spot is occupied |
| `vehicle` | object\|null | (spot only) Vehicle info when occupied. Omitted when not occupied. |
| `vehicle.plateNo` | string | Vehicle plate number |
| `vehicle.score` | number | Recognition score |

**`type` Zone Types:**

| Value | Description |
|-------|-------------|
| `spot` | Parking spot — tracks vehicle occupancy |
| `entrance` | Entrance — recognizes entering vehicles |
| `exit` | Exit — recognizes exiting vehicles |
| `noParking` | No parking — prohibited zone (violation detection) |
| `recognition` | Recognition only — performs plate recognition without tracking occupancy |

**`category` Spot Categories** (when `type:"spot"`):

| Value | Description |
|-------|-------------|
| `normal` | General parking |
| `disabled` | Accessible / handicapped |
| `compact` | Compact car only |
| `eco_friendly` | Eco-friendly vehicle |
| `ev_charging` | EV charging |
| `women_family` | Women / family priority |

### 16.4. Parking Spot Status

Retrieves real-time spot occupancy. Returns only parking spots (`type:"spot"`).

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/spot/status` | All spot status |
| `GET /api/v1/parking/spot/status?ch=1` | Spot status for specific channel (1-based) |
| `GET /api/v1/parking/spot/status?image=true` | Include thumbnail image |
| `GET /api/v1/parking/spot/status?occupied=true` | Occupied spots only |
| `GET /api/v1/parking/spot/status?occupied=false` | Empty spots only |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ch` | String | N | Channel numbers (comma-separated) |
| `id` | String | N | Spot IDs (comma-separated) |
| `image` | Boolean | N | Include image data |

**Response**:
```json
[
  {
    "id": 1,
    "chid": 1,
    "name": "A-001",
    "category": "normal",
    "occupied": true,
    "vehicle": {
      "plateNo": "12가3456",
      "score": 95,
      "ev": false,
      "bike": false,
      "since": "2024-01-01T10:00:00"
    }
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | Int | Spot ID |
| `chid` | Int | Channel number |
| `name` | String | Spot name |
| `category` | String | Category (`normal`, `disabled`, `ev_charging`, etc.) |
| `occupied` | Boolean | Occupancy status |
| `vehicle` | Object\|null | Vehicle info |
| `vehicle.plateNo` | String | License plate number |
| `vehicle.score` | Float | Recognition confidence |
| `vehicle.ev` | Boolean | Electric vehicle |
| `vehicle.bike` | Boolean | Two-wheeler |
| `vehicle.since` | DateTime\|null | Parked since |
| `vehicle.image` | String | (with `image=true`) Vehicle image path |
| `vehicle.plate` | Object | (with `image=true`) Plate coordinates (`left`, `top`, `right`, `bottom`) in **absolute pixels**, relative to the `vehicle.image` crop — an exception to [1.2](#12-box-coordinates) |
| `vehicle.imageSize` | Object | (with `image=true`) Image dimensions (`width`, `height`) |

### 16.5. Parking Session History

A *parking session* is one vehicle's stay in one place. It opens when the vehicle is
confirmed present and closes when the vehicle leaves. Use sessions to find how long a
vehicle has been parked and to build billing records.

Sessions are recorded for three kinds of location (`kind`): a parking spot, an
entrance/exit gate, and a no-parking (dwell) zone.

> Requires the parking history license. Without it, every endpoint in 16.5–16.9 returns
> `403`. To check in advance, call `GET /api/v1/info?license`: the license is active when
> `license.extension` contains `parkingHistory` (see [Server Info](#4-server-info)).
> Reading requires **Playback** permission. 16.7, 16.8 and 16.9 modify history and require
> **Control** permission.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/session` | Session list |
| `GET /api/v1/parking/session?open=true` | Vehicles still parked |
| `GET /api/v1/parking/session?plateNo=12가3456&open=true` | Whether this plate is parked, and for how long |
| `GET /api/v1/parking/session?timeField=out&timeBegin=...&timeEnd=...` | Vehicles that left in a period |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `timeBegin` | DateTime | N | Period start |
| `timeEnd` | DateTime | N | Period end |
| `timeField` | String | N | What the period applies to: `in` (entry, default for most queries), `out` (exit), `overlap` (any overlap with the period) |
| `plateNo` | String | N | Exact plate match |
| `keyword` | String | N | Partial plate match |
| `scope` | String | N | What the query is scoped to: `all` (default), `spot`, `gate`, `noparking`, `channel`, `lot`. See the note below |
| `lot` | String | N | Parking lot IDs, comma-separated (matched against the lots recorded with the session) |
| `src` | String | N | Source IDs, comma-separated (spot / gate / dwell zone) |
| `ch` | String | N | Channel numbers, comma-separated (1-based) |
| `kind` | String | N | `spot`, `gate`, `dwell` — comma-separated, all if omitted |
| `outKind` | String | N | Exit basis, comma-separated (see table below) |
| `inKind` | String | N | Entry basis, comma-separated (see table below). Also matches open sessions |
| `open` | Boolean | N | `true` = still parked, `false` = already left |
| `paid` | Boolean | N | `true` = has an **effective** payment record (undone ones excluded) |
| `exempt` | Boolean | N | `true` = only sessions exempt from billing. Use it to **find an exemption before reverting it** (see [16.7](#167-change-payment-state)) |
| `hasPlate` | Boolean | N | `true` = plate was recognized |
| `durationMin` | Int | N | Minimum stay, seconds |
| `durationMax` | Int | N | Maximum stay, seconds |
| `unpaidDurationMin` | Int | N | Minimum unpaid time, seconds (time since the last payment) |
| `at` | Int | N | Offset for paging (default `0`) |
| `maxCount` | Int | N | Page size (server cap applies) |
| `sort` | String | N | `desc` (default) or `asc` |
| `sortBy` | String | N | `time` (entry time, default) or `duration` |
| `includePayments` | Boolean | N | Include the `payments` array in each session |

**`scope` — what the query is scoped to**

`scope` determines *which list* the item parameter refers to. Each scope uses a different item
parameter.

| `scope` | Item parameter | When items are omitted |
|---------|---------------|------------------------|
| `all` (default) | — | No scope condition; each parameter applies independently (previous behavior) |
| `spot` | `src` | All parking-space history |
| `gate` | `src` | All entrance/exit history |
| `noparking` | `src` | All no-parking-zone history |
| `channel` | `ch` | All channels (no condition) |
| `lot` | `lot` | **Only sessions that belong to a parking lot** |

Omitting the items means "the entire scope", which is **not the same as no condition**. With
`scope=lot` and no `lot`, only sessions that belong to a parking lot are returned. No-parking-zone
history does not belong to a lot and is excluded. Similarly, `scope=spot` returns parking-space
history only.

When `scope` is `spot`, `gate` or `noparking`, it also determines the session kind and overrides
`kind`. Omitting `scope` keeps the previous behavior.

**Response**:
```json
{
  "totalCount": 128,
  "at": 0,
  "asOf": "2026-10-07T09:30:00",
  "summary": {
    "count": 128,
    "totalDurationMs": 442800000,
    "firstTimeIn": "2026-10-07T07:05:11",
    "lastTimeOut": "2026-10-07T09:22:40"
  },
  "data": [
    {
      "id": 4821,
      "kind": "spot",
      "src": {
        "id": 101,
        "name": "A-13"
      },
      "lots": [1],
      "usageFlags": 1,
      "chid": 3,
      "plateNo": "12가3456",
      "plateTime": "2026-10-07T08:01:12",
      "score": 95.0,
      "timeRange": ["2026-10-07T08:01:04", "2026-10-07T09:22:40"],
      "open": false,
      "outKind": "observed",
      "outTimeMeans": "exitedAt",
      "inKind": "observed",
      "inTimeMeans": "enteredAt",
      "durationMs": 4896000,
      "box": { "cx": 0.394, "cy": 0.556, "w": 0.164, "h": 0.201 },
      "paidCount": 1,
      "lastPaidTime": "2026-10-07T09:20:03",
      "unpaidDurationMs": 157000,
      "snapshots": [
        {
          "time": "2026-10-07T08:01:04",
          "chid": 3,
          "tags": ["in", "bestshot", "plate"],
          "plateNo": "12가3456",
          "image": "https://nvr.example.com/storage/f/parking/20261007/4821-in.jpg",
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T08%3A01%3A04&otherwise=nearBefore"
        },
        {
          "time": "2026-10-07T08:04:22",
          "chid": 3,
          "tags": ["bestshot"],
          "plateNo": null,
          "image": "https://nvr.example.com/storage/f/lpr/20261007/99213.jpg",
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T08%3A04%3A22&otherwise=nearBefore"
        },
        {
          "time": "2026-10-07T09:22:40",
          "chid": 3,
          "tags": ["out"],
          "plateNo": null,
          "image": null,
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T09%3A22%3A40&otherwise=nearBefore"
        }
      ]
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `totalCount` | Int | Total matches (`-1` when no time filter was given, so the count was skipped) |
| `at` | Int | Offset of this page |
| `asOf` | DateTime | Server time when the response was generated. Open sessions are measured up to this time |
| `summary.count` | Int | Session count in the whole result |
| `summary.totalDurationMs` | Int | Sum of stay time, milliseconds |
| `summary.firstTimeIn` | DateTime\|null | Earliest entry in the result |
| `summary.lastTimeOut` | DateTime\|null | Latest exit in the result |
| `data[].id` | Int | Session ID |
| `data[].kind` | String | `spot`, `gate` or `dwell` |
| `data[].src` | Object | Location of the session: `id` and `name` of the spot / gate / zone |
| `data[].srcOut` | Int | (gate only) Source ID the vehicle left through |
| `data[].lots` | Int[] | Parking lots the source belonged to **when the session was recorded**, not currently |
| `data[].usageFlags` | Int | Source usage flags recorded with the session |
| `data[].chid` | Int | Channel number (1-based) |
| `data[].plateNo` | String\|null | Plate number, `null` if never recognized. Always the **current** value. After a correction ([16.9](#169-vehicle-number-correction)), this is the corrected plate |
| `data[].plateEdited` | Boolean | `true` if a person corrected the plate |
| `data[].originalPlateNo` | String | (only when `plateEdited`) The plate as first recognized (`""` if none was read) |
| `data[].plateTime` | DateTime\|null | When the plate was read |
| `data[].score` | Float | Recognition confidence (present with `plateNo`) |
| `data[].timeRange` | DateTime[] | `[entry]` while open, `[entry, exit]` once closed |
| `data[].open` | Boolean | `true` = still parked |
| `data[].outKind` | String | How the exit time was determined (closed sessions only) |
| `data[].outTimeMeans` | String | What the exit time represents (closed sessions only) |
| `data[].inKind` | String | How the entry time was determined (present on **open sessions too**) |
| `data[].inTimeMeans` | String | What the entry time represents |
| `data[].durationMs` | Int | Stay in milliseconds. For open sessions, measured up to `asOf` |
| `data[].paidCount` | Int | Number of **effective** payments (undone ones are excluded) |
| `data[].lastPaidTime` | DateTime\|null | Last payment time |
| `data[].unpaidDurationMs` | Int | Time not covered by a payment. **Do not bill from this when `exempt` is `true`** |
| `data[].exempt` | Boolean | Exempt from billing (see [16.7](#167-change-payment-state)) |
| `data[].box` | Object\|null | Box for the vehicle (see [1.2](#12-box-coordinates)). Identifies **which** vehicle in the snapshot belongs to the session |
| `data[].snapshots` | Object[] | Moments of the session, **oldest first** (below) |
| `data[].payments` | Object[] | (with `includePayments=true`) `{ id, time, kind, target?, ref? }`. `kind` is `commit`, `exempt` or `undo`; `target` is the `id` the `undo` reverted |

**Snapshots** — each entry is `{ time, chid, tags, plateNo, image, video }`, **oldest first**.
One picture can have several meanings (the entry frame is often the same shot that read the
plate), so meanings are given as a **tag array** rather than as keys. The same tag can also
appear more than once. For example, an AI camera sends several bestshots for one vehicle.

| Field | Content |
|-------|---------|
| `time` | Time of that moment. `null` for `current`, which means "now" |
| `chid` | Channel number (1-based) |
| `tags` | Tags from the table below |
| `plateNo` | Plate this shot read. **`null` when it read none** |
| `image` | Picture URL, or `null` when the picture was deleted by the retention policy or the moment has no picture |
| `video` | VOD link for that moment (see [13.2](#132-playback-urls), includes `otherwise=nearBefore`) |

| Tag | Meaning |
|-----|---------|
| `in` | Entry |
| `out` | Exit |
| `current` | "Now" for a session still parked (no picture, live link) |
| `bestshot` | A shot on which plate recognition was **attempted** |
| `plate` | Plate recognition **succeeded** on that shot |

> **`bestshot` and `plate` are not the same.** A shot on which recognition failed still appears
> as `bestshot`, without `plate` and with `plateNo: null`. The picture is kept for later review.
> To use only entries with a plate number, check for `plate` in `tags`.

> **At most 20 pictures per session.** Beyond that limit, shots that read a plate are kept
> first, then larger images. Moments without a picture (`in`, `out`, `current`) are video links
> and are always included regardless of the limit.

**Exit basis** — only `observed` is a measured value. The others are estimates whose errors
go in different directions, so a billing app should handle each one differently instead of
relying on the timestamp alone.

| `outKind` | `outTimeMeans` | What the exit time is |
|-----------|----------------|-----------------------|
| `observed` | `exitedAt` | The exit was seen. The only measurement |
| `paid` | `paidAt` | Last payment time. Vehicles usually leave right after paying, so this is closer than video evidence and matches the receipt |
| `covered` | `discoveredAt` | The spot was hidden from view; this is when the vehicle was found to be gone. The vehicle left **some time earlier** |
| `lastSeen` | `lastSeenAt` | **Observation ended** (camera disconnected, program exited). This is the last time the channel was evaluated, which is a **lower bound**. The cause is not recorded |
| `manual` | `closedByOperator` | An operator closed the session (night opening, long occlusion). This is an operational action, not an observed exit |
| `unknown` | `unknown` | Recorded before this rule was introduced; only an approximate value reconstructed later is available |

**Entry basis** — the counterpart of the exit basis, with the error in the **opposite
direction**. `lastSeenAt` is a lower bound on the actual exit, while `firstSeenAt` is an
**upper bound** on the actual entry (the vehicle was already present). Both understate the
parking duration.

Unlike the exit basis, the entry basis is present on **open sessions too**. The entry has
already occurred, so a vehicle that is still parked may have been recorded as `firstSeen`.

| `inKind` | `inTimeMeans` | What the entry time is |
|----------|---------------|------------------------|
| `observed` | `enteredAt` | An empty → occupied transition was seen. The only measurement |
| `firstSeen` | `firstSeenAt` | The vehicle was **already present** when observation started. How long it had been there is unknown |
| `unknown` | `unknown` | Recorded before this rule was introduced; whether the start was observed is unknown |

> **One stay may appear as several sessions.** When observation is interrupted, the session
> is closed as `lastSeen`, and a new session opens as `firstSeen` when observation resumes.
> The unobserved gap is excluded from the parking duration. A `lastSeen` session and a
> `firstSeen` session on the same space that are adjacent in time are likely the same stay.
> Whether to combine them is a billing policy decision; the API does not combine them.
>
> A short interruption does not split the record. No exit or entry can be confirmed within
> it, so it would have been one session even if observation had continued. The threshold is
> the **longer** of:
>
> - **twice the entry/exit confirmation time**
> - **twice the plate recognition interval** — a minimum that prevents a normal recognition
>   cycle from being treated as an interruption. On a unit with a long recognition interval,
>   this value applies, so the same gap does not split the record.

| Query | Description |
|-------|-------------|
| `GET /api/v1/parking/session?inKind=firstSeen` | Only sessions whose entry was not observed |
| `GET /api/v1/parking/session?outKind=lastSeen` | Only sessions closed because observation ended |

### 16.6. Parking Session Detail

Returns one session, always including its payment history. Use it to review the evidence
in a dispute.

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/parking/session/{id}` | Session detail |

**Response**: a single session object with the same structure as `data[]` in 16.5, always
including `payments`.

```json
{
  "id": 4821,
  "kind": "spot",
  "src": {
    "id": 101,
    "name": "A-13"
  },
  "chid": 3,
  "plateNo": "12가3456",
  "timeRange": ["2026-10-07T08:01:04", "2026-10-07T09:22:40"],
  "open": false,
  "outKind": "paid",
  "outTimeMeans": "paidAt",
  "durationMs": 4739000,
  "paidCount": 1,
  "lastPaidTime": "2026-10-07T09:20:03",
  "unpaidDurationMs": 0,
  "snapshots": [
    {
      "time": "2026-10-07T08:01:04",
      "chid": 3,
      "tags": ["in"],
      "plateNo": null,
      "image": null,
      "video": "..."
    }
  ],
  "payments": [
    {
      "id": 77,
      "time": "2026-10-07T09:20:03",
      "ref": "POS-20261007-0042"
    }
  ]
}
```

| Status | Meaning |
|--------|---------|
| `404` | No session with that ID |

### 16.7. Change Payment State

Changes the payment state of a session. The NVR stores only the **time** and the caller's
reference. Amounts, tariffs and discount rules remain in the billing app.

| Endpoint | What it does | `409` |
|----------|--------------|-------|
| `POST /api/v1/parking/session/{id}/payment/commit` | Settle the payment (repeatable) | — |
| `POST /api/v1/parking/session/{id}/payment/exempt` | Exempt the session from billing | Already exempt |
| `POST /api/v1/parking/session/{id}/payment/undo` | Revert the latest effective change | Nothing to revert |

**What each action changes** (response fields in 16.5)

| Action | `paidCount` | `lastPaidTime` | `unpaidDurationMs` | `exempt` |
|--------|-------------|----------------|--------------------|----------|
| `commit` | +1 | this time | recounted from this time | unchanged |
| `exempt` | unchanged | unchanged | unchanged | `true` |
| `undo` | −1 (when a payment is reverted) | previous effective payment | recounted from that payment | `false` when an exemption is reverted |

**Rules**

| Item | Rule |
|---|---|
| Records | Appended, never deleted. An `undo` adds a row of its own |
| `undo` target | Omitted: the latest effective change (payment or exemption). With `ref`: the **payment** carrying that reference |
| `undo` response | `undone` says which kind was reverted (`commit` or `exempt`) |
| Repeated `undo` | Reverts earlier changes one at a time, from newest to oldest |
| What `exempt` means | Records a **decision not to collect**. The time values do not change, so when `exempt` is `true`, do not bill from `unpaidDurationMs` |
| Exempt and queries | Exempt sessions are excluded from `unpaidDurationMin` results. The filter returns only sessions with unsettled time, and exempt sessions are not subject to settlement |
| Reverted payments | Not used as the basis for the `outKind:"paid"` exit time |
| Recorded time | **Always the server clock.** A `time` you pass is kept separately as `clientTime` (see [1.1](#11-time-notation)) |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `time` | DateTime | N | The **caller's clock** reading. Kept separately; the NVR always records its own server time (see [1.1](#11-time-notation)) |
| `ref` | String | N | Transaction identifier in the billing app. For `undo`, identifies the payment to revert |

**Response**:
```json
{
  "session": 4821,
  "time": "2026-10-07T09:20:03",
  "action": "commit",
  "ref": "POS-20261007-0042"
}
```
```json
{
  "session": 4821,
  "time": "2026-10-07T18:40:11",
  "action": "undo",
  "undone": "exempt"
}
```

| Status | Meaning |
|--------|---------|
| `400` | Invalid session ID or time |
| `403` | Needs **Control** permission |
| `404` | No session with that ID |
| `409` | `exempt` on an already exempt session, or `undo` with nothing left to revert |

> A payment on an open session can also be used as the exit time. **When the program
> restarts**, parking space and dwell sessions that are still open are closed. If the last
> payment is later than the video-based estimate, the payment time is used as the exit time,
> with `paid` as the basis (see the exit basis table in [16.5](#165-parking-session-history)).
> This does not apply to entrance/exit sessions.
>
> **Undone payments and exemptions are not used as a basis**, because the exit time would
> then be wrong. A session closed during operation after observation was lost remains
> `lastSeen`; a later payment does not change it to `paid`.

### 16.8. No-exit Cleanup

Lets an operator close a session that remains "parked" because its exit was never observed.

| Item | Detail |
|---|---|
| Purpose | Clear entries where the vehicle left but no exit was recognized |
| Why they occur | Gate left open during free night hours (no exit at a gate) · a spot hidden behind a large vehicle for a long time |
| If not cleared | "Parked" entries accumulate and make the live status and the history unreliable |
| Recorded as | `outKind: "manual"` · `outTimeMeans: "closedByOperator"` |
| A billing app should | **Not** treat it as an observed exit; handle it separately |
| vs. `exempt` in [16.7](#167-change-payment-state) | This closes the **parking state**. `exempt` removes the session from **billing** and may leave it parked |

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/parking/session/{id}/close` | Close at the current time |
| `POST /api/v1/parking/session/{id}/close?time=...` | Close at a given time |

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `time` | DateTime | N | The **caller's clock** reading of the exit. Kept separately; parking duration is computed from the server clock only (see [1.1](#11-time-notation)) |

**Response**:
```json
{
  "session": 4821,
  "time": "2026-10-07T09:30:00",
  "outKind": "manual",
  "outTimeMeans": "closedByOperator"
}
```

| Status | Meaning |
|--------|---------|
| `400` | Invalid session ID, or a time at or before the entry time |
| `403` | Needs **Control** permission |
| `404` | No session with that ID |
| `409` | The session is already closed. An existing exit record is never overwritten |

> Closing a session is **final**. The NVR also discards its tracking state for that spot or
> zone, so it does not reopen the same session automatically. If a vehicle is actually
> present, it is confirmed again from the start (entry confirmation time) and receives a
> **new** session.

### 16.9. Vehicle Number Correction

Corrects a session's **representative plate**, the single plate that the session reports in
`plateNo`. A tracked session may include readings from many shots. Only the representative
plate can be corrected. The per-shot readings (`snapshots[].plateNo`) are kept unchanged as
evidence.

| Endpoint | Description |
|----------|-------------|
| `POST /api/v1/parking/session/{id}/plate` | Correct the plate of session `{id}` |
| `GET /api/v1/parking/session/{id}/plate/history` | Correction history of session `{id}` |

Parameters, responses, history and status codes are the same as [10.4](#104-vehicle-number-correction),
except that the correction response has `"session": {id}` instead of `"id"`, and the history has
`"target": "session"`. Without the parking history license, both endpoints return `403`, like
the other session endpoints.

**Rules**

| Item | Rule |
|---|---|
| Target | Exactly **one** session, by its `id`. There is no bulk correction, no correction by plate value, and no merging of sessions |
| History | Each correction adds a new row. Earlier rows are not changed |
| Open sessions | The corrected plate is kept; later recognitions of the vehicle do not overwrite it. If a **different** vehicle takes the spot, it starts a new session with its own plate |
| Payments | Stay attached to the session (they are keyed by session ID, not by plate) |
| Gate sessions | The exit is matched to the open entry by plate. Correcting an open entry helps only if the exit is read as the corrected plate. Two sessions that were already split by a misread are **not** merged. Close the entry with [16.8](#168-no-exit-cleanup) |
| Program restart | A session that continues across the restart keeps its corrected plate. If the restart closes a session (see the note in 16.7), the correction does not carry over to the session opened after it |

> **Examples:** [JavaScript](examples/javascript/10-parking.js) · [Python](examples/python/10_parking.py) · [C#](examples/csharp/10_Parking.cs) · [Go](examples/go/10_parking/) · [Java](examples/java/V1_10_Parking.java) · [Kotlin](examples/kotlin/V1_10_Parking.kt) · [Swift](examples/swift/10-parking.swift) · [PowerShell](examples/powershell/10-parking.ps1) · [curl](examples/curl/10-parking.sh)

---

## 17. Realtime Event Subscription (WebSocket API)

WebSocket API for real-time event subscription.

### 17.1. Connection Flow

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. WebSocket Connection (with initial topics)
    Client->>Server: WS /wsapi/v1/events?topics=LPR&apikey=xxx
    Server-->>Client: Connection Established

    Note over Client,Server: 2. Receiving Real-time Events
    loop On event
        Server-->>Client: {"topic":"LPR","channel":1,"plates":[{"plateNo":"12가3456",...}]}
    end

    Note over Client,Server: 3. Subscribe to Additional Topic
    Client->>Server: {"subscribe":"channelStatus"}
    Server-->>Client: {"type":"subscribed","topic":"channelStatus"}
    loop On event
        Server-->>Client: {"topic":"channelStatus","chid":1,...}
    end

    Note over Client,Server: 4. Unsubscribe from Topic
    Client->>Server: {"unsubscribe":"LPR"}
    Server-->>Client: {"type":"unsubscribed","topic":"LPR"}

    Note over Client,Server: 5. Connection Close
    Client->>Server: Close
    Server-->>Client: Close ACK
```

**Step-by-step description:**

| Step | Description |
|------|-------------|
| **1. WebSocket Connection** | Connect to the WebSocket endpoint. Specify initial subscription topics via the `topics` URL query parameter, and authenticate with `apikey` or `token`. |
| **2. Receiving Real-time Events** | The server automatically pushes JSON messages when events occur for subscribed topics. |
| **3. Subscribe to Additional Topic** | You can subscribe to additional topics while connected. Send a `{"subscribe":"topicName"}` message and the server responds with `{"type":"subscribed"}` along with initial data for that topic. Filter parameters (`ch`, `lot`, `spot`, etc.) can be included. |
| **4. Unsubscribe from Topic** | Send `{"unsubscribe":"topicName"}` to stop receiving events for that topic. The server responds with `{"type":"unsubscribed"}`. |
| **5. Connection Close** | When the client closes the WebSocket, all subscriptions are automatically released. |

### 17.2. Endpoints

| Endpoint | Description |
|----------|-------------|
| `/wsapi/v1/events` | Real-time event subscription (LPR, status changes, object detection, etc.) |
| `/wsapi/v1/export` | Recording data export (backup) |

### 17.3. Authentication

WebSocket v1 API supports the following authentication methods:

| Method | Header | Query Parameter |
|--------|--------|-----------------|
| JWT Bearer Token | `Authorization: Bearer {token}` | `?token={accessToken}` |
| API Key | `X-API-Key: {apiKey}` | `?apikey={apiKey}` |

> **Note**: The browser WebSocket API does not support custom headers, so query parameters (`?token=`, `?apikey=`) are provided instead. Non-browser clients (Node.js, Python, Go, etc.) can use either headers or query parameters.
>
> **Important**: `?session=` and `?auth=` are **not supported** on v1 WebSocket endpoints (v0 only).

### 17.4. Event Subscription

```
ws://{host}:{port}/wsapi/v1/events?topics={topics}&token={accessToken}
ws://{host}:{port}/wsapi/v1/events?topics={topics}&apikey={apiKey}
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `topics` | Event topics to subscribe (comma-separated) |
| `ch` | Channel filter (optional) |
| `lot` | Parking lot ID filter (optional, v1 only) |
| `spot` | Parking spot ID filter (optional, v1 only) |
| `verbose` | Include detailed info (true/false) |
| `indent` | JSON indentation (0-8) |
| `lang` | Language of the text in events ([1.3](#13-language-lang)) |
| `objectTypes` | Object type filter (human, face, vehicle) |

**Topics:**

| Topic | Description | Condition |
|-------|-------------|-----------|
| `channelStatus` | Channel connection status change | Always |
| `emergencyCall` | Emergency call event | Emergency call license |
| `LPR` | License plate recognition event | Always |
| `systemEvent` | System event (start, shutdown, error, etc.) | Always |
| `notice` | Notices currently in effect — list on subscribe, then raised / updated / cleared ([5.5](#55-system-notices)) | Always |
| `motionChanges` | Motion detection status change | Always |
| `recordingStatus` | Recording status change | Recording enabled |
| `parkingCount` | Parking lot count change | Parking guide license |
| `parkingSpot` | Parking spot occupancy change | Parking spot license |
| `object` | Object detection (face, human, vehicle) | Object detection license |
| `bodyTemperature` | Body temperature measurement | Body temperature license |
| `vehicleTracking` | Vehicle tracking event | Vehicle tracking license |

**Runtime Topic Subscribe/Unsubscribe:**

You can add or remove topic subscriptions at any time after connection by sending WebSocket messages.

Subscribe:
```json
{
  "subscribe": "channelStatus",
  "ch": [1, 2]
}
```

Unsubscribe:
```json
{
  "unsubscribe": "channelStatus"
}
```

**Responses:**

| Response | Description |
|----------|-------------|
| `{"type":"subscribed","topic":"..."}` | Subscription successful. Depending on the topic, initial state data may also be sent. |
| `{"type":"unsubscribed","topic":"..."}` | Unsubscription successful. |
| `{"type":"error","topic":"...","message":"..."}` | Unknown topic or invalid request. |
| `{"type":"error","message":"unknown command"}` | A message that is neither `subscribe` nor `unsubscribe`. |
| `{"type":"error","message":"invalid JSON"}` | A message that cannot be parsed as JSON. |

> **Note**: Re-subscribing to the same topic automatically replaces the existing subscription (useful for changing filters).

**Connecting without topics:**

In v1, you can connect without `topics` and choose topics later with `subscribe` messages.
This lets a client change its topics at runtime without reconnecting.

```
ws://{host}:{port}/wsapi/v1/events?apikey={apiKey}
```

**Filters in a subscribe message:**

| Field | Type | Description |
|-------|------|-------------|
| `subscribe` | string | Topic name to subscribe |
| `ch` | number[] | Channel filter (optional) |
| `objectTypes` | string[] | Object type filter — `human`, `face`, `vehicle` (optional) |
| `lot` | number[] | Parking lot ID filter (optional) |
| `spot` | number[] | Parking spot ID filter (optional) |

```json
{"subscribe": "channelStatus"}
{"subscribe": "channelStatus", "ch": [1, 2, 3]}
{"subscribe": "object", "objectTypes": ["human", "vehicle"]}
{"subscribe": "parkingSpot", "lot": [1, 2], "spot": [100, 200]}
{"subscribe": "LPR", "ch": [1]}
```

**Dynamic subscription example:**

```javascript
const ws = new WebSocket('ws://localhost/wsapi/v1/events?apikey=tsapi_key_...');

ws.onopen = () => {
  // Pick topics after connecting
  ws.send(JSON.stringify({ subscribe: 'channelStatus' }));
  ws.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2] }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  // Handle control messages first
  if (data.type === 'subscribed') { console.log('Subscribed:', data.topic); return; }
  if (data.type === 'unsubscribed') { console.log('Unsubscribed:', data.topic); return; }
  if (data.type === 'error') { console.error('Error:', data.message); return; }

  // Event data
  if (data.topic === 'LPR') (data.plates || [data]).forEach(p => console.log('Plate:', p.plateNo));
};

// Add or drop topics at runtime
ws.send(JSON.stringify({ unsubscribe: 'channelStatus' }));
ws.send(JSON.stringify({ subscribe: 'object', objectTypes: ['human'] }));
```

**LPR Event Format:**

One event is sent per recognized frame. Each plate read in that frame is an entry in `plates`.

```json
{
  "timestamp": "2026-10-23T09:12:31.250+09:00",
  "topic": "LPR",
  "channel": {
    "chid": 1,
    "title": "Main Gate",
    "displayName": "CH1. Main Gate",
    "src": "/watch?ch=1&when=2026-10-23T09%3A12%3A31.250%2B09%3A00"
  },
  "image": "/storage/e/.../plate.jpg",
  "plates": [
    {
      "id": 91234,
      "plateNo": "12가3456",
      "score": 95.5,
      "srcCode": "GATE-IN",
      "srcName": "Entrance Gate",
      "direction": "entry",
      "roi": { "offset": [812, 604], "size": [180, 44] },
      "timeBegin": "2026-10-23T09:12:30.900+09:00",
      "parkingLot": { "entrance": 1 }
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | String | Event time |
| `channel` | Object | Channel of the source — `chid`, `title`, `displayName`, `src` (watch URL at the event time). Omitted when the source is not tied to a channel |
| `linkedChannel` | Array | Linked channels, the same objects as `channel` |
| `image` | String | Image URL of the frame. Omitted when no image was saved |
| `plates[].id` | Int | Recognition record ID — `data[].id` of [10.2](#102-lpr-log) and the `{id}` of [10.4](#104-vehicle-number-correction). Omitted when the record could not be saved (system disk full) |
| `plates[].plateNo` | String\|null | Plate number. `null` when no plate was read |
| `plates[].score` | Number | Recognition confidence. Omitted when the source does not provide one |
| `plates[].srcCode` · `srcName` | String | LPR source code and name ([10.1](#101-lpr-source-list-recognition-pointzone)) |
| `plates[].direction` | String | `entry` or `exit`. Omitted when the direction is unknown (no driving direction is set for the source) |
| `plates[].roi` | Object | Plate area in pixels: `offset` `[x, y]`, `size` `[w, h]` |
| `plates[].timeBegin` | String | Time the plate was first read |
| `plates[].parkingLot` | Object | `entrance` / `exit` parking lot ID. Only for sources linked to a parking lot |

Fields without a value are omitted, except `plateNo`, which is `null`.

**Parking Spot Event Filters:**

The `parkingSpot` topic supports three filter types, combined with OR logic:
- `ch=1,2` — zones belonging to specified channels (1-based)
- `lot=1,2` — zones in specified parking lots
- `spot=100,200` — specific zone IDs

When no filter is specified, all zones are included.

**parkingSpot Response Format:**

The first message after connecting has `event: "currentStatus"` and includes all zone types (spot, entrance, exit, noParking, recognition).
Later updates have `event: "statusChanged"`. Only parking spots (`type:"spot"`) generate status change events.

```json
{
  "timestamp": "2024-01-01T10:00:00+09:00",
  "topic": "parkingSpot",
  "event": "currentStatus",
  "spots": [
    {
      "id": 123,
      "chid": 1,
      "name": "A-001",
      "type": "spot",
      "category": "normal",
      "occupied": true,
      "vehicle": {
        "plateNo": "12가3456",
        "score": 95.5,
        "ev": false,
        "bike": false,
        "since": "2024-01-01T09:30:00+09:00"
      }
    },
    {
      "id": 200,
      "chid": 1,
      "name": "Main Gate",
      "type": "entrance",
      "category": null,
      "vehicle": null
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Zone type: `"spot"`, `"entrance"`, `"exit"`, `"noParking"`, `"recognition"` |
| `category` | string\|null | Spot category (only for `type:"spot"`). `null` for non-spot types. |
| `occupied` | boolean | (spot only) Whether the spot is occupied |
| `vehicle` | object\|null | Vehicle info. For spots: full vehicle object when occupied. For non-spot types: may contain `plateNo` and `score` from the last recognition. |

**Example:**

```javascript
// Subscribe to LPR and channel status with API Key auth
const ws = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=LPR,channelStatus&apikey=tsapi_key_...'
);

ws.onopen = () => {
  console.log('Connected');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  switch(data.topic) {
    case 'LPR':
      // v1.0.1: data.plates (array), v1.0.0: data (single object) — handle both
      (data.plates || [data]).forEach(p => console.log('Plate:', p.plateNo, 'Score:', p.score));
      break;
    case 'channelStatus':
      console.log('Channel', data.chid, 'Status:', data.status);
      break;
  }
};

ws.onclose = () => {
  console.log('Disconnected');
};
```

**Parking Spot Monitoring Examples:**

```javascript
// Monitor all parking spots
const ws1 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&apikey=tsapi_key_...'
);

// Monitor spots in specific channels
const ws2 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&ch=1,2&apikey=tsapi_key_...'
);

// Monitor spots in specific parking lots
const ws3 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&lot=1,2&apikey=tsapi_key_...'
);

// Monitor specific spots
const ws4 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&spot=100,200,300&apikey=tsapi_key_...'
);

// Combined filters (OR logic): ch=1 OR lot=2 OR spot=300
const ws5 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&ch=1&lot=2&spot=300&apikey=tsapi_key_...'
);

// Monitor parking lot counts with lot filter
const ws6 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingCount&lot=1,2,3&apikey=tsapi_key_...'
);

ws1.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.topic === 'parkingSpot') {
    console.log('Event:', data.event); // "currentStatus" or "statusChanged"
    data.spots.forEach(spot => {
      if (spot.type === 'spot') {
        console.log(`Spot ${spot.name}: ${spot.occupied ? 'Occupied' : 'Empty'}`);
        if (spot.vehicle) {
          console.log(`  Vehicle: ${spot.vehicle.plateNo}`);
        }
      } else {
        console.log(`Zone ${spot.name} (${spot.type})`);
      }
    });
  }
};
```

## 18. Data Export — Recording Backup (WebSocket API)

WebSocket API for backing up recorded video as video files.

### 18.1. Export Flow

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. WebSocket Connection
    Client->>Server: WS /wsapi/v1/export?ch=1,2&timeBegin=...&timeEnd=...&apikey=xxx
    Server-->>Client: stage: "ready" (task ID, channels, timeRange)

    Note over Client,Server: 2. Export Start
    Server-->>Client: stage: "begin"

    Note over Client,Server: 3. Per-channel/file Processing
    loop Each channel
        Server-->>Client: stage: "channelBegin" (chid)
        loop Each file
            Server-->>Client: stage: "fileBegin" (filename)
            Server-->>Client: stage: "fileEnd" (download URL, MD5)
            Note over Client: Download file via HTTP GET
            Client->>Server: {"task":"...", "cmd":"next"}
        end
        Server-->>Client: stage: "channelEnd"
    end

    Note over Client,Server: 4. Export Complete
    Server-->>Client: stage: "end" (final status)
    Client->>Server: Close
    Server-->>Client: Close ACK
```

**Step-by-step:**

| Step | stage | Description |
|------|-------|-------------|
| **1. Connect** | `ready` | After the connection opens, the server validates the parameters and issues a task ID. A non-zero `status.code` indicates an error. |
| **2. Start** | `begin` | The export task has started. |
| **3-1. Channel start** | `channelBegin` | Begins processing recorded data for the channel. |
| **3-2. Channel skip** | `channelSkip` | Sent when no recorded data exists for the channel in the specified time range. |
| **3-3. File start** | `fileBegin` | Starts creating a new video file. May occur multiple times if split by `mediaSize`. |
| **3-4. File writing** | `fileWriting` | Sends progress periodically when the `statusInterval` parameter is set. |
| **3-5. File complete** | `fileEnd` | The file is ready for download. **The server waits for a client response.** The client must send `next`, `wait`, or `cancel` within the `ttl` time. |
| **3-6. Channel complete** | `channelEnd` | All files for this channel have been processed. |
| **4. Complete** | `end` | All channels have been processed. Check `status.code` for final result. |

#### Server Messages (Server → Client)

**`ready` — Task ready:**

```json
{
  "stage": "ready",
  "status": {
    "code": 0,
    "message": "Success"
  },
  "task": {
    "id": "task-uuid",
    "ch": [1, 2],
    "timeRange": ["2024-01-01T00:00:00", "2024-01-01T01:00:00"],
    "mediaSize": 1073741824,
    "subtitleFormat": "srt"
  }
}
```

**`ready` error codes:**

| code | Description |
|------|-------------|
| `0` | Success |
| `-1` | No recorded data in specified time range |
| `-2` | Invalid parameters |
| `-3` | Cannot save to recording storage |
| `-4` | Cannot create/write to folder |
| `-5` | Insufficient disk space |

**`fileEnd` — File ready for download:**

```json
{
  "stage": "fileEnd",
  "overallProgress": "30%",
  "timestamp": "2024-01-01T12:40:00",
  "channel": {
    "chid": 1,
    "progress": "100%",
    "file": {
      "fid": 0,
      "ttl": 10000,
      "download": [
        {
          "fileName": "CH01_20240101_120000.mp4",
          "src": "/download/task-uuid/CH01_20240101_120000.mp4",
          "md5": "abc123..."
        },
        {
          "fileName": "CH01_20240101_120000.srt",
          "src": "/download/task-uuid/CH01_20240101_120000.srt",
          "md5": "def456..."
        }
      ]
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `overallProgress` | Overall export progress |
| `channel.chid` | Channel number |
| `channel.progress` | Progress for this channel |
| `channel.file.fid` | File sequence number (0-based) |
| `channel.file.ttl` | Response timeout (ms). Client must send a command within this time. |
| `channel.file.download` | Downloadable file list (video + subtitle) |
| `download[].fileName` | File name |
| `download[].src` | Download URL (HTTP GET) |
| `download[].md5` | MD5 checksum (when `md5=true` requested) |

**`end` — Export complete:**

```json
{
  "stage": "end",
  "overallProgress": "100%",
  "timestamp": "2024-01-01T13:00:00",
  "status": {
    "code": 0,
    "message": "Success"
  }
}
```

#### Client Commands (Client → Server)

After receiving a `fileEnd` message, send one of the following commands within the `ttl` time:

```json
{
  "task": "{taskId}",
  "cmd": "next"
}
```

| cmd | Description |
|-----|-------------|
| `next` | Download complete; proceed to the next file. The server deletes temporary files and starts processing the next file. |
| `wait` | More time is needed for the download. The server resets the `ttl` timer and waits again. Use this for large files. |
| `cancel` | Cancels the export task. The server stops processing and sends an `end` message. |

> **Note**: If no response is received within the `ttl` time, the server sends a `timeoutAlert` message. If there is still no response, the task is cancelled.

### 18.2. Endpoint

```
ws://{host}:{port}/wsapi/v1/export?ch={channels}&timeBegin={start}&timeEnd={end}&apikey={apiKey}
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `ch` | Channel list (comma-separated) |
| `timeBegin` | Start time (ISO 8601) |
| `timeEnd` | End time (ISO 8601) |
| `md5` | Include MD5 checksum (true/false) |
| `password` | Encryption password (base64) |
| `mediaSize` | Media file size limit (e.g., `1GB`, `100MB`) |
| `subtitleFormat` | Subtitle format (srt, vtt, ass, ssa) |
| `statusInterval` | Progress update interval during file writing (e.g., `5s`, `1m`. Default: disabled) |
| `lang` | Language code ([1.3](#13-language-lang)) |
| `indent` | JSON indentation (0-8) |

**Example:**

```javascript
const params = new URLSearchParams({
  ch: '1,2',
  timeBegin: '2024-01-01T00:00:00',
  timeEnd: '2024-01-01T01:00:00',
  apikey: 'tsapi_key_...'
});

const ws = new WebSocket(`ws://localhost/wsapi/v1/export?${params}`);

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  switch(data.stage) {
    case 'ready':
      if (data.status.code !== 0) {
        console.error('Error:', data.status.message);
        ws.close();
        return;
      }
      console.log('Task ID:', data.task.id);
      break;
    case 'fileEnd':
      // Download files
      data.channel.file.download.forEach(f => {
        console.log('Download:', f.src);
      });
      // Proceed to next file
      ws.send(JSON.stringify({ task: data.task.id, cmd: 'next' }));
      break;
    case 'end':
      console.log('Export complete, code:', data.status.code);
      ws.close();
      break;
  }
};
```

> **Examples:** [JavaScript](examples/javascript/15-websocket-export.js) · [Python](examples/python/15_websocket_export.py) · [C#](examples/csharp/15_WebSocketExport.cs) · [Go](examples/go/15_ws_export/) · [Java](examples/java/V1_15_WebSocketExport.java) · [Kotlin](examples/kotlin/V1_15_WebSocketExport.kt) · [Swift](examples/swift/15-websocket-export.swift) · [PowerShell](examples/powershell/15-websocket-export.ps1) · [curl](examples/curl/15-websocket-export.sh)

---

## Appendix

### A. Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict — the request conflicts with the current state |
| 429 | Too Many Requests — sign-in attempt limit (see `Retry-After`) |
| 500 | Internal Server Error |

When an error occurs, the following JSON response body is returned along with the HTTP status code:

```json
{
  "code": -1,
  "message": "Invalid channel"
}
```

### B. Time Format

All time parameters and responses in the API use [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.

| Format | Example | Description |
|--------|---------|-------------|
| Local time | `2024-01-01T10:30:00` | Without timezone offset, interpreted as server local time. |
| UTC | `2024-01-01T10:30:00Z` | `Z` suffix denotes UTC (Coordinated Universal Time). |
| With timezone | `2024-01-01T10:30:00+09:00` | Explicit UTC offset using `+HH:MM` or `-HH:MM`. |

> **Note**: When timezone offset is omitted from time parameters (`timeBegin`, `timeEnd`, `when`, etc.), they are treated as **server local time**.

### C. Code Examples

Example code for each API feature, available in 9 languages.

[curl](#curl) · [JavaScript](#javascript) · [Python](#python) · [C#](#c-sharp) · [Go](#go) · [Java](#java) · [Kotlin](#kotlin) · [Swift](#swift) · [PowerShell](#powershell)

<a id="javascript"></a>**JavaScript** (`examples/javascript/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [01-login.js](examples/javascript/01-login.js) |
| 02 | Channel List | [02-channels.js](examples/javascript/02-channels.js) |
| 03 | PTZ Control | [03-ptz-control.js](examples/javascript/03-ptz-control.js) |
| 04 | Recording Search | [04-recording-search.js](examples/javascript/04-recording-search.js) |
| 05 | Event Log | [05-event-log.js](examples/javascript/05-event-log.js) |
| 06 | LPR Search | [06-lpr-search.js](examples/javascript/06-lpr-search.js) |
| 07 | VOD Stream | [07-vod-stream.js](examples/javascript/07-vod-stream.js) |
| 08 | System Info | [08-system-info.js](examples/javascript/08-system-info.js) |
| 09 | Push Notification | [09-push-notification.js](examples/javascript/09-push-notification.js) |
| 10 | Parking | [10-parking.js](examples/javascript/10-parking.js) |
| 11 | Emergency Call | [11-emergency.js](examples/javascript/11-emergency.js) |
| 12 | WS Event Subscription | [12-websocket-events.js](examples/javascript/12-websocket-events.js) |
| 13 | WS Parking Lot | [13-websocket-parking-lot.js](examples/javascript/13-websocket-parking-lot.js) |
| 14 | WS Parking Spot | [14-websocket-parking-spot.js](examples/javascript/14-websocket-parking-spot.js) |
| 15 | WS Data Export | [15-websocket-export.js](examples/javascript/15-websocket-export.js) |

<a id="python"></a>**Python** (`examples/python/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [01_login.py](examples/python/01_login.py) |
| 02 | Channel List | [02_channels.py](examples/python/02_channels.py) |
| 03 | PTZ Control | [03_ptz_control.py](examples/python/03_ptz_control.py) |
| 04 | Recording Search | [04_recording_search.py](examples/python/04_recording_search.py) |
| 05 | Event Log | [05_event_log.py](examples/python/05_event_log.py) |
| 06 | LPR Search | [06_lpr_search.py](examples/python/06_lpr_search.py) |
| 07 | VOD Stream | [07_vod_stream.py](examples/python/07_vod_stream.py) |
| 08 | System Info | [08_system_info.py](examples/python/08_system_info.py) |
| 09 | Push Notification | [09_push.py](examples/python/09_push.py) |
| 10 | Parking | [10_parking.py](examples/python/10_parking.py) |
| 11 | Emergency Call | [11_emergency.py](examples/python/11_emergency.py) |
| 12 | WS Event Subscription | [12_websocket_events.py](examples/python/12_websocket_events.py) |
| 13 | WS Parking Lot | [13_websocket_parking_lot.py](examples/python/13_websocket_parking_lot.py) |
| 14 | WS Parking Spot | [14_websocket_parking_spot.py](examples/python/14_websocket_parking_spot.py) |
| 15 | WS Data Export | [15_websocket_export.py](examples/python/15_websocket_export.py) |

<a id="c-sharp"></a>**C#** (`examples/csharp/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [01_Login.cs](examples/csharp/01_Login.cs) |
| 02 | Channel List | [02_Channels.cs](examples/csharp/02_Channels.cs) |
| 03 | PTZ Control | [03_PtzControl.cs](examples/csharp/03_PtzControl.cs) |
| 04 | Recording Search | [04_RecordingSearch.cs](examples/csharp/04_RecordingSearch.cs) |
| 05 | Event Log | [05_EventLog.cs](examples/csharp/05_EventLog.cs) |
| 06 | LPR Search | [06_LprSearch.cs](examples/csharp/06_LprSearch.cs) |
| 07 | VOD Stream | [07_VodStream.cs](examples/csharp/07_VodStream.cs) |
| 08 | System Info | [08_SystemInfo.cs](examples/csharp/08_SystemInfo.cs) |
| 09 | Push Notification | [09_Push.cs](examples/csharp/09_Push.cs) |
| 10 | Parking | [10_Parking.cs](examples/csharp/10_Parking.cs) |
| 11 | Emergency Call | [11_Emergency.cs](examples/csharp/11_Emergency.cs) |
| 12 | WS Event Subscription | [12_WebSocketEvents.cs](examples/csharp/12_WebSocketEvents.cs) |
| 13 | WS Parking Lot | [13_WebSocketParkingLot.cs](examples/csharp/13_WebSocketParkingLot.cs) |
| 14 | WS Parking Spot | [14_WebSocketParkingSpot.cs](examples/csharp/14_WebSocketParkingSpot.cs) |
| 15 | WS Data Export | [15_WebSocketExport.cs](examples/csharp/15_WebSocketExport.cs) |

<a id="go"></a>**Go** (`examples/go/`)

| # | Feature | Directory |
|---|---------|-----------|
| 01 | Authentication (Login) | [01_login/](examples/go/01_login/) |
| 02 | Channel List | [02_channels/](examples/go/02_channels/) |
| 03 | PTZ Control | [03_ptz/](examples/go/03_ptz/) |
| 04 | Recording Search | [04_recording/](examples/go/04_recording/) |
| 05 | Event Log | [05_events/](examples/go/05_events/) |
| 06 | LPR Search | [06_lpr/](examples/go/06_lpr/) |
| 07 | VOD Stream | [07_vod/](examples/go/07_vod/) |
| 08 | System Info | [08_system/](examples/go/08_system/) |
| 09 | Push Notification | [09_push/](examples/go/09_push/) |
| 10 | Parking | [10_parking/](examples/go/10_parking/) |
| 11 | Emergency Call | [11_emergency/](examples/go/11_emergency/) |
| 12 | WS Event Subscription | [12_ws_events/](examples/go/12_ws_events/) |
| 13 | WS Parking Lot | [13_ws_parking_lot/](examples/go/13_ws_parking_lot/) |
| 14 | WS Parking Spot | [14_ws_parking_spot/](examples/go/14_ws_parking_spot/) |
| 15 | WS Data Export | [15_ws_export/](examples/go/15_ws_export/) |

<a id="java"></a>**Java** (`examples/java/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [V1_01_Login.java](examples/java/V1_01_Login.java) |
| 02 | Channel List | [V1_02_Channels.java](examples/java/V1_02_Channels.java) |
| 03 | PTZ Control | [V1_03_PtzControl.java](examples/java/V1_03_PtzControl.java) |
| 04 | Recording Search | [V1_04_RecordingSearch.java](examples/java/V1_04_RecordingSearch.java) |
| 05 | Event Log | [V1_05_EventLog.java](examples/java/V1_05_EventLog.java) |
| 06 | LPR Search | [V1_06_LprSearch.java](examples/java/V1_06_LprSearch.java) |
| 07 | VOD Stream | [V1_07_VodStream.java](examples/java/V1_07_VodStream.java) |
| 08 | System Info | [V1_08_SystemInfo.java](examples/java/V1_08_SystemInfo.java) |
| 09 | Push Notification | [V1_09_Push.java](examples/java/V1_09_Push.java) |
| 10 | Parking | [V1_10_Parking.java](examples/java/V1_10_Parking.java) |
| 11 | Emergency Call | [V1_11_Emergency.java](examples/java/V1_11_Emergency.java) |
| 12 | WS Event Subscription | [V1_12_WebSocketEvents.java](examples/java/V1_12_WebSocketEvents.java) |
| 13 | WS Parking Lot | [V1_13_WebSocketParkingLot.java](examples/java/V1_13_WebSocketParkingLot.java) |
| 14 | WS Parking Spot | [V1_14_WebSocketParkingSpot.java](examples/java/V1_14_WebSocketParkingSpot.java) |
| 15 | WS Data Export | [V1_15_WebSocketExport.java](examples/java/V1_15_WebSocketExport.java) |

<a id="kotlin"></a>**Kotlin** (`examples/kotlin/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [V1_01_Login.kt](examples/kotlin/V1_01_Login.kt) |
| 02 | Channel List | [V1_02_Channels.kt](examples/kotlin/V1_02_Channels.kt) |
| 03 | PTZ Control | [V1_03_PtzControl.kt](examples/kotlin/V1_03_PtzControl.kt) |
| 04 | Recording Search | [V1_04_RecordingSearch.kt](examples/kotlin/V1_04_RecordingSearch.kt) |
| 05 | Event Log | [V1_05_EventLog.kt](examples/kotlin/V1_05_EventLog.kt) |
| 06 | LPR Search | [V1_06_LprSearch.kt](examples/kotlin/V1_06_LprSearch.kt) |
| 07 | VOD Stream | [V1_07_VodStream.kt](examples/kotlin/V1_07_VodStream.kt) |
| 08 | System Info | [V1_08_SystemInfo.kt](examples/kotlin/V1_08_SystemInfo.kt) |
| 09 | Push Notification | [V1_09_Push.kt](examples/kotlin/V1_09_Push.kt) |
| 10 | Parking | [V1_10_Parking.kt](examples/kotlin/V1_10_Parking.kt) |
| 11 | Emergency Call | [V1_11_Emergency.kt](examples/kotlin/V1_11_Emergency.kt) |
| 12 | WS Event Subscription | [V1_12_WebSocketEvents.kt](examples/kotlin/V1_12_WebSocketEvents.kt) |
| 13 | WS Parking Lot | [V1_13_WebSocketParkingLot.kt](examples/kotlin/V1_13_WebSocketParkingLot.kt) |
| 14 | WS Parking Spot | [V1_14_WebSocketParkingSpot.kt](examples/kotlin/V1_14_WebSocketParkingSpot.kt) |
| 15 | WS Data Export | [V1_15_WebSocketExport.kt](examples/kotlin/V1_15_WebSocketExport.kt) |

<a id="swift"></a>**Swift** (`examples/swift/`)

| # | Feature | File |
|---|---------|------|
| 01 | Authentication (Login) | [01-login.swift](examples/swift/01-login.swift) |
| 02 | Channel List | [02-channels.swift](examples/swift/02-channels.swift) |
| 03 | PTZ Control | [03-ptz-control.swift](examples/swift/03-ptz-control.swift) |
| 04 | Recording Search | [04-recording-search.swift](examples/swift/04-recording-search.swift) |
| 05 | Event Log | [05-event-log.swift](examples/swift/05-event-log.swift) |
| 06 | LPR Search | [06-lpr-search.swift](examples/swift/06-lpr-search.swift) |
| 07 | VOD Stream | [07-vod-stream.swift](examples/swift/07-vod-stream.swift) |
| 08 | System Info | [08-system-info.swift](examples/swift/08-system-info.swift) |
| 09 | Push Notification | [09-push.swift](examples/swift/09-push.swift) |
| 10 | Parking | [10-parking.swift](examples/swift/10-parking.swift) |
| 11 | Emergency Call | [11-emergency.swift](examples/swift/11-emergency.swift) |
| 12 | WS Event Subscription | [12-websocket-events.swift](examples/swift/12-websocket-events.swift) |
| 13 | WS Parking Lot | [13-websocket-parking-lot.swift](examples/swift/13-websocket-parking-lot.swift) |
| 14 | WS Parking Spot | [14-websocket-parking-spot.swift](examples/swift/14-websocket-parking-spot.swift) |
| 15 | WS Data Export | [15-websocket-export.swift](examples/swift/15-websocket-export.swift) |

<a id="powershell"></a>**PowerShell** (`examples/powershell/`)

| # | Topic | File |
|---|-------|------|
| 01 | Authentication (Login) | [01-login.ps1](examples/powershell/01-login.ps1) |
| 02 | Channel List | [02-channels.ps1](examples/powershell/02-channels.ps1) |
| 03 | PTZ Control | [03-ptz-control.ps1](examples/powershell/03-ptz-control.ps1) |
| 04 | Recording Search | [04-recording-search.ps1](examples/powershell/04-recording-search.ps1) |
| 05 | Event Log | [05-event-log.ps1](examples/powershell/05-event-log.ps1) |
| 06 | LPR Search | [06-lpr-search.ps1](examples/powershell/06-lpr-search.ps1) |
| 07 | VOD Stream | [07-vod-stream.ps1](examples/powershell/07-vod-stream.ps1) |
| 08 | System Info | [08-system-info.ps1](examples/powershell/08-system-info.ps1) |
| 09 | Push Notification | [09-push.ps1](examples/powershell/09-push.ps1) |
| 10 | Parking | [10-parking.ps1](examples/powershell/10-parking.ps1) |
| 11 | Emergency Call | [11-emergency.ps1](examples/powershell/11-emergency.ps1) |
| 12 | WS Event Subscription | [12-websocket-events.ps1](examples/powershell/12-websocket-events.ps1) |
| 13 | WS Parking Lot | [13-websocket-parking-lot.ps1](examples/powershell/13-websocket-parking-lot.ps1) |
| 14 | WS Parking Spot | [14-websocket-parking-spot.ps1](examples/powershell/14-websocket-parking-spot.ps1) |
| 15 | WS Data Export | [15-websocket-export.ps1](examples/powershell/15-websocket-export.ps1) |

<a id="curl"></a>**curl / Shell** (`examples/curl/`)

| # | Topic | File |
|----|-------|------|
| 01 | Authentication (Login) | [01-login.sh](examples/curl/01-login.sh) |
| 02 | Channel List | [02-channels.sh](examples/curl/02-channels.sh) |
| 03 | PTZ Control | [03-ptz-control.sh](examples/curl/03-ptz-control.sh) |
| 04 | Recording Search | [04-recording-search.sh](examples/curl/04-recording-search.sh) |
| 05 | Event Log | [05-event-log.sh](examples/curl/05-event-log.sh) |
| 06 | LPR Search | [06-lpr-search.sh](examples/curl/06-lpr-search.sh) |
| 07 | VOD Stream | [07-vod-stream.sh](examples/curl/07-vod-stream.sh) |
| 08 | System Info | [08-system-info.sh](examples/curl/08-system-info.sh) |
| 09 | Push Notification | [09-push.sh](examples/curl/09-push.sh) |
| 10 | Parking | [10-parking.sh](examples/curl/10-parking.sh) |
| 11 | Emergency Call | [11-emergency.sh](examples/curl/11-emergency.sh) |
| 12 | WS Event Subscription | [12-websocket-events.sh](examples/curl/12-websocket-events.sh) |
| 13 | WS Parking Lot | [13-websocket-parking-lot.sh](examples/curl/13-websocket-parking-lot.sh) |
| 14 | WS Parking Spot | [14-websocket-parking-spot.sh](examples/curl/14-websocket-parking-spot.sh) |
| 15 | WS Data Export | [15-websocket-export.sh](examples/curl/15-websocket-export.sh) |

### D. Supported Languages

Codes accepted by `lang` ([1.3. Language](#13-language-lang)). `en-US` is the source text.

| Code | Native | English |
|------|--------|---------|
| `af-ZA` | Afrikaans | Afrikaans |
| `sq-AL` | Shqip | Albanian |
| `am-ET` | አማርኛ | Amharic |
| `ar-AE` | العربية | Arabic |
| `hy-AM` | Հայերեն | Armenian |
| `az-Latn` | Azərbaycan | Azerbaijani |
| `eu-ES` | euskara | Basque |
| `be-BY` | беларускі | Belarusian |
| `bn-BD` | বাংলা | Bengali |
| `bs-Latn` | Bosanski | Bosnian |
| `bg-BG` | български | Bulgarian |
| `ca-ES` | Català | Catalan |
| `ceb` | Cebuano | Cebuano |
| `ny` | Chichewa | Chichewa |
| `zh-CN` | 简体中国 | Chinese (Simplified) |
| `zh-TW` | 中國傳統 | Chinese (Traditional) |
| `co-FR` | Corsu | Corsican |
| `hr-HR` | hrvatski | Croatian |
| `cs-CZ` | čeština | Czech |
| `da-DK` | dansk | Danish |
| `nl-NL` | Nederlands | Dutch |
| `en-US` | English | English |
| `eo` | Esperanto | Esperanto |
| `et-EE` | Eesti keel | Estonian |
| `fil-PH` | Filipino | Filipino |
| `fi-FI` | Suomalainen | Finnish |
| `fr-FR` | français | French |
| `fy-NL` | Frysk | Frisian |
| `gl-ES` | Galego | Galician |
| `ka-GE` | ქართული | Georgian |
| `de-DE` | Deutsch | German |
| `el-GR` | Ελληνικά | Greek |
| `gu-IN` | ગુજરાતી | Gujarati |
| `ht` | Kreyòl ayisyen | Haitian Creole |
| `ha` | Hausa | Hausa |
| `haw-US` | ʻŌlelo Hawaiʻi | Hawaiian |
| `he-IL` | עברית | Hebrew |
| `hi-IN` | हिन्दी | Hindi |
| `hmn` | Hmong | Hmong |
| `hu-HU` | Magyar | Hungarian |
| `is-IS` | Íslensku | Icelandic |
| `ig-NG` | Igbo | Igbo |
| `id-ID` | bahasa Indonesia | Indonesian |
| `ga-IE` | Gaeilge | Irish |
| `it-IT` | Italiano | Italian |
| `ja-JP` | 日本語 | Japanese |
| `jv-Latn` | Jawa | Javanese |
| `kn-IN` | ಕನ್ನಡ | Kannada |
| `kk-KZ` | Қазақ тілінде | Kazakh |
| `km-KH` | ភាសាខ្មែរ | Khmer |
| `ko-KR` | 한국어 | Korean |
| `kmr-Latn-TR` | Kurdî (Kurmancî) | Kurdish (Kurmanji) |
| `ky-KG` | Кыргызча | Kyrgyz |
| `lo-LA` | ລາວ | Lao |
| `la` | Latine | Latin |
| `lv-LV` | Latviešu | Latvian |
| `lt-LT` | Lietuviškai | Lithuanian |
| `lb-LU` | Lëtzebuergesch | Luxembourgish |
| `mk-MK` | Македонски | Macedonian |
| `mg-MG` | Malagasy | Malagasy |
| `ms-MY` | Melayu | Malay |
| `ml-IN` | മലയാളം | Malayalam |
| `mt-MT` | Malti | Maltese |
| `mi-NZ` | Maori | Maori |
| `mr-IN` | मराठी | Marathi |
| `mn-MN` | Монгол хэл дээр | Mongolian |
| `my-MM` | မြန်မာ | Myanmar (Burmese) |
| `ne-NP` | नेपाली | Nepali |
| `nb-NO` | Norwegian | Norwegian |
| `ps-AF` | پښتو | Pashto |
| `fa-IR` | فارسی | Persian |
| `pl-PL` | Polskie | Polish |
| `pt-BR` | Português (Brasil) | Portuguese |
| `pt-PT` | Português (Portugal) | Portuguese |
| `pa-IN` | ਪੰਜਾਬੀ | Punjabi |
| `ro-RO` | Română | Romanian |
| `ru-RU` | Русский | Russian |
| `sm` | Samoan | Samoan |
| `gd-GB` | Gàidhlig | Scots Gaelic |
| `sr-Cyrl-RS` | Српски | Serbian |
| `st-ZA` | Sesotho | Sesotho |
| `sn-Latn-ZW` | Shona | Shona |
| `sd-Arab-PK` | سنڌي | Sindhi |
| `si-LK` | සිංහල | Sinhala |
| `sk-SK` | slovenský | Slovak |
| `sl-SI` | Slovenščina | Slovenian |
| `so-SO` | Soomaali | Somali |
| `es-ES` | Español | Spanish |
| `su` | Basa Sunda | Sundanese |
| `sw-KE` | Kiswahili | Swahili |
| `sv-SE` | Svenska | Swedish |
| `tg-Cyrl-TJ` | Тоҷикистон | Tajik |
| `ta-IN` | தமிழ் | Tamil |
| `te-IN` | తెలుగు | Telugu |
| `th-TH` | ไทย | Thai |
| `tr-TR` | Türkçe | Turkish |
| `uk-UA` | Українська | Ukrainian |
| `ur-PK` | اردو | Urdu |
| `uz-Latn-UZ` | O'zbek | Uzbek |
| `vi-VN` | Tiếng Việt | Vietnamese |
| `cy-GB` | Cymraeg | Welsh |
| `xh-ZA` | isiXhosa | Xhosa |
| `yi` | ייִדיש | Yiddish |
| `yo-NG` | Yorùbá | Yoruba |
| `zu-ZA` | isiZulu | Zulu |
