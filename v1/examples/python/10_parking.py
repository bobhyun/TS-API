"""
10_parking.py - TS-API v1 Parking

Endpoints:
  GET /api/v1/parking/lot           - List parking lots
  GET /api/v1/parking/lot/status    - Parking lot occupancy status
  GET /api/v1/parking/spot          - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
  GET /api/v1/parking/spot/status   - Status of each parking spot
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

    # --- Parking Lots ---
    print("=== Parking Lots ===")
    r = client.get('/api/v1/parking/lot')
    if r.status_code == 200:
        lots = r.json()
        print(f"  {len(lots)} lots found")
        for lot in lots:
            info = f"  [{lot['id']}] {lot['name']} (type={lot.get('type')}, max={lot.get('maxCount')})"
            if 'parkingSpots' in lot:
                info += f" spots={lot['parkingSpots']}"
            if 'member' in lot:
                info += f" member={lot['member']}"
            print(info)
    else:
        print(f"  Status: {r.status_code}")

    # --- Parking Lot Status (occupancy) ---
    print("\n=== Parking Lot Status ===")
    r = client.get('/api/v1/parking/lot/status')
    if r.status_code == 200:
        statuses = r.json()
        for s in statuses:
            print(f"  {json.dumps(s, ensure_ascii=False)}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Recognition Zones (all types: spot, entrance, exit, noParking, recognition) ---
    print("\n=== Recognition Zones ===")
    r = client.get('/api/v1/parking/spot')
    if r.status_code == 200:
        zones = r.json()
        types = {}
        for z in zones:
            t = z.get('type', 'unknown')
            types[t] = types.get(t, 0) + 1
        print(f"  {len(zones)} zones found ({', '.join(f'{k}: {v}' for k, v in types.items())})")
        for zone in zones[:10]:  # Show first 10
            print(f"  {json.dumps(zone, ensure_ascii=False)}")
        if len(zones) > 10:
            print(f"  ... and {len(zones) - 10} more zones")
    else:
        print(f"  Status: {r.status_code}")

    # --- Parking Spot Status ---
    print("\n=== Parking Spot Status ===")
    r = client.get('/api/v1/parking/spot/status')
    if r.status_code == 200:
        statuses = r.json()
        for s in statuses[:10]:  # Show first 10
            print(f"  {json.dumps(s, ensure_ascii=False)}")
        if len(statuses) > 10:
            print(f"  ... and {len(statuses) - 10} more spots")
    else:
        print(f"  Status: {r.status_code}")


if __name__ == '__main__':
    main()
