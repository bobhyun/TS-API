/**
 * TS-API Examples - Shared Configuration
 *
 * Environment variables:
 *   NVR_HOST    - NVR server hostname (default: localhost)
 *   NVR_SCHEME  - http or https (default: https)
 *   NVR_PORT    - NVR server port (default: 443 for https, 80 for http)
 *   NVR_USER    - Login username (default: admin)
 *   NVR_PASS    - Login password (default: 1234)
 *   NVR_API_KEY - API Key for v1 endpoint authentication
 *
 * Usage:
 *   NVR_HOST=192.168.0.100 node 01-login.js
 *   NVR_SCHEME=http NVR_PORT=80 node 01-login.js
 *   NVR_API_KEY=tsapi_key_... node 02-channels.js
 */

const NVR_HOST = process.env.NVR_HOST || 'localhost';
const NVR_SCHEME = process.env.NVR_SCHEME || 'https';
const NVR_PORT = process.env.NVR_PORT || (NVR_SCHEME === 'https' ? '443' : '80');
const NVR_USER = process.env.NVR_USER || 'admin';
const NVR_PASS = process.env.NVR_PASS || '1234';
const NVR_API_KEY = process.env.NVR_API_KEY || '';

const defaultPort = NVR_SCHEME === 'https' ? '443' : '80';
const portSuffix = NVR_PORT === defaultPort ? '' : `:${NVR_PORT}`;
const BASE_URL = `${NVR_SCHEME}://${NVR_HOST}${portSuffix}`;
const WS_SCHEME = NVR_SCHEME === 'https' ? 'wss' : 'ws';
const WS_URL = `${WS_SCHEME}://${NVR_HOST}${portSuffix}`;

module.exports = { NVR_HOST, NVR_PORT, NVR_SCHEME, NVR_USER, NVR_PASS, NVR_API_KEY, BASE_URL, WS_URL };
