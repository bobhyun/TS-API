/**
 * Example 07: VOD (Video on Demand) - Live & Playback Stream URLs
 *
 * Demonstrates:
 *   - Get live stream URLs (RTMP, FLV)
 *   - Get playback URLs for recorded video
 *   - Navigate between recording segments (next/prev)
 *   - Filter by protocol and stream quality
 *
 * NOTE: X-Host header is required. The http helper sets it automatically.
 *       When using nginx reverse proxy, X-Host is set by the proxy.
 *
 * Response src format:
 *   src: [
 *     { protocol: "rtmp", profile: "main", src: "rtmp://...", type: "...", label: "1080p", size: [1920, 1080] },
 *     { protocol: "flv", profile: "main", src: "http://.../.flv", type: "...", label: "1080p", size: [1920, 1080] }
 *   ]
 */

const { NVR_API_KEY } = require('./config');
const { setApiKey, get } = require('./http');

/** Find stream URL by protocol from src array */
function findStream(src, protocol) {
  if (!Array.isArray(src)) return null;
  const s = src.find(s => s.protocol === protocol);
  return s ? s.src : null;
}

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }
  setApiKey(NVR_API_KEY);

  // ─────────────────────────────────────────────────
  // 1. Get All Live Stream URLs
  //    Response: [{ chid, title, src: [{protocol, src, ...}] }]
  // ─────────────────────────────────────────────────
  console.log('=== All Live Streams ===');
  const liveRes = await get('/api/v1/vod');

  if (liveRes.status === 200 && Array.isArray(liveRes.body)) {
    for (const ch of liveRes.body) {
      console.log(`  CH${ch.chid}: ${ch.title}`);
      const rtmp = findStream(ch.src, 'rtmp');
      const flv = findStream(ch.src, 'flv');
      if (rtmp) console.log(`    RTMP: ${rtmp}`);
      if (flv) console.log(`    FLV:  ${flv}`);
    }
    console.log(`  Total: ${liveRes.body.length} streams\n`);
  }

  // ─────────────────────────────────────────────────
  // 2. Get Specific Channel Stream
  // ─────────────────────────────────────────────────
  console.log('=== Channel 1 Live Stream ===');
  const ch1Res = await get('/api/v1/vod?ch=1');
  if (ch1Res.status === 200 && Array.isArray(ch1Res.body) && ch1Res.body.length > 0) {
    const ch = ch1Res.body[0];
    console.log(`  ${ch.title}: ${findStream(ch.src, 'rtmp') || 'N/A'}`);
  }

  // ─────────────────────────────────────────────────
  // 3. Filter by Protocol
  //    protocol=rtmp - RTMP only
  //    protocol=flv  - FLV only (HTTP-FLV)
  // ─────────────────────────────────────────────────
  console.log('\n=== RTMP Only ===');
  const rtmpRes = await get('/api/v1/vod?ch=1&protocol=rtmp');
  if (rtmpRes.status === 200 && Array.isArray(rtmpRes.body) && rtmpRes.body.length > 0) {
    console.log(`  ${findStream(rtmpRes.body[0].src, 'rtmp') || 'N/A'}`);
  }

  // ─────────────────────────────────────────────────
  // 4. Filter by Stream Quality
  //    stream=main - Main stream (high resolution)
  //    stream=sub  - Sub stream (low resolution, less bandwidth)
  // ─────────────────────────────────────────────────
  console.log('\n=== Sub Stream (Low Resolution) ===');
  const subRes = await get('/api/v1/vod?ch=1&stream=sub');
  if (subRes.status === 200 && Array.isArray(subRes.body) && subRes.body.length > 0) {
    const ch = subRes.body[0];
    console.log(`  ${ch.title}: ${findStream(ch.src, 'rtmp') || 'N/A'}`);
  }

  // ─────────────────────────────────────────────────
  // 5. Playback (Recorded Video)
  //    when=<ISO 8601 datetime> to play recorded video
  // ─────────────────────────────────────────────────
  console.log('\n=== Playback URL ===');
  const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const when = yesterday.toISOString().split('.')[0];

  const playRes = await get(`/api/v1/vod?ch=1&when=${when}`);
  console.log(`  Status: ${playRes.status}`);
  if (playRes.status === 200 && Array.isArray(playRes.body) && playRes.body.length > 0) {
    const ch = playRes.body[0];
    console.log(`  ${ch.title}: ${findStream(ch.src, 'rtmp') || 'N/A'}`);

    // Navigate to next segment
    if (ch.fileId) {
      console.log(`  File ID: ${ch.fileId}`);

      const nextRes = await get(`/api/v1/vod?id=${ch.fileId}&next`);
      if (nextRes.status === 200 && Array.isArray(nextRes.body) && nextRes.body.length > 0) {
        console.log(`  Next segment: ${findStream(nextRes.body[0].src, 'rtmp') || 'N/A'}`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 6. Multiple Channels at Once
  // ─────────────────────────────────────────────────
  console.log('\n=== Multiple Channels ===');
  const multiRes = await get('/api/v1/vod?ch=1,2,3,4');
  if (multiRes.status === 200 && Array.isArray(multiRes.body)) {
    for (const ch of multiRes.body) {
      console.log(`  CH${ch.chid}: ${findStream(ch.src, 'rtmp') || 'no stream'}`);
    }
  }

}

main().catch(console.error);
