"""
14_websocket_parking_spot.py - TS-API v1 WebSocket Parking Spot Monitoring

Subscribes to parkingSpot topic for individual spot status changes.

Endpoint:
  ws://host:port/wsapi/v1/events?topics=parkingSpot&token={accessToken}

Auth:
  Header: Authorization: Bearer {accessToken}  (primary)
  Header: X-API-Key: {apiKey}                  (alternative)
  Query:  ?token={accessToken}                 (browser fallback)
  Query:  ?apikey={apiKey}                     (browser fallback)

Optional filters (OR logic):
  &ch=1,2       - spots belonging to channels 1, 2
  &lot=1,2      - spots belonging to parking lots 1, 2
  &spot=100,200  - specific spot IDs

Events:
  currentStatus  - initial full state on connect (all zone types)
  statusChanged  - only changed spots after initial (type="spot" only)

Zone types (in currentStatus):
  spot         - parking space (has occupied, vehicle, category)
  entrance     - entry gate (category=null, no occupied field)
  exit         - exit gate
  noParking    - no-parking zone
  recognition  - recognition-only zone

Note: statusChanged events only fire for type="spot"
Note: chid is 1-based

See also: 13_websocket_parking_lot.py for lot-level count monitoring

REQUIRES: pip install websockets
"""

import asyncio
import json
import os
import ssl
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY, WS_URL
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)

try:
    import websockets
except ImportError:
    print('pip install websockets')
    sys.exit(1)


async def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    print('=== WebSocket Parking Spot Monitoring (30 seconds) ===')
    # Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
    url = (f'{WS_URL}/wsapi/v1/events'
           f'?topics=parkingSpot&apikey={NVR_API_KEY}')
    headers = {'X-API-Key': NVR_API_KEY}

    msg_count = 0

    ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_ctx.check_hostname = False
    ssl_ctx.verify_mode = ssl.CERT_NONE

    async with websockets.connect(url, additional_headers=headers, ssl=ssl_ctx) as ws:
        print('  Connected! Waiting for spot events...\n')

        async def receive():
            nonlocal msg_count
            async for raw in ws:
                msg = json.loads(raw)
                msg_count += 1
                event = msg.get('event', '')
                spots = msg.get('spots', [])

                if event == 'currentStatus':
                    print(f'  [currentStatus] {len(spots)} zones')
                    for s in spots:
                        zone_type = s.get('type', 'spot')
                        if zone_type == 'spot':
                            if s.get('occupied'):
                                v = s.get('vehicle') or {}
                                print(f'    [{s["id"]}] {s.get("name")} ({s.get("category")}): '
                                      f'occupied [{v.get("plateNo", "")} {v.get("score", 0):.1f}%]')
                            else:
                                print(f'    [{s["id"]}] {s.get("name")} ({s.get("category")}): empty')
                        else:
                            print(f'    [{s["id"]}] {s.get("name")} (type={zone_type})')

                elif event == 'statusChanged':
                    # statusChanged only fires for type="spot"
                    for s in spots:
                        status = 'occupied' if s.get('occupied') else 'empty'
                        print(f'  [statusChanged] spot {s["id"]} -> {status}')
                        if s.get('occupied') and s.get('vehicle'):
                            v = s['vehicle']
                            print(f'    plate: {v.get("plateNo")}  score: {v.get("score")}%')

        try:
            await asyncio.wait_for(receive(), timeout=30.0)
        except asyncio.TimeoutError:
            pass

    print(f'\n  Received {msg_count} events')


if __name__ == '__main__':
    asyncio.run(main())
