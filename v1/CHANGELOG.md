# TS-API Changelog

**English** | [한국어](CHANGELOG.ko.md)

## v1.0.2

### Relative URLs in Response Bodies

URL fields in API responses are now returned as **relative paths** (e.g., `/download/...`) instead of absolute URLs (e.g., `http://host/download/...`).

Affected response fields across REST and WebSocket endpoints:
- `src` — download links from `/wsapi/v1/export` (and v0 `/wsapi/dataExport`)
- `videoSrc` — watch URLs in LPR / find / vehicle tracking results
- `image`, `images[]` — event notifications, LPR / VA search image references
- `faceImg`, `orgImg` — face search results

```json
{
  "download": [
    {"src": "/download/task-uuid/CH01.mp4", "fileName": "CH01.mp4"}
  ]
}
```

**Client compatibility**:
- **Browser clients**: no change required — relative URLs resolve against the page origin automatically.
- **Non-browser clients** (curl, Python `requests`, mobile apps, server-to-server): prepend the API base URL when fetching:
  ```javascript
  const fullUrl = baseUrl + response.download[0].src;
  ```

### Why

Previous absolute URLs embedded the server's `Host:` header verbatim. When the request passed through a reverse proxy that rewrites `Host:`, the wrong hostname was baked into the URL — clients then failed to fetch the resource. Relative paths eliminate this class of issue and align with future federated multi-NVR group routing.

### Live Stream URLs Unchanged

RTMP / HLS / DASH / WebSocket-FLV stream URLs in `src` arrays of `/api/v1/vod` (live stream) responses remain **absolute** — these protocols require fully-qualified URLs.

### Breaking Changes

None for browser clients. Non-browser clients that previously consumed `response.src` directly without combining with a base URL must adapt — see "Client compatibility" above.

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
plates.forEach(p => console.log(p.plateNo, p.score));
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
