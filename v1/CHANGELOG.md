# TS-API Changelog

**English** | [한국어](CHANGELOG.ko.md)

## v1.3.0

### Vehicle number correction

A misread plate can be corrected one record at a time. Every correction is kept in a history.

- `POST /api/v1/lpr/log/{id}/plate` · `GET /api/v1/lpr/log/{id}/plate/history` — one recognition record
- `POST /api/v1/parking/session/{id}/plate` · `GET /api/v1/parking/session/{id}/plate/history` — the
  representative plate of one parking session (per-shot readings stay as evidence)

The target is always one `id`. Bulk correction, correction by plate value and session merging
are not supported. List responses (`/lpr/log`, `/parking/session`) now carry
`plateEdited` and, for corrected items, `originalPlateNo`; `plateNo` is always the current
value. Realtime `LPR` events now carry the record `id` next to each `plateNo`, so a client can
correct exactly the record it received.

Correcting a plate requires **Control** permission. Reading the history requires **Playback**.

### System notices and the system disk warning

A new notice channel reports conditions that are currently in effect. Notices are raised, updated
and cleared, and are kept in memory so the channel works even when the disk is full:

- `GET /api/v1/system/notices` — the notices currently in effect
- `notice` realtime topic — the list on subscribe, then `raised` / `updated` / `cleared`
- `message` is an object by language code — `en-US` always, plus the translation when `lang` is not
  English, keyed by the code the server resolved it to (`lang=zh-HK` adds `zh-TW`)

Its first use is the *system disk* — the disk where the product keeps its database and logs
(normally `C:`). When it fills up, recordings can no longer be indexed and recognition records are
not saved, even if the recording disks still have free space. Previously, no warning was given.

- Notice `kind: systemDisk` — `warning` under 1 GB free, `critical` under 200 MB or when a record
  could not be written.
- `GET /api/v1/system/health?item=systemDisk` — `drive`, `totalSpace`, `freeSpace`,
  `status` (`normal` / `low` / `critical`) and `dataWriteFailed`. Included in the default response.
- `systemEvent` codes `51` *System disk space is low*, `52` *System disk is full*,
  `53` *System disk space has been restored.* record each change of level. If the disk is too
  full to store the event, the event is still sent to subscribers with `id` `-1`.
- `LPR` events are still delivered when a record cannot be saved. Such an event has no `id` and
  no `image`.

### `LPR` events with a direction are delivered

