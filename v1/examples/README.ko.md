# TS-API v1 예제

[English](README.md) | **한국어**

> [curl](curl/) · [JavaScript](javascript/) · [Python](python/) · [Go](go/) · [C#](csharp/) · [Java](java/) · [Kotlin](kotlin/) · [Swift](swift/) · [PowerShell](powershell/)

TS-API v1 RESTful API를 9개 언어로 제공하는 코드 예제입니다. 각 예제는 **API Key** (`X-API-Key` 헤더) 인증 방식으로 독립 실행됩니다.

> **API 레퍼런스**: [tsapi-v1.ko.md](../tsapi-v1.ko.md)

## 지원 언어

| 언어       | 디렉토리     | 공용 클라이언트              | 실행 환경          |
|------------|-------------|-----------------------------|--------------------|
| [curl](curl/) | [`curl/`](curl/) | *(스크립트 내장)* | curl, jq (선택), websocat (WS) |
| [JavaScript](javascript/) | [`javascript/`](javascript/) | [`config.js`](javascript/config.js), [`http.js`](javascript/http.js) | Node.js 18+ |
| [Python](python/) | [`python/`](python/) | [`config.py`](python/config.py), [`http_client.py`](python/http_client.py) | Python 3.6+ |
| [Go](go/) | [`go/`](go/) | [`tsapi/client.go`](go/tsapi/client.go) | Go 1.21+ |
| [C#](csharp/) | [`csharp/`](csharp/) | [`NvrClient.cs`](csharp/NvrClient.cs) | .NET 10+ |
| [Java](java/) | [`java/`](java/) | [`NvrClient.java`](java/NvrClient.java) | Java 11+ |
| [Kotlin](kotlin/) | [`kotlin/`](kotlin/) | [`TsApiClient.kt`](kotlin/TsApiClient.kt) | Kotlin + Java 11+ |
| [Swift](swift/) | [`swift/`](swift/) | [`NvrClient.swift`](swift/NvrClient.swift) | Swift 5.5+ (macOS 12+) |
| [PowerShell](powershell/) | [`powershell/`](powershell/) | [`config.ps1`](powershell/config.ps1), [`http.ps1`](powershell/http.ps1) | PowerShell 7+ (또는 5.1) |

## API Key 발급

모든 예제(01_Login 제외)는 API Key가 필요합니다. `curl`로 발급합니다:

```bash
# 1. 관리자 로그인으로 JWT 토큰 획득
curl -sk -X POST https://SERVER/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'
# 응답: {"accessToken":"eyJ...", "refreshToken":"...", ...}

# 2. API Key 생성 (1단계의 accessToken 사용)
curl -sk -X POST https://SERVER/api/v1/auth/apikey \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"dev-test","permissions":["*"]}'
# 응답: {"id":"key_abc123", "key":"tsapi_key_a1b2c3d4e5f6...", ...}

# 3. 환경변수로 설정
export NVR_API_KEY=tsapi_key_a1b2c3d4e5f6...
```

> `SERVER`, `admin`, `1234`는 예시입니다. 실제 서버 주소, 사용자명, 비밀번호로 변경하세요.
>
> API Key는 생성 시 한 번만 표시됩니다. 안전하게 보관하세요.

## 환경 변수

| 변수           | 기본값       | 설명                        |
|----------------|-------------|------------------------------|
| `NVR_API_KEY`  | *(필수)*     | 인증용 API Key              |
| `NVR_HOST`     | `localhost` | 서버 호스트명                |
| `NVR_SCHEME`   | `https`     | 프로토콜 (`http` 또는 `https`) |
| `NVR_PORT`     | `443`/`80`  | 서버 포트 (프로토콜 기본값)  |

## 예제 목록

| #  | 주제             | 설명                                |
|----|------------------|-------------------------------------|
| 01 | 로그인           | JWT 인증 데모                       |
| 02 | 채널             | 카메라 채널 목록 및 조회            |
| 03 | PTZ 제어         | 카메라 팬/틸트/줌 제어              |
| 04 | 녹화 검색        | 녹화 영상 구간 검색                 |
| 05 | 이벤트 로그      | 시스템 이벤트 로그 조회             |
| 06 | 차번 검색        | 차량 번호판 인식 데이터 검색        |
| 07 | VOD 스트림       | 녹화 영상 재생 (RTMP, FLV)          |
| 08 | 시스템 정보      | 시스템 상태 및 건강도               |
| 09 | 푸시             | 외부 이벤트 푸시                    |
| 10 | Parking            | 주차장 관리                           |
| 11 | 비상호출         | 비상 호출 장치 관리                 |
| 12 | WebSocket 이벤트 | WS 실시간 이벤트 구독               |
| 13 | WS Parking Lot     | WS 주차장 모니터링                    |
| 14 | WS Parking Spot    | WS 주차면 모니터링                    |
| 15 | WS Data Export     | WS 녹화 데이터 내보내기             |

> `01_Login`은 JWT(사용자명/비밀번호) 인증을 사용합니다. 나머지 예제는 모두 API Key를 사용합니다.

## 빠른 시작

```bash
# 환경 설정
export NVR_HOST=192.168.0.100
export NVR_API_KEY=tsapi_key_...

# 실행 (원하는 언어 선택)
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

각 언어의 `README.md`에서 상세한 설정 안내를 확인하세요.
