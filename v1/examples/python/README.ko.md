# TS-API v1 Python 예제

[English](README.md) | **한국어**

## 사전 요구사항

- Python 3.6+
- `requests` 라이브러리: `pip install requests`
- `websocket-client` 라이브러리 (WebSocket 예제만): `pip install websocket-client`

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
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... python 02_channels.py
```

## 파일 목록

| 파일 | 주제 |
|------|------|
| [`config.py`](config.py) | 공용 설정 |
| [`http_client.py`](http_client.py) | 공용 HTTP 클라이언트 (NvrClient) |
| [`01_login.py`](01_login.py) | JWT 인증 데모 |
| [`02_channels.py`](02_channels.py) | 채널 목록 조회 |
| [`03_ptz_control.py`](03_ptz_control.py) | PTZ 카메라 제어 |
| [`04_recording_search.py`](04_recording_search.py) | 녹화 구간 검색 |
| [`05_event_log.py`](05_event_log.py) | 이벤트 로그 조회 |
| [`06_lpr_search.py`](06_lpr_search.py) | 차번 인식 검색 |
| [`07_vod_stream.py`](07_vod_stream.py) | VOD 스트림 URL (RTMP, FLV) |
| [`08_system_info.py`](08_system_info.py) | 시스템 상태 |
| [`09_push.py`](09_push.py) | 외부 이벤트 푸시 |
| [`10_parking.py`](10_parking.py) | 주차장 관리 |
| [`11_emergency.py`](11_emergency.py) | 비상호출 관리 |
| [`12_websocket_events.py`](12_websocket_events.py) | WS 이벤트 구독 |
| [`13_websocket_parking_lot.py`](13_websocket_parking_lot.py) | WS 주차장 모니터링 |
| [`14_websocket_parking_spot.py`](14_websocket_parking_spot.py) | WS 주차면 모니터링 |
| [`15_websocket_export.py`](15_websocket_export.py) | WS 녹화 내보내기 |
