"""
07_vod_stream.py - TS-API v1 VOD (Video on Demand)

Endpoints:
  GET /api/v1/vod
      - List available VOD streams
      - Response: [{ "chid": 1, "title": "Camera 1", "src": [{"protocol": "rtmp", "src": "..."}, {"protocol": "flv", "src": "..."}] }, ...]
      - Note: 'src' is an array of objects with 'protocol' and 'src' fields

  GET /api/v1/vod?protocol=rtmp
      - Filter by protocol (rtmp, flv)

  GET /api/v1/vod?stream=sub
      - Filter by stream type (main, sub)

VOD playback requires specifying a time range via the stream URL parameters.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)


def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    # --- List all VOD streams ---
    print("=== VOD Streams ===")
    r = client.get('/api/v1/vod')
    if r.status_code == 200:
        vods = r.json()
        for v in vods:
            # Fields: chid, title, src (array of {protocol, src} objects)
            print(f"  chid={v['chid']}  title={v.get('title', '')}")
            src = v.get('src', [])
            rtmp_url = next((s['src'] for s in src if s.get('protocol') == 'rtmp'), None)
            flv_url = next((s['src'] for s in src if s.get('protocol') == 'flv'), None)
            if rtmp_url:
                print(f"    RTMP: {rtmp_url}")
            if flv_url:
                print(f"    FLV:  {flv_url}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Filter by protocol (RTMP only) ---
    print("\n=== VOD - RTMP only ===")
    r = client.get('/api/v1/vod', params={'protocol': 'rtmp'})
    if r.status_code == 200:
        for v in r.json():
            src = v.get('src', [])
            rtmp_url = next((s['src'] for s in src if s.get('protocol') == 'rtmp'), '')
            print(f"  chid={v['chid']}  rtmp={rtmp_url}")

    # --- Filter by stream type (sub stream) ---
    print("\n=== VOD - Sub stream ===")
    r = client.get('/api/v1/vod', params={'stream': 'sub'})
    if r.status_code == 200:
        for v in r.json():
            src = v.get('src', [])
            print(f"  chid={v['chid']}  src={src}")

    # --- Playback example ---
    # To play back a specific time range, append time parameters to the stream URL.
    # Example RTMP playback URL:
    #   rtmp://host:port/live/1?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
    # Example FLV playback URL:
    #   http://host:port/live/1.flv?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
    print("\n=== Playback URL Example ===")
    if r.status_code == 200:
        vods = r.json()
        if vods:
            v = vods[0]
            src = v.get('src', [])
            rtmp = next((s['src'] for s in src if s.get('protocol') == 'rtmp'), '')
            if rtmp:
                print(f"  Base URL: {rtmp}")
                print(f"  With time: {rtmp}?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00")


if __name__ == '__main__':
    main()
