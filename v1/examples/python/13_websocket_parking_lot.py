"""
13_websocket_parking_lot.py - TS-API v1 WebSocket Parking Lot Count Monitoring

Subscribes to parkingCount topic for real-time lot occupancy changes.

Endpoint:
  ws://host:port/wsapi/v1/events?topics=parkingCount&token={accessToken}

Auth:
  Header: Authorization: Bearer {accessToken}  (primary)
  Header: X-API-Key: {apiKey}                  (alternative)
  Query:  ?token={accessToken}                 (browser fallback)
  Query:  ?apikey={apiKey}                     (browser fallback)

Optional filter: &lot=1,2 (filter by parking lot ID)

See also: 14_websocket_parking_spot.py for individual spot monitoring

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

    print('=== WebSocket Parking Count Monitoring (30 seconds) ===')
    # Optional filter: &lot=1,2
    url = (f'{WS_URL}/wsapi/v1/events'
           f'?topics=parkingCount&apikey={NVR_API_KEY}')
    headers = {'X-API-Key': NVR_API_KEY}

    msg_count = 0

    ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_ctx.check_hostname = False
    ssl_ctx.verify_mode = ssl.CERT_NONE

    async with websockets.connect(url, additional_headers=headers, ssl=ssl_ctx) as ws:
        print('  Connected! Waiting for parking count events...\n')

        async def receive():
            nonlocal msg_count
            async for raw in ws:
                msg = json.loads(raw)
                msg_count += 1

                # First message is subscription confirmation
                if 'subscriberId' in msg:
                    print(f'  Subscribed (id={msg["subscriberId"]})')
                    continue

                # parkingCount: {topic, updated: [{id, name, type, maxCount, count}, ...]}
                for lot in msg.get('updated', []):
                    available = (lot.get('maxCount', 0) or 0) - (lot.get('count', 0) or 0)
                    print(f'  [{lot.get("id")}] {lot.get("name")} ({lot.get("type")}): '
                          f'{lot.get("count")}/{lot.get("maxCount")} '
                          f'(available={available})')

        try:
            await asyncio.wait_for(receive(), timeout=30.0)
        except asyncio.TimeoutError:
            pass

    print(f'\n  Received {msg_count} events')


if __name__ == '__main__':
    asyncio.run(main())
