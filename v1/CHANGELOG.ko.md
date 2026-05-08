# TS-API 변경이력

[English](CHANGELOG.md) | **한국어**

## v1.0.2

### 응답 URL 상대 경로화

API 응답의 URL 필드를 절대 URL (`http://host/...`) 에서 **상대 경로** (`/...`) 로 변경했습니다.

REST·WebSocket 양쪽에 적용되는 영향 받은 필드:
- `src` — `/wsapi/v1/export` (및 v0 `/wsapi/dataExport`) 의 다운로드 링크
- `videoSrc` — LPR / 검색 / 차량 추적 결과의 watch URL
- `image`, `images[]` — 이벤트 알림, LPR / VA 검색 이미지 참조
- `faceImg`, `orgImg` — 얼굴 검색 결과

```json
{
  "download": [
    {"src": "/download/task-uuid/CH01.mp4", "fileName": "CH01.mp4"}
  ]
}
```

**클라이언트 호환성**:
- **브라우저 클라이언트**: 변경 불필요 — 상대 URL이 페이지 origin 에 자동 결합됩니다.
- **비-브라우저 클라이언트** (curl, Python `requests`, 모바일 앱, 서버 간 통신): fetch 전 base URL 을 결합해야 합니다:
  ```javascript
  const fullUrl = baseUrl + response.download[0].src;
  ```

### 변경 배경

이전의 절대 URL 은 서버가 받은 `Host:` 헤더를 그대로 포함했습니다. 요청이 `Host:` 를 다시 쓰는 리버스 프록시를 통과하면 잘못된 호스트가 URL 에 박혀, 클라이언트가 다운로드에 실패하는 경우가 발생했습니다 (호스트 인젝션 패턴). 상대 경로로 전환해 이 문제를 차단하고, 향후 다중 NVR 그룹 라우팅 아키텍처와 정렬했습니다.

### 라이브 스트림 URL 유지

`/api/v1/vod` (라이브 스트림) 응답 `src` 배열의 RTMP / HLS / DASH / WebSocket-FLV 스트림 URL 은 **절대 URL 유지** — 이 프로토콜들은 완전히 정규화된 URL 이 필요합니다.

### Breaking Changes

브라우저 클라이언트는 영향 없음. `response.src` 를 base URL 결합 없이 직접 사용하던 비-브라우저 클라이언트는 위 "클라이언트 호환성" 항목 참고하여 코드 수정 필요.

---

## v1.0.1

### LPR 이벤트: 번호판 배열 형식 (WebSocket)

한 프레임에서 여러 번호판이 인식된 경우, 개별 이벤트 대신 `plates` 배열로 하나의 이벤트에 통합 전송합니다.

```json
{
  "topic": "LPR",
  "channel": 1,
  "image": "/storage/lpr/...",
  "plates": [
    {"plateNo":"12가3456","score":95,"srcCode":"A01",...},
    {"plateNo":"34나5678","score":88,"srcCode":"A02",...}
  ]
}
```

**클라이언트 호환 처리** — 구/신 형식 모두 대응:
```javascript
const plates = data.plates || [data];
plates.forEach(p => console.log(p.plateNo, p.score));
```

> **참고**: 이 형식은 **v1 WebSocket** (`/wsapi/v1/events`)에만 적용됩니다. v0 WebSocket (`/wsapi/subscribeEvents`)은 기존 단일 plate 형식을 유지합니다.

### 주차면 이벤트 개선 (WebSocket)

- **차량 정보 항상 포함**: 주차장 등록 여부와 관계없이 번호판 인식 데이터가 있으면 `vehicle` 필드를 전송합니다.
- **중복 이벤트 수정**: 한 번의 인식에서 `parkingSpot` 이벤트가 두 번 발생하던 문제를 수정하여 하나의 이벤트로 통합합니다.

### Breaking Changes

없음. 모든 변경사항은 하위 호환됩니다.

---

## v1.0.0

최초 릴리스.
