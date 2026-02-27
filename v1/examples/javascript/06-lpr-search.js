/**
 * Example 06: LPR (License Plate Recognition) Search
 *
 * Demonstrates:
 *   - LPR source list
 *   - License plate log search (keyword, time range, pagination)
 *   - Similar plate search
 *   - CSV export
 *
 * NOTE: timeBegin and timeEnd are required for LPR log searches.
 *
 * WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
 *   errors. For bulk exports, narrow the time range or use pagination
 *   (at/maxCount) to keep each request under a manageable size.
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
  // 1. LPR Source List
  //    Each source represents a recognition point (entrance, exit, etc.)
  // ─────────────────────────────────────────────────
  console.log('=== LPR Sources ===');
  const srcRes = await get('/api/v1/lpr/source');

  if (srcRes.status === 200 && Array.isArray(srcRes.body)) {
    for (const src of srcRes.body) {
      console.log(`  [${src.id}] ${src.code} - ${src.name} (cameras: ${src.linkedChannel?.join(',') || 'none'})`);
    }
    console.log(`  Total: ${srcRes.body.length} sources\n`);
  } else {
    console.log(`  Status: ${srcRes.status}\n`);
  }

  // ─────────────────────────────────────────────────
  // 2. Recent LPR Logs
  // ─────────────────────────────────────────────────
  console.log('=== Recent LPR Logs ===');

  // Search last 7 days
  const endDate = new Date();
  const startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
  const timeBegin = startDate.toISOString().split('.')[0];
  const timeEnd = endDate.toISOString().split('.')[0];

  const logRes = await get(`/api/v1/lpr/log?timeBegin=${timeBegin}&timeEnd=${timeEnd}&maxCount=10`);

  if (logRes.status === 200 && logRes.body) {
    console.log(`  Total: ${logRes.body.totalCount}`);

    if (Array.isArray(logRes.body.data)) {
      for (const entry of logRes.body.data) {
        const time = Array.isArray(entry.timeRange) ? entry.timeRange[0] : '';
        console.log(`  ${time} | ${entry.plateNo} (score: ${entry.score}) [${entry.srcName || entry.srcCode}]`);

        // VOD links for playback
        if (Array.isArray(entry.vod) && entry.vod.length > 0) {
          console.log(`    VOD: ${entry.vod[0].videoSrc}`);
        }
      }
    }
  } else {
    console.log(`  Status: ${logRes.status}`);
  }

  // ─────────────────────────────────────────────────
  // 3. Search by Keyword (partial plate match)
  // ─────────────────────────────────────────────────
  console.log('\n=== Search by Keyword ===');
  const keyword = '1234';
  const searchRes = await get(
    `/api/v1/lpr/log?keyword=${keyword}&timeBegin=${timeBegin}&timeEnd=${timeEnd}&maxCount=5`
  );

  if (searchRes.status === 200 && searchRes.body) {
    console.log(`  Keyword: "${keyword}", Found: ${searchRes.body.totalCount}`);

    if (Array.isArray(searchRes.body.data)) {
      for (const entry of searchRes.body.data) {
        console.log(`    ${entry.plateNo} (score: ${entry.score})`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 4. Similar Plate Search
  //    Finds plates similar to the keyword (edit distance based)
  //    Useful for partial or misrecognized plates
  // ─────────────────────────────────────────────────
  console.log('\n=== Similar Plate Search ===');
  const similarRes = await get(
    `/api/v1/lpr/similar?keyword=${keyword}&timeBegin=${timeBegin}&timeEnd=${timeEnd}`
  );

  if (similarRes.status === 200 && similarRes.body) {
    console.log(`  Similar to "${keyword}": ${similarRes.body.totalCount || 'N/A'} results`);

    const data = Array.isArray(similarRes.body.data) ? similarRes.body.data : similarRes.body;
    if (Array.isArray(data)) {
      for (const entry of data.slice(0, 5)) {
        console.log(`    ${entry.plateNo}`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 5. CSV Export
  //    Returns LPR data in CSV format for spreadsheet import
  // ─────────────────────────────────────────────────
  console.log('\n=== CSV Export ===');
  const exportRes = await get(
    `/api/v1/lpr/log?export=true&timeBegin=${timeBegin}&timeEnd=${timeEnd}&maxCount=5`
  );
  console.log(`  Status: ${exportRes.status}`);
  if (typeof exportRes.body === 'string') {
    const lines = exportRes.body.split('\n').slice(0, 3);
    for (const line of lines) {
      console.log(`    ${line}`);
    }
    console.log('    ...');
  }

}

main().catch(console.error);
