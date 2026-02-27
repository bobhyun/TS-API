# TS-API v1 Swift 예제

[English](README.md) | **한국어**

## 사전 요구사항

- Swift 5.5+ (macOS 12+ / Linux Swift 툴체인)
- 외부 의존성 없음 (Foundation만 사용)

## API Key 발급

```bash
# 1. 관리자 로그인
curl -sk -X POST https://SERVER/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'

# 2. API Key 생성 (1단계의 accessToken 사용)
curl -sk -X POST https://SERVER/api/v1/auth/apikey \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"dev-test","permissions":["*"]}'

# 3. 환경변수 설정
export NVR_API_KEY=tsapi_key_...
```

> `SERVER`, `admin`, `1234`는 예시입니다. 실제 서버 주소, 사용자명, 비밀번호로 변경하세요.

## 환경 변수

| 변수         | 기본값      | 설명                        |
|--------------|-------------|------------------------------|
| `NVR_API_KEY`| *(필수)*    | 인증용 API Key              |
| `NVR_HOST`   | `localhost` | 서버 호스트명                |
| `NVR_SCHEME` | `https`     | 프로토콜 (http/https)        |
| `NVR_PORT`   | `443`/`80`  | 서버 포트                    |

## 빌드 및 실행

```bash
# 컴파일 (모든 예제에 NvrClient.swift 포함)
swiftc -o example NvrClient.swift 02-channels.swift

# 실행
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./example
```

## 파일 목록

| 파일 | 주제 |
|------|------|
| [`NvrClient.swift`](NvrClient.swift) | 공용 HTTP/WebSocket 클라이언트 |
| [`01-login.swift`](01-login.swift) | JWT 인증 데모 |
| [`02-channels.swift`](02-channels.swift) | 채널 목록 조회 |
| [`03-ptz-control.swift`](03-ptz-control.swift) | PTZ 카메라 제어 |
| [`04-recording-search.swift`](04-recording-search.swift) | 녹화 구간 검색 |
| [`05-event-log.swift`](05-event-log.swift) | 이벤트 로그 조회 |
| [`06-lpr-search.swift`](06-lpr-search.swift) | 차번 인식 검색 |
| [`07-vod-stream.swift`](07-vod-stream.swift) | VOD 스트림 URL (RTMP, FLV) |
| [`08-system-info.swift`](08-system-info.swift) | 시스템 상태 |
| [`09-push.swift`](09-push.swift) | 외부 이벤트 푸시 |
| [`10-parking.swift`](10-parking.swift) | 주차장 관리 |
| [`11-emergency.swift`](11-emergency.swift) | 비상호출 관리 |
| [`12-websocket-events.swift`](12-websocket-events.swift) | WS 이벤트 구독 |
| [`13-websocket-parking-lot.swift`](13-websocket-parking-lot.swift) | WS 주차장 모니터링 |
| [`14-websocket-parking-spot.swift`](14-websocket-parking-spot.swift) | WS 주차면 모니터링 |
| [`15-websocket-export.swift`](15-websocket-export.swift) | WS 녹화 내보내기 |
