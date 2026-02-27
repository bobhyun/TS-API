# v0 to v1 Migration Guide

**English** | [한국어](MIGRATION.ko.md)

## Table of Contents

1. [Overview](#1-overview)
2. [v0 vs v1 Comparison](#2-v0-vs-v1-comparison)
3. [Endpoint Mapping](#3-endpoint-mapping)
4. [Code Migration Examples](#4-code-migration-examples)
5. [Key Changes](#5-key-changes)
6. [Authentication Notes](#6-authentication-notes)

7. [Disabling v0 API](#7-disabling-v0-api)

---

## 1. Overview

v1 API has been changed to RESTful path-based. The existing v0 API is still supported and can be optionally enabled/disabled through server settings.

### Legacy API (v0) Settings

You can control whether the v0 API is available from server settings:

| Setting | Behavior |
|---------|----------|
| **Enable legacy API (v0)** checked | Both v0 and v1 endpoints available (default) |
| **Enable legacy API (v0)** unchecked | v0 endpoints disabled, only v1 available |

Setting location: **Web Admin** → **Server Settings** → **API** tab


---

## 2. v0 vs v1 Comparison

| Feature | v0 | [v1](tsapi-v1.md) |
|---------|----|----|
| Auth: Session Cookie | ✅ | ✅ |
| Auth: JWT Bearer Token | ❌ | ✅ |
| Auth: API Key | ❌ | ✅ |
| Channel list | `GET /api/enum?what=channel` | `GET /api/v1/channel` |
| System info | `GET /api/system?info` | `GET /api/v1/system/info` |
| PTZ control | `GET /api/channel/ptz?ch=1&home` | `GET /api/v1/channel/1/ptz?home` |
| System restart | `GET /api/system?restart` | `POST /api/v1/system/restart` |
| **Documentation** | — | [API Guide](tsapi-v1.md) |
| **Examples** | — | [9 Languages](examples/) |

---

## 3. Endpoint Mapping

### 2.1. Auth
| v0 | v1 |
|----|-----|
| `GET /api/auth?login=...` | `POST /api/v1/auth/login` (JSON body) |
| `GET /api/auth?logout` | `POST /api/v1/auth/logout` (JSON body) |

> **Note:** `GET /api/v1/auth?login=...` is blocked in v1 for security reasons. Credentials must not be passed via query string. Use `POST /api/v1/auth/login` with credentials in the JSON request body instead.

### 2.2. Info (No change)
| v0 | v1 |
|----|-----|
| `GET /api/info?all` | `GET /api/v1/info?all` |

### 2.3. System
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

### 2.4. Channel Status
| v0 | v1 |
|----|-----|
| `GET /api/status` | `GET /api/v1/channel/status` |
| `GET /api/status?ch=1,2,3` | `GET /api/v1/channel/status?ch=1,2,3` |

### 2.5. Channel List (Enum)
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=channel` | `GET /api/v1/channel` |
| `GET /api/enum?what=channel&staticSrc` | `GET /api/v1/channel?staticSrc` |
| `GET /api/enum?what=channel&caps` | `GET /api/v1/channel?caps` |

### 2.6. Channel Control
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

### 2.7. Recording (Find)
| v0 | v1 |
|----|-----|
| `GET /api/find?what=recDays` | `GET /api/v1/recording/days` |
| `GET /api/find?what=recDays&ch=1` | `GET /api/v1/recording/days?ch=1` |
| `GET /api/find?what=recMinutes&...` | `GET /api/v1/recording/minutes?...` |

### 2.8. Event
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

### 2.10. Object
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=objectType` | `GET /api/v1/object/type` |
| `GET /api/enum?what=objectAttr&type=face` | `GET /api/v1/object/attr?type=face` |
| `GET /api/find?what=object` | `GET /api/v1/object/log` |

### 2.11. Face Search
| v0 | v1 |
|----|-----|
| `POST /api/searchFace` | `POST /api/v1/face/search` |
| `GET /api/searchFace?...` | `GET /api/v1/face/search?...` |

### 2.12. VOD (No change)
| v0 | v1 |
|----|-----|
| `GET /api/vod` | `GET /api/v1/vod` |
| `GET /api/vod?ch=1&when=...` | `GET /api/v1/vod?ch=1&when=...` |

### 2.13. Emergency
| v0 | v1 |
|----|-----|
| `GET /api/enum?what=emergencyCall` | `GET /api/v1/emergency` |

### 2.14. Push (No change)
| v0 | v1 |
|----|-----|
| `POST /api/push` | `POST /api/v1/push` |

### 2.15. WebSocket Event Subscription
| v0 | v1 |
|----|-----|
| `ws:///wsapi/subscribeEvents?topics=...` | `ws:///wsapi/v1/events?topics=...` |

### 2.16. WebSocket Data Export
| v0 | v1 |
|----|-----|
| `ws:///wsapi/dataExport?ch=1&timeBegin=...&timeEnd=...` | `ws:///wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...` |

> **Auth change**: v0 uses `auth=base64(user:pass)` query parameter, while v1 uses `token={JWT}` or `apikey={key}` query parameter.

---

## 4. Code Migration Examples

### 4.1. JavaScript

**Before (v0)**:
```javascript
// Get channels
fetch('/api/enum?what=channel')

// PTZ control
fetch('/api/channel/ptz?ch=1&home')

// System restart
fetch('/api/system?restart')
```

**After (v1)**:
```javascript
// Get channels
fetch('/api/v1/channel')

// PTZ control
fetch('/api/v1/channel/1/ptz?home')

// System restart
fetch('/api/v1/system/restart', {method: 'POST'})
```

### 4.2. Python

**Before (v0)**:
```python
# Get channels
requests.get(f'{base}/api/enum', params={'what': 'channel'})

# PTZ control
requests.get(f'{base}/api/channel/ptz', params={'ch': 1, 'home': ''})

# System restart
requests.get(f'{base}/api/system', params={'restart': ''})
```

**After (v1)**:
```python
# Get channels
requests.get(f'{base}/api/v1/channel')

# PTZ control
requests.get(f'{base}/api/v1/channel/1/ptz', params={'home': ''})

# System restart
requests.post(f'{base}/api/v1/system/restart')
```

---

## 5. Key Changes

1. **Path-based Resources**: Channel ID is included in the URL path
   - v0: `/api/channel/ptz?ch=1`
   - v1: `/api/v1/channel/1/ptz`

2. **RESTful HTTP Methods**: Uses appropriate HTTP methods for state-changing operations
   - v0: `GET /api/system?restart`
   - v1: `POST /api/v1/system/restart`

3. **Resource-oriented URLs**: Resource-oriented URL structure
   - v0: `/api/enum?what=channel`
   - v1: `/api/v1/channel`

4. **Consistent Parameter Names**:
   - v0: `info=os`, `health=cpu`
   - v1: `item=os`, `item=cpu`

5. **Response field name notes** (same for v0/v1):
   - Channel list: `title` (channel name), `displayName` (display name, `"CH{N}. {title}"` format)
   - VOD response: stream URLs are in the `src` field (e.g., `src.rtmp`, `src.flv`)
   - Event types: `id` (type ID), `code` (sub-code array)
   - System info: response field name is `disk` when requesting `item=storage`

---

## 6. Authentication Notes

v1 API supports **JWT Bearer Token** and **API Key** authentication on all endpoints. Session cookies are not supported on v1 endpoints.

| Existing v0 Auth | v1 Recommended Method |
|-------------|-------------|
| Session Cookie | JWT Login (`POST /api/v1/auth/login`) - credentials in JSON body |
| External system integration | API Key (`X-API-Key` header) - no login required |

---

## 7. Disabling v0 API

v0 API is deprecated and can be disabled in settings for enhanced security. Since v0 API uses insecure patterns such as passing credentials via query strings, it is recommended to disable it once v1 migration is complete.

**How to disable:**

Uncheck "Enable legacy API (v0)" in web server settings.

**Behavior when disabled:**

Returns 404 error when v0 API is called:

```json
{
  "code": -1,
  "message": "Legacy API (v0) is disabled. Please use /api/v1/ endpoints."
}
```

**Affected endpoints:**

| Type | Endpoints |
|------|-----------|
| REST API | `/api/auth`, `/api/info`, `/api/system`, `/api/enum`, `/api/find`, `/api/vod`, `/api/status`, `/api/channel/*`, `/api/push`, `/api/subscribeEvents`, `/api/searchFace` |
| WebSocket API | `/wsapi/subscribeEvents`, `/wsapi/dataExport` |

