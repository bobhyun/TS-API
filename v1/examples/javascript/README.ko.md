# TS-API v1 JavaScript 예제

[English](README.md) | **한국어**

## 사전 요구사항

- Node.js 18+
- `ws` 패키지 (WebSocket 예제만 해당): `npm install`

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

## 실행

```bash
# WebSocket 의존성 설치 (최초 1회)
npm install

# 예제 실행
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... node 02-channels.js
```

## 파일 목록

| 파일 | 주제 |
|------|------|
| [`config.js`](config.js) | 공용 설정 |
| [`http.js`](http.js) | 공용 HTTP 클라이언트 |
| [`01-login.js`](01-login.js) | JWT 인증 데모 |
| [`02-channels.js`](02-channels.js) | 채널 목록 조회 |
| [`03-ptz-control.js`](03-ptz-control.js) | PTZ 카메라 제어 |
| [`04-recording-search.js`](04-recording-search.js) | 녹화 구간 검색 |
| [`05-event-log.js`](05-event-log.js) | 이벤트 로그 조회 |
| [`06-lpr-search.js`](06-lpr-search.js) | 차번 인식 검색 |
| [`07-vod-stream.js`](07-vod-stream.js) | VOD 스트림 URL (RTMP, FLV) |
| [`08-system-info.js`](08-system-info.js) | 시스템 상태 |
| [`09-push-notification.js`](09-push-notification.js) | 외부 이벤트 푸시 |
| [`10-parking.js`](10-parking.js) | 주차장 관리 |
| [`11-emergency.js`](11-emergency.js) | 비상호출 관리 |
| [`12-websocket-events.js`](12-websocket-events.js) | WS 이벤트 구독 |
| [`13-websocket-parking-lot.js`](13-websocket-parking-lot.js) | WS 주차장 모니터링 |
| [`14-websocket-parking-spot.js`](14-websocket-parking-spot.js) | WS 주차면 모니터링 |
| [`15-websocket-export.js`](15-websocket-export.js) | WS 녹화 내보내기 |
