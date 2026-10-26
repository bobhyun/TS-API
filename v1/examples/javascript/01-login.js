/**
 * Example 01: Authentication
 *
 * Three authentication methods:
 *   1. Client login - http.js logs in with JWT and sends the Bearer token automatically
 *   2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
 *   3. API Key      - X-API-Key header, for external integrations
 *
 * NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
 * NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.
 */

const { NVR_USER, NVR_PASS } = require('./config');
const { request, get, post, login, logout, jwtLogin, jwtRefresh, jwtLogout, getAccessToken } = require('./http');

async function main() {
  // ─────────────────────────────────────────────────
  // Method 1: Client login (JWT stored by http.js)
  //   POST /api/v1/auth/login
  //   Subsequent requests send the Bearer token automatically
  // ─────────────────────────────────────────────────
  console.log('=== Simple Login ===');

  const ok = await login(NVR_USER, NVR_PASS);
  console.log('Login:', ok ? 'OK' : 'Failed');
  console.log('Access Token:', getAccessToken().substring(0, 30) + '...');

  // Token is stored; data endpoints are accessible
  const channelRes = await get('/api/v1/channel');
  console.log('Channels:', channelRes.status, Array.isArray(channelRes.body) ? `(${channelRes.body.length} channels)` : '');

  await logout();
  console.log('Logged out\n');

  // ─────────────────────────────────────────────────
  // Method 2: JWT (manage tokens yourself)
  // ─────────────────────────────────────────────────
  console.log('=== JWT Login ===');

  // 1) Login -> accessToken + refreshToken
  const tokens = await jwtLogin(NVR_USER, NVR_PASS);
  if (tokens) {
    const { accessToken, refreshToken, expiresIn } = tokens;
    console.log('Access Token: ', accessToken.substring(0, 30) + '...');
    console.log('Refresh Token:', refreshToken.substring(0, 30) + '...');
    console.log('Expires In:   ', expiresIn, 'seconds');
    if (tokens.user) {
      console.log('User:         ', tokens.user.username, `(${tokens.user.role})`);
    }

    // 2) Use accessToken for API calls
    const apikeyList = await get('/api/v1/auth/apikey', {
      'Authorization': `Bearer ${accessToken}`,
    });
    console.log('API Key List:', apikeyList.status);

    // 3) Refresh accessToken
    //    NOTE: The server rotates refreshToken: the old one is revoked
    const refreshed = await jwtRefresh(refreshToken);
    if (refreshed) {
      console.log('Refreshed:    ', refreshed.accessToken.substring(0, 30) + '...');
      console.log('New Refresh:  ', refreshed.refreshToken.substring(0, 30) + '...');
    }

    // 4) Logout (revoke refreshToken)
    //    Use the new refreshToken after rotation
    await jwtLogout(refreshed ? refreshed.refreshToken : refreshToken);
    console.log('JWT logged out (refreshToken revoked)');
  } else {
    console.log('JWT Login failed');
  }

  console.log('');

  // ─────────────────────────────────────────────────
  // Method 3: API Key (create -> use -> list -> delete)
  //   POST /api/v1/auth/apikey        (create, requires admin JWT)
  //   X-API-Key header                (use, v1 endpoints only)
  //   GET /api/v1/auth/apikey         (list)
  //   DELETE /api/v1/auth/apikey/{id} (delete)
  // ─────────────────────────────────────────────────
  console.log('=== API Key ===');

  // 1) Get an admin token via JWT login
  const authTokens = await jwtLogin(NVR_USER, NVR_PASS);
  if (!authTokens) {
    console.log('JWT login failed');
    return;
  }
  const auth = { 'Authorization': `Bearer ${authTokens.accessToken}` };

  // 2) Create API Key
  const createRes = await post('/api/v1/auth/apikey', {
    name: 'example-integration',
    // permissions: ['remote'],         // optional: permissions (default: remote)
    // channels: [1, 2],                // optional: allowed channels
    // ipWhitelist: ['192.168.0.0/24'], // optional: allowed client IPs
    // expiresAt: 1735689600,           // optional: expiry (Unix timestamp)
  }, auth);
  console.log('Create API Key:', createRes.status);
  if (createRes.status !== 200) return;

  const { id: keyId, key: apiKey } = createRes.body;
  console.log('  Key ID:', keyId);
  console.log('  API Key:', apiKey.substring(0, 24) + '...');
  console.log('  WARNING:', createRes.body.message);

  // 3) Call a data endpoint with the API Key (no login required)
  const dataRes = await get('/api/v1/channel', { 'X-API-Key': apiKey });
  console.log('Use API Key -> GET /api/v1/channel:', dataRes.status);

  // 4) List API Keys
  const listRes = await get('/api/v1/auth/apikey', auth);
  console.log('List API Keys:', listRes.status, `(${listRes.body.length} keys)`);

  // 5) Delete API Key
  const delRes = await request('DELETE', `/api/v1/auth/apikey/${keyId}`, null, auth);
  console.log('Delete API Key:', delRes.status);

  await jwtLogout(authTokens.refreshToken);
}

main().catch(console.error);
