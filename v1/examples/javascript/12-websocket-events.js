/**
 * Example 12: WebSocket - Real-time Event Subscription
 *
 * Demonstrates subscribing to real-time events via WebSocket.
 * Topics: LPR, channelStatus, emergencyCall, object, recording
 *
 * Two subscription modes:
 *   1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
 *   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
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
  // Method 1: Subscribe via URL query params (classic)
  // ─────────────────────────────────────────────────
  console.log('=== Method 1: Subscribe via URL (10 seconds) ===');

  try {
    const ws1 = new WebSocket(
      `${WS_URL}/wsapi/v1/events?topics=LPR,channelStatus`,
      { headers: { 'X-API-Key': NVR_API_KEY }, rejectUnauthorized: false }
    );
    const messages1 = [];

    ws1.on('open', () => console.log('  Connected!'));
    ws1.on('message', (data) => {
      const msg = JSON.parse(data.toString());
      messages1.push(msg);
      console.log(`  [${msg.topic || msg.type}] ${JSON.stringify(msg)}`);
    });
    ws1.on('error', (err) => console.log(`  Error: ${err.message}`));

    await sleep(10000);
    console.log(`  Received ${messages1.length} events`);
    ws1.close();
    await sleep(500);
  } catch (err) {
    console.log(`  Failed: ${err.message}`);
  }

  // ─────────────────────────────────────────────────
  // Method 2: Dynamic subscribe/unsubscribe via send() (v1 only)
  //   - Connect WITHOUT topics
  //   - Subscribe/unsubscribe at any time
  //   - Per-topic filters (ch, objectTypes, lot, spot)
  //   - Re-subscribe to update filters
  // ─────────────────────────────────────────────────
  console.log('\n=== Method 2: Dynamic Subscribe (10 seconds) ===');

  try {
    // Connect without topics
    const ws2 = new WebSocket(
      `${WS_URL}/wsapi/v1/events`,
      { headers: { 'X-API-Key': NVR_API_KEY }, rejectUnauthorized: false }
    );
    const messages2 = [];

    ws2.on('open', () => {
      console.log('  Connected (no topics yet)');

      // Phase 1: Subscribe to initial topics with per-topic filters
      console.log('  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)');
      ws2.send(JSON.stringify({ subscribe: 'channelStatus' }));
      ws2.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2] }));
    });

    ws2.on('message', (data) => {
      const msg = JSON.parse(data.toString());
      messages2.push(msg);

      // Handle control responses
      if (msg.type === 'subscribed') {
        console.log(`  Subscribed to: ${msg.topic}`);
        return;
      }
      if (msg.type === 'unsubscribed') {
        console.log(`  Unsubscribed from: ${msg.topic}`);
        return;
      }
      if (msg.type === 'error') {
        console.log(`  Error: ${msg.message} (topic: ${msg.topic || 'N/A'})`);
        return;
      }

      // Handle event data
      console.log(`  [${msg.topic}] ${JSON.stringify(msg)}`);
    });

    ws2.on('error', (err) => console.log(`  Error: ${err.message}`));

    // Phase 2 (3s): Add new topic + update existing filter
    await sleep(3000);
    console.log('  [Phase 2] Add object topic + expand LPR to ch 1-4');
    ws2.send(JSON.stringify({ subscribe: 'object', objectTypes: ['human', 'vehicle'] }));
    ws2.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2, 3, 4] }));  // re-subscribe updates filter

    // Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
    await sleep(3000);
    console.log('  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3');
    ws2.send(JSON.stringify({ unsubscribe: 'channelStatus' }));
    ws2.send(JSON.stringify({ subscribe: 'motionChanges', ch: [1] }));
    ws2.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 3] }));  // re-subscribe with fewer ch drops ch 2,4

    await sleep(4000);
    console.log(`  Received ${messages2.length} messages`);
    ws2.close();
    await sleep(500);
  } catch (err) {
    console.log(`  Failed: ${err.message}`);
  }
}

main().catch(console.error);

/*
 * ─────────────────────────────────────────────────
 * Browser Example (using native WebSocket)
 * ─────────────────────────────────────────────────
 *
 * // Method 1: Subscribe via URL
 * const ws = new WebSocket(
 *   'ws://nvr-server/wsapi/v1/events?topics=LPR,channelStatus&apikey=tsapi_key_...'
 * );
 *
 * // Method 2: Dynamic subscribe/unsubscribe (v1 only)
 * const ws = new WebSocket(
 *   'ws://nvr-server/wsapi/v1/events?apikey=tsapi_key_...'
 * );
 * ws.onopen = () => {
 *   // Phase 1: Initial subscribe
 *   ws.send(JSON.stringify({ subscribe: 'channelStatus' }));
 *   ws.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2] }));
 * };
 *
 * ws.onmessage = (event) => {
 *   const data = JSON.parse(event.data);
 *
 *   // Handle control messages
 *   if (data.type === 'subscribed')   { console.log('Subscribed:', data.topic); return; }
 *   if (data.type === 'unsubscribed') { console.log('Unsubscribed:', data.topic); return; }
 *   if (data.type === 'error')        { console.error('Error:', data.message); return; }
 *
 *   // Handle events
 *   switch (data.topic) {
 *     case 'LPR':           (data.plates || [data]).forEach(p => showPlate(p.plateNo, p.score)); break;  // v1.0.0/v1.0.1 compatible
 *     case 'channelStatus': updateStatus(data.chid, data.status.code); break;
 *     case 'object':        showObject(data);                          break;
 *   }
 * };
 *
 * // Phase 2: Add new topic + update channel filter (re-subscribe)
 * ws.send(JSON.stringify({ subscribe: 'object', objectTypes: ['human'] }));
 * ws.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2, 3, 4] }));
 *
 * // Phase 3: Unsubscribe topic + subscribe new topic + reduce channels
 * ws.send(JSON.stringify({ unsubscribe: 'channelStatus' }));
 * ws.send(JSON.stringify({ subscribe: 'motionChanges', ch: [1] }));
 * ws.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 3] }));  // re-subscribe with fewer ch drops ch 2,4
 */
