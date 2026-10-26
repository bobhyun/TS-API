"""
08_system_info.py - TS-API v1 System Information

Endpoints:
  GET /api/v1/info?all
      - All NVR info (version, license, etc.)

  GET /api/v1/system/info?item=os       - OS information
  GET /api/v1/system/info?item=cpu      - CPU usage
  GET /api/v1/system/info?item=storage  - Disk info (response field is 'disk')
  GET /api/v1/system/info?item=network  - Network interfaces

  GET /api/v1/system/health             - System health status
  GET /api/v1/system/health?item=systemDisk
                                        - System disk (database and logs) status
  GET /api/v1/system/hddsmart           - HDD S.M.A.R.T. data
  GET /api/v1/system/notices?lang=ko-KR - Notices currently in effect

Note: item=storage returns its data in the 'disk' field (NOT 'storage').
"""

import os
import sys
import json

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)


def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    # --- NVR Info (all) ---
    print("=== NVR Info ===")
    r = client.get('/api/v1/info?all')
    if r.status_code == 200:
        info = r.json()
        print(f"  {json.dumps(info, indent=2, ensure_ascii=False)}")

    # --- System Info: OS ---
    print("\n=== OS Info ===")
    r = client.get('/api/v1/system/info?item=os')
    if r.status_code == 200:
        print(f"  {r.json()}")

    # --- System Info: CPU ---
    print("\n=== CPU Info ===")
    r = client.get('/api/v1/system/info?item=cpu')
    if r.status_code == 200:
        print(f"  {r.json()}")

    # --- System Info: Storage ---
    # NOTE: query param is 'storage' but response field is 'disk'
    print("\n=== Storage Info ===")
    r = client.get('/api/v1/system/info?item=storage')
    if r.status_code == 200:
        data = r.json()
        # Access via 'disk' field in response
        disks = data.get('disk', data)
        print(f"  {json.dumps(disks, indent=2, ensure_ascii=False)}")

    # --- System Info: Network ---
    print("\n=== Network Info ===")
    r = client.get('/api/v1/system/info?item=network')
    if r.status_code == 200:
        print(f"  {json.dumps(r.json(), indent=2, ensure_ascii=False)}")

    # --- System Health ---
    print("\n=== System Health ===")
    r = client.get('/api/v1/system/health')
    if r.status_code == 200:
        print(f"  {json.dumps(r.json(), indent=2, ensure_ascii=False)}")

    # --- System Disk ---
    # Holds the database and logs (normally C:), separate from the recording disks.
    # When it is full, records stop being saved even if the recording disks have room.
    # Watch status here, not only disk[].
    print("\n=== System Disk ===")
    r = client.get('/api/v1/system/health?item=systemDisk')
    if r.status_code == 200:
        sd = r.json().get('systemDisk', {})
        print(f"  drive={sd.get('drive')} free={sd.get('freeSpace')}/{sd.get('totalSpace')} "
              f"status={sd.get('status')} dataWriteFailed={sd.get('dataWriteFailed')}")
    else:
        print(f"  Status: {r.status_code}")

    # --- System Notices ---
    # Conditions in effect right now (raised, updated, cleared).
    # message is keyed by language code: en-US is always present,
    # plus the requested lang when it is not English.
    print("\n=== System Notices ===")
    lang = 'ko-KR'
    r = client.get('/api/v1/system/notices', params={'lang': lang})
    if r.status_code == 200:
        notices = r.json()
        if not notices:
            print("  (no notices)")
        for n in notices:
            msg = n['message']
            print(f"  [{n['severity']}] {n['kind']}: {msg.get(lang, msg['en-US'])}")
    else:
        print(f"  Status: {r.status_code}")

    # --- HDD S.M.A.R.T. ---
    print("\n=== HDD S.M.A.R.T. ===")
    r = client.get('/api/v1/system/hddsmart')
    if r.status_code == 200:
        print(f"  {json.dumps(r.json(), indent=2, ensure_ascii=False)}")
    else:
        print(f"  Status: {r.status_code} (S.M.A.R.T. may not be available)")


if __name__ == '__main__':
    main()
