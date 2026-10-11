/**
 * v1 API - Parking Management
 *
 * Endpoints:
 *   GET /api/v1/parking/lot           - List parking lots
 *   GET /api/v1/parking/lot/status    - Lot occupancy status
 *   GET /api/v1/parking/spot          - List parking spots
 *   GET /api/v1/parking/spot/status   - Individual spot status
 *   GET /api/v1/info?license          - License check (parkingHistory extension token)
 *
 * Compile: javac NvrClient.java V1_10_Parking.java
 * Run:     java V1_10_Parking
 */
public class V1_10_Parking {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── Parking Lots ──
        // GET /api/v1/parking/lot
        System.out.println("=== Parking Lots ===");
        NvrClient.Response r = client.get("/api/v1/parking/lot");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Lot Occupancy Status ──
        // GET /api/v1/parking/lot/status
        System.out.println("\n=== Parking Lot Status ===");
        r = client.get("/api/v1/parking/lot/status");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Parking Spots ──
        // GET /api/v1/parking/spot
        System.out.println("\n=== Parking Spots ===");
        r = client.get("/api/v1/parking/spot");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Spot Status ──
        // GET /api/v1/parking/spot/status
        System.out.println("\n=== Parking Spot Status ===");
        r = client.get("/api/v1/parking/spot/status");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Parking Session History ──
        // GET /api/v1/parking/session
        // A session opens when a vehicle is confirmed present and closes when it is
        // gone. Needs the parking history license - 403 without it. Ask /api/v1/info
        // first: the "parkingHistory" extension token says whether the session
        // endpoints will answer. No JSON parser here, so test for the quoted token.
        r = client.get("/api/v1/info?license");
        if (r.status != 200 || !r.body.contains("\"parkingHistory\"")) {
            System.out.println("\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples");
            return;
        }
        System.out.println("\n=== Currently Parked ===");
        r = client.get("/api/v1/parking/session?open=true&maxCount=10");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Session Detail ──
        // GET /api/v1/parking/session/{id}
        // outKind / outTimeMeans say HOW the exit time was decided. Only "observed"
        // is a measurement; the others are estimates whose error leans in different
        // directions, so bill from the basis, not from the number alone.
        //
        // inKind / inTimeMeans do the same for the entry, and the error leans the
        // OTHER way: firstSeen is an UPPER bound on the real entry (already there
        // when observation started). It is present on OPEN sessions too — the body
        // below shows both fields.
        System.out.println("\n=== Session Detail ===");
        r = client.get("/api/v1/parking/session?maxCount=1");
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Scope: what the query is scoped to ──
        // Items omitted means "the whole scope", which is NOT the same as no
        // filter: scope=lot with no lot returns only sessions that belong to a
        // parking lot, so no-parking-zone history is excluded.
        System.out.println("\n=== Scope ===");
        for (String qs : new String[] {"scope=channel&ch=1,2", "scope=lot", "scope=noparking"}) {
            r = client.get("/api/v1/parking/session?" + qs + "&maxCount=5");
            System.out.println("  " + qs + " => " + r.status);
        }

        // ── Video for a session: otherwise=nearBefore ──
        // A parked car does not move, so motion-triggered recording may have
        // stopped while it was still there. The car is in the same place, so the
        // preceding footage still shows the situation. Parking history only.
        // An empty result means there is no usable recording at all (never
        // recorded, or already recycled); the snapshots remain available.
        System.out.println("\n=== Video at entry time (nearest earlier if none) ===");
        r = client.get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore");
        System.out.println("  => " + r.status);

        // ── Which car is it? the bounding box ──
        // A snapshot can hold several cars. `box` points at the one this session
        // is about. YOLO style: center based, all four values 0..1 (see 1.2) —
        // multiply by the size of whatever you draw on:
        //   left = (cx - w/2) * width,  top = (cy - h/2) * height
        // Entrance/exit sessions carry no vehicle box (a single plate read) and
        // the value is null; the key is always present.
        System.out.println("\n=== Bounding box of the session vehicle ===");
        r = client.get("/api/v1/parking/session?maxCount=1");
        System.out.println("  => " + r.status);
        if (r.status == 200 && r.body != null) {
            System.out.println(r.body.contains("\"box\":null")
                ? "  (no box for this session)"
                : "  box present - see 1.2 for the conversion");
        }

        // ── Writing history (Control permission) ──
        // Both change stored history, so they are not executed here.
        // Payment state (16.7): commit settles it, exempt records a decision not to
        // collect, undo reverts the most recent change (the response says which one).
        // Records are appended, never deleted.
        //
        // close (16.8) is a different axis: it clears the lingering "parked" state left
        // when an exit was never observed. Exempt takes a session out of billing and may
        // leave it parked; close ends the session. Do not conflate the two.
        //
        //   client.post("/api/v1/parking/session/" + id + "/payment/commit?ref=POS-0042", "");
        //   client.post("/api/v1/parking/session/" + id + "/payment/exempt", "");
        //   client.post("/api/v1/parking/session/" + id + "/payment/undo", "");
        //   client.post("/api/v1/parking/session/" + id + "/close", "");
    }
}
