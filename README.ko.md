# TS-API Reference

[English](README.md) | **한국어**

**TS-API**는 TS Solution Corp.의 영상 보안 제품군 — **TS-CMS**, **TS-NVR**, **TS-IVR** — 에 내장된 웹 API입니다.

> TS-API v1 웹서버는 TS-IVR, TS-NVR, TS-CMS v3.0.0 이후버전부터 적용되었습니다.
> RESTful API(`/api/v1`)는 JWT 및 API Key 인증을 지원하며, 경로 기반으로 설계되었습니다.

## 목차

1. [API 버전](#1-api-버전)
2. [빠른 시작](#2-빠른-시작)
3. [문서](#3-문서)
4. [엔드포인트 요약](#4-엔드포인트-요약)
5. [응답 형식](#5-응답-형식)
6. [HTTP 상태 코드](#6-http-상태-코드)
7. [라이선스 종속 기능](#7-라이선스-종속-기능)
8. [WebSocket API](#8-websocket-api)

---

## 1. API 버전

| 버전 | 스타일 | 기본 URL | 문서 |
|---------|-------|----------|------|
| [v1](v1/tsapi-v1.ko.md) | RESTful 경로 | `/api/v1`, `/wsapi/v1` | [API 가이드](v1/tsapi-v1.ko.md) · [예제](v1/examples/) |
| [legacy](legacy/ko/TS-API.ko.md) | Query String | `/api` | [API 가이드](legacy/ko/TS-API.ko.md) · [예제](legacy/ko/examples/) |

---

## 2. 빠른 시작

### 2.1. 로그인 (JWT)
```bash
# JWT 로그인 - accessToken 반환
# 참고: auth = base64("admin:1234"). 실제 NVR 계정 정보를 사용하세요.
curl -X POST "http://localhost/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"auth":"YWRtaW46MTIzNA=="}'
# Response: {"accessToken":"eyJ...","refreshToken":"...","expiresIn":3600,"tokenType":"Bearer"}
```

### 2.2. 채널 조회
```bash
curl "http://localhost/api/v1/channel" \
  -H "Authorization: Bearer {accessToken}"
```

### 2.3. PTZ 제어
```bash
curl "http://localhost/api/v1/channel/1/ptz?home" \
  -H "Authorization: Bearer {accessToken}"
```

### 2.4. 대안: API Key (외부 연동용)
```bash
# API Key 생성 (관리자 전용 - JWT 인증 필요)
curl -X POST "http://localhost/api/v1/auth/apikey" \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{"name":"Monitoring System"}'

# API Key 사용 (모든 v1 엔드포인트 접근 가능, 로그인 불필요)
curl "http://localhost/api/v1/channel" \
  -H "X-API-Key: tsapi_key_..."
```

---

## 3. 문서

- [v1 API Guide](v1/tsapi-v1.ko.md) - RESTful 경로 기반 API
- [v1 Examples](v1/examples/) - v1 API 예제 코드 (9개 언어)
- [Legacy API Guide](legacy/ko/TS-API.ko.md) - 레거시 쿼리스트링 기반 API
- [마이그레이션 가이드](v1/MIGRATION.ko.md) - 레거시에서 v1으로 전환

---

## 4. 엔드포인트 요약

### 4.1. v1 REST API 엔드포인트

#### 4.1.1. 인증
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/auth/login` | POST | JWT 로그인 (username, password) |
| `/api/v1/auth/refresh` | POST | Access Token 갱신 (refreshToken) |
| `/api/v1/auth/logout` | POST | 로그아웃 (refreshToken 무효화) |
| `/api/v1/auth/apikey` | POST | API Key 생성 (관리자 전용) |
| `/api/v1/auth/apikey` | GET | API Key 목록 조회 |
| `/api/v1/auth/apikey/{id}` | DELETE | API Key 삭제 |
| `/api/v1/auth` | GET | 레거시 (차단됨: POST /api/v1/auth/login 사용) |

#### 4.1.2. 서버 정보
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/info` | GET | 서버 정보 (apiVersion, siteName, timezone, product, license) |

#### 4.1.3. 시스템
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/system/info` | GET | 시스템 정보 (OS, CPU, Storage, Network) |
| `/api/v1/system/health` | GET | 시스템 상태 (CPU%, Memory, Disk 사용량) |
| `/api/v1/system/hddsmart` | GET | HDD S.M.A.R.T 정보 |
| `/api/v1/system/restart` | POST | 서버 재시작 |
| `/api/v1/system/reboot` | POST | 시스템 재부팅 |

#### 4.1.4. 채널
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/channel` | GET | 채널(카메라) 목록 |
| `/api/v1/channel` | POST | 채널 추가 |
| `/api/v1/channel/{id}` | DELETE | 채널 삭제 |
| `/api/v1/channel/status` | GET | 채널 연결/녹화 상태 |
| `/api/v1/channel/info` | GET | 채널 상세 정보 |
| `/api/v1/channel/{id}/ptz` | GET | PTZ 제어 (home, move, zoom, focus) |
| `/api/v1/channel/{id}/preset` | GET/POST/PUT/DELETE | 프리셋 관리 |
| `/api/v1/channel/{id}/relay` | GET/PUT | 릴레이 출력 제어 |
| `/api/v1/channel/{id}/reboot` | POST | 카메라 원격 재부팅 |

#### 4.1.5. 녹화
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/recording/days` | GET | 녹화 날짜 조회 (캘린더용) |
| `/api/v1/recording/minutes` | GET | 녹화 구간 조회 (타임라인용) |

#### 4.1.6. 이벤트
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/event/type` | GET | 이벤트 유형 목록 |
| `/api/v1/event/log` | GET | 이벤트 로그 검색 |
| `/api/v1/event/trigger` | PUT | 이벤트 수동 트리거 |

#### 4.1.7. LPR (차량 번호 인식)
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/lpr/source` | GET | LPR 소스(인식 지점) 목록 |
| `/api/v1/lpr/log` | GET | 차량 번호 인식 기록 검색 |
| `/api/v1/lpr/similar` | GET | 유사 번호판 검색 |

#### 4.1.8. 객체 감지
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/object/type` | GET | 감지 가능 객체 유형 |
| `/api/v1/object/attr` | GET | 객체 속성 목록 |
| `/api/v1/object/log` | GET | 감지된 객체 검색 |

#### 4.1.9. 얼굴 검색
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/face/search` | POST | 이미지 기반 얼굴 검색 |
| `/api/v1/face/search` | GET | 기간별 얼굴 목록 조회 |

#### 4.1.10. VOD (주문형 비디오)
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/vod` | GET | 실시간/녹화 스트림 URL 조회 |

#### 4.1.11. 기타
| 엔드포인트 | 메서드 | 설명 |
|----------|--------|-------------|
| `/api/v1/emergency` | GET | 비상 호출 장치 목록 |
| `/api/v1/push` | POST | 외부 이벤트 수신 |
| `/api/v1/parking/lot` | GET | 주차장 목록/상태 |
| `/api/v1/parking/spot` | GET | 주차면 목록/상태 |

### 4.2. v1 WebSocket 엔드포인트

| 엔드포인트 | 설명 |
|----------|-------------|
| `/wsapi/v1/events` | 실시간 이벤트 구독 (LPR, 채널상태, 객체감지 등) |
| `/wsapi/v1/export` | 녹화 데이터 내보내기 (백업) |

---

## 5. 응답 형식

응답 형식은 엔드포인트별로 다릅니다:

### 5.1. 배열 응답 (채널, 상태, 이벤트 유형 등)
```json
[
  {"chid": 1, "title": "Front Door"},
  {"chid": 2, "title": "Parking Lot"}
]
```

### 5.2. 페이지네이션 응답 (이벤트 로그, LPR 로그, 객체 검색)
```json
{
  "totalCount": 100,
  "at": 0,
  "data": [ ... ]
}
```

### 5.3. 오류 응답
```json
{
  "code": -1,
  "message": "Error description"
}
```

---

## 6. HTTP 상태 코드

| 코드 | 설명 |
|------|-------------|
| 200 | 성공 |
| 400 | 잘못된 요청 |
| 401 | 인증 필요 |
| 403 | 접근 거부 |
| 404 | 찾을 수 없음 |
| 500 | 내부 서버 오류 |

---

## 7. 라이선스 종속 기능

일부 API 기능은 해당 라이선스가 필요합니다. 라이선스가 활성화되지 않은 경우 404를 반환합니다.

| 기능 | 관련 엔드포인트 |
|------|----------------|
| LPR (차량 번호 인식) | `/api/v1/lpr/*` |
| 주차 유도 | `/api/v1/parking/lot`, `/wsapi/v1/events?topics=parkingCount` |
| 주차면 감지 | `/api/v1/parking/spot`, `/wsapi/v1/events?topics=parkingSpot` |
| 객체 감지 | `/api/v1/object/*` |
| 얼굴 검색 | `/api/v1/face/search` |
| 비상 호출 | `/api/v1/emergency` |
| Push 수신 | `/api/v1/push` |
| 이벤트 백업 | `/wsapi/v1/export` |
| 체온 측정 | `/wsapi/v1/events?topics=bodyTemperature` |
| 차량 추적 | `/wsapi/v1/events?topics=vehicleTracking` |

---

## 8. WebSocket API

실시간 이벤트 구독 및 데이터 내보내기를 위한 WebSocket API입니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `ws://{host}:{port}/wsapi/v1/events` | 실시간 이벤트 구독 |
| `ws://{host}:{port}/wsapi/v1/export` | 데이터 내보내기 |

### 8.1. WebSocket 인증

```javascript
// JWT (query param)
const ws = new WebSocket('ws://server:port/wsapi/v1/events?topics=LPR&token={accessToken}');

// API Key (query param)
const ws = new WebSocket('ws://server:port/wsapi/v1/events?topics=LPR&apikey=tsapi_key_...');
```

### 이벤트 구독 예시

```javascript
const ws = new WebSocket('ws://server/wsapi/v1/events?topics=LPR,channelStatus&apikey=tsapi_key_...');

ws.onmessage = (e) => {
  const data = JSON.parse(e.data);
  console.log('Event:', data);
};
```
