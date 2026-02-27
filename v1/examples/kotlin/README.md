# TS-API v1 Kotlin Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- Kotlin compiler + Java 11+ runtime

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
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... kotlinc -script TsApiClient.kt V1_02_Channels.kt
```

## Files

| File | Topic |
|------|-------|
| [`TsApiClient.kt`](TsApiClient.kt) | Shared HTTP client |
| [`V1_01_Login.kt`](V1_01_Login.kt) | JWT authentication demo |
| [`V1_02_Channels.kt`](V1_02_Channels.kt) | Channel list and query |
| [`V1_03_PtzControl.kt`](V1_03_PtzControl.kt) | PTZ camera control |
| [`V1_04_RecordingSearch.kt`](V1_04_RecordingSearch.kt) | Recording segment search |
| [`V1_05_EventLog.kt`](V1_05_EventLog.kt) | Event log query |
| [`V1_06_LprSearch.kt`](V1_06_LprSearch.kt) | LPR data search |
| [`V1_07_VodStream.kt`](V1_07_VodStream.kt) | VOD stream URLs (RTMP, FLV) |
| [`V1_08_SystemInfo.kt`](V1_08_SystemInfo.kt) | System status |
| [`V1_09_Push.kt`](V1_09_Push.kt) | External event push |
| [`V1_10_Parking.kt`](V1_10_Parking.kt) | Parking management |
| [`V1_11_Emergency.kt`](V1_11_Emergency.kt) | Emergency call management |
| [`V1_12_WebSocketEvents.kt`](V1_12_WebSocketEvents.kt) | WS event subscription |
| [`V1_13_WebSocketParkingLot.kt`](V1_13_WebSocketParkingLot.kt) | WS parking lot monitoring |
| [`V1_14_WebSocketParkingSpot.kt`](V1_14_WebSocketParkingSpot.kt) | WS parking spot monitoring |
| [`V1_15_WebSocketExport.kt`](V1_15_WebSocketExport.kt) | WS recording export |
