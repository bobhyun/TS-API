# v0 to v1 Migration Guide

[English](MIGRATION.md) | **한국어**

## 목차

1. [개요](#1-개요)
2. [v0 vs v1 비교](#2-v0-vs-v1-비교)
3. [엔드포인트 매핑](#3-엔드포인트-매핑)
4. [코드 마이그레이션 예제](#4-코드-마이그레이션-예제)
5. [주요 변경사항](#5-주요-변경사항)
6. [인증 참고사항](#6-인증-참고사항)

7. [v0 API 비활성화](#7-v0-api-비활성화)

---

## 1. 개요

v1 API는 RESTful 경로 기반으로 변경되었습니다. 기존 v0 API도 계속 지원되며, 서버 설정에서 선택적으로 활성화/비활성화할 수 있습니다.

### 레거시 API (v0) 지원 설정

v0 API의 사용 여부는 서버 설정에서 제어합니다:

| 설정 | 동작 |
|------|------|
| **레거시 API 활성화 (v0)** 체크 | v0, v1 엔드포인트 모두 사용 가능 (기본값) |
| **레거시 API 활성화 (v0)** 해제 | v0 엔드포인트 비활성화, v1만 사용 가능 |

설정 위치: **웹 관리자** → **서버 설정** → **API** 탭


---

## 2. v0 vs v1 비교

| 기능 | v0 | [v1](tsapi-v1.ko.md) |
|------|----|----|
| 인증: 세션 쿠키 | ✅ | ✅ |
| 인증: JWT Bearer Token | ❌ | ✅ |
| 인증: API Key | ❌ | ✅ |
| 채널 목록 | `GET /api/enum?what=channel` | `GET /api/v1/channel` |
| 시스템 정보 | `GET /api/system?info` | `GET /api/v1/system/info` |
| PTZ 제어 | `GET /api/channel/ptz?ch=1&home` | `GET /api/v1/channel/1/ptz?home` |
| 시스템 재시작 | `GET /api/system?restart` | `POST /api/v1/system/restart` |
| **문서** | — | [API 가이드](tsapi-v1.ko.md) |
| **예제** | — | [9개 언어](examples/) |

---

## 3. 엔드포인트 매핑

### 2.1. 인증
| v0 | v1 |
|----|-----|
| `GET /api/auth?login=...` | `POST /api/v1/auth/login` (JSON body) |
| `GET /api/auth?logout` | `POST /api/v1/auth/logout` (JSON body) |

> **참고:** `GET /api/v1/auth?login=...`은 보안상의 이유로 v1에서 차단되었습니다. 크레덴셜을 쿼리 스트링으로 전달해서는 안 됩니다. 대신 `POST /api/v1/auth/login`을 사용하여 JSON 요청 본문으로 크레덴셜을 전송하십시오.

### 2.2. Info (변경 없음)
| v0 | v1 |
|----|-----|
| `GET /api/info?all` | `GET /api/v1/info?all` |

### 2.3. 시스템
| v0 | v1 |
|----|-----|
| `GET /api/system?info` | `GET /api/v1/system/info` |
| `GET /api/system?info=os` | `GET /api/v1/system/info?item=os` |
| `GET /api/system?health` | `GET /api/v1/system/health` |
| `GET /api/system?health=cpu` | `GET /api/v1/system/health?item=cpu` |
| `GET /api/system?hddsmart` | `GET /api/v1/system/hddsmart` |
| `GET /api/system?hddsmart=1` | `GET /api/v1/system/hddsmart?disk=1` |
| `GET /api/system?restart` | `POST /api/v1/system/restart` |
| `GET /api/system?reboot` | `POST /api/v1/system/reboot` |

### 2.4. 채널 상태
| v0 | v1 |
|----|-----|
| `GET /api/status` | `GET /api/v1/channel/status` |
| `GET /api/status?ch=1,2,3` | `GET /api/v1/channel/status?ch=1,2,3` |

### 2.5. 채널 목록 (Enum)
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=channel` | `GET /api/v1/channel` |
| `GET /api/enum?what=channel&staticSrc` | `GET /api/v1/channel?staticSrc` |
| `GET /api/enum?what=channel&caps` | `GET /api/v1/channel?caps` |

### 2.6. 채널 제어
| v0 | v1 |
|----|-----|
| `GET /api/channel/info` | `GET /api/v1/channel/info` |
| `GET /api/channel/info?caps&ch=1` | `GET /api/v1/channel/1/info?caps` |
| `GET /api/channel/ptz?ch=1&home` | `GET /api/v1/channel/1/ptz?home` |
| `GET /api/channel/ptz?ch=1&move=0.5,0.5` | `GET /api/v1/channel/1/ptz?move=0.5,0.5` |
| `GET /api/channel/preset?ch=1&list` | `GET /api/v1/channel/1/preset` |
| `GET /api/channel/preset?ch=1&add&name=door` | `POST /api/v1/channel/1/preset?name=door` |
| `GET /api/channel/preset?ch=1&set=preset1` | `PUT /api/v1/channel/1/preset/preset1` |
| `GET /api/channel/preset?ch=1&rm=1` | `DELETE /api/v1/channel/1/preset/1` |
| `GET /api/channel/preset?ch=1&go=1` | `GET /api/v1/channel/1/preset/1/go` |
| `GET /api/channel/relay?ch=1&list` | `GET /api/v1/channel/1/relay` |
| `GET /api/channel/relay?ch=1&on=uuid` | `PUT /api/v1/channel/1/relay/uuid?state=on` |
| `GET /api/channel/relay?ch=1&off=uuid` | `PUT /api/v1/channel/1/relay/uuid?state=off` |
| `GET /api/channel/aux?ch=1&on=0` | `PUT /api/v1/channel/1/aux/0?state=on` |
| `GET /api/channel/reboot?ch=1` | `POST /api/v1/channel/1/reboot` |
| `POST /api/channel` | `POST /api/v1/channel` |
| `DELETE /api/channel/1` | `DELETE /api/v1/channel/1` |

### 2.7. 녹화 (Find)
| v0 | v1 |
|----|-----|
| `GET /api/find?what=recDays` | `GET /api/v1/recording/days` |
| `GET /api/find?what=recDays&ch=1` | `GET /api/v1/recording/days?ch=1` |
| `GET /api/find?what=recMinutes&...` | `GET /api/v1/recording/minutes?...` |

### 2.8. 이벤트
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=eventType` | `GET /api/v1/event/type` |
| `GET /api/enum?what=realtimeEvent` | `GET /api/v1/event/realtime` |
| `GET /api/find?what=eventLog` | `GET /api/v1/event/log` |
| `PUT /api/event/trigger` | `PUT /api/v1/event/trigger` |

### 2.9. LPR
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=lprSrc` | `GET /api/v1/lpr/source` |
| `GET /api/find?what=carNo` | `GET /api/v1/lpr/log` |
| `GET /api/find?what=carNo&keyword=12` | `GET /api/v1/lpr/log?keyword=12` |
| `GET /api/find?what=similarCarNo&keyword=1234` | `GET /api/v1/lpr/similar?keyword=1234` |

### 2.10. 객체
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=objectType` | `GET /api/v1/object/type` |
| `GET /api/enum?what=objectAttr&type=face` | `GET /api/v1/object/attr?type=face` |
| `GET /api/find?what=object` | `GET /api/v1/object/log` |

### 2.11. 얼굴 검색
| v0 | v1 |
|----|-----|
| `POST /api/searchFace` | `POST /api/v1/face/search` |
| `GET /api/searchFace?...` | `GET /api/v1/face/search?...` |

### 2.12. VOD (변경 없음)
| v0 | v1 |
|----|-----|
| `GET /api/vod` | `GET /api/v1/vod` |
| `GET /api/vod?ch=1&when=...` | `GET /api/v1/vod?ch=1&when=...` |

### 2.13. 비상호출
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=emergencyCall` | `GET /api/v1/emergency` |

### 2.14. Push (변경 없음)
| v0 | v1 |
|----|-----|
| `POST /api/push` | `POST /api/v1/push` |

### 2.15. WebSocket 이벤트 구독
| v0 | v1 |
|----|-----|
| `ws:///wsapi/subscribeEvents?topics=...` | `ws:///wsapi/v1/events?topics=...` |

### 2.16. WebSocket 데이터 내보내기
| v0 | v1 |
|----|-----|
| `ws:///wsapi/dataExport?ch=1&timeBegin=...&timeEnd=...` | `ws:///wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...` |

> **인증 변경**: v0는 `auth=base64(user:pass)` 쿼리 파라미터를 사용하지만, v1은 `token={JWT}` 또는 `apikey={key}` 쿼리 파라미터를 사용합니다.

---

## 4. 코드 마이그레이션 예제

### 4.1. JavaScript

**변경 전 (v0)**:
```javascript
// Get channels
fetch('/api/enum?what=channel')

// PTZ control
fetch('/api/channel/ptz?ch=1&home')

// System restart
fetch('/api/system?restart')
```

**변경 후 (v1)**:
```javascript
// Get channels
fetch('/api/v1/channel')

// PTZ control
fetch('/api/v1/channel/1/ptz?home')

// System restart
fetch('/api/v1/system/restart', {method: 'POST'})
```

### 4.2. Python

**변경 전 (v0)**:
```python
# Get channels
requests.get(f'{base}/api/enum', params={'what': 'channel'})

# PTZ control
requests.get(f'{base}/api/channel/ptz', params={'ch': 1, 'home': ''})

# System restart
requests.get(f'{base}/api/system', params={'restart': ''})
```

**변경 후 (v1)**:
```python
# Get channels
requests.get(f'{base}/api/v1/channel')

# PTZ control
requests.get(f'{base}/api/v1/channel/1/ptz', params={'home': ''})

# System restart
requests.post(f'{base}/api/v1/system/restart')
```

---

## 5. 주요 변경사항

1. **경로 기반 리소스**: 채널 ID가 URL 경로에 포함됨
   - v0: `/api/channel/ptz?ch=1`
   - v1: `/api/v1/channel/1/ptz`

2. **RESTful HTTP 메서드**: 상태 변경 작업에 적절한 HTTP 메서드 사용
   - v0: `GET /api/system?restart`
   - v1: `POST /api/v1/system/restart`

3. **리소스 지향 URL**: 리소스 중심의 URL 구조
   - v0: `/api/enum?what=channel`
   - v1: `/api/v1/channel`

4. **일관된 파라미터 이름**:
   - v0: `info=os`, `health=cpu`
   - v1: `item=os`, `item=cpu`

5. **응답 필드명 참고사항** (v0/v1 동일):
   - 채널 목록: `title` (채널명), `displayName` (표시명, `"CH{N}. {title}"` 형식)
   - VOD 응답: 스트림 URL은 `src` 필드 (예: `src.rtmp`, `src.flv`)
   - 이벤트 유형: `id` (유형 ID), `code` (하위 코드 배열)
   - 시스템 정보: `item=storage` 요청 시 응답 필드명은 `disk`

---

## 6. 인증 참고사항

v1 API는 모든 엔드포인트에서 **JWT Bearer Token** 및 **API Key** 인증을 지원합니다. v1 엔드포인트에서는 세션 쿠키를 지원하지 않습니다.

| 기존 v0 인증 | v1 권장 방식 |
|-------------|-------------|
| 세션 쿠키 | JWT 로그인 (`POST /api/v1/auth/login`) - 크레덴셜은 JSON body로 전송 |
| 외부 시스템 연동 | API Key (`X-API-Key` 헤더) - 로그인 불필요 |

---

## 7. v0 API 비활성화

v0 API는 deprecated 되었으며, 보안 강화를 위해 설정에서 비활성화할 수 있습니다. v0 API는 쿼리 스트링을 통한 인증 정보 전달 등 보안에 취약한 방식을 사용하므로, v1 마이그레이션이 완료된 환경에서는 비활성화를 권장합니다.

**비활성화 방법:**

웹 서버 설정에서 "레거시 API 활성화 (v0)" 체크박스를 해제합니다.

**비활성화 시 동작:**

v0 API 호출 시 404 에러가 반환됩니다:

```json
{
  "code": -1,
  "message": "Legacy API (v0) is disabled. Please use /api/v1/ endpoints."
}
```

**영향받는 엔드포인트:**

| 구분 | 엔드포인트 |
|------|-----------|
| REST API | `/api/auth`, `/api/info`, `/api/system`, `/api/enum`, `/api/find`, `/api/vod`, `/api/status`, `/api/channel/*`, `/api/push`, `/api/subscribeEvents`, `/api/searchFace` |
| WebSocket API | `/wsapi/subscribeEvents`, `/wsapi/dataExport` |

