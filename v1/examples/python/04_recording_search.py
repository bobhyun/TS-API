"""
04_recording_search.py - TS-API v1 Recording Search

Endpoints:
  GET /api/v1/recording/days?ch=1&timeBegin=2026-01-01&timeEnd=2026-02-01
      - Returns which days have recordings in the given time range
      - Response: { "data": [{ "year": 2026, "month": 1, "days": [1, 5, 10, ...] }] }

  GET /api/v1/recording/minutes?ch=1&timeBegin=2026-01-15&timeEnd=2026-01-16
      - Returns minute-level recording timeline as JSON
      - Response: { "data": [...] }

Use these endpoints to build a recording timeline calendar UI.
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

    ch = 1
    time_begin = '2026-01-01'
    time_end = '2026-02-01'

    # --- Days with recordings ---
    print(f"=== Recording Days (ch={ch}, {time_begin} ~ {time_end}) ===")
    r = client.get(f'/api/v1/recording/days?ch={ch}&timeBegin={time_begin}&timeEnd={time_end}')
    if r.status_code == 200:
        result = r.json()
        data = result.get('data', [])
        for entry in data:
            # When ch= filter is used, response wraps per-channel: {chid, data: [{year,month,days}]}
            months = entry.get('data', [entry])
            for m in months:
                year = m.get('year')
                month = m.get('month')
                days = m.get('days', [])
                if year is not None and month is not None:
                    print(f"  {year}-{month:02d}: {len(days)} days with recordings")
                    print(f"    Days: {days}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Minute-level timeline ---
    minute_begin = '2026-01-15'
    minute_end = '2026-01-16'
    print(f"\n=== Recording Minutes (ch={ch}, {minute_begin} ~ {minute_end}) ===")
    r = client.get(f'/api/v1/recording/minutes?ch={ch}&timeBegin={minute_begin}&timeEnd={minute_end}')
    if r.status_code == 200:
        result = r.json()
        data = result.get('data', [])
        print(f"  {len(data)} entries returned")
        for entry in data[:10]:  # Show first 10
            print(f"    {entry}")
    else:
        print(f"  Status: {r.status_code}")


if __name__ == '__main__':
    main()
