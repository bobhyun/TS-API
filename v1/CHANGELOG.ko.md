# TS-API 변경이력

[English](CHANGELOG.md) | **한국어**

## v1.0.2

### v1 응답 URL 상대 경로화

**v1** API 응답의 URL 필드를 **상대 경로** (`/...`) 로 변경했습니다. **v0 (레거시) 엔드포인트는 기존과 동일하게 절대 URL** (`http://{host}/...`) 을 반환합니다 — 기존 연동 시스템의 하위 호환성을 위해 유지됩니다.

영향 받는 v1 응답 필드 (REST·WebSocket):
- `src` — `/wsapi/v1/export` 의 다운로드 링크
- `videoSrc` — LPR / 검색 / 차량 추적 결과의 watch URL
- `image`, `images[]` — 이벤트 알림, LPR / VA 검색 이미지 참조
- `faceImg`, `orgImg` — 얼굴 검색 결과

```json
// v1 응답
{
  "download": [
    {"src": "/download/task-uuid/CH01.mp4", "fileName": "CH01.mp4"}
  ]
}

// v0 응답 (레거시 — 변경 없음)
{
  "download": [
    {"src": "http://nvr.example.com/download/task-uuid/CH01.mp4", "fileName": "CH01.mp4"}
  ]
}
```

v0 절대 URL의 host는 **Canonical Host** 서버 설정(웹 관리자 → 서버 설정 → API)이 지정되어 있으면 그 값을 사용하고, 없으면 요청의 `X-Host` 헤더로 fallback 합니다.

**클라이언트 호환성 (v1)**:
- **브라우저 클라이언트**: 변경 불필요 — 상대 URL이 페이지 origin 에 자동 결합됩니다.
- **비-브라우저 클라이언트** (curl, Python `requests`, 모바일 앱, 서버 간 통신): fetch 전 base URL 을 결합해야 합니다:
  ```javascript
  const fullUrl = baseUrl + response.download[0].src;
  ```

### 변경 배경

이전의 절대 URL 은 서버가 받은 `Host:` 헤더를 그대로 포함했습니다. 요청이 `Host:` 를 다시 쓰는 리버스 프록시를 통과하면 잘못된 호스트가 URL 에 박혀, 클라이언트가 다운로드에 실패하는 경우가 발생했습니다 (호스트 인젝션 패턴). v1 에서 상대 경로로 전환해 이 문제를 차단하고, 향후 다중 NVR 그룹 라우팅 아키텍처와 정렬했습니다. v0 는 기존 레거시 연동 시스템이 코드 수정 없이 동작하도록 절대 URL 을 유지합니다.

### 라이브 스트림 URL 유지

`/api/v1/vod` (라이브 스트림) 응답 `src` 배열의 RTMP / WebSocket-FLV 스트림 URL 은 **절대 URL 유지** — 이 프로토콜들은 완전히 정규화된 URL 이 필요합니다.

### Breaking Changes

없음. v0 클라이언트는 기존과 동일하게 절대 URL 을 받습니다. 신규 v1 클라이언트는 상대 URL 을 받으므로 위 "클라이언트 호환성 (v1)" 항목 참고.

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
