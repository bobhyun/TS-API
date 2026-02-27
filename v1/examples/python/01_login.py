"""
01_login.py - TS-API v1 Authentication Methods

Three authentication methods:
  1. Session Login   - POST /api/v1/auth/login (JSON body, cookie-based)
  2. JWT Token       - POST /api/v1/auth/login (JSON body, token-based)
  3. API Key         - X-API-Key header (v1 endpoints only)

NOTE: JWT tokens only work on /api/v1/auth/* endpoints.
      For data endpoints (channels, events, etc.), use Legacy Session or API Key.
NOTE: API Key authentication is supported on v1 endpoints only.
      v0 endpoints (/api/*) reject X-API-Key with 401 Unauthorized.
"""

import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_USER, NVR_PASS, BASE_URL
from http_client import NvrClient


def demo_session_login():
    """Method 1: Session Login (POST with JSON body).

    POST /api/v1/auth/login with {"auth": "base64(username:password)"}
    The server sets a session cookie on successful login.
    All subsequent requests carry the cookie automatically.
    """
    print("=== Session Login ===")
    client = NvrClient()

    # Login via POST (credentials in JSON body, not URL)
    ok = client.login(NVR_USER, NVR_PASS)
    print(f"Login: {'OK' if ok else 'FAILED'}")

    if ok:
        # Session cookie is now set; data endpoints work
        r = client.get('/api/v1/channel')
        print(f"GET /api/v1/channel -> {r.status_code}")

        # Always logout to release the session
        client.logout()
        print("Logged out")


def demo_jwt():
    """Method 2: JWT Token (accessToken + refreshToken).

    POST /api/v1/auth/login -> {accessToken, refreshToken, expiresIn, tokenType}
    POST /api/v1/auth/refresh -> {accessToken, expiresIn, tokenType}
    POST /api/v1/auth/logout  (revoke refreshToken)
    """
    print("\n=== JWT Login ===")
    client = NvrClient()

    # 1) Login -> get accessToken + refreshToken
    tokens = client.jwt_login(NVR_USER, NVR_PASS)
    if not tokens:
        print("JWT login failed")
        return

    access_token = tokens['accessToken']
    refresh_token = tokens['refreshToken']
    print(f"Access Token:  {access_token[:30]}...")
    print(f"Refresh Token: {refresh_token[:30]}...")
    print(f"Expires In:    {tokens['expiresIn']}s")

    # 2) Use accessToken for auth endpoints
    r = client.get('/api/v1/auth/apikey',
                    headers={'Authorization': f'Bearer {access_token}'})
    print(f"GET /api/v1/auth/apikey -> {r.status_code}")

    # 3) Refresh accessToken using refreshToken
    new_tokens = client.jwt_refresh(refresh_token)
    if new_tokens:
        print(f"Refreshed:     {new_tokens['accessToken'][:30]}...")

    # 4) Logout (revoke refreshToken)
    client.jwt_logout(refresh_token)
    print("JWT logged out (refreshToken revoked)")


def demo_api_key():
    """Method 3: API Key (Create -> Use -> List -> Delete).

    POST /api/v1/auth/apikey        (Create, admin JWT required)
    X-API-Key header                (Use, v1 endpoints only)
    GET /api/v1/auth/apikey         (List)
    DELETE /api/v1/auth/apikey/{id} (Delete)

    NOTE: API Key only works on v1 endpoints (/api/v1/*).
          v0 endpoints (/api/*) reject API Key with 401.
    """
    print("\n=== API Key ===")
    client = NvrClient()

    # 1) Obtain admin token via JWT login
    token_data = client.jwt_login(NVR_USER, NVR_PASS)
    if not token_data:
        print("JWT login failed")
        return
    token = token_data['accessToken']
    auth = {'Authorization': f'Bearer {token}'}

    # 2) Create API Key
    r = client.post('/api/v1/auth/apikey', json={
        'name': 'example-integration',
        # 'permissions': ['remote'],       # Optional: specify permissions (default: remote)
        # 'channels': [1, 2],              # Optional: restrict accessible channels
        # 'ipWhitelist': ['192.168.0.0/24'], # Optional: IP restriction
    }, headers=auth)
    print(f"Create API Key: {r.status_code}")
    if r.status_code != 200:
        return

    data = r.json()
    key_id = data['id']
    api_key = data['key']
    print(f"  Key ID: {key_id}")
    print(f"  API Key: {api_key[:24]}...")
    if 'message' in data:
        print(f"  WARNING: {data['message']}")

    # 3) Access data endpoints using API Key (no login required)
    r = client.get('/api/v1/channel', headers={'X-API-Key': api_key})
    print(f"Use API Key -> GET /api/v1/channel: {r.status_code}")

    # 4) List API Keys
    r = client.get('/api/v1/auth/apikey', headers=auth)
    print(f"List API Keys: {r.status_code} ({len(r.json())} keys)")

    # 5) Delete API Key
    r = client.delete(f'/api/v1/auth/apikey/{key_id}', headers=auth)
    print(f"Delete API Key: {r.status_code}")


if __name__ == '__main__':
    demo_session_login()
    demo_jwt()
    demo_api_key()
