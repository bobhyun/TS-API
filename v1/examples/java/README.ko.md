# TS-API v1 Java 예제

[English](README.md) | **한국어**

## 사전 요구사항

- Java 11+ (`java.net.http.HttpClient` 사용)

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
# Java 11+ 소스 파일 직접 실행 (컴파일 불필요)
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... java NvrClient.java V1_02_Channels.java
```

## 파일 목록

| 파일 | 주제 |
|------|------|
| [`NvrClient.java`](NvrClient.java) | 공용 HTTP 클라이언트 |
| [`V1_01_Login.java`](V1_01_Login.java) | JWT 인증 데모 |
| [`V1_02_Channels.java`](V1_02_Channels.java) | 채널 목록 조회 |
| [`V1_03_PtzControl.java`](V1_03_PtzControl.java) | PTZ 카메라 제어 |
| [`V1_04_RecordingSearch.java`](V1_04_RecordingSearch.java) | 녹화 구간 검색 |
| [`V1_05_EventLog.java`](V1_05_EventLog.java) | 이벤트 로그 조회 |
| [`V1_06_LprSearch.java`](V1_06_LprSearch.java) | 차번 인식 검색 |
| [`V1_07_VodStream.java`](V1_07_VodStream.java) | VOD 스트림 URL (RTMP, FLV) |
| [`V1_08_SystemInfo.java`](V1_08_SystemInfo.java) | 시스템 상태 |
| [`V1_09_Push.java`](V1_09_Push.java) | 외부 이벤트 푸시 |
| [`V1_10_Parking.java`](V1_10_Parking.java) | 주차장 관리 |
| [`V1_11_Emergency.java`](V1_11_Emergency.java) | 비상호출 관리 |
| [`V1_12_WebSocketEvents.java`](V1_12_WebSocketEvents.java) | WS 이벤트 구독 |
| [`V1_13_WebSocketParkingLot.java`](V1_13_WebSocketParkingLot.java) | WS 주차장 모니터링 |
| [`V1_14_WebSocketParkingSpot.java`](V1_14_WebSocketParkingSpot.java) | WS 주차면 모니터링 |
| [`V1_15_WebSocketExport.java`](V1_15_WebSocketExport.java) | WS 녹화 내보내기 |
