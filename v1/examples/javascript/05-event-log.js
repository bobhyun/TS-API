/**
 * Example 05: Event Log Search
 *
 * Demonstrates:
 *   - Event type enumeration
 *   - Event log search with filters (time, type, channel)
 *   - Pagination (at, maxCount)
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
  // 1. List Event Types
  //    Each type has id, name, and an array of sub-codes
  // ─────────────────────────────────────────────────
  console.log('=== Event Types ===');
  const typeRes = await get('/api/v1/event/type');

  if (typeRes.status === 200 && Array.isArray(typeRes.body)) {
    for (const eventType of typeRes.body) {
      // Response: { id: 0, name: "System Log", code: [{id: 1, name: "System Start"}, ...] }
      const codeCount = Array.isArray(eventType.code) ? eventType.code.length : 0;
      console.log(`  [${eventType.id}] ${eventType.name} (${codeCount} codes)`);

      if (Array.isArray(eventType.code)) {
        for (const code of eventType.code.slice(0, 3)) {
          console.log(`    - [${code.id}] ${code.name}`);
        }
        if (eventType.code.length > 3) {
          console.log(`    ... and ${eventType.code.length - 3} more`);
        }
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 2. List Event Types in English
  // ─────────────────────────────────────────────────
  console.log('\n=== Event Types (English) ===');
  const typeEnRes = await get('/api/v1/event/type?lang=en-US');

  if (typeEnRes.status === 200 && Array.isArray(typeEnRes.body)) {
    for (const eventType of typeEnRes.body) {
      console.log(`  [${eventType.id}] ${eventType.name}`);
    }
  }

  // ─────────────────────────────────────────────────
  // 3. Search Recent Events
  // ─────────────────────────────────────────────────
  console.log('\n=== Recent Events (latest 10) ===');
  const logRes = await get('/api/v1/event/log?maxCount=10&sort=desc');

  if (logRes.status === 200 && logRes.body) {
    console.log(`  Total: ${logRes.body.totalCount}, Showing from: ${logRes.body.at}`);

    if (Array.isArray(logRes.body.data)) {
      for (const event of logRes.body.data) {
        const time = Array.isArray(event.timeRange) ? event.timeRange[0] : '';
        console.log(`  ${time} | [${event.typeName}] ${event.codeName} (CH${event.chid})`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 4. Search Events with Time Range
  // ─────────────────────────────────────────────────
  console.log('\n=== Events from Today ===');
  const today = new Date().toISOString().split('T')[0];
  const todayRes = await get(`/api/v1/event/log?timeBegin=${today}T00:00:00&timeEnd=${today}T23:59:59&maxCount=5`);

  if (todayRes.status === 200 && todayRes.body) {
    console.log(`  Total today: ${todayRes.body.totalCount}`);

    if (Array.isArray(todayRes.body.data)) {
      for (const event of todayRes.body.data) {
        const time = Array.isArray(event.timeRange) ? event.timeRange[0] : '';
        console.log(`  ${time} | [${event.typeName}] ${event.codeName}`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 5. Pagination Example
  //    at=0 (start index), maxCount=5 (page size)
  // ─────────────────────────────────────────────────
  console.log('\n=== Pagination ===');
  const page1 = await get('/api/v1/event/log?at=0&maxCount=5');
  console.log(`  Page 1 (at=0): ${page1.body?.data?.length || 0} items`);

  const page2 = await get('/api/v1/event/log?at=5&maxCount=5');
  console.log(`  Page 2 (at=5): ${page2.body?.data?.length || 0} items`);

  // ─────────────────────────────────────────────────
  // 6. Filter by Channel
  // ─────────────────────────────────────────────────
  console.log('\n=== Events for Channel 1 ===');
  const ch1Res = await get('/api/v1/event/log?ch=1&maxCount=5');

  if (ch1Res.status === 200 && ch1Res.body) {
    console.log(`  Total for CH1: ${ch1Res.body.totalCount}`);
  }

}

main().catch(console.error);
