/**
 * Example 03: PTZ Camera Control
 *
 * Demonstrates:
 *   - Home position
 *   - Pan/Tilt movement (move=x,y, range: -1.0 ~ 1.0)
 *   - Zoom control (zoom=z, range: -1.0 ~ 1.0)
 *   - Focus/Iris control
 *   - Stop movement
 *   - Preset management (list, go to)
 *
 * NOTE: PTZ commands are sent via ONVIF to the camera.
 *       Returns 500 if the camera doesn't support ONVIF or is unreachable.
 */

const { NVR_API_KEY } = require('./config');
const { setApiKey, get } = require('./http');

const CHANNEL = 1; // Target camera channel

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }
  setApiKey(NVR_API_KEY);

  // ─────────────────────────────────────────────────
  // 1. Move to Home Position
  // ─────────────────────────────────────────────────
  console.log('=== Home Position ===');
  const homeRes = await get(`/api/v1/channel/${CHANNEL}/ptz?home`);
  console.log(`  Status: ${homeRes.status}`);
  await sleep(1000);

  // ─────────────────────────────────────────────────
  // 2. Pan/Tilt Movement
  //    move=x,y where x=pan(-1~1), y=tilt(-1~1)
  //    Positive x = right, Positive y = up
  // ─────────────────────────────────────────────────
  console.log('\n=== Pan/Tilt ===');

  // Move right and up
  let res = await get(`/api/v1/channel/${CHANNEL}/ptz?move=0.3,0.3`);
  console.log(`  Move right+up (0.3, 0.3): ${res.status}`);
  await sleep(500);

  // Stop
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?stop`);
  console.log(`  Stop: ${res.status}`);
  await sleep(500);

  // Move left and down
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?move=-0.3,-0.3`);
  console.log(`  Move left+down (-0.3, -0.3): ${res.status}`);
  await sleep(500);

  // Stop
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?stop`);
  console.log(`  Stop: ${res.status}`);

  // ─────────────────────────────────────────────────
  // 3. Zoom Control
  //    zoom > 0 = zoom in, zoom < 0 = zoom out
  // ─────────────────────────────────────────────────
  console.log('\n=== Zoom ===');

  res = await get(`/api/v1/channel/${CHANNEL}/ptz?zoom=0.5`);
  console.log(`  Zoom in (0.5): ${res.status}`);
  await sleep(1000);

  res = await get(`/api/v1/channel/${CHANNEL}/ptz?stop`);
  console.log(`  Stop: ${res.status}`);
  await sleep(500);

  res = await get(`/api/v1/channel/${CHANNEL}/ptz?zoom=-0.5`);
  console.log(`  Zoom out (-0.5): ${res.status}`);
  await sleep(1000);

  res = await get(`/api/v1/channel/${CHANNEL}/ptz?stop`);
  console.log(`  Stop: ${res.status}`);

  // ─────────────────────────────────────────────────
  // 4. Focus & Iris Control
  // ─────────────────────────────────────────────────
  console.log('\n=== Focus & Iris ===');

  // Focus: -1.0=near, 1.0=far
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?focus=0.3`);
  console.log(`  Focus far (0.3): ${res.status}`);

  // Iris: -1.0=close, 1.0=open
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?iris=0.3`);
  console.log(`  Iris open (0.3): ${res.status}`);

  // ─────────────────────────────────────────────────
  // 5. Preset List & Go
  // ─────────────────────────────────────────────────
  console.log('\n=== Presets ===');

  const listRes = await get(`/api/v1/channel/${CHANNEL}/preset`);
  console.log(`  List presets: ${listRes.status}`);
  if (listRes.status === 200 && Array.isArray(listRes.body)) {
    for (const preset of listRes.body) {
      console.log(`    - Token: ${preset.token}, Name: ${preset.name}`);
    }

    // Go to first preset if exists
    if (listRes.body.length > 0) {
      const token = listRes.body[0].token;
      const goRes = await get(`/api/v1/channel/${CHANNEL}/preset/${token}/go`);
      console.log(`  Go to preset '${listRes.body[0].name}': ${goRes.status}`);
    }
  }

  // Return to home
  console.log('\n=== Return Home ===');
  res = await get(`/api/v1/channel/${CHANNEL}/ptz?home`);
  console.log(`  Status: ${res.status}`);

}

main().catch(console.error);
