# TS-API v1 C# Examples

**English** | [한국어](README.ko.md)

## Prerequisites

- .NET 10 SDK

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

Change `StartupObject` in `TsApiExamples.csproj` or run directly:

```bash
# Edit TsApiExamples.csproj StartupObject to the desired example, then:
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... dotnet run
```

## Files

| File | Topic |
|------|-------|
| [`NvrClient.cs`](NvrClient.cs) | Shared HTTP client |
| [`TsApiExamples.csproj`](TsApiExamples.csproj) | Project file |
| [`01_Login.cs`](01_Login.cs) | JWT authentication demo |
| [`02_Channels.cs`](02_Channels.cs) | Channel list and query |
| [`03_PtzControl.cs`](03_PtzControl.cs) | PTZ camera control |
| [`04_RecordingSearch.cs`](04_RecordingSearch.cs) | Recording segment search |
| [`05_EventLog.cs`](05_EventLog.cs) | Event log query |
| [`06_LprSearch.cs`](06_LprSearch.cs) | LPR data search |
| [`07_VodStream.cs`](07_VodStream.cs) | VOD stream URLs (RTMP, FLV) |
| [`08_SystemInfo.cs`](08_SystemInfo.cs) | System status |
| [`09_Push.cs`](09_Push.cs) | External event push |
| [`10_Parking.cs`](10_Parking.cs) | Parking management |
| [`11_Emergency.cs`](11_Emergency.cs) | Emergency call management |
| [`12_WebSocketEvents.cs`](12_WebSocketEvents.cs) | WS event subscription |
| [`13_WebSocketParkingLot.cs`](13_WebSocketParkingLot.cs) | WS parking lot monitoring |
| [`14_WebSocketParkingSpot.cs`](14_WebSocketParkingSpot.cs) | WS parking spot monitoring |
| [`15_WebSocketExport.cs`](15_WebSocketExport.cs) | WS recording export |
