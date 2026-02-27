# TS-API v1 Examples

**English** | [한국어](README.ko.md)

> [curl](curl/) · [JavaScript](javascript/) · [Python](python/) · [Go](go/) · [C#](csharp/) · [Java](java/) · [Kotlin](kotlin/) · [Swift](swift/) · [PowerShell](powershell/)

Code examples for the TS-API v1 RESTful API in 9 languages. Each example authenticates via **API Key** (`X-API-Key` header) and can be run independently.

> **API Reference**: [tsapi-v1.md](../tsapi-v1.md)

## Languages

| Language   | Directory    | Shared Client              | Runtime Required   |
|------------|-------------|----------------------------|--------------------|
| [curl](curl/) | [`curl/`](curl/) | *(built-in helpers)* | curl, jq (optional), websocat (WS) |
| [JavaScript](javascript/) | [`javascript/`](javascript/) | [`config.js`](javascript/config.js), [`http.js`](javascript/http.js) | Node.js 18+ |
| [Python](python/) | [`python/`](python/) | [`config.py`](python/config.py), [`http_client.py`](python/http_client.py) | Python 3.6+ |
| [Go](go/) | [`go/`](go/) | [`tsapi/client.go`](go/tsapi/client.go) | Go 1.21+ |
| [C#](csharp/) | [`csharp/`](csharp/) | [`NvrClient.cs`](csharp/NvrClient.cs) | .NET 10+ |
| [Java](java/) | [`java/`](java/) | [`NvrClient.java`](java/NvrClient.java) | Java 11+ |
| [Kotlin](kotlin/) | [`kotlin/`](kotlin/) | [`TsApiClient.kt`](kotlin/TsApiClient.kt) | Kotlin + Java 11+ |
| [Swift](swift/) | [`swift/`](swift/) | [`NvrClient.swift`](swift/NvrClient.swift) | Swift 5.5+ (macOS 12+) |
| [PowerShell](powershell/) | [`powershell/`](powershell/) | [`config.ps1`](powershell/config.ps1), [`http.ps1`](powershell/http.ps1) | PowerShell 7+ (or 5.1) |

## API Key Setup

All examples (except `01_Login`) require an API Key. Issue one using `curl`:

```bash
# 1. Login as admin to get a JWT token
curl -sk -X POST https://SERVER/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'
# Response: {"accessToken":"eyJ...", "refreshToken":"...", ...}

# 2. Create an API Key (use the accessToken from step 1)
curl -sk -X POST https://SERVER/api/v1/auth/apikey \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"dev-test","permissions":["*"]}'
# Response: {"id":"key_abc123", "key":"tsapi_key_a1b2c3d4e5f6...", ...}

# 3. Set the API Key as an environment variable
export NVR_API_KEY=tsapi_key_a1b2c3d4e5f6...
```

> Replace `SERVER`, `admin`, and `1234` with your actual server address, username, and password.
>
> The API Key is shown only once at creation. Store it securely.

## Environment Variables

| Variable       | Default     | Description                      |
|----------------|-------------|----------------------------------|
| `NVR_API_KEY`  | *(required)* | API Key for authentication      |
| `NVR_HOST`     | `localhost` | Server hostname                  |
| `NVR_SCHEME`   | `https`     | Protocol (`http` or `https`)     |
| `NVR_PORT`     | `443`/`80`  | Server port (default by scheme)  |

## Example Topics

| #  | Topic              | Description                           |
|----|--------------------|---------------------------------------|
| 01 | Login              | JWT authentication demo               |
| 02 | Channels           | List and query camera channels        |
| 03 | PTZ Control        | Pan/Tilt/Zoom camera control          |
| 04 | Recording Search   | Search recorded video segments        |
| 05 | Event Log          | Query system event logs               |
| 06 | LPR Search         | License plate recognition search      |
| 07 | VOD Stream         | Video-on-demand (RTMP, FLV)           |
| 08 | System Info        | System status and health              |
| 09 | Push               | External event push                   |
| 10 | Parking            | Parking lot management                |
| 11 | Emergency          | Emergency call device management      |
| 12 | WebSocket Events   | WS real-time event subscription       |
| 13 | WS Parking Lot     | WS parking lot monitoring             |
| 14 | WS Parking Spot    | WS parking spot monitoring            |
| 15 | WS Data Export     | WS recording data export              |

> `01_Login` uses JWT (username/password). All other examples use API Key.

## Quick Start

```bash
# Set environment
export NVR_HOST=192.168.0.100
export NVR_API_KEY=tsapi_key_...

# Run (pick your language)
cd curl       && bash 02-channels.sh
cd javascript && node 02-channels.js
cd python     && python 02_channels.py
cd go         && go run ./02_channels
cd csharp     && dotnet run --project . -- 02
cd java       && java NvrClient.java V1_02_Channels.java
cd kotlin     && kotlinc -script TsApiClient.kt V1_02_Channels.kt
cd swift      && swiftc -o example NvrClient.swift 02-channels.swift && ./example
cd powershell && pwsh 02-channels.ps1
```

See each language's `README.md` for detailed setup instructions.
