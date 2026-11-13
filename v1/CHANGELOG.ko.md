# TS-API 변경이력

[English](CHANGELOG.md) | **한국어**

## v1.5.0

### 실시간 스트림 인증

`flv`·`websocket-flv`·`rtmp` 실시간 스트림을 인증합니다([13.1](tsapi-v1.ko.md#131-스트림-url)).
이전에는 이 스트림들이 인증 없이 재생되었습니다.

- `flv`·`websocket-flv`: URL 의 인증 매개변수 `?token=`(JWT), `?apikey=`(API Key), `?auth=`·`?login=`(base64 `id:pw`). 미디어 파일과 같습니다([3.4](tsapi-v1.ko.md#34-storage--미디어-파일-인증)). 쿠키와 `Authorization` 헤더로는 인증되지 않습니다.
- `rtmp`: URL 의 계정 정보 `rtmp://user:pass@host/...`, API Key 는 `rtmp://apikey:<키>@host/...`. Adobe RTMP 인증 방식으로 확인합니다.
  - 업그레이드 후 계정은 한 번 로그인해야 사용할 수 있습니다.
  - 이전에 발급한 API Key 는 RTMP 에 사용할 수 없으므로 새로 발급해야 합니다.
- `rtsp` 는 이전과 같이 Basic 인증을 사용합니다.

### 미디어 파일: `?auth=`·`?login=`

미디어 파일(`/storage`, `/event-storage`, `/download`)이 `?auth=`·`?login=` 을 항상 받습니다. 이전에는 v0 API 호환을 켠 경우에만 받았습니다.
실시간 스트림과 같은 규칙을 적용하기 위해 변경합니다. 비밀번호가 URL 에 포함되므로 `token` 또는 `apikey` 사용을 권장합니다.

### API Key 접속 주소 제한

API Key 의 허용 IP(`ipWhitelist`)를 요청을 보낸 클라이언트 주소로 확인합니다. 이전에는 서버 내부 중계 주소로 확인되어 허용 IP 가 의도대로 적용되지 않았습니다.

### 서버 식별자 `nodeId`

`GET /api/v1/info?nodeId` 가 서버 식별자(UUID)를 반환합니다([4](tsapi-v1.ko.md#4-서버-정보)). 여러 주소로 접속하는 클라이언트가 같은 서버인지 판별할 때 사용합니다.

- `remote` 권한을 가진 JWT 또는 API Key 가 필요합니다. 미인증은 `401`, 권한이 없으면 `403` 을 반환합니다.
- `?all` 은 인증된 요청에만 `nodeId` 를 포함합니다. 다른 항목의 인증 조건은 변경하지 않습니다.

### API Key 관리 권한

API Key 관리(`/api/v1/auth/apikey` 발급·목록·폐기)는 모든 권한을 가진 관리자 계정으로 로그인한 JWT 로만 사용할 수 있습니다([3.2](tsapi-v1.ko.md#32-api-key-권한-모델)).
이전에는 `settings` 권한을 가진 계정과 API Key 가 모든 권한의 키를 발급할 수 있었습니다. 유출된 키로 새 키를 발급할 수 없도록 변경합니다.

- API Key 로 요청하면 권한과 무관하게 `403 Forbidden` 을 반환합니다.
- API Key 의 권한은 사용할 때마다 발급한 계정의 현재 권한으로 제한됩니다. 계정이 사용 중지되거나 삭제되면 그 계정이 발급한 키는 사용할 수 없습니다.

### Breaking Changes

API Key 또는 관리자가 아닌 계정으로 API Key 를 관리하던 클라이언트는 `403 Forbidden` 을 받습니다. 관리자 계정으로 로그인하여 관리하십시오.

인증 없이 `flv`·`websocket-flv`·`rtmp` URL 을 재생하는 클라이언트는 재생되지 않습니다.
`flv`·`websocket-flv` 는 `GET /api/v1/vod` 가 반환한 URL 에 `?token=` 또는 `?apikey=` 를 덧붙이십시오.
`rtmp` 는 URL 에 계정 정보(`user:pass@` 또는 `apikey:<키>@`)를 포함하십시오.

## v1.4.0

### 로그인 시도 제한

비밀번호 인증을 무차별 대입으로부터 보호하기 위해 시도 횟수를 제한합니다([3.3. JWT 인증](tsapi-v1.ko.md#33-jwt-인증)).

- 실패하면 같은 접속 주소에서는 3초 동안 다시 시도할 수 없습니다.
- 1분 안에 3회 실패하면 그 주소의 비밀번호 인증을 1분 동안 차단합니다. 서버를 다시 시작해도 남은 시간만큼 유지됩니다.
- 그동안 받은 비밀번호 인증 요청은 `429 Too Many Requests` 와 `Retry-After`(남은 초)를 반환합니다.
- 토큰(JWT)과 API Key 인증에는 적용하지 않습니다.

로그인 실패 이벤트(`type` `1`, `code` `6`)의 `param` 에 접속 주소 `addr` 와, 차단이 시작된 경우 해제 시각
`lockedUntil` 이 추가됩니다. API 와 실시간 스트림의 로그인 실패도 기록됩니다.

### 사용 중지된 계정

사용 중지된 계정(사용자 속성의 **계정 사용 중지**)은 비밀번호가 맞아도 인증되지 않습니다(`401`). 이전에는 API 인증이 계정 상태와 무관하게 처리되었습니다.

## v1.3.0

### 차량 번호 수정

오인식된 번호를 한 건씩 수정할 수 있습니다. 모든 수정은 이력으로 기록됩니다.

- `POST /api/v1/lpr/log/{id}/plate` · `GET /api/v1/lpr/log/{id}/plate/history` — 인식 기록 한 건
- `POST /api/v1/parking/session/{id}/plate` · `GET /api/v1/parking/session/{id}/plate/history` —
  주차 세션 한 건의 대표 번호 (이미지별 판독 결과는 증거로 보존합니다)

수정 대상은 항상 `id` 한 건입니다. 일괄 수정, 번호 값으로 대상을 지정하는 수정, 세션 병합은 지원하지 않습니다.
목록 응답(`/lpr/log`, `/parking/session`)에는 `plateEdited` 필드가 포함되고, 수정된 항목에는
`originalPlateNo` 도 포함됩니다. `plateNo` 는 항상 현재 값입니다. 실시간 `LPR` 이벤트는 각
`plateNo` 와 함께 기록 `id` 를 전달합니다. 이 `id` 로 수신한 기록을 정확히 지정해 수정할 수 있습니다.

수정은 **제어(Control)**, 이력 조회는 **재생(Playback)** 권한이 필요합니다.

### 시스템 알림과 시스템 디스크 경고

현재 유효한 주의 사항을 전달하는 알림 채널을 추가했습니다. 알림은 발생·갱신·해제되며, 메모리에만
보관하므로 디스크가 가득 차도 동작합니다.

- `GET /api/v1/system/notices` — 현재 유효한 알림 목록
- 실시간 토픽 `notice` — 구독 직후 목록, 이후 `raised` / `updated` / `cleared`
- `message` 는 언어 코드별 객체입니다. `en-US` 는 항상 포함되고, 영어가 아닌 `lang` 으로 요청하면 해당 언어의
  번역문이 추가됩니다. 키는 서버가 결정한 언어 코드입니다(`lang=zh-HK` 이면 `zh-TW`)

첫 적용 대상은 *시스템 디스크*(제품이 데이터베이스와 로그를 저장하는 디스크, 보통 `C:`)입니다. 이 디스크가
가득 차면 녹화 디스크에 공간이 남아 있어도 새 녹화를 색인하지 못하고 인식 기록이 저장되지 않습니다.
이전에는 이 상태를 표시할 방법이 없었습니다.

- 알림 `kind: systemDisk` — 여유 1 GB 미만이면 `warning`, 200 MB 미만이거나 기록을 저장하지 못하면 `critical`.
- `GET /api/v1/system/health?item=systemDisk` — `drive`, `totalSpace`, `freeSpace`,
  `status` (`normal` / `low` / `critical`), `dataWriteFailed`. 기본 응답에도 포함됩니다.
- `systemEvent` 코드 `51` *System disk space is low*, `52` *System disk is full*,
  `53` *System disk space has been restored.* 로 단계 변화를 기록합니다. 디스크가 가득 차 이벤트를
  저장하지 못한 경우에도 구독자에게는 `id` 를 `-1` 로 하여 전달합니다.
- 기록을 저장하지 못해도 `LPR` 이벤트는 계속 전달됩니다. 이때 이벤트에는 `id` 와 `image` 가 없습니다.

### 방향이 있는 `LPR` 이벤트가 전달됩니다

주행 방향(`direction`)이 포함된 `LPR` 이벤트는 직렬화 도중 실패하여 v1·v0 구독자 모두에게
전달되지 않았습니다. `direction` 은 인식 지점에 주행 방향을 설정한 경우에 포함됩니다. 이제 `direction` 이 `"entry"` 또는
`"exit"` 로 포함되어 전달됩니다. 이벤트 형식은 [17.4](tsapi-v1.ko.md#174-이벤트-구독) 에 정리했습니다.

### 언어: 가장 가까운 언어와 바로잡은 코드

`lang` 은 가장 가까운 지원 언어로 결정됩니다([1.3. 언어](tsapi-v1.ko.md#13-언어-lang)). 이전에는
대소문자까지 정확히 일치하지 않으면 영어로 처리되었습니다. 이제 대소문자를 구분하지 않고(`ko-kr`),
언어만 지정하거나 다른 지역을 지정한 코드도 해당 언어로 결정되며(`ko` → `ko-KR`, `ar-SA` → `ar-AE`),
언어 파일이 여러 개인 언어는 기본 지역으로 결정됩니다(`zh-HK` → `zh-TW`, `pt` → `pt-BR`).

언어 파일 다섯 개에 다른 언어의 코드가 지정되어 있었습니다. 이 코드를 수정했으며, 포르투갈어는 두
언어로 분리했습니다.

| 언어 | 옛 코드 | 새 코드 |
|------|---------|---------|
| 키르기스어 | `ru-KG` | `ky-KG` |
| 라틴어 | `sr-Latn` | `la` |
| 세소토어 | `nso-ZA` | `st-ZA` |
| 스와힐리어 | `swc-CD` | `sw-KE` |
| 쿠르드어 (쿠르만지) | `ku-Arab-IR` | `kmr-Latn-TR` |
| 포르투갈어 (브라질) | `pt-PT` | `pt-BR` |
| 포르투갈어 (포르투갈) | — | `pt-PT` (신규) |

NVR 에 설정된 언어는 처음 시작할 때 한 번 새 코드로 변환합니다.
전체 코드 목록은 [부록 D](tsapi-v1.ko.md#d-지원-언어) 를 참조하십시오.

### 미출차 정리가 추적 상태도 버립니다

`POST /api/v1/parking/session/{id}/close` 는 해당 주차면·구역의 추적 상태도 함께 초기화합니다.
이전에는 종료한 세션이 같은 위치에서 곧바로 다시 열릴 수 있었습니다. 차량이 실제로 있으면 확정
절차를 다시 거쳐 새 세션으로 열립니다.

### 번호를 읽지 못한 건이 조회됩니다

`/lpr/log` 와 `unrecognized=true` 조회에서 번호를 인식하지 못한 건이 누락되었습니다. 이제 해당 건도
포함되며, `plateNo` 는 문서에 명시된 대로 `null` 입니다.

### 제어 명령을 동시에 보내도 응답합니다

같은 카메라에 PTZ 명령을 동시에 여러 개 보내면 일부 요청이 60초 후 `504` 로 응답하거나 NVR 이 종료될
수 있었습니다. 릴레이·보조 출력·프리셋·재부팅 명령에도 같은 문제가 있었습니다. 이제 이전 명령이
처리 중이면 최대 0.5초 대기한 후 실행하고, 그때까지 완료되지 않으면 즉시 실패로 응답합니다.

### WebSocket: JSON 이 아닌 메시지에 오류를 돌려줍니다

JSON 으로 해석할 수 없는 메시지는 응답 없이 무시되었습니다. 이제 문서에 명시된 대로
`{"type":"error","message":"invalid JSON"}` 을 반환합니다.

### Breaking Changes

요청에 포함된 옛 언어 코드는 새 코드로 변환하지 않습니다. 요청의 코드는 표준 의미로 해석합니다.
옛 코드를 보내는 클라이언트는 결과가 달라지므로 새 코드로 변경해야 합니다.

| 보낸 `lang` | 현재 결과 |
|-------------|-----------|
| `ru-KG` | 러시아어 (`ru-RU`) |
| `sr-Latn` | 세르비아어 (`sr-Cyrl-RS`) |
| `pt-PT` | 유럽 포르투갈어 — 브라질 문구는 `pt-BR` |
| `nso-ZA`, `swc-CD`, `ku-Arab-IR` | 번역하지 않음 (영어) |

## v1.2.0

### 주차 내역

`/api/v1/parking/session` 아래 4개 엔드포인트로 차량의 입·출차 이력을 제공합니다. **세션**은
차량의 존재가 확정되면 열리고 차량이 사라지면 닫히는 한 건의 기록입니다. 세션은 주차면·출입구·
주차 금지(체류) 구역에서 생성됩니다.

- `GET /api/v1/parking/session` — 목록을 반환합니다. 페이징과 요약을 제공하며, 시간·번호·주차장·
  영역·채널·종류·출차 근거·주차 시간·미정산 시간으로 필터링할 수 있습니다
- `GET /api/v1/parking/session/{id}` — 한 건을 정산 이력과 함께 반환합니다
- `POST /api/v1/parking/session/{id}/payment` — 정산이 이뤄졌음을 기록합니다
- `POST /api/v1/parking/session/{id}/close` — 관측으로 종료되지 않는 세션을 수동으로 종료합니다

NVR 은 **이력**만 제공합니다. 금액·요금표·할인 규칙은 정산 앱이 관리합니다. NVR 이 저장하는 정보는
정산 **시각**과 호출자의 참조 값뿐입니다.

주차 내역 조회 라이선스가 필요합니다(없으면 `403`). 조회는 **재생(Playback)**, 두 `POST` 는
**제어(Control)** 권한이 필요합니다.

`GET /api/v1/info?license` 의 `license.extension` 에 `parkingHistory` 토큰이 포함됩니다.
클라이언트는 `403` 응답을 확인하지 않고도 이 값으로 내역 화면의 표시 여부를 결정할 수 있습니다.

### 출차 시각은 근거와 함께 옵니다

닫힌 세션은 출차 시각과 함께 그 시각을 **결정한 근거**를 제공합니다. 측정값은 `observed` 하나뿐이고
나머지는 추정값입니다. 추정값은 근거별로 오차 방향이 다르므로, 정산 앱은 근거에 맞게 출차 시각을
처리할 수 있습니다.

| `outKind` | `outTimeMeans` | 시각의 의미 |
|-----------|----------------|-------------------|
| `observed` | `exitedAt` | 출차를 관측했습니다 |
| `paid` | `paidAt` | 마지막 정산 시각입니다. 보통 정산 직후 출차합니다 |
| `covered` | `discoveredAt` | 가려져 있던 차량이 없어진 것을 확인한 시점입니다 |
| `lastSeen` | `lastSeenAt` | 관측이 끊겼습니다(카메라 접속 종료·프로그램 종료). 하한입니다 |
| `manual` | `closedByOperator` | 운영자가 종료한 시각이며, 관측된 출차가 아닙니다 |
| `unknown` | `unknown` | 이 규칙이 적용되기 전의 데이터입니다 |

입차 시각도 같은 방식으로 `inKind` · `inTimeMeans` 를 제공합니다. 관측을 시작했을 때 이미 차량이
있었으면 `firstSeen` 이며, 이 시각은 실제 입차 시각의 **상한**입니다(출차와 오차 방향이 반대입니다).
출차 근거와 달리 입차 근거는 **열린 세션에도** 포함됩니다.

### 기존 주차 엔드포인트는 그대로입니다

`/api/v1/parking/lot`, `/lot/status`, `/spot`, `/spot/status` 는 변경되지 않았습니다. 세션 객체는
주차면 API 와 **같은 필드 이름**(`id`, `name`, `chid`)을 사용하되 `src` 안에 둡니다. 세션의 출처가
주차면에 한정되지 않기 때문입니다. 출처의 종류는 `kind` 로 구분합니다.

## v1.1.0

### 새 실시간 프로토콜: `websocket-flv`

`GET /api/v1/vod` 응답에서 `flv` 를 제공하던 모든 채널에 `websocket-flv` 항목이
함께 포함됩니다. 같은 스트림, 같은 엔드포인트이며 **전송 프레이밍만 다릅니다**.
`flv` 는 HTTP chunked 전송을 사용하고, `websocket-flv` 는 연결을 업그레이드해 FLV 태그
하나를 WebSocket 바이너리 프레임 하나로 전송합니다.

- URL 스킴은 요청 스킴을 따릅니다: `http` → `ws://`, `https` → `wss://`
- `GET /api/v1/vod?protocol=websocket-flv` 로 필터링할 수 있습니다
- 프록시나 클라이언트가 오래 열린 chunked 응답을 제대로 처리하지 못할 때 사용하십시오

### 새 실시간 프로토콜: `rtsp`

RTSP 재송출 기능이 포함된 서버에서는 `GET /api/v1/vod` 응답에 채널마다 `rtsp` 항목이
함께 포함됩니다. 서버가 같은 RTMP publish 스트림을 RTP 로 재송출하므로 재인코딩은 없습니다.
채널이 publish 중이 아니면 스트림이 존재하지 않습니다(이 상태의 `DESCRIBE` 는 `404`).

- URL: `rtsp://[user:pass@]host[:554]/live/ch<N>{main|sub}` — 채널 번호는 1부터입니다
- **TCP interleaved 전용입니다.** UDP `SETUP` 에는 `461 Unsupported Transport` 로
  응답하므로, 기본값이 UDP 인 클라이언트에는 TCP 를 지정해야 합니다:
  `vlc --rtsp-tcp`, `ffplay -rtsp_transport tcp`
- Basic 인증은 필수이며 비활성화할 수 없습니다. 자격 증명은 URL 에 포함하고 예약 문자는 퍼센트
  인코딩하십시오(`@` 는 `%40`)
- 영상은 **H.264 전용**입니다
- `GET /api/v1/vod?protocol=rtsp` 로 필터링할 수 있습니다
- 브라우저는 RTSP 를 재생할 수 없습니다. 외부 플레이어·VMS 연동·FFmpeg 기반
  파이프라인에 사용합니다

### 새 스토리지 상태: `-9` (스토리지 쓰기 정지)

녹화 스토리지의 쓰기가 녹화 속도를 따라가지 못하는 상태를 이벤트로 전달합니다. 응답하지 않은
시간과 그 구간에 손실된 프레임 수를 함께 전달합니다. 이전에는 결과인
`"녹화 프레임 누락"` 이벤트만 있었고, 원인은 기록되지 않았습니다.

이벤트 발생 조건은 두 가지입니다. 디스크 I/O 지연이 반복되면(1시간 관측 창 안에 10초 초과 호출 3건
이상) **사건 행** 이 열리고, 장애가 지속되는 동안 갱신됩니다. 완전한 정지(쓸 데이터가 대기 중인데
한 바이트도 쓰지 못한 경우)는 정지가 끝난 뒤 한 번만 기록합니다.

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

- 기존 `"저장 장치 오류"` 이벤트의 `param.statusCode` 에 새 값이 추가되었습니다. 새 이벤트
  `type` · `code` 는 추가되지 않으므로 기존 필터·구독에는 영향이 없습니다.
- 해당 이벤트의 `param` 에 `stalledSec`, `stallCount`, `chid`, `ongoing` 과
  손실 요약(`lostSec`, `channels`, `channelList`, `droppedFrames`)이 추가됩니다.
  손실 요약은 사건이 열린 시점부터 집계합니다.
- **영상 손실이 없으면 손실 요약 키는 포함되지 않습니다.** 쓰기 큐가 정지를 흡수한
  정상 상태입니다. 키가 없으면 데이터 누락이 아니라 "손실 없음" 으로 처리하십시오.
  기본값 0 을 채워 손실 0 으로 보고하지 마십시오.
- `lostSec` 은 실제로 손실된 영상 구간의 합계이며, 사건이 지속된 시간이 아닙니다.
  두 시간 동안 지속된 사건의 손실이 3분일 수 있습니다.
- 사건 행은 장애가 끝난 후가 아니라 조건을 만족하는 즉시 열리므로, 문제가 진행 중일 때
  조회할 수 있습니다. 사건이 닫힐 때까지 `data[].timeRange` 가 확장됩니다. 같은
  `data[].id` 를 나중에 다시 조회하면 더 넓은 구간이 반환됩니다.
- `param.chid` 는 다른 모든 이벤트 payload 와 같이 **0부터 시작** 합니다.
  `data[].chid` 는 기존과 같이 1부터 시작합니다.
- `9.3. 이벤트 로그` 에 `data[].param` 과 `statusCode` 표 전체를 문서화했습니다(그동안
  문서에 없던 `-8`, 스토리지 정리 중단 포함).

### `"녹화 프레임 누락"` 이 채널별이 아니라 사건별 한 건이 됩니다

이전에는 스토리지 정체 하나에 대해 채널 × 집계 구간마다 이벤트가 기록되었습니다. 144채널
서버에서 2시간 30분 동안 지속된 사건 하나가 1,800건이 넘는 행을 만들어 문제의 전체 양상을
파악하기 어려웠습니다. 이제 이 행들을 사건 한 건으로 통합합니다.

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
- 프레임 누락 사이의 간격이 60초 이내인 구간을 한 사건으로 처리합니다. `-9` 와 마찬가지로 행은
  즉시 열리고, 닫힐 때까지 `data[].timeRange` 와 `param.period` 가 함께 늘어납니다.
- `param` 필드 — 제거: `windowSec`, 추가: `period`, `channels`, `channelList`,
  `ongoing`. `droppedFrames` 는 의미는 같지만 이제 사건 전체·전 채널 합계입니다.
- `param.channelList` 의 값은 `param.chid` 와 같이 **0부터 시작** 합니다.

### `"녹화 누락"` payload 문서화

이벤트 자체는 변경되지 않았으며, 그동안 문서화되지 않았던 `param` 을 정리했습니다.
`9.3. 이벤트 로그` 에 `secs`, `streamFps`, `storage`, `freeMB`, `anchorAge`, `queuePct`
를 정리했습니다. 이 값으로 스토리지 문제와 스트림 문제를 구분할 수 있습니다.

### Breaking Changes

아래 항목을 읽는 클라이언트만 수정하면 됩니다.

- `"녹화 프레임 누락"` 의 `data[].chid` 를 읽는 경우 → 이제 `null` 입니다.
  `param.channelList`(0부터 시작) 또는 `param.channels` 를 쓰십시오.
- 그 이벤트의 `param.windowSec` 을 읽는 경우 → `param.period` 를 쓰십시오. 집계 구간이
  아니라 실제 누락 구간입니다.
- 이벤트 건수로 심각도를 판단하는 경우 → 한 행이 여러 채널과 긴 구간을 포함합니다.
  `param.channels` 와 `param.droppedFrames` 를 사용하십시오.
- 사건이 열려 있는 동안 `data[].id` 로 다시 조회하면 `timeRange` 와 `param` 이 갱신된
  값으로 반환됩니다. `param.ongoing` 이 있는 행은 아직 확정되지 않은 것으로 처리하십시오.

기존에 저장된 이벤트는 이전 payload 를 그대로 유지하므로, 클라이언트는 두 형식을 모두
처리해야 합니다.


---

## v1.0.3

### 녹화 이벤트 이름 변경: "디스크 쓰기 지연" → "녹화 프레임 누락"

녹화 이벤트 1건의 `codeName` 과 `param` 필드가 변경되었습니다. 이벤트 `type` · `code` 정수값은 **불변**이라, `code` 기준 이벤트 필터·WebSocket/SSE 구독은 그대로 동작합니다.

- `codeName`: `"디스크 쓰기 지연"` → `"녹화 프레임 누락"` (영문 `"Disk write delay"` → `"Recording frame drop"`)
- 의미: 이제 **누락된 녹화 프레임**(녹화가 밀림)을 채널별로 보고합니다.
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

**배경**: 기존 절대 URL 은 요청의 `Host:` 헤더를 그대로 사용하므로, 리버스 프록시가 `Host:` 를 재작성하면 URL 에 잘못된 호스트가 포함되었습니다. 이 변경은 향후 다중 NVR 그룹 라우팅 방식과도 일치합니다.

**클라이언트 호환성**:

- 브라우저: 변경 불필요 — 상대 URL 이 페이지 origin 에 자동 결합됩니다.
- 비-브라우저 (curl, 모바일, 서버 간 통신): 요청 전에 base URL 을 결합해야 합니다.

**예외**:

- v0 절대 URL 의 host 는 **Canonical Host** (웹 관리자 → 서버 설정 → API) 값을 사용하고, 값이 없으면 `X-Host` 헤더를 사용합니다.
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
