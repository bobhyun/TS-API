/**
 * Example 01: Authentication
 *
 * TS-API v1 supports three authentication methods:
 *   1. JWT Login (POST) - primary method for all v1 endpoints
 *   2. API Key - for external system integration (v1 endpoints only)
 *   3. Session Login - uses JWT internally, tokens stored by http helper
 *
 * NOTE: v1 data endpoints require JWT Bearer token or API Key.
 *       Session cookies are NOT supported by v1 endpoints.
 * NOTE: API Key authentication is supported on v1 endpoints only.
 *       v0 endpoints (/api/*) reject X-API-Key with 401 Unauthorized.
 */

const { NVR_USER, NVR_PASS } = require('./config');
const { request, get, post, login, logout, jwtLogin, jwtRefresh, jwtLogout, getAccessToken } = require('./http');

async function main() {
  // ─────────────────────────────────────────────────
  // Method 1: Simple Login (JWT stored internally by http helper)
  //   POST /api/v1/auth/login with JSON body
  //   Tokens are stored automatically; subsequent requests use Bearer header
  // ─────────────────────────────────────────────────
  console.log('=== Simple Login ===');

  const ok = await login(NVR_USER, NVR_PASS);
  console.log('Login:', ok ? 'OK' : 'Failed');
  console.log('Access Token:', getAccessToken().substring(0, 30) + '...');

  // Now all data API calls will use the Bearer token automatically
  const channelRes = await get('/api/v1/channel');
  console.log('Channels:', channelRes.status, Array.isArray(channelRes.body) ? `(${channelRes.body.length} channels)` : '');

  await logout();
  console.log('Logged out\n');

  // ─────────────────────────────────────────────────
  // Method 2: JWT Login (manual token management)
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

    // 3) Refresh accessToken using refreshToken
    //    NOTE: Server performs token rotation - old refreshToken is revoked
    const refreshed = await jwtRefresh(refreshToken);
    if (refreshed) {
      console.log('Refreshed:    ', refreshed.accessToken.substring(0, 30) + '...');
      console.log('New Refresh:  ', refreshed.refreshToken.substring(0, 30) + '...');
    }

    // 4) Logout (revoke refreshToken)
    //    Must use the NEW refreshToken after rotation
    await jwtLogout(refreshed ? refreshed.refreshToken : refreshToken);
    console.log('JWT logged out (refreshToken revoked)');
  } else {
    console.log('JWT Login failed');
  }

  console.log('');

  // ─────────────────────────────────────────────────
  // Method 3: API Key (issue -> use -> list -> revoke)
  //   POST /api/v1/auth/apikey   (create, requires admin JWT)
  //   X-API-Key header           (use, v1 endpoints only)
  //   GET /api/v1/auth/apikey    (list)
  //   DELETE /api/v1/auth/apikey/{id}  (delete)
  //   NOTE: v0 endpoints (/api/*) reject API Key with 401
  // ─────────────────────────────────────────────────
  console.log('=== API Key ===');

  // 1) JWT login for admin access
  const authTokens = await jwtLogin(NVR_USER, NVR_PASS);
  if (!authTokens) {
    console.log('JWT login failed');
    return;
  }
  const auth = { 'Authorization': `Bearer ${authTokens.accessToken}` };

  // 2) Create API Key
  const createRes = await post('/api/v1/auth/apikey', {
    name: 'example-integration',
    // permissions: ['remote'],       // optional: specify permissions (default: remote)
    // channels: [1, 2],              // optional: restrict accessible channels
    // ipWhitelist: ['192.168.0.0/24'], // optional: IP restriction
    // expiresAt: 1735689600,         // optional: expiration (Unix timestamp)
  }, auth);
  console.log('Create API Key:', createRes.status);
  if (createRes.status !== 200) return;

  const { id: keyId, key: apiKey } = createRes.body;
  console.log('  Key ID:', keyId);
  console.log('  API Key:', apiKey.substring(0, 24) + '...');
  console.log('  WARNING:', createRes.body.message);

  // 3) Use API Key for data endpoint access (no login required)
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
