"""
06_lpr_search.py - TS-API v1 LPR (License Plate Recognition)

Endpoints:
  GET /api/v1/lpr/source
      - List LPR-enabled sources (cameras)

  GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
      - Search LPR recognition log (timeBegin and timeEnd are required)

  GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
      - Plates containing the keyword (partial or misread plates)

  GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
      - Export the LPR log as CSV

  GET  /api/v1/lpr/log/{id}/plate/history
      - Plate correction history of one record (Playback permission)
  POST /api/v1/lpr/log/{id}/plate   {"plateNo": "...", "reason": "..."}
      - Correct the plate of one record (Control permission, not executed here)

WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
  Narrow the time range or page with at/maxCount.
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
    time_end = now.strftime('%Y-%m-%dT%H:%M:%S')
    time_begin = (now - timedelta(hours=24)).strftime('%Y-%m-%dT%H:%M:%S')

    print(f"\n=== LPR Log ({time_begin} ~ {time_end}) ===")
    r = client.get('/api/v1/lpr/log', params={
        'timeBegin': time_begin,
        'timeEnd': time_end,
    })
    if r.status_code == 200:
        records = r.json().get('data', [])
        print(f"  {len(records)} records found")
        for rec in records[:5]:  # Show first 5
            # plateNo is null when no plate was read; direction is "entry"/"exit" or absent
            line = (f"  [{rec['id']}] {rec.get('timeRange', '')} "
                    f"plateNo={rec.get('plateNo') or '(unrecognized)'} "
                    f"direction={rec.get('direction', '-')}")
            if rec.get('plateEdited'):
                line += f" (corrected, originally {rec.get('originalPlateNo') or '(unrecognized)'})"
            print(line)
    else:
        records = []
        print(f"  Status: {r.status_code}")

    # --- Similar Plate Search ---
    plate_query = '1234'  # Partial plate number
    print(f"\n=== Similar Plate Search (keyword={plate_query}) ===")
    r = client.get('/api/v1/lpr/similar', params={
        'keyword': plate_query,
        'timeBegin': time_begin,
        'timeEnd': time_end,
    })
    if r.status_code == 200:
        body = r.json()
        # Response: array of plate strings, most recent first
        results = body.get('data', body) if isinstance(body, dict) else body
        print(f"  {len(results)} similar plates found")
        for rec in results[:10]:
            if isinstance(rec, str):
                print(f"    {rec}")
            else:
                print(f"  [{rec.get('timeRange', '')}] plateNo={rec.get('plateNo', '')}")
    else:
        print(f"  Status: {r.status_code}")

    # --- Plate Correction History (one record, by id) ---
    # plateNo in the log is always the current value.
    # edits[] lists corrections in recorded order; it is empty if the record was never corrected.
    if records:
        rec_id = records[0]['id']
        print(f"\n=== Plate Correction History (id={rec_id}) ===")
        r = client.get(f'/api/v1/lpr/log/{rec_id}/plate/history')
        if r.status_code == 200:
            h = r.json()
            print(f"  plateNo={h.get('plateNo')} original={h.get('originalPlateNo', '(never corrected)')}")
            for e in h.get('edits', []):
                print(f"    {e['time']} {e['user']}: {e['before']} -> {e['after']} {e.get('reason', '')}")
        else:
            print(f"  Status: {r.status_code}")

    # --- Plate Correction (Control permission) ---
    # Changes the stored record, so it is not executed here. The target is always
    # one record id - from data[].id above, or the id a realtime LPR event carries
    # next to each plateNo. 409 when plateNo equals the current plate.
    #
    # Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
    # Uncomment it to try it against a test record.
    #   client.post(f'/api/v1/lpr/log/{rec_id}/plate',
    #               json={'plateNo': '12가3456', 'reason': 'misread at night'})

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
