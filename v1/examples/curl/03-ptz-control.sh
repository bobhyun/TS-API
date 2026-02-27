#!/usr/bin/env bash
# Example 03: PTZ Camera Control
#
# Demonstrates:
#   - Home position
#   - Pan/Tilt movement (move=x,y, range: -1.0 ~ 1.0)
#   - Zoom control (zoom=z, range: -1.0 ~ 1.0)
#   - Focus/Iris control
#   - Stop movement
#   - Preset management (list, go to)
#
# NOTE: PTZ commands are sent via ONVIF to the camera.
#       Returns 500 if the camera doesn't support ONVIF or is unreachable.
#
# Usage:
#   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... bash 03-ptz-control.sh

set -euo pipefail

HOST="${NVR_HOST:-localhost}"
SCHEME="${NVR_SCHEME:-https}"
PORT="${NVR_PORT:-$([ "$SCHEME" = "https" ] && echo 443 || echo 80)}"
API_KEY="${NVR_API_KEY:?NVR_API_KEY environment variable is required}"

DEFAULT_PORT=$([ "$SCHEME" = "https" ] && echo 443 || echo 80)
[ "$PORT" = "$DEFAULT_PORT" ] && BASE="${SCHEME}://${HOST}" || BASE="${SCHEME}://${HOST}:${PORT}"
AUTH=(-H "X-API-Key: ${API_KEY}")
CURL=(curl -sk)

CHANNEL="${NVR_CHANNEL:-1}"  # Target camera channel

jqf() { jq . 2>/dev/null || cat; }

# ─────────────────────────────────────────────────
# 1. Move to Home Position
# ─────────────────────────────────────────────────
echo "=== Home Position ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?home" | jqf
sleep 1

# ─────────────────────────────────────────────────
# 2. Pan/Tilt Movement
#    move=x,y where x=pan(-1~1), y=tilt(-1~1)
#    Positive x = right, Positive y = up
# ─────────────────────────────────────────────────
echo ""
echo "=== Pan/Tilt ==="

# Move right and up
echo "--- Move right+up (0.3, 0.3) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?move=0.3,0.3" | jqf
sleep 0.5

# Stop
echo "--- Stop ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?stop" | jqf
sleep 0.5

# Move left and down
echo "--- Move left+down (-0.3, -0.3) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?move=-0.3,-0.3" | jqf
sleep 0.5

# Stop
echo "--- Stop ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?stop" | jqf

# ─────────────────────────────────────────────────
# 3. Zoom Control
#    zoom > 0 = zoom in, zoom < 0 = zoom out
# ─────────────────────────────────────────────────
echo ""
echo "=== Zoom ==="

echo "--- Zoom in (0.5) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?zoom=0.5" | jqf
sleep 1

echo "--- Stop ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?stop" | jqf
sleep 0.5

echo "--- Zoom out (-0.5) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?zoom=-0.5" | jqf
sleep 1

echo "--- Stop ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?stop" | jqf

# ─────────────────────────────────────────────────
# 4. Focus & Iris Control
#    focus: -1.0=near, 1.0=far
#    iris:  -1.0=close, 1.0=open
# ─────────────────────────────────────────────────
echo ""
echo "=== Focus & Iris ==="

echo "--- Focus far (0.3) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?focus=0.3" | jqf

echo "--- Iris open (0.3) ---"
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?iris=0.3" | jqf

# ─────────────────────────────────────────────────
# 5. Preset List & Go
# ─────────────────────────────────────────────────
echo ""
echo "=== Presets ==="

echo "--- List presets ---"
PRESETS=$("${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/preset")
echo "$PRESETS" | jqf

# Go to first preset if exists
FIRST_TOKEN=$(echo "$PRESETS" | jq -r '.[0].token // empty' 2>/dev/null)
if [ -n "$FIRST_TOKEN" ]; then
  FIRST_NAME=$(echo "$PRESETS" | jq -r '.[0].name // "unknown"' 2>/dev/null)
  echo ""
  echo "--- Go to preset '${FIRST_NAME}' (token: ${FIRST_TOKEN}) ---"
  "${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/preset/${FIRST_TOKEN}/go" | jqf
fi

# ─────────────────────────────────────────────────
# 6. Return to Home
# ─────────────────────────────────────────────────
echo ""
echo "=== Return Home ==="
"${CURL[@]}" "${AUTH[@]}" "${BASE}/api/v1/channel/${CHANNEL}/ptz?home" | jqf
