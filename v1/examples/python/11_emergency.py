"""
11_emergency.py - TS-API v1 Emergency Call Device List

Endpoint:
  GET /api/v1/emergency  - Emergency call device list

Response:
  [
    {
      "id": 1,
      "code": "EM-001",
      "name": "Fire Alarm",
      "linkedChannel": [1, 2, 3]
    }
  ]

Note: Requires Emergency Call license. Returns 404 if not supported.
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

    # ── Emergency Call Device List ──
    r = client.get('/api/v1/emergency')
    print(f'=== Emergency Devices === status={r.status_code}')

    if r.status_code == 200:
        devices = r.json()
        print(f'  Total: {len(devices)} device(s)')
        for dev in devices:
            chans = dev.get('linkedChannel', [])
            print(f'  id={dev["id"]}  code={dev.get("code", "")}'
                  f'  name={dev.get("name", "")}'
                  f'  linkedChannel={chans}')
    elif r.status_code == 404:
        print('  Emergency Call not enabled on this server (license required)')


if __name__ == '__main__':
    main()
