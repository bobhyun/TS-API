[English](README.md) | **한국어**

# TS-API v1 curl 예제

`curl`과 `websocat`을 사용한 TS-NVR REST API 쉘 스크립트 예제입니다.

## 사전 요구사항

- **curl** (대부분의 시스템에 기본 포함)
- **jq** (선택사항, JSON 포맷 출력) - [https://jqlang.github.io/jq/](https://jqlang.github.io/jq/)
- **websocat** (WebSocket 예제 12-15에 필요) - [https://github.com/nickel-org/websocat](https://github.com/nickel-org/websocat)

## 빠른 시작

```bash
# 환경변수 설정
export NVR_HOST=192.168.0.100
export NVR_API_KEY=tsapi_key_...

# 예제 실행
bash 02-channels.sh
```

## 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `NVR_HOST` | `localhost` | NVR 서버 호스트명 또는 IP |
| `NVR_SCHEME` | `https` | 프로토콜 (`http` 또는 `https`) |
| `NVR_PORT` | `443` (https) / `80` (http) | 서버 포트 |
| `NVR_USER` | `admin` | 로그인 사용자명 (01-login.sh 전용) |
| `NVR_PASS` | `1234` | 로그인 비밀번호 (01-login.sh 전용) |
| `NVR_API_KEY` | *(필수)* | v1 엔드포인트용 API Key (02-15) |
| `NVR_CHANNEL` | `1` | 대상 카메라 채널 (03, 15) |

## 예제 목록

### 인증

| 파일 | 설명 |
|------|------|
| [01-login.sh](01-login.sh) | JWT 로그인/갱신/로그아웃 + API Key 생성/삭제 |

### REST API (API Key 인증)

| 파일 | 설명 | 엔드포인트 |
|------|------|-----------|
| [02-channels.sh](02-channels.sh) | 채널 목록, 상태, 기능 조회 | `GET channel`, `channel/status`, `channel/{id}/info` |
| [03-ptz-control.sh](03-ptz-control.sh) | PTZ 카메라 제어 | `GET channel/{id}/ptz`, `channel/{id}/preset` |
| [04-recording-search.sh](04-recording-search.sh) | 녹화 캘린더 및 타임라인 | `GET recording/days`, `recording/minutes` |
| [05-event-log.sh](05-event-log.sh) | 이벤트 검색 및 필터링 | `GET event/type`, `event/log` |
| [06-lpr-search.sh](06-lpr-search.sh) | 차번 인식 검색 | `GET lpr/source`, `lpr/log`, `lpr/similar` |
| [07-vod-stream.sh](07-vod-stream.sh) | 라이브/재생 스트림 URL | `GET vod` |
| [08-system-info.sh](08-system-info.sh) | 시스템 및 서버 정보 | `GET info`, `system/info`, `system/health`, `system/hddsmart` |
| [09-push.sh](09-push.sh) | 외부 이벤트 푸시 (LPR, 비상호출) | `POST push` |
| [10-parking.sh](10-parking.sh) | 주차장 및 주차면 관리 | `GET parking/lot`, `parking/spot`, `/status` |
| [11-emergency.sh](11-emergency.sh) | 비상호출 장치 목록 | `GET emergency` |

### WebSocket (websocat)

| 파일 | 설명 | 엔드포인트 |
|------|------|-----------|
| [12-websocket-events.sh](12-websocket-events.sh) | 실시간 이벤트 구독 | `wsapi/v1/events` |
| [13-websocket-parking-lot.sh](13-websocket-parking-lot.sh) | 주차장 입출차 카운트 모니터링 | `wsapi/v1/events?topics=parkingCount` |
| [14-websocket-parking-spot.sh](14-websocket-parking-spot.sh) | 주차면 점유 상태 모니터링 | `wsapi/v1/events?topics=parkingSpot` |
| [15-websocket-export.sh](15-websocket-export.sh) | 녹화 데이터 내보내기 | `wsapi/v1/export` |

## 인증 방식

### API Key (예제 02-15)

```bash
curl -sk -H "X-API-Key: tsapi_key_..." https://nvr-server/api/v1/channel
```

> API Key는 `/api/v1/*` 엔드포인트에서만 사용 가능합니다. v0 엔드포인트(`/api/*`)는 API Key를 401로 거부합니다.

### JWT Bearer 토큰 (예제 01)

```bash
# 로그인
AUTH=$(echo -n "admin:1234" | base64)
RESPONSE=$(curl -sk -X POST https://nvr-server/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"auth\":\"${AUTH}\"}")
TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken')

# 토큰 사용
curl -sk -H "Authorization: Bearer ${TOKEN}" https://nvr-server/api/v1/channel
```

> 토큰 갱신 시 서버는 토큰 로테이션을 수행합니다. 이전 refreshToken은 폐기되므로 반드시 새로운 refreshToken을 사용하세요.

### WebSocket 인증

```bash
# 헤더 인증 (websocat)
websocat -k -H "X-API-Key: tsapi_key_..." wss://nvr-server/wsapi/v1/events?topics=LPR

# 쿼리 파라미터 인증 (브라우저 대체)
# wss://nvr-server/wsapi/v1/events?topics=LPR&apikey=tsapi_key_...
# wss://nvr-server/wsapi/v1/events?topics=LPR&token=jwt_access_token
```

## 참고사항

- 모든 스크립트는 `set -euo pipefail`로 안전 실행
- 자체 서명 인증서 허용 (`curl -k`, `websocat -k`)
- `jq` 설치 시 JSON 포맷 출력, 미설치 시 원본 출력
- 시간 파라미터는 ISO 8601 형식 (예: `2025-01-15T09:30:00`)
- 채널 ID는 1부터 시작 (1-based)
