"""
15_websocket_export.py - TS-API v1 WebSocket Recording Export

Recording data backup/export via WebSocket.

Endpoint:
  ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...&token={accessToken}

Auth:
  Header: Authorization: Bearer {accessToken}  (primary)
  Header: X-API-Key: {apiKey}                  (alternative)
  Query:  ?token={accessToken}                 (browser fallback)
  Query:  ?apikey={apiKey}                     (browser fallback)

Flow:
  1. Connect with channel and time range
  2. Receive stage="ready" with task.id
  3. Receive stage="fileEnd" with download URL
  4. Send { task, cmd: "next" } for next file
  5. Receive stage="end" when complete

REQUIRES: pip install websockets
"""

import asyncio
import json
import os
import ssl
import sys
from datetime import datetime, timedelta

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

    # Time range: yesterday 00:00 ~ 00:10
    yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    time_begin = f'{yesterday}T00:00:00'
    time_end = f'{yesterday}T00:10:00'

    print('=== WebSocket Recording Export ===')
    print(f'  Channel: 1,  {time_begin} ~ {time_end}')

    url = (f'{WS_URL}/wsapi/v1/export'
           f'?ch=1&timeBegin={time_begin}&timeEnd={time_end}&apikey={NVR_API_KEY}')
    headers = {'X-API-Key': NVR_API_KEY}

    task_id = None

    ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_ctx.check_hostname = False
    ssl_ctx.verify_mode = ssl.CERT_NONE

    async with websockets.connect(url, additional_headers=headers, ssl=ssl_ctx) as ws:
        print('  Connected')

        async def receive():
            nonlocal task_id
            async for raw in ws:
                msg = json.loads(raw)
                stage = msg.get('stage', '')

                if stage == 'ready':
                    # Check status code (code:-1 = no recording in range)
                    status = msg.get('status', {})
                    if status.get('code', 0) != 0:
                        print(f'  Ready - Error: {status.get("message", msg)}')
                        return
                    task_id = msg.get('task', {}).get('id')
                    print(f'  Ready - Task ID: {task_id}')

                elif stage == 'fileEnd':
                    # download: [{fileName, src}, ...]
                    dl_arr = msg.get('channel', {}).get('file', {}).get('download', [])
                    src = dl_arr[0].get('src', 'N/A') if dl_arr else 'N/A'
                    print(f'  File ready: {src}')
                    if task_id:
                        await ws.send(json.dumps({'task': str(task_id), 'cmd': 'next'}))

                elif stage == 'end':
                    print('  Export complete!')
                    return

                elif stage == 'error':
                    print(f'  Error: {msg.get("message", msg)}')
                    return

                else:
                    print(f'  [{stage}] {json.dumps(msg)}')

        try:
            await asyncio.wait_for(receive(), timeout=60)
        except asyncio.TimeoutError:
            print('  Timeout - cancelling...')
            if task_id:
                await ws.send(json.dumps({'task': str(task_id), 'cmd': 'cancel'}))


if __name__ == '__main__':
    asyncio.run(main())
