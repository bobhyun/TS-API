"""
02_channels.py - TS-API v1 Channel

Endpoints:
  GET /api/v1/channel              - List all channels
  GET /api/v1/channel?staticSrc    - Include static stream source URLs
  GET /api/v1/channel?caps         - Include channel capabilities
  GET /api/v1/channel/status?recordingStatus - Recording status per channel
  GET /api/v1/channel/{chid}/info?caps       - Single channel capabilities

Channel fields: chid, title, displayName (NOT 'name')
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

    # --- List all channels ---
    r = client.get('/api/v1/channel')
    channels = r.json()
    print(f"=== Channels ({len(channels)}) ===")
    for ch in channels:
        # Key fields: chid, title, displayName
        print(f"  chid={ch['chid']}  title={ch.get('title', '')}  "
              f"displayName={ch.get('displayName', '')}")

    # --- Static source URLs (RTMP/FLV addresses for each channel) ---
    r = client.get('/api/v1/channel?staticSrc')
    print(f"\n=== Channels with staticSrc ===")
    for ch in r.json():
        print(f"  chid={ch['chid']}  staticSrc={ch.get('staticSrc', {})}")

    # --- Channel capabilities ---
    r = client.get('/api/v1/channel?caps')
    print(f"\n=== Channels with caps ===")
    for ch in r.json():
        print(f"  chid={ch['chid']}  caps={ch.get('caps', {})}")

    # --- Recording status ---
    r = client.get('/api/v1/channel/status?recordingStatus')
    print(f"\n=== Recording Status ===")
    statuses = r.json()
    for s in statuses:
        print(f"  chid={s.get('chid')}  recording={s.get('recordingStatus')}")

    # --- Single channel capabilities (channel 1) ---
    if channels:
        chid = channels[0]['chid']
        r = client.get(f'/api/v1/channel/{chid}/info?caps')
        print(f"\n=== Channel {chid} Capabilities ===")
        print(f"  {r.json()}")


if __name__ == '__main__':
    main()
