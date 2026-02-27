# TS-API v1 PowerShell 예제

[English](README.md) | **한국어**

TS-API v1 RESTful API를 PowerShell로 제공하는 코드 예제입니다. 각 예제는 **API Key** (`X-API-Key` 헤더) 인증 방식으로 독립 실행됩니다.

> **API 레퍼런스**: [tsapi-v1.ko.md](../../tsapi-v1.ko.md)

## 사전 요구사항

- **PowerShell 7+** (권장) 또는 Windows PowerShell 5.1
- 외부 모듈 불필요 (내장 `Invoke-RestMethod` 및 `System.Net.WebSockets.ClientWebSocket` 사용)

### PowerShell 7 설치

```powershell
# Windows (winget)
winget install Microsoft.PowerShell

# 또는 다운로드: https://github.com/PowerShell/PowerShell/releases
```

## API Key 발급

모든 예제(`01-login.ps1` 제외)는 API Key가 필요합니다. PowerShell로 발급합니다:

```powershell
# 1. 관리자 로그인으로 JWT 토큰 획득
$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('admin:1234'))
$r = Invoke-RestMethod -Uri 'https://SERVER/api/v1/auth/login' `
  -Method Post -ContentType 'application/json' `
  -Body (@{ auth = $auth } | ConvertTo-Json) -SkipCertificateCheck
# $r.accessToken에 JWT 토큰 포함

# 2. API Key 생성 (1단계의 accessToken 사용)
$r2 = Invoke-RestMethod -Uri 'https://SERVER/api/v1/auth/apikey' `
  -Method Post -ContentType 'application/json' `
  -Headers @{ Authorization = "Bearer $($r.accessToken)" } `
  -Body (@{ name = 'dev-test'; permissions = @('*') } | ConvertTo-Json) `
  -SkipCertificateCheck
# $r2.key에 API Key 포함 (생성 시 한 번만 표시!)

# 3. 환경변수로 설정
$env:NVR_API_KEY = $r2.key
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

## 빠른 시작

```powershell
# 환경 설정
$env:NVR_HOST = '192.168.0.100'
$env:NVR_API_KEY = 'tsapi_key_...'

# 예제 실행
pwsh 02-channels.ps1
pwsh 08-system-info.ps1
pwsh 12-websocket-events.ps1
```

## 예제 목록

| 파일 | 설명 |
|------|------|
| [`config.ps1`](config.ps1) | 공용 설정 (환경변수, URL 빌드, SSL) |
| [`http.ps1`](http.ps1) | HTTP 헬퍼 함수 (Get/Post/Put/Delete, JWT) |
| [`01-login.ps1`](01-login.ps1) | JWT 인증, 토큰 갱신, 로그아웃, API Key CRUD |
| [`02-channels.ps1`](02-channels.ps1) | 채널 목록, 상태, 기능, 정보 |
| [`03-ptz-control.ps1`](03-ptz-control.ps1) | PTZ 홈/이동/정지/줌/포커스/아이리스/프리셋 |
| [`04-recording-search.ps1`](04-recording-search.ps1) | 녹화 일/분 검색 |
| [`05-event-log.ps1`](05-event-log.ps1) | 이벤트 유형 및 로그 검색 (페이지네이션) |
| [`06-lpr-search.ps1`](06-lpr-search.ps1) | LPR 소스, 로그, 키워드, 유사번호 검색 |
| [`07-vod-stream.ps1`](07-vod-stream.ps1) | 실시간/녹화 스트림 URL |
| [`08-system-info.ps1`](08-system-info.ps1) | 서버/시스템 정보, 건강도, HDD SMART |
| [`09-push.ps1`](09-push.ps1) | LPR 푸시, 비상호출 푸시 |
| [`10-parking.ps1`](10-parking.ps1) | 주차장/주차면 관리 |
| [`11-emergency.ps1`](11-emergency.ps1) | 비상호출 장치 목록 |
| [`12-websocket-events.ps1`](12-websocket-events.ps1) | WS 실시간 이벤트 구독 |
| [`13-websocket-parking-lot.ps1`](13-websocket-parking-lot.ps1) | WS 주차장 카운트 모니터링 |
| [`14-websocket-parking-spot.ps1`](14-websocket-parking-spot.ps1) | WS 주차면 모니터링 |
| [`15-websocket-export.ps1`](15-websocket-export.ps1) | WS 녹화 데이터 내보내기 |

## 참고사항

- **SSL**: PowerShell 7+는 `-SkipCertificateCheck` 스플래팅 사용. Windows PowerShell 5.1은 자체 서명 인증서를 위해 `TrustAllCertsPolicy` 사용.
- **WebSocket**: `System.Net.WebSockets.ClientWebSocket` 사용 (내장 .NET 클래스, 외부 의존성 없음).
- **한국어 텍스트**: `config.ps1`에서 콘솔 인코딩을 UTF-8로 자동 설정.
- **인증**: `01-login.ps1`은 JWT(사용자명/비밀번호) 인증 사용. 나머지 예제는 모두 API Key 사용.
- 채널 ID는 **1-based** (예: 채널 1, 2, 3...).
- 시간 형식: **ISO 8601** (예: `2026-01-15T10:30:00`).
