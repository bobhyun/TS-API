"""
05_event_log.py - TS-API v1 Event Log

Endpoints:
  GET /api/v1/event/type
      - List event types with nested codes
      - Response: [{ "id": 1, "name": "Motion", "code": [{"id": 1, "name": "Start"}, ...] }, ...]
      - Note: field is 'id' (NOT 'type'), nested array is 'code'

  GET /api/v1/event/log?timeBegin=...&timeEnd=...&at=0&maxCount=50
      - Query event log with time range and pagination
      - Response: { "data": [{ "timeRange": "...", "chid": ..., "typeName": "...", "codeName": "..." }, ...] }
"""

import os
import sys
from datetime import datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)


def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    # --- Event Types ---
    print("=== Event Types ===")
    r = client.get('/api/v1/event/type')
    if r.status_code == 200:
        types = r.json()
        for t in types:
            # Each type has 'id', 'name', and nested 'code' array
            print(f"  id={t['id']}  name={t['name']}")
            for code in t.get('code', []):
                print(f"    code id={code['id']}  name={code['name']}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Event Log (last 24 hours, paginated) ---
    print("\n=== Event Log (last 24h) ===")
    now = datetime.now()
    time_end = now.strftime('%Y-%m-%d %H:%M:%S')
    time_begin = (now - timedelta(hours=24)).strftime('%Y-%m-%d %H:%M:%S')

    at = 0
    max_count = 20  # Page size
    total_fetched = 0

    while True:
        r = client.get('/api/v1/event/log', params={
            'timeBegin': time_begin,
            'timeEnd': time_end,
            'at': at,
            'maxCount': max_count,
        })
        if r.status_code != 200:
            print(f"  Error: {r.status_code}")
            break

        events = r.json().get('data', [])
        if not events:
            break  # No more events

        for ev in events:
            print(f"  [{ev.get('timeRange', '')}] ch={ev.get('chid', '')} "
                  f"type={ev.get('typeName', '')} code={ev.get('codeName', '')}")
        total_fetched += len(events)

        # Stop after first page for demo; remove break for full pagination
        print(f"\n  Fetched {total_fetched} events (at={at})")
        break

        # To fetch next page:
        # at += max_count


if __name__ == '__main__':
    main()
