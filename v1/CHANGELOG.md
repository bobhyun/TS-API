# TS-API Changelog

**English** | [한국어](CHANGELOG.ko.md)

## v1.1.0

### New live protocol: `websocket-flv`

`GET /api/v1/vod` now also returns a `websocket-flv` entry for every channel that
already advertises `flv`. Same stream, same endpoint — only the transport framing
differs: `flv` uses HTTP chunked transfer, `websocket-flv` upgrades the connection
and sends each FLV tag as one WebSocket binary frame.

- URL scheme follows the request scheme: `http` → `ws://`, `https` → `wss://`
- Filter with `GET /api/v1/vod?protocol=websocket-flv`
- Use it when a proxy or client mishandles long-lived chunked responses

### New live protocol: `rtsp`

`GET /api/v1/vod` now also returns an `rtsp` entry for every channel, on servers built
with RTSP re-streaming. The server re-sends the same RTMP publish as RTP — there is no
second encode, and no stream exists unless the channel is publishing (`DESCRIBE` on an
idle channel answers `404`).

- URL: `rtsp://[user:pass@]host[:554]/live/ch<N>{main|sub}` — channel numbers are 1-based
- **TCP interleaved only.** A UDP `SETUP` is answered with `461 Unsupported Transport`,
  so clients that default to UDP must be told to use TCP: `vlc --rtsp-tcp`,
  `ffplay -rtsp_transport tcp`
- Basic authentication is required and cannot be turned off. Put the credentials in the
  URL and percent-encode reserved characters (`@` becomes `%40`)
- Video is **H.264 only**
- Filter with `GET /api/v1/vod?protocol=rtsp`
- Browsers cannot play RTSP — use it for external players, VMS integrations and
  FFmpeg-based pipelines

### New storage status: `-9` (storage write stalled)

Recording storage events can now report that the storage is not keeping up, with how long it
was unresponsive and how many frames were lost. Until now only the *result* was reported —
the `"Recording frame drop"` events; this is the cause behind them.

Two conditions raise it. Repeated slow disk I/O (three or more calls over 10 seconds within a
rolling 1-hour window) opens an **incident row** that stays open and is refreshed while the
trouble lasts. A hard stall — data queued and not one byte written — is reported once, after
it ends.

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
  (the write queue absorbed the stall). Treat their absence as "no loss" rather than
  missing data — do not default them to zero and report a loss of 0.
- `lostSec` is the total missing video, not the span it happened over. A two-hour
  incident may have lost only three minutes.
- An incident row is opened as soon as the condition is met, not after it passes, so it is
  visible while the trouble is happening. `data[].timeRange` grows until the incident closes
  — the same `data[].id` returns a wider range on a later poll.
- `param.chid` is **0-based**, matching every other event payload. `data[].chid` stays
  1-based.
- `9.3. Event Log` now documents `data[].param` and the full `statusCode` table (including
  the previously undocumented `-8`, storage cleanup stopped).

### "Recording frame drop" is now one event per incident, not per channel

A storage stall used to produce one event per channel per aggregation window — a single
2.5-hour incident on a 144-channel server produced over 1,800 rows, which buried the shape of
the problem. Those rows are now collected into a single incident row.

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

No change to the event — its `param` was simply never documented. `9.3. Event Log` now lists
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

Previously stored events keep their old payload, and the reader must tolerate both.


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

**Why**: absolute URLs embedded the request's `Host:` header verbatim, so a reverse proxy rewriting `Host:` baked the wrong hostname into the URL. Relative paths also align with future multi-NVR group routing.

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
- **Duplicate event fix**: A single recognition no longer triggers two `parkingSpot` events. Occupancy + vehicle data are combined into one event.

### Breaking Changes

None. All changes are backward compatible.

---

## v1.0.0

Initial release.
