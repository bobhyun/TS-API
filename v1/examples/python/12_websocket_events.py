"""
12_websocket_events.py - TS-API v1 WebSocket Real-time Event Subscription

Subscribes to real-time events (LPR, channelStatus, notice, etc.) via WebSocket.

Two subscription modes:
  1. URL query params:  ?topics=LPR,channelStatus,notice  (subscribe on connect)
  2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)

Endpoint:
  ws://host:port/wsapi/v1/events

Auth:
  Header: Authorization: Bearer {accessToken}  (primary)
  Header: X-API-Key: {apiKey}                  (alternative)
  Query:  ?token={accessToken}                 (browser fallback)
  Query:  ?apikey={apiKey}                     (browser fallback)

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
    print('REQUIRES: pip install websockets')
    sys.exit(1)

LANG = 'ko-KR'


def print_event(msg):
    """Print LPR and notice events by field; other topics as raw JSON."""
    topic = msg.get('topic')
    if topic == 'LPR':
        # id: record id for plate correction (absent when the record could not be saved)
        # direction: "entry" / "exit" (absent when unknown)
        for p in msg.get('plates') or [msg]:
            print(f'  [LPR] id={p.get("id", "-")} plateNo={p.get("plateNo")} '
                  f'score={p.get("score")} direction={p.get("direction", "-")}')
    elif topic == 'notice':
        # snapshot: current list once after subscribing; raised/updated/cleared: one notice
        # message is keyed by language code: en-US always, plus the requested lang
        notices = msg.get('notices', []) if msg.get('action') == 'snapshot' else [msg.get('notice', {})]
        if not notices:
            print('  [notice] snapshot: (no notices)')
        for n in notices:
            text = n.get('message', {})
            print(f'  [notice] {msg.get("action")} {n.get("id")} {n.get("severity")}: '
                  f'{text.get(LANG, text.get("en-US"))}')
    else:
        print(f'  [{topic or msg.get("type", "?")}] {json.dumps(msg)}')


async def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_ctx.check_hostname = False
    ssl_ctx.verify_mode = ssl.CERT_NONE
    headers = {'X-API-Key': NVR_API_KEY}

    # ── Method 1: Subscribe via URL query params (classic) ──
    print('=== Method 1: Subscribe via URL (10 seconds) ===')

    ws_url = f'{WS_URL}/wsapi/v1/events?topics=LPR,channelStatus,notice&lang={LANG}&apikey={NVR_API_KEY}'
    messages = []

    try:
        async with websockets.connect(ws_url, additional_headers=headers, ssl=ssl_ctx) as ws:
            print('  Connected!')

            async def receive_events():
                try:
                    async for data in ws:
                        try:
                            msg = json.loads(data)
                            messages.append(msg)
                            print_event(msg)
                        except json.JSONDecodeError:
                            print(f'  Raw: {data}')
                except websockets.ConnectionClosed:
                    pass

            try:
                await asyncio.wait_for(receive_events(), timeout=10.0)
            except asyncio.TimeoutError:
                pass

            print(f'  Received {len(messages)} events')

    except Exception as e:
        print(f'  Failed: {e}')

    # ── Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) ──
    #   - Connect WITHOUT topics
    #   - Subscribe/unsubscribe at any time
    #   - Per-topic filters (ch, objectTypes, lot, spot)
    #   - Re-subscribe to update filters
    print('\n=== Method 2: Dynamic Subscribe (10 seconds) ===')

    ws_url2 = f'{WS_URL}/wsapi/v1/events'
    messages2 = []

    try:
        async with websockets.connect(ws_url2, additional_headers=headers, ssl=ssl_ctx) as ws:
            print('  Connected (no topics yet)')

            # Phase 1: Subscribe to initial topics with per-topic filters
            print('  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)')
            await ws.send(json.dumps({'subscribe': 'channelStatus'}))
            await ws.send(json.dumps({'subscribe': 'LPR', 'ch': [1, 2]}))

            async def receive_dynamic():
                try:
                    async for data in ws:
                        try:
                            msg = json.loads(data)
                            messages2.append(msg)

                            # Handle control responses
                            if msg.get('type') == 'subscribed':
                                print(f'  Subscribed to: {msg.get("topic")}')
                                continue
                            if msg.get('type') == 'unsubscribed':
                                print(f'  Unsubscribed from: {msg.get("topic")}')
                                continue
                            if msg.get('type') == 'error':
                                print(f'  Error: {msg.get("message")} (topic: {msg.get("topic", "N/A")})')
                                continue

                            # Handle event data
                            print_event(msg)
                        except json.JSONDecodeError:
                            print(f'  Raw: {data}')
                except websockets.ConnectionClosed:
                    pass

            async def dynamic_flow():
                recv_task = asyncio.create_task(receive_dynamic())

                # Phase 2 (3s): Add new topic + update existing filter
                await asyncio.sleep(3)
                print('  [Phase 2] Add object topic + expand LPR to ch 1-4')
                await ws.send(json.dumps({'subscribe': 'object', 'objectTypes': ['human', 'vehicle']}))
                await ws.send(json.dumps({'subscribe': 'LPR', 'ch': [1, 2, 3, 4]}))

                # Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
                await asyncio.sleep(3)
                print('  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3')
                await ws.send(json.dumps({'unsubscribe': 'channelStatus'}))
                await ws.send(json.dumps({'subscribe': 'motionChanges', 'ch': [1]}))
                await ws.send(json.dumps({'subscribe': 'LPR', 'ch': [1, 3]}))  # re-subscribe replaces the filter (drops ch 2,4)

                await asyncio.sleep(4)
                recv_task.cancel()

            try:
                await asyncio.wait_for(dynamic_flow(), timeout=11.0)
            except (asyncio.TimeoutError, asyncio.CancelledError):
                pass

            print(f'  Received {len(messages2)} messages')

    except Exception as e:
        print(f'  Failed: {e}')


if __name__ == '__main__':
    asyncio.run(main())

# ─────────────────────────────────────────────────
# LPR Event Compatibility
# ─────────────────────────────────────────────────
#
# LPR events may arrive in two formats:
#
#   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
#   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
#
# To handle both formats transparently:
#
#   msg = json.loads(data)
#   if msg.get('topic') == 'LPR':
#       plates = msg.get('plates') or [msg]
#       for p in plates:
#           print(f"Plate: {p.get('plateNo')}  Score: {p.get('score')}")
#
# Each plate carries the record "id" (use it with POST /api/v1/lpr/log/{id}/plate)
# and "direction" as a string ("entry" / "exit"), not a number.
#
