"""
01_login.py - TS-API v1 Authentication Methods

Three authentication methods:
  1. Client login - NvrClient logs in with JWT and sends the Bearer token automatically
  2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
  3. API Key      - X-API-Key header, for external integrations

NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.
"""

import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NVR_USER, NVR_PASS, BASE_URL
from http_client import NvrClient


def demo_session_login():
    """Method 1: Client login.

    POST /api/v1/auth/login with {"auth": "base64(username:password)"}
    NvrClient stores the JWT and sends it as a Bearer token.
    """
    print("=== Session Login ===")
    client = NvrClient()

    # Credentials go in the JSON body, not the URL
    ok = client.login(NVR_USER, NVR_PASS)
    print(f"Login: {'OK' if ok else 'FAILED'}")

    if ok:
        # Token is stored; data endpoints are accessible
        r = client.get('/api/v1/channel')
        print(f"GET /api/v1/channel -> {r.status_code}")

        # Log out to revoke the refreshToken
        client.logout()
        print("Logged out")


def demo_jwt():
    """Method 2: JWT Token (accessToken + refreshToken).

    POST /api/v1/auth/login -> {accessToken, refreshToken, expiresIn, tokenType}
    POST /api/v1/auth/refresh -> {accessToken, refreshToken, expiresIn, tokenType} (rotates refreshToken)
    POST /api/v1/auth/logout  (revoke refreshToken)
    """
    print("\n=== JWT Login ===")
    client = NvrClient()

    # 1) Login -> accessToken + refreshToken
    tokens = client.jwt_login(NVR_USER, NVR_PASS)
    if not tokens:
        print("JWT login failed")
        return

    access_token = tokens['accessToken']
    refresh_token = tokens['refreshToken']
    print(f"Access Token:  {access_token[:30]}...")
    print(f"Refresh Token: {refresh_token[:30]}...")
    print(f"Expires In:    {tokens['expiresIn']}s")

    # 2) Use accessToken for API calls
    r = client.get('/api/v1/auth/apikey',
                    headers={'Authorization': f'Bearer {access_token}'})
    print(f"GET /api/v1/auth/apikey -> {r.status_code}")

    # 3) Refresh accessToken
    new_tokens = client.jwt_refresh(refresh_token)
    if new_tokens:
        print(f"Refreshed:     {new_tokens['accessToken'][:30]}...")

    # 4) Logout (revoke refreshToken)
    client.jwt_logout(refresh_token)
    print("JWT logged out (refreshToken revoked)")


def demo_api_key():
    """Method 3: API Key (create -> use -> list -> delete).

    POST /api/v1/auth/apikey        (create, requires admin JWT)
    X-API-Key header                (use, v1 endpoints only)
    GET /api/v1/auth/apikey         (list)
    DELETE /api/v1/auth/apikey/{id} (delete)
    """
    print("\n=== API Key ===")
    client = NvrClient()

    # 1) Get an admin token via JWT login
    token_data = client.jwt_login(NVR_USER, NVR_PASS)
    if not token_data:
        print("JWT login failed")
        return
    token = token_data['accessToken']
    auth = {'Authorization': f'Bearer {token}'}

    # 2) Create API Key
    r = client.post('/api/v1/auth/apikey', json={
        'name': 'example-integration',
        # 'permissions': ['remote'],         # optional: permissions (default: remote)
        # 'channels': [1, 2],                # optional: allowed channels
        # 'ipWhitelist': ['192.168.0.0/24'], # optional: allowed client IPs
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

    # 3) Call a data endpoint with the API Key (no login required)
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
