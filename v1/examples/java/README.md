# TS-API v1 Java Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Java 11+ (uses `java.net.http.HttpClient`)

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
# Java 11+ source-file execution (no compilation needed)
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... java NvrClient.java V1_02_Channels.java
```

## Files

| File | Topic |
|------|-------|
| [`NvrClient.java`](NvrClient.java) | Shared HTTP client |
| [`V1_01_Login.java`](V1_01_Login.java) | JWT authentication demo |
| [`V1_02_Channels.java`](V1_02_Channels.java) | Channel list and query |
| [`V1_03_PtzControl.java`](V1_03_PtzControl.java) | PTZ camera control |
| [`V1_04_RecordingSearch.java`](V1_04_RecordingSearch.java) | Recording segment search |
| [`V1_05_EventLog.java`](V1_05_EventLog.java) | Event log query |
| [`V1_06_LprSearch.java`](V1_06_LprSearch.java) | LPR data search |
| [`V1_07_VodStream.java`](V1_07_VodStream.java) | VOD stream URLs (RTMP, FLV) |
| [`V1_08_SystemInfo.java`](V1_08_SystemInfo.java) | System status |
| [`V1_09_Push.java`](V1_09_Push.java) | External event push |
| [`V1_10_Parking.java`](V1_10_Parking.java) | Parking management |
| [`V1_11_Emergency.java`](V1_11_Emergency.java) | Emergency call management |
| [`V1_12_WebSocketEvents.java`](V1_12_WebSocketEvents.java) | WS event subscription |
| [`V1_13_WebSocketParkingLot.java`](V1_13_WebSocketParkingLot.java) | WS parking lot monitoring |
| [`V1_14_WebSocketParkingSpot.java`](V1_14_WebSocketParkingSpot.java) | WS parking spot monitoring |
| [`V1_15_WebSocketExport.java`](V1_15_WebSocketExport.java) | WS recording export |
