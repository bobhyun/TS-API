"""
06_lpr_search.py - TS-API v1 LPR (License Plate Recognition)

Endpoints:
  GET /api/v1/lpr/source
      - List LPR-enabled sources (cameras)

  GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
      - Search LPR recognition log (timeBegin and timeEnd are required)

  GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
      - Search for similar plate numbers (fuzzy match)

  GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
      - Export LPR log as downloadable file (CSV/Excel)

WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
  errors. For bulk exports, narrow the time range or use pagination
  (at/maxCount) to keep each request under a manageable size.
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

    # --- LPR Sources ---
    print("=== LPR Sources ===")
    r = client.get('/api/v1/lpr/source')
    if r.status_code == 200:
        sources = r.json()
        for s in sources:
            print(f"  {s}")
    else:
        print(f"  Status: {r.status_code}")

    # --- LPR Log (last 24 hours) ---
    # timeBegin and timeEnd are REQUIRED parameters
    now = datetime.now()
    time_end = now.strftime('%Y-%m-%d %H:%M:%S')
    time_begin = (now - timedelta(hours=24)).strftime('%Y-%m-%d %H:%M:%S')

    print(f"\n=== LPR Log ({time_begin} ~ {time_end}) ===")
    r = client.get('/api/v1/lpr/log', params={
        'timeBegin': time_begin,
        'timeEnd': time_end,
    })
    if r.status_code == 200:
        records = r.json().get('data', [])
        print(f"  {len(records)} records found")
        for rec in records[:5]:  # Show first 5
            print(f"  [{rec.get('timeRange', '')}] plateNo={rec.get('plateNo', '')} "
                  f"ch={rec.get('chid', '')}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Similar Plate Search ---
    plate_query = '1234'  # Partial or similar plate number
    print(f"\n=== Similar Plate Search (keyword={plate_query}) ===")
    r = client.get('/api/v1/lpr/similar', params={
        'keyword': plate_query,
        'timeBegin': time_begin,
        'timeEnd': time_end,
    })
    if r.status_code == 200:
        body = r.json()
        # similar returns flat array of plate strings, or {data:[...]} wrapper
        results = body.get('data', body) if isinstance(body, dict) else body
        print(f"  {len(results)} similar plates found")
        for rec in results[:10]:
            if isinstance(rec, str):
                print(f"    {rec}")
            else:
                print(f"  [{rec.get('timeRange', '')}] plateNo={rec.get('plateNo', '')}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Export LPR Log ---
    print(f"\n=== Export LPR Log ===")
    r = client.get('/api/v1/lpr/log', params={
        'timeBegin': time_begin,
        'timeEnd': time_end,
        'export': 'true',
    })
    if r.status_code == 200:
        content_type = r.headers.get('Content-Type', '')
        print(f"  Content-Type: {content_type}")
        print(f"  Size: {len(r.content)} bytes")
        # Save to file:
        # with open('lpr_export.csv', 'wb') as f:
        #     f.write(r.content)
    else:
        print(f"  Status: {r.status_code}")


if __name__ == '__main__':
    main()
