# TS-API 변경이력

[English](CHANGELOG.md) | **한국어**

## v1.1.0

### 새 실시간 프로토콜: `websocket-flv`

`GET /api/v1/vod` 응답에서 `flv` 를 제공하던 모든 채널에 `websocket-flv` 항목이
함께 나옵니다. 같은 스트림, 같은 엔드포인트이고 **전송 프레이밍만 다릅니다** —
`flv` 는 HTTP chunked 전송을 쓰고, `websocket-flv` 는 연결을 업그레이드해 FLV 태그
하나를 WebSocket 바이너리 프레임 하나로 보냅니다.

- URL 스킴은 요청 스킴을 따릅니다: `http` → `ws://`, `https` → `wss://`
- `GET /api/v1/vod?protocol=websocket-flv` 로 필터링할 수 있습니다
- 프록시나 클라이언트가 오래 열린 chunked 응답을 제대로 처리하지 못할 때 쓰십시오

### 새 실시간 프로토콜: `rtsp`

RTSP 재송출이 포함된 서버에서는 `GET /api/v1/vod` 응답에 채널마다 `rtsp` 항목이
함께 나옵니다. 같은 RTMP publish 를 서버가 RTP 로 다시 내보내는 것이라 재인코딩이
없고, 채널이 publish 중이 아니면 스트림 자체가 없습니다(그 상태의 `DESCRIBE` 는
`404`).

- URL: `rtsp://[user:pass@]host[:554]/live/ch<N>{main|sub}` — 채널 번호는 1부터입니다
- **TCP interleaved 전용입니다.** UDP `SETUP` 에는 `461 Unsupported Transport` 로
  답하므로, 기본값이 UDP 인 클라이언트에는 TCP 를 지정해야 합니다:
  `vlc --rtsp-tcp`, `ffplay -rtsp_transport tcp`
- Basic 인증이 필수이고 끌 수 없습니다. 자격증명을 URL 에 넣고 예약 문자는 퍼센트
  인코딩하십시오(`@` 는 `%40`)
- 영상은 **H.264 전용**입니다
- `GET /api/v1/vod?protocol=rtsp` 로 필터링할 수 있습니다
- 브라우저는 RTSP 를 재생할 수 없습니다 — 외부 플레이어·VMS 연동·FFmpeg 기반
  파이프라인용입니다

### 새 스토리지 상태: `-9` (스토리지 쓰기 정지)

녹화 스토리지가 따라오지 못하는 상태를 이벤트로 알립니다. 얼마 동안 응답하지 않았는지와
그 구간에 잃은 프레임 수를 함께 보고합니다. 지금까지는 *결과*, 즉
`"녹화 프레임 누락"` 이벤트만 있었고 그 원인은 어디에도 남지 않았습니다.

발화 조건은 둘입니다. 디스크 I/O 지연이 반복되면(1시간 관측 창 안에 10초 초과 호출 3건
이상) **사건 행** 이 열려 장애가 지속되는 동안 갱신됩니다. 완전한 정지 — 쓸 데이터가
밀려 있는데 한 바이트도 못 쓴 경우 — 는 끝난 뒤 한 번만 냅니다.

