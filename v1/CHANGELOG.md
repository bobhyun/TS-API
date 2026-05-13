# TS-API Changelog

**English** | [한국어](CHANGELOG.ko.md)

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
