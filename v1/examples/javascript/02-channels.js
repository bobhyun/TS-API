/**
 * Example 02: Channel Management
 *
 * Demonstrates:
 *   - List channels (basic info, static source, capabilities)
 *   - Channel status (connection state, recording status)
 *   - Channel detailed info
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
  // 1. List Channels (basic info)
  // ─────────────────────────────────────────────────
  console.log('=== Channel List ===');
  const channelRes = await get('/api/v1/channel');

  if (channelRes.status === 200 && Array.isArray(channelRes.body)) {
    for (const ch of channelRes.body) {
      // Response fields: chid, title, displayName
      console.log(`  CH${ch.chid}: ${ch.title} (${ch.displayName})`);
    }
    console.log(`Total: ${channelRes.body.length} channels\n`);
  }

  // ─────────────────────────────────────────────────
  // 2. List Channels with static source URLs
  // ─────────────────────────────────────────────────
  console.log('=== Channel List with Sources ===');
  const srcRes = await get('/api/v1/channel?staticSrc');

  if (srcRes.status === 200 && Array.isArray(srcRes.body)) {
    for (const ch of srcRes.body) {
      console.log(`  CH${ch.chid}: ${ch.title}`);
      if (ch.src) {
        console.log(`    Source: ${JSON.stringify(ch.src)}`);
      }
    }
    console.log('');
  }

  // ─────────────────────────────────────────────────
  // 3. List Channels with capabilities
  // ─────────────────────────────────────────────────
  console.log('=== Channel Capabilities ===');
  const capsRes = await get('/api/v1/channel?caps');

  if (capsRes.status === 200 && Array.isArray(capsRes.body)) {
    for (const ch of capsRes.body) {
      const features = [];
      if (ch.caps) {
        if (ch.caps.pantilt) features.push('Pan/Tilt');
        if (ch.caps.zoom) features.push('Zoom');
        if (ch.caps.relay) features.push('Relay');
      }
      console.log(`  CH${ch.chid}: ${ch.title} [${features.join(', ') || 'No PTZ'}]`);
    }
    console.log('');
  }

  // ─────────────────────────────────────────────────
  // 4. Channel Status
  // ─────────────────────────────────────────────────
  console.log('=== Channel Status ===');
  const statusRes = await get('/api/v1/channel/status?recordingStatus');

  if (statusRes.status === 200 && Array.isArray(statusRes.body)) {
    // Status codes: 0=Connected, -1=Disconnected, -2=Connecting, -3=Auth Failed
    const statusMap = { 0: 'Connected', '-1': 'Disconnected', '-2': 'Connecting', '-3': 'Auth Failed' };

    for (const ch of statusRes.body) {
      const statusText = statusMap[ch.status?.code] || `Unknown(${ch.status?.code})`;
      const recText = ch.recording ? ' [REC]' : '';
      console.log(`  CH${ch.chid}: ${statusText}${recText}`);
    }
    console.log('');
  }

  // ─────────────────────────────────────────────────
  // 5. Specific Channel Info
  // ─────────────────────────────────────────────────
  console.log('=== Channel 1 Detailed Info ===');
  const infoRes = await get('/api/v1/channel/1/info?caps');
  console.log(`  Status: ${infoRes.status}`);
  if (infoRes.status === 200) {
    console.log(`  Data: ${JSON.stringify(infoRes.body, null, 2)}`);
  }

}

main().catch(console.error);
