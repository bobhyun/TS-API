"""
09_push.py - TS-API v1 Push Event

Endpoint:
  POST /api/v1/push
      - Push external events into the NVR
      - Requires Push license enabled on the NVR

Event Types:
  1. LPR - Push a license plate recognition result
  2. emergencyCall - Trigger emergency call alarm

  WARNING: emergencyCall with event=callStart triggers a REAL alarm on the NVR.
           The alarm persists until callEnd is sent. Always send callEnd after callStart.

  IMPORTANT: For emergencyCall, you MUST send callEnd to stop the alarm.
             Forgetting callEnd leaves the NVR in alarm state.
"""

import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_API_KEY
from http_client import NvrClient

if not NVR_API_KEY:
    print('NVR_API_KEY environment variable is required')
    sys.exit(1)


def push_lpr_event(client):
    """Push an LPR (license plate recognition) event."""
    print("=== Push LPR Event ===")
    payload = {
        'topic': 'LPR',
        'plateNo': '12AB3456',
        'src': 'booth-01',          # Source booth code (string)
        'when': '2026-01-15 10:30:00',
    }
    r = client.post('/api/v1/push', json=payload)
    print(f"  Status: {r.status_code}")
    if r.status_code == 200:
        print(f"  Response: {r.json()}")
    else:
        print(f"  Ensure Push license is enabled")


def push_emergency_call(client):
    """Push an emergency call event.

    WARNING: callStart triggers a REAL alarm on the NVR!
    You MUST send callEnd to stop it.
    """
    print("\n=== Push Emergency Call ===")
    print("  WARNING: This triggers a REAL alarm on the NVR!")

    # Uncomment the lines below to actually trigger the alarm.
    # Make sure you always send callEnd after callStart.

    # --- Start the emergency call ---
    # print("  Sending callStart...")
    # r = client.post('/api/v1/push', json={
    #     'topic': 'emergencyCall',
    #     'event': 'callStart',
    #     'device': 'intercom-01',   # Device identifier
    #     'src': 'lobby-entrance',   # Source identifier
    # })
    # print(f"  callStart -> {r.status_code}")
    #
    # time.sleep(3)  # Alarm is active for 3 seconds
    #
    # --- MUST send callEnd to stop the alarm ---
    # print("  Sending callEnd...")
    # r = client.post('/api/v1/push', json={
    #     'topic': 'emergencyCall',
    #     'event': 'callEnd',
    #     'device': 'intercom-01',   # Device identifier
    #     'src': 'lobby-entrance',   # Source identifier
    # })
    # print(f"  callEnd -> {r.status_code}")

    print("  (Commented out for safety - uncomment to test)")
    print("  IMPORTANT: Always send callEnd after callStart!")


def main():
    client = NvrClient()
    client.set_api_key(NVR_API_KEY)

    push_lpr_event(client)
    push_emergency_call(client)


if __name__ == '__main__':
    main()
