# TS-API v1 Go 예제

[English](README.md) | **한국어**

## 사전 요구사항

- Go 1.21+
- `gorilla/websocket` (WebSocket 예제만): `go mod tidy`

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
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... go run ./02_channels
```

## 디렉토리 구조

| 디렉토리 | 주제 |
|-----------|------|
| [`tsapi/`](tsapi/) | 공용 클라이언트 라이브러리 |
| [`01_login/`](01_login/) | JWT 인증 데모 |
| [`02_channels/`](02_channels/) | 채널 목록 조회 |
| [`03_ptz/`](03_ptz/) | PTZ 카메라 제어 |
| [`04_recording/`](04_recording/) | 녹화 구간 검색 |
| [`05_events/`](05_events/) | 이벤트 로그 조회 |
| [`06_lpr/`](06_lpr/) | 차번 인식 검색 |
| [`07_vod/`](07_vod/) | VOD 스트림 URL (RTMP, FLV) |
| [`08_system/`](08_system/) | 시스템 상태 |
| [`09_push/`](09_push/) | 외부 이벤트 푸시 |
| [`10_parking/`](10_parking/) | 주차장 관리 |
| [`11_emergency/`](11_emergency/) | 비상호출 관리 |
| [`12_ws_events/`](12_ws_events/) | WS 이벤트 구독 |
| [`13_ws_parking_lot/`](13_ws_parking_lot/) | WS 주차장 모니터링 |
| [`14_ws_parking_spot/`](14_ws_parking_spot/) | WS 주차면 모니터링 |
| [`15_ws_export/`](15_ws_export/) | WS 녹화 내보내기 |
