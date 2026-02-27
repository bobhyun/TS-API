# TS-API v1 C# 예제

[English](README.md) | **한국어**

## 사전 요구사항

- .NET 10 SDK

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

`TsApiExamples.csproj`의 `StartupObject`를 변경하거나 직접 실행:

```bash
# TsApiExamples.csproj의 StartupObject를 원하는 예제로 변경 후:
NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... dotnet run
```

## 파일 목록

| 파일 | 주제 |
|------|------|
| [`NvrClient.cs`](NvrClient.cs) | 공용 HTTP 클라이언트 |
| [`TsApiExamples.csproj`](TsApiExamples.csproj) | 프로젝트 파일 |
| [`01_Login.cs`](01_Login.cs) | JWT 인증 데모 |
| [`02_Channels.cs`](02_Channels.cs) | 채널 목록 조회 |
| [`03_PtzControl.cs`](03_PtzControl.cs) | PTZ 카메라 제어 |
| [`04_RecordingSearch.cs`](04_RecordingSearch.cs) | 녹화 구간 검색 |
| [`05_EventLog.cs`](05_EventLog.cs) | 이벤트 로그 조회 |
| [`06_LprSearch.cs`](06_LprSearch.cs) | 차번 인식 검색 |
| [`07_VodStream.cs`](07_VodStream.cs) | VOD 스트림 URL (RTMP, FLV) |
| [`08_SystemInfo.cs`](08_SystemInfo.cs) | 시스템 상태 |
| [`09_Push.cs`](09_Push.cs) | 외부 이벤트 푸시 |
| [`10_Parking.cs`](10_Parking.cs) | 주차장 관리 |
| [`11_Emergency.cs`](11_Emergency.cs) | 비상호출 관리 |
| [`12_WebSocketEvents.cs`](12_WebSocketEvents.cs) | WS 이벤트 구독 |
| [`13_WebSocketParkingLot.cs`](13_WebSocketParkingLot.cs) | WS 주차장 모니터링 |
| [`14_WebSocketParkingSpot.cs`](14_WebSocketParkingSpot.cs) | WS 주차면 모니터링 |
| [`15_WebSocketExport.cs`](15_WebSocketExport.cs) | WS 녹화 내보내기 |
