/**
 * v1 API - Parking Management
 *
 * Endpoints:
 *   GET /api/v1/parking/lot           - List parking lots
 *   GET /api/v1/parking/lot/status    - Lot occupancy status
 *   GET /api/v1/parking/spot          - List parking spots
 *   GET /api/v1/parking/spot/status   - Individual spot status
 *   GET /api/v1/info?license          - License check (parkingHistory extension token)
 *   GET /api/v1/parking/session        - Parking session history
 *   GET /api/v1/parking/session/{id}/plate/history - Plate correction history of one session
 *   POST /api/v1/parking/session/{id}/plate        - Correct the session plate (not executed here)
 *
 * Compile: kotlinc TsApiClient.kt V1_10_Parking.kt -include-runtime -d V1_10_Parking.jar
 * Run:     java -jar V1_10_Parking.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- Parking Lots --
    // GET /api/v1/parking/lot
    println("=== Parking Lots ===")
    var r = client.get("/api/v1/parking/lot")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Lot Occupancy Status --
    // GET /api/v1/parking/lot/status
    println("\n=== Parking Lot Status ===")
    r = client.get("/api/v1/parking/lot/status")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Parking Spots --
    // GET /api/v1/parking/spot
    println("\n=== Parking Spots ===")
    r = client.get("/api/v1/parking/spot")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Spot Status --
    // GET /api/v1/parking/spot/status
    println("\n=== Parking Spot Status ===")
    r = client.get("/api/v1/parking/spot/status")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Parking Session History --
    // GET /api/v1/parking/session
    // A session opens when a vehicle is confirmed present and closes when it
    // leaves. Requires the parking history license (403 without it).
    // Check /api/v1/info first: the `parkingHistory` extension token tells
    // whether the session endpoints are available.
    // No JSON parser here, so look for the quoted token.
    r = client.get("/api/v1/info?license")
    if (r.status != 200 || "\"parkingHistory\"" !in r.body) {
        println("\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples")
        return
    }
    // plateEdited is true when a person corrected the plate (originalPlateNo then
    // holds the plate as first recognized); plateNo is always the current value.
    println("\n=== Currently Parked ===")
    r = client.get("/api/v1/parking/session?open=true&maxCount=10")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Session Detail --
    // GET /api/v1/parking/session/{id}
    // outKind / outTimeMeans tell how the exit time was determined.
    // Only "observed" is a measurement; the others are estimates that can err
    // in different directions, so bill from the basis, not from the time alone.
    //
    // inKind / inTimeMeans do the same for the entry, but err the opposite way:
    // firstSeen is an upper bound on the real entry (the vehicle was already
    // there when observation started). Unlike the exit basis, it is present
    // on open sessions too; the body below shows both fields.
    println("\n=== Session Detail ===")
    r = client.get("/api/v1/parking/session?maxCount=1")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Scope: what the query is scoped to --
    // Omitting the items means "the whole scope", not "no filter":
    // scope=lot without a lot list returns only sessions that belong to a
    // parking lot, so no-parking-zone sessions (which belong to no lot) are
    // excluded.
    println("\n=== Scope ===")
    for (qs in listOf("scope=channel&ch=1,2", "scope=lot", "scope=noparking")) {
        r = client.get("/api/v1/parking/session?$qs&maxCount=5")
        println("  $qs => ${r.status}")
    }

    // -- Video for a session: otherwise=nearBefore --
    // A parked car does not move, so motion-triggered recording may stop
    // while it is still there. Because the car stays in place, earlier
    // footage still shows it. Use otherwise=nearBefore for parking history only.
    // An empty result means no usable recording exists (never recorded, or
    // already recycled); the session snapshots are still available.
    println("\n=== Video at entry time (nearest earlier if none) ===")
    r = client.get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore")
    println("  => ${r.status}")

    // -- Which car is it? the bounding box --
    // A snapshot can contain several cars; `box` marks the one this session
    // is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
    // Multiply by the size of the surface you draw on:
    //   left = (cx - w/2) * width,  top = (cy - h/2) * height
    // Entrance/exit sessions have no vehicle box (a single plate read):
    // the value is null, but the key is always present.
    println("\n=== Bounding box of the session vehicle ===")
    r = client.get("/api/v1/parking/session?maxCount=1")
    println("  => ${r.status}")
    if (r.status == 200) {
        println(if (r.body.contains("\"box\":null")) "  (no box for this session)"
                else "  box present - see 1.2 for the conversion")
    }

    // -- Plate correction history --
    // GET /api/v1/parking/session/{id}/plate/history
    // Only the session's representative plate (plateNo) is corrected; per-shot
    // readings (snapshots[].plateNo) are kept as evidence.
    // Reading requires Playback permission.
    println("\n=== Plate correction history ===")
    r = client.get("/api/v1/parking/session?maxCount=1")
    val sid = if (r.status == 200)
        """"data"\s*:\s*\[\s*\{\s*"id"\s*:\s*(\d+)""".toRegex().find(r.body)?.groupValues?.get(1)
    else null
    if (sid != null) {
        r = client.get("/api/v1/parking/session/$sid/plate/history")
        println("  status=${r.status}")
        if (r.status == 200) {
            println(r.body)
        }
    } else {
        println("  (no sessions yet)")
    }

    // -- Writing history (Control permission) --
    // These calls change stored history, so they are not executed here.
    // Payment state (16.7): commit settles it, exempt records a decision not to
    // collect, and undo reverts the most recent change (the response says which).
    // Records are appended, never deleted.
    //
    // close (16.8) is separate: it ends a session whose exit was never observed
    // and would otherwise stay "parked". exempt removes a session from billing
    // but may leave it parked; close ends it. Do not confuse the two.
    //
    //   client.post("/api/v1/parking/session/$id/payment/commit?ref=POS-0042")
    //   client.post("/api/v1/parking/session/$id/payment/exempt")
    //   client.post("/api/v1/parking/session/$id/payment/undo")
    //   client.post("/api/v1/parking/session/$id/close")
    //
    // Plate correction (16.9): one session by id; no bulk correction or merging.
    // Payments stay with the session. Returns 409 when plateNo equals the current plate.
    //
    // Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
    // Uncomment it to try it against a test record.
    //   client.post("/api/v1/parking/session/$id/plate",
    //       """{"plateNo":"12가3456","reason":"misread at night"}""")
}
