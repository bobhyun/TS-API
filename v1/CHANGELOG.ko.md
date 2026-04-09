# TS-API 변경이력

[English](CHANGELOG.md) | **한국어**

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
