"""
10_parking.py - TS-API v1 Parking

Endpoints:
  GET /api/v1/parking/lot           - List parking lots
  GET /api/v1/parking/lot/status    - Parking lot occupancy status
  GET /api/v1/parking/spot          - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
  GET /api/v1/parking/spot/status   - Status of each parking spot
  GET /api/v1/info?license          - License check (parkingHistory extension token)
  GET /api/v1/parking/session        - Parking session history
  GET /api/v1/parking/session/{id}   - One session with its payment history
  GET /api/v1/parking/session/{id}/plate/history - Plate correction history of one session
  POST /api/v1/parking/session/{id}/plate        - Correct the session plate (not executed here)
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

    # --- Parking Session History ---
    # A session opens when a vehicle is confirmed present and closes when it
    # leaves. Requires the parking history license (403 without it).
    # Check /api/v1/info first: the `parkingHistory` extension token tells
    # whether the session endpoints are available. license.extension is
    # omitted when no extension is active.
    r = client.get('/api/v1/info?license')
    extension = r.json().get('license', {}).get('extension', []) if r.status_code == 200 else []
    if 'parkingHistory' not in extension:
        print("\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples")
        return

    print("\n=== Currently Parked ===")
    r = client.get('/api/v1/parking/session', params={'open': 'true', 'maxCount': 10})
    if r.status_code == 200:
        body = r.json()
        print(f"  total={body['totalCount']} asOf={body['asOf']}")
        for row in body['data']:
            mins = row['durationMs'] // 60000
            edited = ' (corrected)' if row.get('plateEdited') else ''
            print(f"  [{row['id']}] {row['src']['name']} {row.get('plateNo') or '(no plate)'}{edited} {mins}m")
    else:
        print(f"  Status: {r.status_code}")

    # --- Session Detail ---
    # outKind / outTimeMeans tell how the exit time was determined.
    # Only "observed" is a measurement; the others are estimates that can err
    # in different directions, so bill from the basis, not from the time alone.
    #
    # inKind / inTimeMeans do the same for the entry, but err the opposite way:
    # firstSeen is an upper bound on the real entry (the vehicle was already
    # there when observation started). Unlike the exit basis, it is present on
    # open sessions too, so do not read it inside an `if not open` branch.
    print("\n=== Session Detail ===")
    r = client.get('/api/v1/parking/session', params={'maxCount': 1})
    rows = r.json()['data'] if r.status_code == 200 else []
    if rows:
        r = client.get(f"/api/v1/parking/session/{rows[0]['id']}")
        if r.status_code == 200:
            d = r.json()
            print(f"  {json.dumps(d, ensure_ascii=False)[:400]}")
            print(f"  entry basis: {d['inKind']} ({d['inTimeMeans']})")
            if not d['open']:
                print(f"  exit basis: {d['outKind']} ({d['outTimeMeans']})")
    else:
        print("  (no sessions yet)")

    # --- Scope: what the query is scoped to ---
    # Omitting the items means "the whole scope", not "no filter":
    # scope=lot without a lot list returns only sessions that belong to a
    # parking lot, so no-parking-zone sessions (which belong to no lot) are
    # excluded.
    print('\n=== By channel / whole lot scope / no-parking zones ===')
    for params in (
        {'scope': 'channel', 'ch': '1,2', 'maxCount': 5},
        {'scope': 'lot', 'maxCount': 5},
        {'scope': 'noparking', 'maxCount': 5},
    ):
        r = client.get('/api/v1/parking/session', params=params)
        n = r.json()['totalCount'] if r.status_code == 200 else -1
        print(f"  scope={params['scope']:<10} totalCount={n}")

    # --- Video for a session: otherwise=nearBefore ---
    # A parked car does not move, so motion-triggered recording may stop
    # while it is still there. Because the car stays in place, earlier
    # footage still shows it. Use otherwise=nearBefore for parking history only.
    # An empty result means no usable recording exists (never recorded, or
    # already recycled); the session snapshots are still available.
    print('\n=== Video at entry time (nearest earlier if none) ===')
    r = client.get('/api/v1/parking/session', params={'maxCount': 1})
    rows = r.json()['data'] if r.status_code == 200 else []
    if rows:
        d = client.get(f"/api/v1/parking/session/{rows[0]['id']}").json()
        # snapshots is a time-ordered array, not a map; each entry carries tags.
        # Several shots can share a tag (best shots), so find by tag and use the first (earliest).
        def tagged(snaps, tag):
            return next((x for x in (snaps or []) if tag in (x.get('tags') or [])), {})

        shot = tagged(d.get('snapshots'), 'in')
        chid, at = shot.get('chid'), shot.get('time')

        # Which shots read the plate: bestshot = attempted, plate = succeeded.
        # A failed shot keeps its image (plateNo is null) so a person can review it later.
        print('  snapshots:')
        for x in (d.get('snapshots') or []):
            print(f"    {x.get('time') or 'now'}  tags={','.join(x.get('tags') or [])}"
                  f"  plate={x.get('plateNo') or '-'}")
        if chid is not None and at:
            v = client.get('/api/v1/vod',
                           params={'ch': chid, 'when': at, 'otherwise': 'nearBefore'})
            srcs = v.json() if v.status_code == 200 else []
            print(f"  ch={chid} when={at} -> {len(srcs)} channel(s)")
            if not srcs:
                print('  (no recorded video at or before this time)')

    # --- Which car is it? the bounding box ---
    # A snapshot can contain several cars; `box` marks the one this session
    # is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
    # Multiply by the size of the surface you draw on; the internal
    # coordinate space does not matter.
    # Entrance/exit sessions have no vehicle box (a single plate read):
    # the value is null, but the key is always present.
    print('\n=== Bounding box of the session vehicle ===')
    if rows:
        box = client.get(f"/api/v1/parking/session/{rows[0]['id']}").json().get('box')
        if not box:
            print('  (no box for this session)')
        else:
            W, H = 1920, 1080          # drawing surface size
            left = int((box['cx'] - box['w'] / 2) * W)
            top = int((box['cy'] - box['h'] / 2) * H)
            print(f"  box = {box}")
            print(f"  on {W}x{H} -> left={left} top={top} "
                  f"width={int(box['w'] * W)} height={int(box['h'] * H)}")

    # --- Plate correction history ---
    # Only the session's representative plate (plateNo) is corrected; per-shot
    # readings (snapshots[].plateNo) are kept as evidence.
    # Reading requires Playback permission.
    print('\n=== Plate correction history ===')
    if rows:
        sid = rows[0]['id']
        r = client.get(f"/api/v1/parking/session/{sid}/plate/history")
        if r.status_code == 200:
            h = r.json()
            print(f"  session={h['id']} plateNo={h.get('plateNo')} "
                  f"original={h.get('originalPlateNo', '(never corrected)')}")
            for e in h.get('edits', []):
                print(f"    {e['time']} {e['user']}: {e['before']} -> {e['after']} {e.get('reason', '')}")
        else:
            print(f"  Status: {r.status_code}")

    # --- Writing history (Control permission) ---
    # These calls change stored history, so they are not executed here.
    # Payment state (16.7): commit settles it, exempt records a decision not to
    # collect, and undo reverts the most recent change (the response says which).
    # Records are appended, never deleted.
    #
    # close (16.8) is separate: it ends a session whose exit was never observed
    # and would otherwise stay "parked". exempt removes a session from billing
    # but may leave it parked; close ends it. Do not confuse the two.
    #
    #   client.post(f'/api/v1/parking/session/{sid}/payment/commit', params={'ref': 'POS-0042'})
    #   client.post(f'/api/v1/parking/session/{sid}/payment/exempt')
    #   client.post(f'/api/v1/parking/session/{sid}/payment/undo')
    #   client.post(f'/api/v1/parking/session/{sid}/close')
    #
    # Plate correction (16.9): one session by id; no bulk correction or merging.
    # Payments stay with the session. Returns 409 when plateNo equals the current plate.
    #
    # Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
    # Uncomment it to try it against a test record.
    #   client.post(f'/api/v1/parking/session/{sid}/plate',
    #               json={'plateNo': '12가3456', 'reason': 'misread at night'})


if __name__ == '__main__':
    main()
