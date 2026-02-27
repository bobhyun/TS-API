/**
 * Example 04: Recording Search
 *
 * Demonstrates:
 *   - Recording days (calendar view - which dates have recordings)
 *   - Recording minutes (timeline view - minute-by-minute recording status)
 *
 * These APIs are typically used to build:
 *   - Calendar UI: highlight dates that have recorded video
 *   - Timeline UI: show recording segments on a time bar
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
  // 1. Recording Days (Calendar)
  //    Returns which dates have recordings for given channels
  // ─────────────────────────────────────────────────
  console.log('=== Recording Days (All Channels) ===');
  const daysRes = await get('/api/v1/recording/days');
  console.log(`  Status: ${daysRes.status}`);

  if (daysRes.status === 200 && daysRes.body) {
    if (daysRes.body.timeBegin) {
      console.log(`  Range: ${daysRes.body.timeBegin} ~ ${daysRes.body.timeEnd}`);
    }
    if (Array.isArray(daysRes.body.data)) {
      for (const entry of daysRes.body.data) {
        console.log(`  ${entry.year}-${String(entry.month).padStart(2, '0')}: ${entry.days.join(', ')}`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 2. Recording Days (Specific Channel)
  // ─────────────────────────────────────────────────
  console.log('\n=== Recording Days (Channel 1) ===');
  const ch1Days = await get('/api/v1/recording/days?ch=1');
  console.log(`  Status: ${ch1Days.status}`);

  if (ch1Days.status === 200 && ch1Days.body && Array.isArray(ch1Days.body.data)) {
    // When ch= filter is used, response wraps per-channel: [{chid, data: [{year,month,days}]}]
    for (const chEntry of ch1Days.body.data) {
      const months = chEntry.data || [chEntry]; // handle both nested and flat formats
      for (const entry of months) {
        console.log(`  ${entry.year}-${String(entry.month).padStart(2, '0')}: [${entry.days.length} days]`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 3. Recording Minutes (Timeline)
  //    Returns 1440-char string per channel (24h x 60min)
  //    '1' = recording exists, '0' = no recording
  // ─────────────────────────────────────────────────
  console.log('\n=== Recording Minutes (Timeline) ===');

  // Query today's recordings
  const today = new Date();
  const dateStr = today.toISOString().split('T')[0];
  const timeBegin = `${dateStr}T00:00:00`;
  const timeEnd = `${dateStr}T23:59:59`;

  const minsRes = await get(`/api/v1/recording/minutes?ch=1&timeBegin=${timeBegin}&timeEnd=${timeEnd}`);
  console.log(`  Status: ${minsRes.status}`);
  console.log(`  Date: ${dateStr}`);

  if (minsRes.status === 200 && minsRes.body && Array.isArray(minsRes.body.data)) {
    for (const entry of minsRes.body.data) {
      const minutes = entry.minutes || '';
      const recordedMinutes = (minutes.match(/1/g) || []).length;
      const totalMinutes = minutes.length;

      console.log(`  CH${entry.chid}: ${recordedMinutes}/${totalMinutes} minutes recorded`);

      // Show hourly summary
      if (minutes.length === 1440) {
        const hourly = [];
        for (let h = 0; h < 24; h++) {
          const hourSlice = minutes.substring(h * 60, (h + 1) * 60);
          const recMins = (hourSlice.match(/1/g) || []).length;
          hourly.push(recMins > 0 ? '#' : '.');
        }
        console.log(`    Timeline: [${hourly.join('')}]`);
        console.log(`              0         1         2   `);
        console.log(`              0123456789012345678901234`);
        console.log(`              (#=recorded, .=empty)`);
      }
    }
  }

}

main().catch(console.error);
