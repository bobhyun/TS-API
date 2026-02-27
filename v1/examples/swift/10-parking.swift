/**
 * Example 10: Parking Management
 *
 * Demonstrates:
 *   - Parking lot list and status (counter-based, entry/exit)
 *   - Recognition zones (all types: spot, entrance, exit, noParking, recognition)
 *   - Parking spot status (AI vision-based, per-space occupancy)
 *   - Filtering by zone type, channel, ID, category, occupancy
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
  }
}
