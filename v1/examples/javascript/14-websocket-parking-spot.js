/**
 * Example 14: WebSocket - Parking Spot Monitoring
 *
 * Subscribes to parkingSpot topic for parking zone monitoring.
 * First message: currentStatus (ALL zone types: spot, entrance, exit, noParking, recognition)
 *   - Each zone has a `type` field; only type="spot" has `occupied` and `category`
 *   - Non-spot zones have `category: null` and no `occupied` field
 * Subsequent: statusChanged (only fires for type="spot" zones)
 *
 * Channel IDs (chid) are 1-based.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingSpot
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filters (OR logic):
 *   &ch=1,2       - spots belonging to channels 1, 2
 *   &lot=1,2      - spots belonging to parking lots 1, 2
 *   &spot=100,200  - specific spot IDs
 *
 * See also: 13-websocket-parking-lot.js for lot-level count monitoring
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
  // Subscribe to Parking Spot Status (30 seconds)
  //   Filters (OR logic, combine as needed):
  //   &ch=1,2    - by channel
  //   &lot=1,2   - by parking lot
  //   &spot=100  - by spot ID
  // ─────────────────────────────────────────────────
  console.log('=== WebSocket Parking Spot Monitoring (30 seconds) ===');

  const url = `${WS_URL}/wsapi/v1/events?topics=parkingSpot`;
  // With filters (append to URL):
  //   ...&ch=1,2
  //   ...&lot=1,2
  //   ...&spot=100,200
  //   ...&ch=1&lot=2&spot=300  (OR logic)
  // Browser: use ?apikey=${NVR_API_KEY} (no custom headers in browser WebSocket)

  try {
    const ws = new WebSocket(url, {
      headers: { 'X-API-Key': NVR_API_KEY },
      rejectUnauthorized: false,
    });
    let msgCount = 0;

    ws.on('open', () => {
      console.log('  Connected! Waiting for spot events...\n');
    });

    ws.on('message', (data) => {
      try {
        const msg = JSON.parse(data.toString());
        msgCount++;

        if (msg.event === 'currentStatus') {
          console.log(`  [currentStatus] ${msg.spots.length} zones`);
          for (const zone of msg.spots) {
            if (zone.type === 'spot') {
              if (zone.occupied) {
                const v = zone.vehicle || {};
                console.log(`    [${zone.id}] ${zone.name} (${zone.category}): occupied [${v.plateNo || ''} ${(v.score || 0).toFixed(1)}%]`);
              } else {
                console.log(`    [${zone.id}] ${zone.name} (${zone.category}): empty`);
              }
            } else {
              console.log(`    [${zone.id}] ${zone.name} (type: ${zone.type})`);
            }
          }
        } else if (msg.event === 'statusChanged') {
          // statusChanged only fires for type="spot"
          for (const spot of msg.spots) {
            const status = spot.occupied ? 'occupied' : 'empty';
            console.log(`  [statusChanged] spot ${spot.id} -> ${status}`);
            if (spot.occupied && spot.vehicle) {
              console.log(`    plate: ${spot.vehicle.plateNo}  score: ${spot.vehicle.score}%`);
            }
          }
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
