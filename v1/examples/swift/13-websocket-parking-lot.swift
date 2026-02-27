/**
 * Example 13: WebSocket - Parking Lot Count Monitoring
 *
 * Subscribes to parkingCount topic for real-time lot occupancy changes.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingCount
 *
 * Auth:
 *   Header: X-API-Key: {apiKey}                  (primary)
 *   Header: Authorization: Bearer {accessToken}   (alternative)
 *   Query:  ?apikey={apiKey}                      (browser fallback)
 *   Query:  ?token={accessToken}                  (browser fallback)
 *
 * Optional filter: &lot=1,2 (filter by parking lot ID)
 *
 * See also: 14-websocket-parking-spot.swift for individual spot monitoring
 *
 * Build: swiftc -o 13-websocket-parking-lot NvrClient.swift 13-websocket-parking-lot.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./13-websocket-parking-lot
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
    // Subscribe to Parking Count (30 seconds)
    //   topic: parkingCount
    //   filter: &lot=1,2 (optional, filter by lot ID)
    // -------------------------------------------------
    print("=== WebSocket Parking Count Monitoring (30 seconds) ===")

    let wsTask = client.websocket(
        path: "/wsapi/v1/events?topics=parkingCount"
    )
    // With lot filter: "/wsapi/v1/events?topics=parkingCount&lot=1,2"

    wsTask.resume()
    print("  Connected! Waiting for parking count events...\n")

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

                // First message may be subscription confirmation
                if msg["subscriberId"] != nil {
                    print("  Subscribed (id=\(msg["subscriberId"]!))")
                    continue
                }

                // parkingCount: { topic, updated: [{id, name, type, maxCount, count}, ...] }
                if let updated = msg["updated"] as? [[String: Any]] {
                    for lot in updated {
                        let id = lot["id"] as? Int ?? 0
                        let name = lot["name"] as? String ?? ""
                        let type = lot["type"] as? String ?? ""
                        let maxCount = lot["maxCount"] as? Int ?? 0
                        let count = lot["count"] as? Int ?? 0
                        let available = maxCount - count
                        print("  [\(id)] \(name) (\(type)): \(count)/\(maxCount) (available=\(available))")
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
