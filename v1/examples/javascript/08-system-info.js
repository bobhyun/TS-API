/**
 * Example 08: System & Server Information
 *
 * Demonstrates:
 *   - Server info (API version, product, license, timezone)
 *   - System info (OS, CPU, disk, network)
 *   - System health (CPU usage, memory, disk usage)
 *   - HDD S.M.A.R.T status
 *
 * NOTE: System info 'storage' parameter returns response field named 'disk'.
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
  // 1. Server Info (all at once)
  // ─────────────────────────────────────────────────
  console.log('=== Server Info ===');
  const infoRes = await get('/api/v1/info?all');

  if (infoRes.status === 200 && infoRes.body) {
    const info = infoRes.body;
    console.log(`  API Version: ${info.apiVersion}`);
    console.log(`  Site Name:   ${info.siteName}`);
    console.log(`  Product:     ${info.product?.name} v${info.product?.version}`);
    console.log(`  Timezone:    ${info.timezone?.name} (${info.timezone?.bias})`);
    console.log(`  License:     ${info.license?.type} (max ${info.license?.maxChannels} channels)`);
    console.log(`  User:        ${info.whoAmI?.uid} (${info.whoAmI?.name})`);
  }

  // ─────────────────────────────────────────────────
  // 2. System Info (individual items)
  //    Available items: os, cpu, storage, network
  //    NOTE: 'storage' request returns 'disk' field in response
  // ─────────────────────────────────────────────────
  console.log('\n=== System Info ===');

  // OS info
  const osRes = await get('/api/v1/system/info?item=os');
  if (osRes.status === 200 && osRes.body) {
    console.log(`  OS: ${JSON.stringify(osRes.body.os || osRes.body)}`);
  }

  // CPU info
  const cpuRes = await get('/api/v1/system/info?item=cpu');
  if (cpuRes.status === 200 && cpuRes.body) {
    console.log(`  CPU: ${JSON.stringify(cpuRes.body.cpu || cpuRes.body)}`);
  }

  // Storage info (response field is 'disk', not 'storage')
  const storageRes = await get('/api/v1/system/info?item=storage');
  if (storageRes.status === 200 && storageRes.body) {
    const disks = storageRes.body.disk || storageRes.body.storage || storageRes.body;
    console.log(`  Disk: ${JSON.stringify(disks)}`);
  }

  // Network info (includes lastUpdate field)
  const netRes = await get('/api/v1/system/info?item=network');
  if (netRes.status === 200 && netRes.body) {
    console.log(`  Network: ${JSON.stringify(netRes.body.network || netRes.body)}`);
    if (netRes.body.lastUpdate) {
      console.log(`  Last Update: ${netRes.body.lastUpdate}`);
    }
  }

  // Multiple items at once
  console.log('\n--- Multiple items ---');
  const multiRes = await get('/api/v1/system/info?item=os,cpu');
  if (multiRes.status === 200) {
    console.log(`  ${JSON.stringify(multiRes.body, null, 2)}`);
  }

  // ─────────────────────────────────────────────────
  // 3. System Health (real-time usage)
  //    Available items: cpu, memory, disk
  // ─────────────────────────────────────────────────
  console.log('\n=== System Health ===');
  const healthRes = await get('/api/v1/system/health');

  if (healthRes.status === 200 && healthRes.body) {
    const h = healthRes.body;

    if (Array.isArray(h.cpu)) {
      for (const c of h.cpu) {
        console.log(`  CPU Usage: ${c.usage?.total ?? 'N/A'}%`);
      }
    }
    if (h.memory) {
      const total = h.memory.totalPhysical || 0;
      const free = h.memory.freePhysical || 0;
      const used = total - free;
      const pct = total > 0 ? ((used / total) * 100).toFixed(1) : 'N/A';
      console.log(`  Memory: ${pct}% (${formatBytes(used)} / ${formatBytes(total)})`);
    }
    if (Array.isArray(h.disk)) {
      for (const d of h.disk) {
        const total = d.totalSpace || 0;
        const free = d.freeSpace || 0;
        const used = total - free;
        const pct = total > 0 ? ((used / total) * 100).toFixed(1) : 'N/A';
        console.log(`  Disk ${d.mount || ''}: ${pct}% (${formatBytes(used)} / ${formatBytes(total)})`);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // 4. HDD S.M.A.R.T Status
  // ─────────────────────────────────────────────────
  console.log('\n=== HDD S.M.A.R.T ===');
  const smartRes = await get('/api/v1/system/hddsmart');
  console.log(`  Status: ${smartRes.status}`);

  if (smartRes.status === 200 && smartRes.body) {
    if (Array.isArray(smartRes.body)) {
      for (const disk of smartRes.body) {
        console.log(`  ${disk.model || disk.name || 'Disk'}: ${disk.health || disk.status || 'N/A'}`);
      }
    } else {
      console.log(`  ${JSON.stringify(smartRes.body, null, 2)}`);
    }
  }

}

function formatBytes(bytes) {
  if (!bytes) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  let i = 0;
  let val = bytes;
  while (val >= 1024 && i < units.length - 1) { val /= 1024; i++; }
  return `${val.toFixed(1)} ${units[i]}`;
}

main().catch(console.error);
