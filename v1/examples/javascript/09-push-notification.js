/**
 * Example 09: Push Notification - External Event Input
 *
 * Demonstrates:
 *   - LPR push (external plate recognition data)
 *   - Emergency call push (alarm start/stop)
 *
 * REQUIRES: Push license enabled on the server.
 *           Returns 404 if not enabled.
 *
 * WARNING: Emergency call 'callStart' triggers actual alarm hardware!
 *          Always send 'callEnd' to stop the alarm.
 */

const { NVR_API_KEY } = require('./config');
const { setApiKey, post } = require('./http');

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }
  setApiKey(NVR_API_KEY);

  // ─────────────────────────────────────────────────
  // 1. LPR Push
  //    External LPR camera sends recognized plate number
  // ─────────────────────────────────────────────────
  console.log('=== LPR Push ===');
  const lprRes = await post('/api/v1/push', {
    topic: 'LPR',
    src: '1',                           // LPR source ID
    plateNo: '12가3456',                // Recognized plate number
    when: new Date().toISOString(),     // Recognition time
  });
  console.log(`  Status: ${lprRes.status}`);
  if (lprRes.status === 404) {
    console.log('  Push API not enabled (license required)');
  }

  // ─────────────────────────────────────────────────
  // 2. Emergency Call Push
  //    Sends alarm start/stop events from emergency call device
  //
  //    IMPORTANT:
  //    - callStart triggers actual alarm bell
  //    - Always send callEnd to stop the alarm
  //    - camera field links to NVR channels for popup
  // ─────────────────────────────────────────────────
  console.log('\n=== Emergency Call Push ===');

  // Start emergency alarm
  console.log('  Sending callStart...');
  const startRes = await post('/api/v1/push', {
    topic: 'emergencyCall',
    device: 'intercom-01',             // Device identifier
    src: '1',                           // Source ID
    event: 'callStart',                 // Start alarm
    camera: '1,2',                      // Linked camera channels
    when: new Date().toISOString(),     // Event time
  });
  console.log(`  callStart status: ${startRes.status}`);

  // ALWAYS stop the alarm!
  console.log('  Sending callEnd...');
  const endRes = await post('/api/v1/push', {
    topic: 'emergencyCall',
    device: 'intercom-01',
    src: '1',
    event: 'callEnd',                   // Stop alarm
    camera: '1,2',
    when: new Date().toISOString(),
  });
  console.log(`  callEnd status: ${endRes.status}`);

}

main().catch(console.error);
