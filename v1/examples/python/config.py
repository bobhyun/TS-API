"""
TS-API Examples - Shared Configuration

Environment variables:
  NVR_HOST    - NVR server hostname (default: localhost)
  NVR_SCHEME  - http or https (default: https)
  NVR_PORT    - NVR server port (default: 443 for https, 80 for http)
  NVR_USER    - Login username (default: admin)
  NVR_PASS    - Login password (default: 1234)
  NVR_API_KEY - API Key for v1 endpoints (used by examples 02-16)

Usage:
  NVR_API_KEY=tsapi_key_... python v1/02_channels.py
  NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... python v1/02_channels.py
  NVR_SCHEME=http NVR_PORT=80 python v1/01_login.py
"""

import os
import sys

# Fix Windows console encoding for Korean text output
if sys.platform == 'win32' and hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

NVR_HOST = os.environ.get('NVR_HOST', 'localhost')
NVR_SCHEME = os.environ.get('NVR_SCHEME', 'https')
NVR_PORT = os.environ.get('NVR_PORT', '443' if NVR_SCHEME == 'https' else '80')
NVR_USER = os.environ.get('NVR_USER', 'admin')
NVR_PASS = os.environ.get('NVR_PASS', '1234')
NVR_API_KEY = os.environ.get('NVR_API_KEY', '')

_default_port = '443' if NVR_SCHEME == 'https' else '80'
_port_suffix = '' if NVR_PORT == _default_port else f':{NVR_PORT}'
BASE_URL = f'{NVR_SCHEME}://{NVR_HOST}{_port_suffix}'
WS_SCHEME = 'wss' if NVR_SCHEME == 'https' else 'ws'
WS_URL = f'{WS_SCHEME}://{NVR_HOST}{_port_suffix}'
