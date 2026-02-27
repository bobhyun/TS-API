"""
TS-API Examples - HTTP Client Helper

Uses 'requests' library. Install: pip install requests
v1 API supports JWT Bearer token and API Key authentication.
"""

import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

from config import BASE_URL, NVR_HOST, NVR_PORT


class NvrClient:
    """Simple HTTP client for TS-API with JWT Bearer and API Key authentication."""

    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False
        self.session.headers.update({
            'Content-Type': 'application/json',
            'X-Host': f'{NVR_HOST}:{NVR_PORT}',
        })
        self._access_token = ''
        self._refresh_token = ''
        self._api_key = ''

    def set_api_key(self, key):
        """Set API Key for X-API-Key header authentication (v1 endpoints only)."""
        self._api_key = key
        if key:
            self.session.headers['X-API-Key'] = key
        else:
            self.session.headers.pop('X-API-Key', None)

    def _set_auth(self):
        """Set Authorization header from stored access token."""
        if self._access_token:
            self.session.headers['Authorization'] = f'Bearer {self._access_token}'
        else:
            self.session.headers.pop('Authorization', None)

    def get(self, path, **kwargs):
        return self.session.get(f'{BASE_URL}{path}', **kwargs)

    def post(self, path, json=None, **kwargs):
        return self.session.post(f'{BASE_URL}{path}', json=json, **kwargs)

    def put(self, path, json=None, **kwargs):
        return self.session.put(f'{BASE_URL}{path}', json=json, **kwargs)

    def delete(self, path, **kwargs):
        return self.session.delete(f'{BASE_URL}{path}', **kwargs)

    def login(self, username, password):
        """Login via JWT and store tokens for subsequent requests."""
        import base64
        auth = base64.b64encode(f'{username}:{password}'.encode()).decode()
        r = self.post('/api/v1/auth/login', json={'auth': auth})
        if r.status_code == 200:
            data = r.json()
            self._access_token = data.get('accessToken', '')
            self._refresh_token = data.get('refreshToken', '')
            self._set_auth()
            return True
        return False

    def logout(self):
        """Logout - revoke refresh token and clear stored tokens."""
        if self._refresh_token:
            self.post('/api/v1/auth/logout', json={
                'refreshToken': self._refresh_token,
            })
        self._access_token = ''
        self._refresh_token = ''
        self._set_auth()

    def jwt_login(self, username, password):
        """JWT login. Returns {accessToken, refreshToken, expiresIn, tokenType, user} or None."""
        import base64
        auth = base64.b64encode(f'{username}:{password}'.encode()).decode()
        r = self.post('/api/v1/auth/login', json={'auth': auth})
        if r.status_code == 200:
            return r.json()
        return None

    def jwt_refresh(self, refresh_token):
        """Refresh access token. Server performs token rotation: old refreshToken is revoked.
        Returns {accessToken, refreshToken, expiresIn, tokenType} or None."""
        r = self.post('/api/v1/auth/refresh', json={
            'refreshToken': refresh_token,
        })
        if r.status_code == 200:
            data = r.json()
            self._access_token = data.get('accessToken', self._access_token)
            self._refresh_token = data.get('refreshToken', self._refresh_token)
            self._set_auth()
            return data
        return None

    def jwt_logout(self, refresh_token):
        """JWT logout - revoke refresh token."""
        self.post('/api/v1/auth/logout', json={
            'refreshToken': refresh_token,
        })
