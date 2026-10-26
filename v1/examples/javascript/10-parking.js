/**
 * Example 10: Parking Management
 *
 * Demonstrates:
 *   - Parking lot list and status (counter-based, entry/exit)
 *   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
 *   - Parking spot status (AI vision-based, per-space occupancy)
 *   - Filtering by zone type, channel, ID, category, occupancy
 *   - License check via /api/v1/info extension token (parkingHistory)
 *   - Parking session history, plate correction history (/plate/history)
 */

const { NVR_API_KEY } = require('./config');
const { setApiKey, get, post } = require('./http');

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


  // ─────────────────────────────────────────────────
  // 8. Parking Session History
  //    A session opens when a vehicle is confirmed present and closes when it
  //    leaves. Requires the parking history license (403 without it).
  //    Check /api/v1/info first: the `parkingHistory` extension token tells
  //    whether the session endpoints are available. license.extension is
  //    omitted when no extension is active.
  // ─────────────────────────────────────────────────
  const infoRes = await get('/api/v1/info?license');
  const extension = infoRes.body?.license?.extension || [];
  if (!extension.includes('parkingHistory')) {
    console.log(`\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples`);
    return;
  }

  console.log('\n=== Currently Parked ===');
  const openRes = await get('/api/v1/parking/session?open=true&maxCount=10');
  if (openRes.status === 200) {
    const { totalCount, asOf, data } = openRes.body;
    console.log(`  total=${totalCount} asOf=${asOf}`);
    for (const row of data) {
      const mins = Math.floor(row.durationMs / 60000);
      const edited = row.plateEdited ? ' (corrected)' : '';
      console.log(`  [${row.id}] ${row.src.name} ${row.plateNo || '(no plate)'}${edited} ${mins}m`);
    }
  } else {
    console.log(`  Status: ${openRes.status}`);
  }

  // ─────────────────────────────────────────────────
  // 9. Session Detail
  //    outKind / outTimeMeans tell how the exit time was determined.
  //    Only "observed" is a measurement; the others are estimates that can err
  //    in different directions, so bill from the basis, not from the time alone.
  //
  //    inKind / inTimeMeans do the same for the entry, but err the opposite way:
  //    firstSeen is an upper bound on the real entry (the vehicle was already
  //    there when observation started). Unlike the exit basis, it is present
  //    on open sessions too.
  // ─────────────────────────────────────────────────
  console.log('\n=== Session Detail ===');
  const oneRes = await get('/api/v1/parking/session?maxCount=1');
  const first = oneRes.status === 200 ? oneRes.body.data[0] : null;
  if (first) {
    const detail = await get(`/api/v1/parking/session/${first.id}`);
    if (detail.status === 200) {
      const d = detail.body;
      console.log(`  ${JSON.stringify(d).slice(0, 400)}`);
      console.log(`  entry basis: ${d.inKind} (${d.inTimeMeans})`);
      if (!d.open) console.log(`  exit basis: ${d.outKind} (${d.outTimeMeans})`);
    }
  } else {
    console.log('  (no sessions yet)');
  }

  // ─────────────────────────────────────────────────
  // 9b. Scope — what the query is scoped to
  //     Omitting the items means "the whole scope", not "no filter":
  //     scope=lot without a lot list returns only sessions that belong to a
  //     parking lot, so no-parking-zone sessions (which belong to no lot) are
  //     excluded.
  // ─────────────────────────────────────────────────
  console.log('\n=== Scope ===');
  for (const qs of [
    'scope=channel&ch=1,2',
    'scope=lot',
    'scope=noparking'
  ]) {
    const r = await get(`/api/v1/parking/session?${qs}&maxCount=5`);
    console.log(`  ${qs} => totalCount=${r.status === 200 ? r.body.totalCount : -1}`);
  }

  // ─────────────────────────────────────────────────
  // 9c. Video for a session — otherwise=nearBefore
  //     A parked car does not move, so motion-triggered recording may stop
  //     while it is still there. Because the car stays in place, earlier
  //     footage still shows it. Use otherwise=nearBefore for parking history only.
  //     An empty result means no usable recording exists (never recorded, or
  //     already recycled); the session snapshots are still available.
  // ─────────────────────────────────────────────────
  console.log('\n=== Video at entry time (nearest earlier if none) ===');
  if (first) {
    const d = (await get(`/api/v1/parking/session/${first.id}`)).body;
    // snapshots is a time-ordered array, not a map; each entry carries tags.
    // Several shots can share a tag (best shots), so find by tag and use the first (earliest).
    const snaps = (d && d.snapshots) || [];
    const tagged = t => snaps.find(x => (x.tags || []).indexOf(t) >= 0) || null;
    const shot = tagged('in');
    const chid = shot ? shot.chid : null;
    const at = shot ? shot.time : null;

    // Which shots read the plate: bestshot = attempted, plate = succeeded.
    // A failed shot keeps its image (plateNo is null) so a person can review it later.
    console.log('  snapshots:');
    for (const x of snaps) {
      console.log(`    ${x.time || 'now'}  tags=${(x.tags || []).join(',')}` +
        `  plate=${x.plateNo || '-'}`);
    }
    if (chid != null && at) {
      const v = await get(`/api/v1/vod?ch=${chid}&when=${encodeURIComponent(at)}&otherwise=nearBefore`);
      const srcs = v.status === 200 ? v.body : [];
      console.log(`  ch=${chid} when=${at} -> ${srcs.length} channel(s)`);
      if (srcs.length === 0)
        console.log('  (no recorded video at or before this time)');
    }
  }

  // ─────────────────────────────────────────────────
  // 9d. Which car is it? — the bounding box
  //     A snapshot can contain several cars; `box` marks the one this session
  //     is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
  //     Multiply by the size of the surface you draw on; the internal
  //     coordinate space does not matter.
  //     Entrance/exit sessions have no vehicle box (a single plate read):
  //     the value is null, but the key is always present.
  // ─────────────────────────────────────────────────
  console.log('\n=== Bounding box of the session vehicle ===');
  if (first) {
    const box = (await get(`/api/v1/parking/session/${first.id}`)).body.box;
    if (!box) {
      console.log('  (no box for this session)');
    } else {
      const W = 1920, H = 1080;       // drawing surface size
      const left = Math.round((box.cx - box.w / 2) * W);
      const top = Math.round((box.cy - box.h / 2) * H);
      console.log(`  box = ${JSON.stringify(box)}`);
      console.log(`  on ${W}x${H} -> left=${left} top=${top} ` +
        `width=${Math.round(box.w * W)} height=${Math.round(box.h * H)}`);
    }
  }

  // ─────────────────────────────────────────────────
  // 9e. Plate correction history
  //     Only the session's representative plate (plateNo) is corrected; per-shot
  //     readings (snapshots[].plateNo) are kept as evidence.
  //     Reading requires Playback permission.
  // ─────────────────────────────────────────────────
  console.log('\n=== Plate correction history ===');
  if (first) {
    const r = await get(`/api/v1/parking/session/${first.id}/plate/history`);
    if (r.status === 200) {
      const h = r.body;
      console.log(`  session=${h.id} plateNo=${h.plateNo} original=${h.originalPlateNo ?? '(never corrected)'}`);
      for (const e of h.edits || []) {
        console.log(`    ${e.time} ${e.user}: ${e.before} -> ${e.after} ${e.reason || ''}`);
      }
    } else {
      console.log(`  Status: ${r.status}`);
    }
  }

  // ─────────────────────────────────────────────────
  // 10. Writing history (Control permission)
  //     These calls change stored history, so they are not executed here.
  //     Payment state (16.7): commit settles it, exempt records a decision not to
  //     collect, and undo reverts the most recent change (the response says which).
  //     Records are appended, never deleted.
  //
  //     close (16.8) is separate: it ends a session whose exit was never observed
  //     and would otherwise stay "parked". exempt removes a session from billing
  //     but may leave it parked; close ends it. Do not confuse the two.
  //
  //     await post(`/api/v1/parking/session/${id}/payment/commit?ref=POS-0042`);
  //     await post(`/api/v1/parking/session/${id}/payment/exempt`);
  //     await post(`/api/v1/parking/session/${id}/payment/undo`);
  //     await post(`/api/v1/parking/session/${id}/close`);
  //
  //     Plate correction (16.9): one session by id; no bulk correction or merging.
  //     Payments stay with the session. Returns 409 when plateNo equals the current plate.
  //
  //     Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
  //     Uncomment it to try it against a test record.
  //     await post(`/api/v1/parking/session/${id}/plate`, { plateNo: '12가3456', reason: 'misread at night' });
  // ─────────────────────────────────────────────────

}

main().catch(console.error);
