/**
 * Example 10: Parking Management
 *
 * Demonstrates:
 *   - Parking lot list and status (counter-based, entry/exit)
 *   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
 *   - Parking spot status (AI vision-based, per-space occupancy)
 *   - Filtering by zone type, channel, ID, category, occupancy
 *   - License check via /api/v1/info extension token (parkingHistory)
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
  //    is gone. Needs the parking history license — 403 without it. Ask
  //    /api/v1/info first: the `parkingHistory` extension token says whether
  //    the session endpoints will answer (the array is omitted when no
  //    extension is active).
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
      console.log(`  [${row.id}] ${row.src.name} ${row.plateNo || '(no plate)'} ${mins}m`);
    }
  } else {
    console.log(`  Status: ${openRes.status}`);
  }

  // ─────────────────────────────────────────────────
  // 9. Session Detail
  //    outKind / outTimeMeans say HOW the exit time was decided. Only
  //    "observed" is a measurement; the others are estimates whose error leans
  //    in different directions, so bill from the basis, not the number alone.
  //
  //    inKind / inTimeMeans do the same for the entry, and the error leans the
  //    OTHER way: firstSeen is an UPPER bound on the real entry (already there
  //    when observation started). It is present on OPEN sessions too.
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
  //     Items omitted means "the whole scope", which is NOT the same as no
  //     filter: scope=lot with no lot returns only sessions that belong to a
  //     parking lot, so no-parking-zone history is excluded (it belongs to no
  //     lot).
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
  //     A parked car does not move, so motion-triggered recording may have
  //     stopped while it was still there. The car is in the same place, so the
  //     preceding footage still shows the situation. Parking history only.
  //     An empty result means there is no usable recording at all (never
  //     recorded, or already recycled); the snapshots remain available.
  // ─────────────────────────────────────────────────
  console.log('\n=== Video at entry time (nearest earlier if none) ===');
  if (first) {
    const d = (await get(`/api/v1/parking/session/${first.id}`)).body;
    // snapshots 는 시각 오름차순 배열이고 각 항목이 tags 를 든다 — 키로 꺼내지 않는다.
    // 같은 뜻이 여러 장일 수 있어(베스트샷) 태그로 찾고 첫 항목을 쓴다.
    const snaps = (d && d.snapshots) || [];
    const tagged = t => snaps.find(x => (x.tags || []).indexOf(t) >= 0) || null;
    const shot = tagged('in');
    const chid = shot ? shot.chid : null;
    const at = shot ? shot.time : null;

    // 어느 샷이 번호를 읽어냈나. bestshot = 시도, plate = 성공.
    // 실패한 샷도 사진은 남는다(plateNo 는 null) — 나중에 사람이 확인할 수 있다.
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
  //     A snapshot can hold several cars. `box` points at the one this session
  //     is about. YOLO style: center based, all four values 0..1 (see 1.2), so
  //     you multiply by the size of whatever you draw on — no need to know the
  //     internal coordinate space. Entrance/exit sessions carry no vehicle box
  //     (a single plate read) and the value is null; the key is always present.
  // ─────────────────────────────────────────────────
  console.log('\n=== Bounding box of the session vehicle ===');
  if (first) {
    const box = (await get(`/api/v1/parking/session/${first.id}`)).body.box;
    if (!box) {
      console.log('  (no box for this session)');
    } else {
      const W = 1920, H = 1080;       // 그릴 대상 크기
      const left = Math.round((box.cx - box.w / 2) * W);
      const top = Math.round((box.cy - box.h / 2) * H);
      console.log(`  box = ${JSON.stringify(box)}`);
      console.log(`  on ${W}x${H} -> left=${left} top=${top} ` +
        `width=${Math.round(box.w * W)} height=${Math.round(box.h * H)}`);
    }
  }

  // ─────────────────────────────────────────────────
  // 10. Writing history (Control permission)
  //     Both change stored history, so they are not executed here.
  //     Payment state (16.7): commit settles it, exempt records a decision not to
  //     collect, undo reverts the most recent change (the response says which one).
  //     Records are appended, never deleted.
  //    
  //     close (16.8) is a different axis: it clears the lingering "parked" state left
  //     when an exit was never observed. Exempt takes a session out of billing and may
  //     leave it parked; close ends the session. Do not conflate the two.
  //
  //     await post(`/api/v1/parking/session/${id}/payment/commit?ref=POS-0042`);
  //     await post(`/api/v1/parking/session/${id}/payment/exempt`);
  //     await post(`/api/v1/parking/session/${id}/payment/undo`);
  //     await post(`/api/v1/parking/session/${id}/close`);
  // ─────────────────────────────────────────────────

}

main().catch(console.error);
