/**
 * TS-API Examples - Minimal HTTP Client
 *
 * Node.js built-in http module wrapper. No external dependencies required.
 * v1 API uses JWT Bearer token authentication (not session cookies).
 */

const https = require('https');
const http = require('http');
const { BASE_URL, NVR_HOST, NVR_PORT } = require('./config');
const httpModule = BASE_URL.startsWith('https') ? https : http;

let _accessToken = '';
let _refreshToken = '';
let _apiKey = '';

/**
 * Set API Key for subsequent requests.
 * When set, requests will include X-API-Key header.
 * @param {string} key - The API key
 */
function setApiKey(key) { _apiKey = key; }

/**
 * Make HTTP request to NVR API
 * @param {string} method - HTTP method (GET, POST, PUT, DELETE)
 * @param {string} path - API path (e.g. '/api/v1/channel')
 * @param {object} [body] - Request body (will be JSON-serialized)
 * @param {object} [headers] - Additional headers
 * @returns {Promise<{status: number, headers: object, body: any}>}
 */
function request(method, path, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);

    const opts = {
      hostname: url.hostname,
      port: url.port || (BASE_URL.startsWith('https') ? 443 : 80),
      path: url.pathname + url.search,
      method,
      rejectUnauthorized: false,  // allow self-signed certificates
      headers: {
        'Content-Type': 'application/json',
        'X-Host': `${NVR_HOST}:${NVR_PORT}`,
        ...(_apiKey ? { 'X-API-Key': _apiKey } : {}),
        ...(_accessToken ? { 'Authorization': `Bearer ${_accessToken}` } : {}),
        ...headers,
      },
    };

    const req = httpModule.request(opts, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        let parsed = null;
        try { parsed = data ? JSON.parse(data) : null; }
        catch { parsed = data; }

        resolve({ status: res.statusCode, headers: res.headers, body: parsed });
      });
    });

    req.on('error', reject);

    if (body !== undefined && body !== null) {
      req.write(typeof body === 'string' ? body : JSON.stringify(body));
    }
    req.end();
  });
}

/** GET request */
const get = (path, headers) => request('GET', path, null, headers);

/** POST request */
const post = (path, body, headers) => request('POST', path, body, headers);

/** PUT request */
const put = (path, body, headers) => request('PUT', path, body, headers);

/** DELETE request */
const del = (path, headers) => request('DELETE', path, null, headers);

/**
 * Login via JWT and store tokens for subsequent requests.
 * @returns {Promise<boolean>} true if login succeeded
 */
async function login(username, password) {
  const auth = Buffer.from(`${username}:${password}`).toString('base64');
  const res = await post('/api/v1/auth/login', { auth });
  if (res.status === 200 && res.body) {
    _accessToken = res.body.accessToken || '';
    _refreshToken = res.body.refreshToken || '';
    return true;
  }
  return false;
}

/** Logout - revoke refresh token and clear stored tokens */
async function logout() {
  if (_refreshToken) {
    await post('/api/v1/auth/logout', { refreshToken: _refreshToken });
  }
  _accessToken = '';
  _refreshToken = '';
}

/**
 * JWT login - returns { accessToken, refreshToken, expiresIn, tokenType, user } or null
 */
async function jwtLogin(username, password) {
  const auth = Buffer.from(`${username}:${password}`).toString('base64');
  const res = await post('/api/v1/auth/login', { auth });
  return res.status === 200 ? res.body : null;
}

/**
 * Refresh access token using refresh token.
 * Server performs token rotation: old refreshToken is revoked.
 * Returns { accessToken, refreshToken, expiresIn, tokenType } or null
 */
async function jwtRefresh(refreshToken) {
  const res = await post('/api/v1/auth/refresh', { refreshToken });
  if (res.status === 200 && res.body) {
    _accessToken = res.body.accessToken || _accessToken;
    _refreshToken = res.body.refreshToken || _refreshToken;
    return res.body;
  }
  return null;
}

/**
 * JWT logout - revoke refresh token
 */
async function jwtLogout(refreshToken) {
  return post('/api/v1/auth/logout', { refreshToken });
}

/** Get current access token */
function getAccessToken() { return _accessToken; }

/** Get current refresh token */
function getRefreshToken() { return _refreshToken; }

module.exports = {
  request, get, post, put, del,
  login, logout,
  jwtLogin, jwtRefresh, jwtLogout,
  getAccessToken, getRefreshToken,
  setApiKey,
};
