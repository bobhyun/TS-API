/**
 * Example 11: Emergency Call Device List
 *
 * Endpoint:
 *   GET /api/v1/emergency  - Emergency call device list
 *
 * Response: [{ id, code, name, linkedChannel }, ...]
 * Note: Requires Emergency Call license. Returns 404 if not supported.
 */

const { NVR_API_KEY } = require('./config');
const { setApiKey, get } = require('./http');

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }
  setApiKey(NVR_API_KEY);

  // ─────────────────────────────────────────────────
  // Emergency Call Device List
  // ─────────────────────────────────────────────────
  console.log('=== Emergency Call Devices ===');
  const res = await get('/api/v1/emergency');

  if (res.status === 200 && Array.isArray(res.body)) {
    console.log(`  Total: ${res.body.length} device(s)`);
    for (const dev of res.body) {
      const channels = dev.linkedChannel || [];
      console.log(`  id=${dev.id}  code=${dev.code}  name=${dev.name}  linkedChannel=[${channels.join(', ')}]`);
    }
  } else if (res.status === 404) {
    console.log('  Emergency Call not enabled on this server (license required)');
  } else {
    console.log(`  Unexpected status: ${res.status}`);
  }

}

main().catch(console.error);