```json
{
  "storagePath": "G:\\recData",
  "statusCode": -9,
  "stalledSec": 67,
  "stallCount": 19,
  "chid": 3,
  "lostSec": 200,
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

- 기존 `"저장 장치 오류"` 이벤트의 `param.statusCode` 에 값이 추가된 것입니다. 이벤트
  `type` · `code` 는 새로 생기지 않으므로 기존 필터·구독은 영향받지 않습니다.
- 해당 이벤트의 `param` 에 `stalledSec`, `stallCount`, `chid`, `ongoing` 과
  손실 요약(`lostSec`, `channels`, `channelList`, `droppedFrames`)이 추가됩니다.
  손실 요약은 사건이 열린 시점부터 집계합니다.
- **영상 손실이 없으면 손실 요약 키가 실리지 않습니다.** 쓰기 큐가 정지를 흡수한
  정상적인 결과입니다. 값이 빠진 것으로 보고 0 으로 채워 "손실 0" 을 보고하지
  마십시오.
- `lostSec` 은 실제로 빈 영상의 합이지 그 일이 걸쳐 있던 시간대가 아닙니다.
  두 시간짜리 사건에서 손실은 3분뿐일 수 있습니다.
- 사건 행은 장애가 지나간 뒤가 아니라 조건을 만족하는 즉시 열리므로, 문제가 진행 중일 때
  볼 수 있습니다. 사건이 닫힐 때까지 `data[].timeRange` 가 늘어납니다 — 같은
  `data[].id` 를 나중에 다시 조회하면 더 넓은 구간이 옵니다.
- `param.chid` 는 다른 모든 이벤트 payload 와 같이 **0부터 시작** 합니다.
  `data[].chid` 는 1부터 그대로입니다.
- `9.3. 이벤트 로그` 에 `data[].param` 과 `statusCode` 표 전체를 문서화했습니다(그동안
  문서에 없던 `-8`, 스토리지 정리 중단 포함).

### `"녹화 프레임 누락"` 이 채널별이 아니라 사건별 한 건이 됩니다

지금까지는 스토리지 정체 하나가 채널 × 집계 구간마다 이벤트를 냈습니다. 144채널 서버의
2시간 30분짜리 사건 하나가 1,800건이 넘는 행을 만들어 문제의 모양이 오히려 묻혔습니다.
이 행들을 사건 한 건으로 모읍니다.

```json
{
  "period": ["2026-08-31T19:36:41", "2026-08-31T20:22:30"],
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

- 이 이벤트의 `data[].chid` 는 이제 `null` 입니다. 영향받은 채널은
  `param.channelList` 에, 개수는 `param.channels` 에 있습니다.
- 드롭 사이 간격이 60초를 넘지 않는 구간을 한 사건으로 봅니다. `-9` 와 마찬가지로 행은
  즉시 열리고, 닫힐 때까지 `data[].timeRange` 와 `param.period` 가 함께 늘어납니다.
- `param` 필드 — 제거: `windowSec`, 추가: `period`, `channels`, `channelList`,
  `ongoing`. `droppedFrames` 는 의미는 같지만 이제 사건 전체·전 채널 합계입니다.
- `param.channelList` 의 값은 `param.chid` 와 같이 **0부터 시작** 합니다.

### `"녹화 누락"` payload 문서화

이벤트 자체는 바뀌지 않았고, `param` 이 그동안 문서에 없었을 뿐입니다.
`9.3. 이벤트 로그` 에 `secs`, `streamFps`, `storage`, `freeMB`, `anchorAge`, `queuePct`
를 정리했습니다. 이 값들이 스토리지 문제와 스트림 문제를 가릅니다.

### Breaking Changes

아래를 읽는 클라이언트만 손보면 됩니다.

- `"녹화 프레임 누락"` 의 `data[].chid` 를 읽는 경우 → 이제 `null` 입니다.
  `param.channelList`(0부터 시작) 또는 `param.channels` 를 쓰십시오.
- 그 이벤트의 `param.windowSec` 을 읽는 경우 → `param.period` 를 쓰십시오. 집계 구간이
  아니라 실제 누락 구간입니다.
- 이벤트 건수로 심각도를 가늠하는 경우 → 한 행이 여러 채널과 긴 구간을 덮습니다.
  `param.channels` 와 `param.droppedFrames` 를 보십시오.
- 사건이 열려 있는 동안 `data[].id` 로 다시 조회하면 `timeRange` 와 `param` 이 갱신된
  값으로 옵니다. `param.ongoing` 이 있는 행은 아직 확정 전으로 다루십시오.

기존에 저장된 이벤트는 예전 payload 를 그대로 갖고 있으므로, 읽는 쪽이 양쪽을 모두
견뎌야 합니다.


---

## v1.0.3

### 녹화 이벤트 이름 변경: "디스크 쓰기 지연" → "녹화 프레임 누락"

녹화 이벤트 1건의 `codeName` 과 `param` 필드가 변경되었습니다. 이벤트 `type` · `code` 정수값은 **불변**이라, `code` 기준 이벤트 필터·WebSocket/SSE 구독은 그대로 동작합니다.

- `codeName`: `"디스크 쓰기 지연"` → `"녹화 프레임 누락"` (영문 `"Disk write delay"` → `"Recording frame drop"`)
- 의미: 이제 **누락된 녹화 프레임**(녹화가 밀림)을 채널별로 알립니다.
- `param` 필드:
  - 제거: `latencyMs`, `function`, `storagePath`, `videoFile`
  - 추가: `droppedFrames`(누락 프레임 수), `windowSec`(집계 구간 초); `chid` 유지

### Breaking Changes

이 이벤트에 한해 `codeName` 과 `param` 이 변경됨 — 클라이언트가 이를 읽는 경우에**만** 대응 필요:

- `codeName` 문자열 매칭 → `"Recording frame drop"` 사용, 또는 `code` 정수 매칭으로 전환.
- `param.latencyMs` / `param.function` 파싱 → `param.droppedFrames` / `param.windowSec` 사용. 기존 저장된 이벤트는 옛 payload 유지.

---

## v1.0.2

### v1 응답 URL 상대 경로화

**v1** 응답의 URL 필드를 **상대 경로** (`/...`) 로 변경했습니다. **v0 엔드포인트는 절대 URL** (`http://{host}/...`) 을 유지합니다 (하위 호환).

영향 필드: `src`, `videoSrc`, `image`, `images[]`, `faceImg`, `orgImg`.

**배경**: 기존 절대 URL 은 요청의 `Host:` 헤더를 그대로 사용해서, 리버스 프록시가 `Host:` 를 재작성하면 잘못된 호스트가 URL 에 박혔습니다. 향후 다중 NVR 그룹 라우팅과도 정렬됩니다.

**클라이언트 호환성**:

- 브라우저: 변경 불필요 — 상대 URL 이 페이지 origin 에 자동 결합됩니다.
- 비-브라우저 (curl, 모바일, 서버 간 통신): fetch 전 base URL 을 결합해야 합니다.

**예외**:

- v0 절대 URL 의 host 는 **Canonical Host** (웹 관리자 → 서버 설정 → API) 값을 사용하고, 없으면 `X-Host` 헤더로 fallback.
- `/api/v1/vod` 라이브 스트림 URL (RTMP / WebSocket-FLV) 은 절대 URL 유지.

### Breaking Changes

없음.

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
plates.forEach((p) => console.log(p.plateNo, p.score));
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