An `LPR` event whose plate carried a driving direction (`direction`, set when the recognition
point has a driving direction) failed during encoding and was not sent to v1 or v0
subscribers. It is now delivered, with `direction` `"entry"` or `"exit"`. The
event format is now documented in [17.4](tsapi-v1.md#174-event-subscription).

### Language: closest match and corrected codes

`lang` now resolves to the closest supported language ([1.3. Language](tsapi-v1.md#13-language-lang)).
Previously, a code that was not an exact, case-sensitive match fell back to English. Now case is
ignored (`ko-kr`), a code with only the language or another region finds its language
(`ko` → `ko-KR`, `ar-SA` → `ar-AE`), and languages with several files have a default region
(`zh-HK` → `zh-TW`, `pt` → `pt-BR`).

Five language files used the code of a different language. Their codes are corrected,
and Portuguese is now two languages:

| Language | Old code | New code |
|----------|----------|----------|
| Kyrgyz | `ru-KG` | `ky-KG` |
| Latin | `sr-Latn` | `la` |
| Sesotho | `nso-ZA` | `st-ZA` |
| Swahili | `swc-CD` | `sw-KE` |
| Kurdish (Kurmanji) | `ku-Arab-IR` | `kmr-Latn-TR` |
| Portuguese (Brazil) | `pt-PT` | `pt-BR` |
| Portuguese (Portugal) | — | `pt-PT` (new) |

The language configured on the NVR is migrated to the new code once, on the first start.
[Appendix D](tsapi-v1.md#d-supported-languages) lists every code.

### No-exit cleanup also drops the tracking state

`POST /api/v1/parking/session/{id}/close` now also clears the NVR's tracking state for that
spot or zone. Previously, a closed session could be reopened immediately for the same spot.
A vehicle that is still present is confirmed again and gets a new session.

### Unrecognized reads are returned

`/lpr/log` and `unrecognized=true` queries omitted reads whose plate could not be recognized. They
are now returned, with `plateNo` set to `null` as documented.

### Concurrent control commands get a response

Sending several PTZ commands to the same camera at once could cause some requests to return `504`
after 60 seconds, or cause the NVR to terminate. Relay, aux output, preset and reboot commands
were affected in the same way. A command sent while another is in progress now waits up to
0.5 seconds for it to finish, and fails immediately if it is still running.

### WebSocket: non-JSON messages get an error

A message that could not be parsed as JSON was discarded without a response. It now receives
`{"type":"error","message":"invalid JSON"}`, as documented.

### Breaking Changes

Old language codes are not mapped to the corrected ones. A request is interpreted by the
code's standard meaning, so a client that sends an old code gets a different result and must
switch to the new code:

| `lang` sent | Result now |
|-------------|------------|
| `ru-KG` | Russian (`ru-RU`) |
| `sr-Latn` | Serbian (`sr-Cyrl-RS`) |
| `pt-PT` | European Portuguese — the Brazilian text is `pt-BR` |
| `nso-ZA`, `swc-CD`, `ku-Arab-IR` | Not translated (English) |

## v1.2.0

### Parking session history

Four endpoints under `/api/v1/parking/session` provide the history of vehicles parking and
leaving. A *session* opens when a vehicle is confirmed present and closes when it is no longer
present. Sessions are recorded for parking spots, entrance/exit gates and no-parking (dwell) zones.

- `GET /api/v1/parking/session` — list, with paging, a summary block and filters for time,
  plate, lot, source, channel, kind, exit basis, stay duration and unpaid time
- `GET /api/v1/parking/session/{id}` — one session with its payment history
- `POST /api/v1/parking/session/{id}/payment` — record that a payment was settled
- `POST /api/v1/parking/session/{id}/close` — close a session that observation cannot end

The NVR provides only the history. Amounts, tariffs and discount rules are handled by the
billing app.
Only the payment **time** and the caller's reference are stored.

These endpoints require the parking history license and return `403` without it. Reading
requires **Playback** permission; the two `POST` endpoints require **Control**.

`GET /api/v1/info?license` reports that license as the `parkingHistory` token in
`license.extension`, so a client can show or hide its history UI without probing for `403`.

### Exit time carries its basis

A closed session reports **how** its exit time was determined, in addition to the time
itself. Only `observed` is a measurement. The others are estimates whose errors lie in
different directions, so a billing app can handle each one accordingly.

| `outKind` | `outTimeMeans` | What the exit time is |
|-----------|----------------|-----------------------|
| `observed` | `exitedAt` | The exit was seen |
| `paid` | `paidAt` | Last payment time — vehicles usually leave right after paying |
| `covered` | `discoveredAt` | The view was blocked; this is when the vehicle was found gone |
| `lastSeen` | `lastSeenAt` | Observation ended (camera disconnected, program exited); a lower bound |
| `manual` | `closedByOperator` | An operator closed it — an action, not an observed exit |
| `unknown` | `unknown` | Pre-dates this rule |

The entry time carries the same kind of basis as `inKind` · `inTimeMeans`. If the vehicle
was already present when observation started, the basis is `firstSeen`, and the timestamp is
an **upper bound** on the actual entry time. Its error lies in the opposite direction from
the exit basis. Unlike the exit basis, the entry basis is also present on **open sessions**.

### Existing parking endpoints unchanged

`/api/v1/parking/lot`, `/lot/status`, `/spot` and `/spot/status` are unchanged. Session
objects use the same leaf names as the spot API (`id`, `name`, `chid`), nested under `src`
because a session's source is not always a spot. `kind` indicates the source type.

## v1.1.0

### New live protocol: `websocket-flv`

`GET /api/v1/vod` now also returns a `websocket-flv` entry for every channel that
already advertises `flv`. The stream and endpoint are the same; only the transport framing
differs: `flv` uses HTTP chunked transfer, `websocket-flv` upgrades the connection
and sends each FLV tag as one WebSocket binary frame.

- URL scheme follows the request scheme: `http` → `ws://`, `https` → `wss://`
- Filter with `GET /api/v1/vod?protocol=websocket-flv`
- Use it when a proxy or client mishandles long-lived chunked responses

### New live protocol: `rtsp`

`GET /api/v1/vod` now also returns an `rtsp` entry for every channel, on servers built
with RTSP re-streaming. The server repackages the same RTMP publish as RTP without
re-encoding. A stream exists only while the channel is publishing; `DESCRIBE` on an idle
channel returns `404`.

- URL: `rtsp://[user:pass@]host[:554]/live/ch<N>{main|sub}` — channel numbers are 1-based
- **TCP interleaved only.** A UDP `SETUP` is answered with `461 Unsupported Transport`,
  so clients that default to UDP must be told to use TCP: `vlc --rtsp-tcp`,
  `ffplay -rtsp_transport tcp`
- Basic authentication is required and cannot be turned off. Put the credentials in the
  URL and percent-encode reserved characters (`@` becomes `%40`)
- Video is **H.264 only**
- Filter with `GET /api/v1/vod?protocol=rtsp`
- Browsers cannot play RTSP. Use it for external players, VMS integrations and
  FFmpeg-based pipelines

### New storage status: `-9` (storage write stalled)

Recording storage events can now report that the storage cannot keep up, including how long it
was unresponsive and how many frames were lost. Previously, only the *result* was reported, as
`"Recording frame drop"` events. This status reports the underlying cause.

Two conditions trigger this status. Repeated slow disk I/O (three or more calls over 10 seconds
within a rolling 1-hour window) opens an **incident row** that stays open and is updated while
the condition persists. A hard stall, in which data is queued but nothing is written, is
reported once after it ends.

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

- New `param.statusCode` value on the existing `"Storage error"` event. No new event `type`
  or `code`, so existing filters and subscriptions are unaffected.
- New `param` keys on that event: `stalledSec`, `stallCount`, `chid`, `ongoing`, and
  a loss summary — `lostSec`, `channels`, `channelList`, `droppedFrames` — measured
  from the moment the incident opened.
- **The loss keys are absent when no video was lost**, which is the normal outcome
  (the write queue absorbed the stall). Treat their absence as "no loss", not as
  missing data. Do not default them to zero and report a loss of 0.
- `lostSec` is the total missing video, not the span it happened over. A two-hour
  incident may have lost only three minutes.
- An incident row is opened as soon as the condition is met, not after it passes, so it is
  visible while the condition is in progress. `data[].timeRange` grows until the incident
  closes, so a later poll of the same `data[].id` returns a wider range.
- `param.chid` is **0-based**, matching every other event payload. `data[].chid` stays
  1-based.
- `9.3. Event Log` now documents `data[].param` and the full `statusCode` table (including
  the previously undocumented `-8`, storage cleanup stopped).

### "Recording frame drop" is now one event per incident, not per channel

A storage stall used to produce one event per channel per aggregation window — a single
2.5-hour incident on a 144-channel server produced over 1,800 rows, which obscured the overall
pattern. These events are now combined into a single incident row.

```json
{
  "period": ["2026-08-31T19:36:41", "2026-08-31T20:22:30"],
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

- `data[].chid` is now `null` on this event. The affected channels are in
  `param.channelList`, and `param.channels` carries the count.
- An incident spans drops with no gap longer than 60 seconds. As with `-9`, the row opens
  immediately and both `data[].timeRange` and `param.period` grow until it closes.
- `param` fields — removed: `windowSec`; added: `period`, `channels`, `channelList`,
  `ongoing`. `droppedFrames` is unchanged in meaning but now counts the whole incident
  across all channels.
- `param.channelList` entries are **0-based**, like `param.chid`.

### `"Missing recording"` payload documented

The event itself is unchanged; its `param` was previously undocumented. `9.3. Event Log` now lists
`secs`, `streamFps`, `storage`, `freeMB`, `anchorAge` and `queuePct`, which together separate
a storage problem from a stream problem.

### Breaking Changes

Action needed **only if** your client reads these:

- Reading `data[].chid` on `"Recording frame drop"` → it is now `null`. Read
  `param.channelList` (0-based) or `param.channels` instead.
- Reading `param.windowSec` on that event → use `param.period`, which gives the actual
  missing interval rather than an aggregation window.
- Counting these events to gauge severity → one row now covers many channels and a long
  stretch. Use `param.channels` and `param.droppedFrames`.
- Re-polling an event by `data[].id` while an incident is open now returns updated
  `timeRange` and `param`. Treat rows with `param.ongoing` as not yet final.

Previously stored events keep their old payload, so clients must handle both formats.


---

## v1.0.3

### Recording event renamed: "Disk write delay" → "Recording frame drop"

One recording event changed its `codeName` and `param` fields. The event `type` and `code` integers are **unchanged**, so event filters and WebSocket/SSE subscriptions keyed on `code` keep working.

- `codeName`: `"Disk write delay"` → `"Recording frame drop"`
- Meaning: it now reports **dropped recording frames** (recording fell behind), reported per channel.
- `param` fields:
  - Removed: `latencyMs`, `function`, `storagePath`, `videoFile`
  - Added: `droppedFrames` (frames lost), `windowSec` (aggregation window in seconds); `chid` unchanged

### Breaking Changes

For this event only, `codeName` and `param` changed — action needed **only if** your client reads them:

- Matching the `codeName` string → use `"Recording frame drop"`, or match the `code` integer instead.
- Reading `param.latencyMs` / `param.function` → use `param.droppedFrames` / `param.windowSec`. Previously stored events keep the old payload.

---

## v1.0.2

### Relative URLs in v1 Responses

URL fields in **v1** responses are now **relative paths** (`/...`). **v0 endpoints keep absolute URLs** (`http://{host}/...`) for backward compatibility.

Affected v1 fields: `src`, `videoSrc`, `image`, `images[]`, `faceImg`, `orgImg`.

**Why**: absolute URLs embedded the request's `Host:` header verbatim, so a reverse proxy that rewrote `Host:` caused the wrong hostname to appear in the URL. Relative paths also align with future multi-NVR group routing.

**Client compatibility**:

- Browsers: no change — relative URLs resolve against the page origin.
- Non-browser clients (curl, mobile, server-to-server): prepend the API base URL before fetching.

**Exceptions**:

- v0 absolute URL host comes from **Canonical Host** (Web Admin → Server Settings → API), falling back to the `X-Host` header.
- `/api/v1/vod` live stream URLs (RTMP / WebSocket-FLV) remain absolute.

### Breaking Changes

None.

---

## v1.0.1

### LPR Event: Batch Plate Array (WebSocket)

Multiple plates recognized in a single frame are now delivered as one event with a `plates` array, instead of separate events per plate.

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

**Client compatibility** — handle both formats:

```javascript
const plates = data.plates || [data];
plates.forEach((p) => console.log(p.plateNo, p.score));
```

> **Note**: This format applies to **v1 WebSocket** (`/wsapi/v1/events`) only. v0 WebSocket (`/wsapi/subscribeEvents`) continues to use the legacy single-plate format.

### Parking Spot Improvements (WebSocket)

- **Vehicle info always included**: `vehicle` field is now populated whenever plate data exists, regardless of parking lot registration.
- **Duplicate event fix**: A single recognition no longer triggers two `parkingSpot` events. Occupancy and vehicle data are combined into one event.

### Breaking Changes

None. All changes are backward compatible.

---

## v1.0.0

Initial release.
