/**
 * Example 10: Parking Management
 *
 * Demonstrates:
 *   - Parking lot list and status (counter-based, entry/exit)
 *   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
 *   - Parking spot status (AI vision-based, per-space occupancy)
 *   - Filtering by zone type, channel, ID, category, occupancy
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
  // 1. Parking Lot List
  //    Counter-based parking management (entry/exit counting)
  // ─────────────────────────────────────────────────
  console.log('=== Parking Lots ===');
  const lotRes = await get('/api/v1/parking/lot');

  if (lotRes.status === 200 && Array.isArray(lotRes.body)) {
    for (const lot of lotRes.body) {
      let info = `  [${lot.id}] ${lot.name} (type: ${lot.type}, max: ${lot.maxCount})`;
      if (lot.parkingSpots) info += ` spots: [${lot.parkingSpots.join(', ')}]`;
      if (lot.member) info += ` member: [${lot.member.join(', ')}]`;
      console.log(info);
    }
    console.log(`  Total: ${lotRes.body.length} lots`);
  } else {
    console.log(`  Status: ${lotRes.status} (parking lot feature may not be configured)`);
  }

  // ─────────────────────────────────────────────────
  // 2. Parking Lot Status (real-time counts)
  // ─────────────────────────────────────────────────
  console.log('\n=== Parking Lot Status ===');
  const lotStatusRes = await get('/api/v1/parking/lot/status');

  if (lotStatusRes.status === 200 && Array.isArray(lotStatusRes.body)) {
    for (const lot of lotStatusRes.body) {
      const occupancy = lot.maxCount > 0 ? ((lot.count / lot.maxCount) * 100).toFixed(0) : 0;
      console.log(`  ${lot.name}: ${lot.count}/${lot.maxCount} (${occupancy}% full, ${lot.available} available)`);
    }
  }

  // ─────────────────────────────────────────────────
  // 3. Recognition Zone List (all types)
  //    Returns all zone types: spot, entrance, exit, noParking, recognition
  //    chid is 1-based
  // ─────────────────────────────────────────────────
  console.log('\n=== Recognition Zones ===');
  const spotRes = await get('/api/v1/parking/spot');

  if (spotRes.status === 200 && Array.isArray(spotRes.body)) {
    for (const zone of spotRes.body) {
      let info = `  [${zone.id}] ${zone.name} (CH${zone.chid}, type: ${zone.type}`;
      if (zone.type === 'spot') {
        info += `, category: ${zone.category}, ${zone.occupied ? 'occupied' : 'empty'}`;
      }
      info += ')';
      console.log(info);
    }
    const types = {};
    for (const zone of spotRes.body) {
      types[zone.type] = (types[zone.type] || 0) + 1;
    }
    console.log(`  Total: ${spotRes.body.length} zones (${Object.entries(types).map(([k, v]) => `${k}: ${v}`).join(', ')})`);
  } else {
    console.log(`  Status: ${spotRes.status} (parking spot feature may not be configured)`);
  }

  // ─────────────────────────────────────────────────
  // 4. Parking Spot Status (real-time occupancy)
  //    Only returns zones with type=spot (not entrance/exit/etc.)
  // ─────────────────────────────────────────────────
  console.log('\n=== Parking Spot Status ===');
  const spotStatusRes = await get('/api/v1/parking/spot/status');

  if (spotStatusRes.status === 200 && Array.isArray(spotStatusRes.body)) {
    let occupied = 0;
    let empty = 0;

    for (const spot of spotStatusRes.body) {
      if (spot.occupied) {
        occupied++;
        const plate = spot.vehicle?.plateNo || 'unknown';
        const since = spot.vehicle?.since || '';
        console.log(`  ${spot.name}: OCCUPIED (${plate}, since ${since})`);
      } else {
        empty++;
        console.log(`  ${spot.name}: EMPTY`);
      }
    }
    console.log(`\n  Summary: ${occupied} occupied, ${empty} empty`);
  }

  // ─────────────────────────────────────────────────
  // 5. Filter by Zone Type (entrance/exit vs parking spots)
  //    Use the zone list from section 3 and filter client-side
  // ─────────────────────────────────────────────────
  console.log('\n=== Entrance/Exit Zones ===');
  if (spotRes.status === 200 && Array.isArray(spotRes.body)) {
    const entranceExitZones = spotRes.body.filter(z => z.type === 'entrance' || z.type === 'exit');
    for (const zone of entranceExitZones) {
      console.log(`  [${zone.id}] ${zone.name} (CH${zone.chid}, type: ${zone.type})`);
    }
    console.log(`  Total: ${entranceExitZones.length} entrance/exit zones`);

    const parkingSpots = spotRes.body.filter(z => z.type === 'spot');
    console.log(`\n=== Parking Spots Only ===`);
    for (const zone of parkingSpots) {
      console.log(`  [${zone.id}] ${zone.name} (CH${zone.chid}, category: ${zone.category})`);
    }
    console.log(`  Total: ${parkingSpots.length} parking spots`);
  }

  // ─────────────────────────────────────────────────
  // 6. Filter by Category (disabled parking, etc.)
  // ─────────────────────────────────────────────────
  console.log('\n=== Disabled Parking Spots ===');
  const disabledRes = await get('/api/v1/parking/spot?category=disabled');
  if (disabledRes.status === 200 && Array.isArray(disabledRes.body)) {
    console.log(`  Found: ${disabledRes.body.length} disabled parking spots`);
  }

  // ─────────────────────────────────────────────────
  // 7. Filter by Occupancy
  // ─────────────────────────────────────────────────
  console.log('\n=== Empty Spots Only ===');
  const emptyRes = await get('/api/v1/parking/spot/status?occupied=false');
  if (emptyRes.status === 200 && Array.isArray(emptyRes.body)) {
    console.log(`  Available spots: ${emptyRes.body.length}`);
  }

}

main().catch(console.error);
