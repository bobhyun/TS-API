/**
 * Example 13: WebSocket - Parking Lot Count Monitoring
 *
 * Subscribes to parkingCount topic for real-time lot occupancy changes.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingCount
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filter: &lot=1,2 (filter by parking lot ID)
 *
 * See also: 14-websocket-parking-spot.js for individual spot monitoring
 *
 * REQUIRES: npm install ws
 */

const WebSocket = require('ws');
const { WS_URL, NVR_API_KEY } = require('./config');

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }

  // ─────────────────────────────────────────────────
  // Subscribe to Parking Count (30 seconds)
  //   topic: parkingCount
  //   filter: &lot=1,2 (optional, filter by lot ID)
  // ─────────────────────────────────────────────────
  console.log('=== WebSocket Parking Count Monitoring (30 seconds) ===');

  const url = `${WS_URL}/wsapi/v1/events?topics=parkingCount`;
  // With lot filter: `${WS_URL}/wsapi/v1/events?topics=parkingCount&lot=1,2`
  // Browser: use ?apikey=${NVR_API_KEY} (no custom headers in browser WebSocket)

  try {
    const ws = new WebSocket(url, {
      headers: { 'X-API-Key': NVR_API_KEY },
      rejectUnauthorized: false,
    });
    let msgCount = 0;

    ws.on('open', () => {
      console.log('  Connected! Waiting for parking count events...\n');
    });

    ws.on('message', (data) => {
      try {
        const msg = JSON.parse(data.toString());
        msgCount++;

        // First message is subscription confirmation
        if (msg.subscriberId) {
          console.log(`  Subscribed (id=${msg.subscriberId})`);
          return;
        }

        // parkingCount messages: {topic, updated: [{id, name, type, maxCount, count}, ...]}
        const updated = msg.updated || [];
        for (const lot of updated) {
          const available = (lot.maxCount || 0) - (lot.count || 0);
          console.log(`  [${lot.id}] ${lot.name} (${lot.type}): ${lot.count}/${lot.maxCount} (available=${available})`);
        }
      } catch {
        console.log(`  Raw: ${data.toString()}`);
      }
    });

    ws.on('error', (err) => {
      console.log(`  Error: ${err.message}`);
    });

    ws.on('close', (code, reason) => {
      console.log(`  Closed: ${code} ${reason || ''}`);
    });

    await sleep(30000);
    console.log(`\n  Received ${msgCount} events`);
    ws.close();
    await sleep(500);

  } catch (err) {
    console.log(`  Failed: ${err.message}`);
  }

}

main().catch(console.error);
