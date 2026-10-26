/**
 * Example 06: LPR (License Plate Recognition) Search
 *
 * Demonstrates:
 *   - LPR source list
 *   - License plate log search (keyword, time range, pagination)
 *   - Similar plate search
 *   - CSV export
 *   - Plate correction history (GET /api/v1/lpr/log/{id}/plate/history)
 *   - Plate correction (POST /api/v1/lpr/log/{id}/plate, Control permission, not executed)
 *
 * NOTE: timeBegin and timeEnd are required for LPR log searches.
 *
 * WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
 *   Narrow the time range or page with at/maxCount.
 */

const { BASE_URL, NVR_API_KEY } = require('./config');
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
        // plateNo is null when no plate was read; direction is "entry"/"exit" or absent
        console.log(`  [${entry.id}] ${time} | ${entry.plateNo || '(unrecognized)'} (score: ${entry.score}) ` +
          `[${entry.srcName || entry.srcCode}] direction: ${entry.direction || '-'}`);
        if (entry.plateEdited) {
          console.log(`    corrected, originally: ${entry.originalPlateNo || '(unrecognized)'}`);
        }

        // VOD links for playback
        // v1 returns relative paths (e.g. "/watch?ch=1&when=..."); prepend BASE_URL for non-browser clients.
        if (Array.isArray(entry.vod) && entry.vod.length > 0) {
          const videoSrc = entry.vod[0].videoSrc || '';
          const fullUrl = videoSrc.startsWith('http') ? videoSrc : `${BASE_URL}${videoSrc}`;
          console.log(`    VOD: ${fullUrl}`);
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
  //    Returns every plate containing the keyword, most recent first
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
        // Response: array of plate strings, most recent first
        console.log(`    ${typeof entry === 'string' ? entry : entry.plateNo}`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 5. Plate Correction History (one record, by id)
  //    plateNo in the log is always the current value.
  //    edits[] lists corrections in recorded order; it is empty if the record was never corrected.
  // ─────────────────────────────────────────────────
  const first = logRes.status === 200 && Array.isArray(logRes.body?.data) ? logRes.body.data[0] : null;
  if (first) {
    console.log(`\n=== Plate Correction History (id=${first.id}) ===`);
    const histRes = await get(`/api/v1/lpr/log/${first.id}/plate/history`);
    if (histRes.status === 200 && histRes.body) {
      const h = histRes.body;
      console.log(`  plateNo: ${h.plateNo}, original: ${h.originalPlateNo ?? '(never corrected)'}`);
      for (const e of h.edits || []) {
        console.log(`    ${e.time} ${e.user}: ${e.before} -> ${e.after} ${e.reason || ''}`);
      }
    } else {
      console.log(`  Status: ${histRes.status}`);
    }
  }

  // ─────────────────────────────────────────────────
  // 6. Plate Correction (Control permission)
  //    Changes the stored record, so it is not executed here. The target is always
  //    one record id - from data[].id above, or the id a realtime LPR event carries
  //    next to each plateNo. 409 when plateNo equals the current plate.
  //
  //    Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
  //    Uncomment it to try it against a test record.
  //    await post(`/api/v1/lpr/log/${first.id}/plate`, { plateNo: '12가3456', reason: 'misread at night' });
  // ─────────────────────────────────────────────────

  // ─────────────────────────────────────────────────
  // 7. CSV Export
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
