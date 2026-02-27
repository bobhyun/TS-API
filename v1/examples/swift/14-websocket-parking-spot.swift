/**
 * Example 14: WebSocket - Parking Spot Monitoring
 *
 * Subscribes to parkingSpot topic for parking zone monitoring.
 * First message: currentStatus (ALL zone types: spot, entrance, exit, noParking, recognition)
 *   - Each zone has a `type` field; only type="spot" has `occupied` and `category`
 *   - Non-spot zones have `category: null` and no `occupied` field
 * Subsequent: statusChanged (only fires for type="spot" zones)
 *
 * Channel IDs (chid) are 1-based.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingSpot
 *
 * Auth:
 *   Header: X-API-Key: {apiKey}                  (primary)
 *   Header: Authorization: Bearer {accessToken}   (alternative)
 *   Query:  ?apikey={apiKey}                      (browser fallback)
 *   Query:  ?token={accessToken}                  (browser fallback)
 *
 * Optional filters (OR logic):
 *   &ch=1,2       - spots belonging to channels 1, 2
 *   &lot=1,2      - spots belonging to parking lots 1, 2
 *   &spot=100,200 - specific spot IDs
 *
 * See also: 13-websocket-parking-lot.swift for lot-level count monitoring
 *
 * Build: swiftc -o 14-websocket-parking-spot NvrClient.swift 14-websocket-parking-spot.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./14-websocket-parking-spot
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
    // Subscribe to Parking Spot Status (30 seconds)
    //   Filters (OR logic, combine as needed):
    //   &ch=1,2    - by channel
    //   &lot=1,2   - by parking lot
    //   &spot=100  - by spot ID
    // -------------------------------------------------
    print("=== WebSocket Parking Spot Monitoring (30 seconds) ===")

    let wsTask = client.websocket(
        path: "/wsapi/v1/events?topics=parkingSpot"
    )
    // With filters (append to path):
    //   "/wsapi/v1/events?topics=parkingSpot&ch=1,2"
    //   "/wsapi/v1/events?topics=parkingSpot&lot=1,2"
    //   "/wsapi/v1/events?topics=parkingSpot&spot=100,200"

    wsTask.resume()
    print("  Connected! Waiting for spot events...\n")

    var msgCount = 0

    // Read messages for 30 seconds
    let deadline = Date().addingTimeInterval(30.0)

    while Date() < deadline {
        do {
            let message = try await withThrowingTaskGroup(of: URLSessionWebSocketTask.Message?.self) { group in
                group.addTask {
                    try await wsTask.receive()
                }
                group.addTask {
                    let remaining = deadline.timeIntervalSinceNow
                    if remaining > 0 {
                        try await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                    }
                    return nil
                }

                let result = try await group.next()
                group.cancelAll()
                return result ?? nil
            }

            guard let message = message else { break }

            switch message {
            case .string(let text):
                msgCount += 1
                guard let data = text.data(using: .utf8),
                      let msg = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("  Raw: \(text)")
                    continue
                }

                let event = msg["event"] as? String ?? ""

                if event == "currentStatus" {
                    let spots = msg["spots"] as? [[String: Any]] ?? []
                    print("  [currentStatus] \(spots.count) zones")
                    for zone in spots {
                        let id = zone["id"] as? Int ?? 0
                        let name = zone["name"] as? String ?? ""
                        let type = zone["type"] as? String ?? ""

                        if type == "spot" {
                            let category = zone["category"] as? String ?? ""
                            let occupied = zone["occupied"] as? Bool ?? false
                            if occupied {
                                let v = zone["vehicle"] as? [String: Any] ?? [:]
                                let plate = v["plateNo"] as? String ?? ""
                                let score = v["score"] as? Double ?? 0
                                print("    [\(id)] \(name) (\(category)): occupied [\(plate) \(String(format: "%.1f", score))%]")
                            } else {
                                print("    [\(id)] \(name) (\(category)): empty")
                            }
                        } else {
                            print("    [\(id)] \(name) (type: \(type))")
                        }
                    }
                } else if event == "statusChanged" {
                    // statusChanged only fires for type="spot"
                    let spots = msg["spots"] as? [[String: Any]] ?? []
                    for spot in spots {
                        let id = spot["id"] as? Int ?? 0
                        let occupied = spot["occupied"] as? Bool ?? false
                        let status = occupied ? "occupied" : "empty"
                        print("  [statusChanged] spot \(id) -> \(status)")
                        if occupied, let vehicle = spot["vehicle"] as? [String: Any] {
                            let plate = vehicle["plateNo"] as? String ?? ""
                            let score = vehicle["score"] as? Double ?? 0
                            print("    plate: \(plate)  score: \(score)%")
                        }
                    }
                }

            case .data(let data):
                msgCount += 1
                print("  Binary: \(data.count) bytes")

            @unknown default:
                break
            }
        } catch {
            break
        }
    }

    print("\n  Received \(msgCount) events")
    wsTask.cancel(with: .normalClosure, reason: nil)
    try await Task.sleep(nanoseconds: 500_000_000)
  }
}
