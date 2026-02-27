/**
 * Example 09: Push Notification - External Event Input
 *
 * Demonstrates:
 *   - LPR push (external plate recognition data)
 *   - Emergency call push (alarm start/stop)
 *
 * REQUIRES: Push license enabled on the server.
 *           Returns 404 if not enabled.
 *
 * WARNING: Emergency call 'callStart' triggers actual alarm hardware!
 *          Always send 'callEnd' to stop the alarm.
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
    // 1. LPR Push
    //    External LPR camera sends recognized plate number
    // -------------------------------------------------
    print("=== LPR Push ===")

    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())

    let lprRes = try await client.post("/api/v1/push", body: [
        "topic": "LPR",
        "src": "1",                     // LPR source ID
        "plateNo": "12\u{AC00}3456",    // Recognized plate number
        "when": now,                     // Recognition time
    ])
    print("  Status: \(lprRes.status)")
    if lprRes.status == 404 {
        print("  Push API not enabled (license required)")
    }

    // -------------------------------------------------
    // 2. Emergency Call Push
    //    Sends alarm start/stop events from emergency call device
    //
    //    IMPORTANT:
    //    - callStart triggers actual alarm bell
    //    - Always send callEnd to stop the alarm
    //    - camera field links to NVR channels for popup
    // -------------------------------------------------
    print("\n=== Emergency Call Push ===")

    // Start emergency alarm
    print("  Sending callStart...")
    let startRes = try await client.post("/api/v1/push", body: [
        "topic": "emergencyCall",
        "device": "intercom-01",       // Device identifier
        "src": "1",                     // Source ID
        "event": "callStart",           // Start alarm
        "camera": "1,2",               // Linked camera channels
        "when": isoFormatter.string(from: Date()),
    ])
    print("  callStart status: \(startRes.status)")

    // ALWAYS stop the alarm!
    print("  Sending callEnd...")
    let endRes = try await client.post("/api/v1/push", body: [
        "topic": "emergencyCall",
        "device": "intercom-01",
        "src": "1",
        "event": "callEnd",             // Stop alarm
        "camera": "1,2",
        "when": isoFormatter.string(from: Date()),
    ])
    print("  callEnd status: \(endRes.status)")
  }
}
