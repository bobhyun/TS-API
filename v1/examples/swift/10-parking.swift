/**
 * Example 10: Parking Management
 *
 * Demonstrates:
 *   - Parking lot list and status (counter-based, entry/exit)
 *   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
 *   - Parking spot status (AI vision-based, per-space occupancy)
 *   - Filtering by zone type, channel, ID, category, occupancy
 *   - License check via /api/v1/info extension token (parkingHistory)
 *   - Parking session history, detail and plate correction history
 *     (GET /api/v1/parking/session/{id}/plate/history; the POST correction is not executed)
 *
 * Build: swiftc -o 10-parking NvrClient.swift 10-parking.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./10-parking
 */

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct App {
  static func main() async throws {
    let client = NvrClient()
    guard !client.apiKey.isEmpty else {
        print("NVR_API_KEY environment variable is required")
        exit(1)
    }
    client.setApiKey(client.apiKey)

    // -------------------------------------------------
    // 1. Parking Lot List
    //    Counter-based parking management (entry/exit counting)
    // -------------------------------------------------
    print("=== Parking Lots ===")
    let lotRes = try await client.get("/api/v1/parking/lot")

    if lotRes.status == 200, let lots = lotRes.body as? [[String: Any]] {
        for lot in lots {
            let id = lot["id"] as? Int ?? 0
            let name = lot["name"] as? String ?? ""
            let type = lot["type"] as? String ?? ""
            let maxCount = lot["maxCount"] as? Int ?? 0
            var info = "  [\(id)] \(name) (type: \(type), max: \(maxCount))"
            if let spots = lot["parkingSpots"] as? [Int] {
                info += " spots: [\(spots.map(String.init).joined(separator: ", "))]"
            }
            if let members = lot["member"] as? [Int] {
                info += " member: [\(members.map(String.init).joined(separator: ", "))]"
            }
            print(info)
        }
        print("  Total: \(lots.count) lots")
    } else {
        print("  Status: \(lotRes.status) (parking lot feature may not be configured)")
    }

    // -------------------------------------------------
    // 2. Parking Lot Status (real-time counts)
    // -------------------------------------------------
    print("\n=== Parking Lot Status ===")
    let lotStatusRes = try await client.get("/api/v1/parking/lot/status")

    if lotStatusRes.status == 200, let lots = lotStatusRes.body as? [[String: Any]] {
        for lot in lots {
            let name = lot["name"] as? String ?? ""
            let count = lot["count"] as? Int ?? 0
            let maxCount = lot["maxCount"] as? Int ?? 0
            let available = lot["available"] as? Int ?? 0
            let occupancy = maxCount > 0 ? Int(Double(count) / Double(maxCount) * 100) : 0
            print("  \(name): \(count)/\(maxCount) (\(occupancy)% full, \(available) available)")
        }
    }

    // -------------------------------------------------
    // 3. Recognition Zone List (all types)
    //    Returns all zone types: spot, entrance, exit, noParking, recognition
    //    chid is 1-based
    // -------------------------------------------------
    print("\n=== Recognition Zones ===")
    let spotRes = try await client.get("/api/v1/parking/spot")

    if spotRes.status == 200, let zones = spotRes.body as? [[String: Any]] {
        var typeCounts: [String: Int] = [:]
        for zone in zones {
            let id = zone["id"] as? Int ?? 0
            let name = zone["name"] as? String ?? ""
            let chid = zone["chid"] as? Int ?? 0
            let type = zone["type"] as? String ?? ""
            typeCounts[type, default: 0] += 1

            var info = "  [\(id)] \(name) (CH\(chid), type: \(type)"
            if type == "spot" {
                let category = zone["category"] as? String ?? ""
                let occupied = zone["occupied"] as? Bool ?? false
                info += ", category: \(category), \(occupied ? "occupied" : "empty")"
            }
            info += ")"
            print(info)
        }
        let typeStr = typeCounts.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        print("  Total: \(zones.count) zones (\(typeStr))")
    } else {
        print("  Status: \(spotRes.status) (parking spot feature may not be configured)")
    }

    // -------------------------------------------------
    // 4. Parking Spot Status (real-time occupancy)
    //    Only returns zones with type=spot (not entrance/exit/etc.)
    // -------------------------------------------------
    print("\n=== Parking Spot Status ===")
    let spotStatusRes = try await client.get("/api/v1/parking/spot/status")

    if spotStatusRes.status == 200, let spots = spotStatusRes.body as? [[String: Any]] {
        var occupied = 0
        var empty = 0

        for spot in spots {
            let name = spot["name"] as? String ?? ""
            let isOccupied = spot["occupied"] as? Bool ?? false
            if isOccupied {
                occupied += 1
                let vehicle = spot["vehicle"] as? [String: Any]
                let plate = vehicle?["plateNo"] as? String ?? "unknown"
                let since = vehicle?["since"] as? String ?? ""
                print("  \(name): OCCUPIED (\(plate), since \(since))")
            } else {
                empty += 1
                print("  \(name): EMPTY")
            }
        }
        print("\n  Summary: \(occupied) occupied, \(empty) empty")
    }

    // -------------------------------------------------
    // 5. Filter by Zone Type (entrance/exit vs parking spots)
    // -------------------------------------------------
    print("\n=== Entrance/Exit Zones ===")
    if spotRes.status == 200, let zones = spotRes.body as? [[String: Any]] {
        let entranceExit = zones.filter {
            let t = $0["type"] as? String ?? ""
            return t == "entrance" || t == "exit"
        }
        for zone in entranceExit {
            let id = zone["id"] as? Int ?? 0
            let name = zone["name"] as? String ?? ""
            let chid = zone["chid"] as? Int ?? 0
            let type = zone["type"] as? String ?? ""
            print("  [\(id)] \(name) (CH\(chid), type: \(type))")
        }
        print("  Total: \(entranceExit.count) entrance/exit zones")

        let parkingSpots = zones.filter { ($0["type"] as? String) == "spot" }
        print("\n=== Parking Spots Only ===")
        for zone in parkingSpots {
            let id = zone["id"] as? Int ?? 0
            let name = zone["name"] as? String ?? ""
            let chid = zone["chid"] as? Int ?? 0
            let category = zone["category"] as? String ?? ""
            print("  [\(id)] \(name) (CH\(chid), category: \(category))")
        }
        print("  Total: \(parkingSpots.count) parking spots")
    }

    // -------------------------------------------------
    // 6. Filter by Category (disabled parking, etc.)
    // -------------------------------------------------
    print("\n=== Disabled Parking Spots ===")
    let disabledRes = try await client.get("/api/v1/parking/spot?category=disabled")
    if disabledRes.status == 200, let spots = disabledRes.body as? [[String: Any]] {
        print("  Found: \(spots.count) disabled parking spots")
    }

    // -------------------------------------------------
    // 7. Filter by Occupancy
    // -------------------------------------------------
    print("\n=== Empty Spots Only ===")
    let emptyRes = try await client.get("/api/v1/parking/spot/status?occupied=false")
    if emptyRes.status == 200, let spots = emptyRes.body as? [[String: Any]] {
        print("  Available spots: \(spots.count)")
    }

    // -------------------------------------------------
    // 8. Parking Session History
    //    A session opens when a vehicle is confirmed present and closes when it
    //    leaves. Requires the parking history license (403 without it).
    //    Check /api/v1/info first: the `parkingHistory` extension token tells
    //    whether the session endpoints are available. license.extension is
    //    omitted when no extension is active.
    // -------------------------------------------------
    let infoRes = try await client.get("/api/v1/info?license")
    let license = (infoRes.body as? [String: Any])?["license"] as? [String: Any]
    let extTokens = license?["extension"] as? [String] ?? []
    if !extTokens.contains("parkingHistory") {
        print("\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples")
        return
    }

    print("\n=== Currently Parked ===")
    let openRes = try await client.get("/api/v1/parking/session?open=true&maxCount=10")
    if openRes.status == 200, let body = openRes.body as? [String: Any] {
      let total = body["totalCount"] as? Int ?? -1
      let asOf = body["asOf"] as? String ?? ""
      print("  total=\(total) asOf=\(asOf)")
      for row in (body["data"] as? [[String: Any]] ?? []) {
        let id = row["id"] as? Int ?? 0
        let mins = (row["durationMs"] as? Int ?? 0) / 60000
        let plate = row["plateNo"] as? String ?? "(no plate)"
        let name = (row["src"] as? [String: Any])?["name"] as? String ?? ""
        let edited = (row["plateEdited"] as? Bool) == true ? " (corrected)" : ""
        print("  [\(id)] \(name) \(plate)\(edited) \(mins)m")
      }
    }

    // -------------------------------------------------
    // 9. Session Detail
    //    outKind / outTimeMeans tell how the exit time was determined.
    //    Only "observed" is a measurement; the others are estimates that can err
    //    in different directions, so bill from the basis, not from the time alone.
    //
    //    inKind / inTimeMeans do the same for the entry, but err the opposite way:
    //    firstSeen is an upper bound on the real entry (the vehicle was already
    //    there when observation started). Unlike the exit basis, it is present
    //    on open sessions too.
    // -------------------------------------------------
    print("\n=== Session Detail ===")
    let oneRes = try await client.get("/api/v1/parking/session?maxCount=1")
    if oneRes.status == 200,
       let body = oneRes.body as? [String: Any],
       let first = (body["data"] as? [[String: Any]])?.first,
       let id = first["id"] as? Int {
      let detail = try await client.get("/api/v1/parking/session/\(id)")
      if detail.status == 200, let d = detail.body as? [String: Any] {
        print("  \(d)")
        let inKind = d["inKind"] as? String ?? ""
        let inMeans = d["inTimeMeans"] as? String ?? ""
        print("  entry basis: \(inKind) (\(inMeans))")
        if (d["open"] as? Bool) == false {
          let kind = d["outKind"] as? String ?? ""
          let means = d["outTimeMeans"] as? String ?? ""
          print("  exit basis: \(kind) (\(means))")
        }
      }
    } else {
      print("  (no sessions yet)")
    }

    // -------------------------------------------------
    // 9b. Scope — what the query is scoped to
    //     Omitting the items means "the whole scope", not "no filter":
    //     scope=lot without a lot list returns only sessions that belong to a
    //     parking lot, so no-parking-zone sessions (which belong to no lot) are
    //     excluded.
    // -------------------------------------------------
    print("\n=== Scope ===")
    for qs in ["scope=channel&ch=1,2", "scope=lot", "scope=noparking"] {
      let sr = try await client.get("/api/v1/parking/session?\(qs)&maxCount=5")
      print("  \(qs) => \(sr.status)")
    }

    // -------------------------------------------------
    // 9c. Video for a session — otherwise=nearBefore
    //     A parked car does not move, so motion-triggered recording may stop
    //     while it is still there. Because the car stays in place, earlier
    //     footage still shows it. Use otherwise=nearBefore for parking history only.
    //     An empty result means no usable recording exists (never recorded, or
    //     already recycled); the session snapshots are still available.
    // -------------------------------------------------
    print("\n=== Video at entry time (nearest earlier if none) ===")
    let vr = try await client.get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore")
    print("  => \(vr.status)")

    // -------------------------------------------------
    // 9d. Which car is it? — the bounding box
    //     A snapshot can contain several cars; `box` marks the one this session
    //     is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
    //     Multiply by the size of the surface you draw on; the internal
    //     coordinate space does not matter.
    //     Entrance/exit sessions have no vehicle box (a single plate read):
    //     the value is null, but the key is always present.
    // -------------------------------------------------
    print("\n=== Bounding box of the session vehicle ===")
    let boxRes = try await client.get("/api/v1/parking/session?maxCount=1")
    if boxRes.status == 200,
       let bbody = boxRes.body as? [String: Any],
       let bfirst = (bbody["data"] as? [[String: Any]])?.first,
       let bid = bfirst["id"] as? Int {
      let detail = try await client.get("/api/v1/parking/session/\(bid)")
      if detail.status == 200, let d = detail.body as? [String: Any] {
        if let box = d["box"] as? [String: Any],
           let cx = box["cx"] as? Double, let cy = box["cy"] as? Double,
           let bw = box["w"] as? Double, let bh = box["h"] as? Double {
          let W = 1920.0, H = 1080.0     // drawing surface size
          print("  box = cx=\(cx) cy=\(cy) w=\(bw) h=\(bh)")
          print("  on \(Int(W))x\(Int(H)) -> left=\(Int((cx - bw / 2) * W)) "
            + "top=\(Int((cy - bh / 2) * H)) width=\(Int(bw * W)) height=\(Int(bh * H))")
        } else {
          print("  (no box for this session)")
        }
      }
    }

    // -------------------------------------------------
    // 9e. Plate correction history
    //     Only the session's representative plate (plateNo) is corrected; per-shot
    //     readings (snapshots[].plateNo) are kept as evidence.
    //     Reading requires Playback permission.
    // -------------------------------------------------
    print("\n=== Plate correction history ===")
    if boxRes.status == 200,
       let hbody = boxRes.body as? [String: Any],
       let hfirst = (hbody["data"] as? [[String: Any]])?.first,
       let hid = hfirst["id"] as? Int {
      let hr = try await client.get("/api/v1/parking/session/\(hid)/plate/history")
      if hr.status == 200, let h = hr.body as? [String: Any] {
        let original = h["originalPlateNo"] as? String ?? "(never corrected)"
        print("  session=\(h["id"] ?? "") plateNo=\(h["plateNo"] ?? "") original=\(original)")
        for e in h["edits"] as? [[String: Any]] ?? [] {
          print("    \(e["time"] ?? "") \(e["user"] ?? ""): \(e["before"] ?? "") -> \(e["after"] ?? "") \(e["reason"] ?? "")")
        }
      } else {
        print("  Status: \(hr.status)")
      }
    }

    // -------------------------------------------------
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
    //     _ = try await client.post("/api/v1/parking/session/\(id)/payment/commit?ref=POS-0042")
    //     _ = try await client.post("/api/v1/parking/session/\(id)/payment/exempt")
    //     _ = try await client.post("/api/v1/parking/session/\(id)/payment/undo")
    //     _ = try await client.post("/api/v1/parking/session/\(id)/close")
    //
    //     Plate correction (16.9): one session by id; no bulk correction or merging.
    //     Payments stay with the session. Returns 409 when plateNo equals the current plate.
    //
    //     Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
    //     Uncomment it to try it against a test record.
    //     _ = try await client.post("/api/v1/parking/session/\(id)/plate",
    //                               body: ["plateNo": "12가3456", "reason": "misread at night"])
    // -------------------------------------------------
  }
}
