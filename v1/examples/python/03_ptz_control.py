"""
03_ptz_control.py - TS-API v1 PTZ Control

Endpoints:
  GET /api/v1/channel/{chid}/ptz?home         - Move to home position
  GET /api/v1/channel/{chid}/ptz?move=x,y     - Continuous move (x,y: -1.0 to 1.0)
  GET /api/v1/channel/{chid}/ptz?zoom=speed   - Zoom (positive=in, negative=out)
  GET /api/v1/channel/{chid}/ptz?focus=speed  - Focus (positive=far, negative=near)
  GET /api/v1/channel/{chid}/ptz?iris=speed   - Iris (positive=open, negative=close)
  GET /api/v1/channel/{chid}/ptz?stop         - Stop all PTZ movement
  GET /api/v1/channel/{chid}/preset           - List presets
  GET /api/v1/channel/{chid}/preset/{token}/go - Go to preset

NOTE: PTZ may return HTTP 500 if camera does not support ONVIF PTZ
      or if the ONVIF connection is unavailable.
"""

import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)

CHID = 1  # Target channel ID


def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    # --- Go Home ---
    print("=== PTZ Home ===")
    r = client.get(f'/api/v1/channel/{CHID}/ptz?home')
    print(f"  home -> {r.status_code}")
    if r.status_code == 500:
        print("  PTZ unavailable (ONVIF not supported or camera offline)")
        return
    time.sleep(2)

    # --- Continuous Move (pan right, tilt up) ---
    print("\n=== PTZ Move ===")
    # x=0.5 (pan right at half speed), y=0.3 (tilt up at 30% speed)
    r = client.get(f'/api/v1/channel/{CHID}/ptz?move=0.5,0.3')
    print(f"  move=0.5,0.3 -> {r.status_code}")
    time.sleep(1)

    # --- Stop ---
    r = client.get(f'/api/v1/channel/{CHID}/ptz?stop')
    print(f"  stop -> {r.status_code}")

    # --- Zoom In ---
    print("\n=== PTZ Zoom ===")
    r = client.get(f'/api/v1/channel/{CHID}/ptz?zoom=0.5')
    print(f"  zoom=0.5 (in) -> {r.status_code}")
    time.sleep(1)
    client.get(f'/api/v1/channel/{CHID}/ptz?stop')

    # --- Zoom Out ---
    r = client.get(f'/api/v1/channel/{CHID}/ptz?zoom=-0.5')
    print(f"  zoom=-0.5 (out) -> {r.status_code}")
    time.sleep(1)
    client.get(f'/api/v1/channel/{CHID}/ptz?stop')

    # --- Focus ---
    print("\n=== PTZ Focus ===")
    r = client.get(f'/api/v1/channel/{CHID}/ptz?focus=0.5')
    print(f"  focus=0.5 (far) -> {r.status_code}")
    time.sleep(1)
    client.get(f'/api/v1/channel/{CHID}/ptz?stop')

    # --- Iris ---
    print("\n=== PTZ Iris ===")
    r = client.get(f'/api/v1/channel/{CHID}/ptz?iris=0.5')
    print(f"  iris=0.5 (open) -> {r.status_code}")
    time.sleep(1)
    client.get(f'/api/v1/channel/{CHID}/ptz?stop')

    # --- List Presets ---
    print("\n=== Presets ===")
    r = client.get(f'/api/v1/channel/{CHID}/preset')
    if r.status_code == 200:
        presets = r.json()
        if not isinstance(presets, list):
            code = presets.get('code', '') if isinstance(presets, dict) else ''
            print(f"  No presets (code={code})")
        else:
            for p in presets:
                if isinstance(p, dict):
                    print(f"  token={p.get('token')}  name={p.get('name', '')}")
                else:
                    print(f"  preset: {p}")

            # --- Go to first preset ---
            if presets:
                first = presets[0]
                token = first['token'] if isinstance(first, dict) else first
                print(f"\n=== Go to Preset (token={token}) ===")
                r = client.get(f'/api/v1/channel/{CHID}/preset/{token}/go')
                print(f"  preset/{token}/go -> {r.status_code}")
    else:
        print(f"  presets -> {r.status_code}")


if __name__ == '__main__':
    main()
