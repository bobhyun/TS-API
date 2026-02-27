#!/usr/bin/env bash
# Example 01: Authentication
#
# TS-API v1 supports three authentication methods:
#   1. JWT Login (POST) - primary method for all v1 endpoints
#   2. API Key - for external system integration (v1 endpoints only)
#   3. Session Login - uses JWT internally, tokens stored by http helper
#
# NOTE: v1 data endpoints require JWT Bearer token or API Key.
#       Session cookies are NOT supported by v1 endpoints.
# NOTE: API Key authentication is supported on v1 endpoints only.
#       v0 endpoints (/api/*) reject X-API-Key with 401 Unauthorized.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_USER=admin NVR_PASS=1234 bash 01-login.sh

set -euo pipefail

HOST="${NVR_HOST:-localhost}"
SCHEME="${NVR_SCHEME:-https}"
PORT="${NVR_PORT:-$([ "$SCHEME" = "https" ] && echo 443 || echo 80)}"
USER="${NVR_USER:-admin}"
PASS="${NVR_PASS:-1234}"

DEFAULT_PORT=$([ "$SCHEME" = "https" ] && echo 443 || echo 80)
[ "$PORT" = "$DEFAULT_PORT" ] && BASE="${SCHEME}://${HOST}" || BASE="${SCHEME}://${HOST}:${PORT}"
CURL=(curl -sk)

# jq fallback: pretty-print if jq is available, raw output otherwise
jqf() { jq . 2>/dev/null || cat; }

# ─────────────────────────────────────────────────
# Method 1: JWT Login (manual token management)
#   POST /api/v1/auth/login with JSON body { auth: base64("user:pass") }
#   Returns: { accessToken, refreshToken, expiresIn, tokenType, user }
# ─────────────────────────────────────────────────
echo "=== JWT Login ==="

AUTH_B64=$(echo -n "${USER}:${PASS}" | base64)
RESPONSE=$("${CURL[@]}" -X POST "${BASE}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"auth\":\"${AUTH_B64}\"}")
echo "$RESPONSE" | jqf

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken // empty')
REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refreshToken // empty')
EXPIRES_IN=$(echo "$RESPONSE" | jq -r '.expiresIn // empty')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Login failed"
  exit 1
fi

echo "Access Token:  ${ACCESS_TOKEN:0:30}..."
echo "Refresh Token: ${REFRESH_TOKEN:0:30}..."
echo "Expires In:    ${EXPIRES_IN} seconds"

# ─────────────────────────────────────────────────
# 2. Use Access Token for API calls
#    Header: Authorization: Bearer {accessToken}
# ─────────────────────────────────────────────────
echo ""
echo "=== Use Access Token ==="
"${CURL[@]}" "${BASE}/api/v1/channel" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jqf

# ─────────────────────────────────────────────────
# 3. Refresh Access Token
#    POST /api/v1/auth/refresh with { refreshToken }
#    NOTE: Server performs token rotation - old refreshToken is revoked.
#          You MUST use the NEW refreshToken for subsequent operations.
# ─────────────────────────────────────────────────
echo ""
echo "=== Refresh Token ==="
REFRESH_RESPONSE=$("${CURL[@]}" -X POST "${BASE}/api/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH_TOKEN}\"}")
echo "$REFRESH_RESPONSE" | jqf

NEW_ACCESS_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.accessToken // empty')
NEW_REFRESH_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.refreshToken // empty')

if [ -n "$NEW_ACCESS_TOKEN" ]; then
  echo "New Access Token:  ${NEW_ACCESS_TOKEN:0:30}..."
  echo "New Refresh Token: ${NEW_REFRESH_TOKEN:0:30}..."
fi

# ─────────────────────────────────────────────────
# 4. Logout (revoke refreshToken)
#    Must use the NEW refreshToken after rotation
# ─────────────────────────────────────────────────
echo ""
echo "=== Logout ==="
LOGOUT_TOKEN="${NEW_REFRESH_TOKEN:-$REFRESH_TOKEN}"
"${CURL[@]}" -X POST "${BASE}/api/v1/auth/logout" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${LOGOUT_TOKEN}\"}" | jqf
echo "JWT logged out (refreshToken revoked)"

# ─────────────────────────────────────────────────
# Method 2: API Key (issue -> use -> list -> revoke)
#   POST /api/v1/auth/apikey   (create, requires admin JWT)
#   X-API-Key header           (use, v1 endpoints only)
#   GET /api/v1/auth/apikey    (list)
#   DELETE /api/v1/auth/apikey/{id}  (delete)
#   NOTE: v0 endpoints (/api/*) reject API Key with 401
# ─────────────────────────────────────────────────
echo ""
echo "=== API Key ==="

# 1) JWT login for admin access
AUTH_B64=$(echo -n "${USER}:${PASS}" | base64)
RESPONSE=$("${CURL[@]}" -X POST "${BASE}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"auth\":\"${AUTH_B64}\"}")
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken // empty')
REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refreshToken // empty')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "JWT login failed"
  exit 1
fi

# 2) Create API Key
echo "--- Create API Key ---"
CREATE_RESPONSE=$("${CURL[@]}" -X POST "${BASE}/api/v1/auth/apikey" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "example-integration"
  }')
echo "$CREATE_RESPONSE" | jqf

# Optional fields for POST /api/v1/auth/apikey:
#   "permissions": ["remote"]         - specify permissions (default: remote)
#   "channels": [1, 2]               - restrict accessible channels
#   "ipWhitelist": ["192.168.0.0/24"] - IP restriction
#   "expiresAt": 1735689600          - expiration (Unix timestamp)

KEY_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id // empty')
API_KEY=$(echo "$CREATE_RESPONSE" | jq -r '.key // empty')
echo "Key ID:  ${KEY_ID}"
echo "API Key: ${API_KEY:0:24}..."

# 3) Use API Key for data endpoint access (no login required)
echo ""
echo "--- Use API Key ---"
"${CURL[@]}" "${BASE}/api/v1/channel" \
  -H "X-API-Key: ${API_KEY}" | jqf

# 4) List API Keys
echo ""
echo "--- List API Keys ---"
"${CURL[@]}" "${BASE}/api/v1/auth/apikey" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jqf

# 5) Delete API Key
echo ""
echo "--- Delete API Key ---"
"${CURL[@]}" -X DELETE "${BASE}/api/v1/auth/apikey/${KEY_ID}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jqf
echo "API Key deleted"

# Cleanup: logout
"${CURL[@]}" -X POST "${BASE}/api/v1/auth/logout" \
  -H "Content-Type: application/json" \
  -d "{\"refreshToken\":\"${REFRESH_TOKEN}\"}" > /dev/null 2>&1
