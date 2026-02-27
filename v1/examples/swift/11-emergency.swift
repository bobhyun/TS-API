/**
 * Example 11: Emergency Call Device List
 *
 * Endpoint:
 *   GET /api/v1/emergency  - Emergency call device list
 *
 * Response: [{ id, code, name, linkedChannel }, ...]
 * Note: Requires Emergency Call license. Returns 404 if not supported.
 *
 * Build: swiftc -o 11-emergency NvrClient.swift 11-emergency.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./11-emergency
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
    // Emergency Call Device List
    // -------------------------------------------------
    print("=== Emergency Call Devices ===")
    let res = try await client.get("/api/v1/emergency")

    if res.status == 200, let devices = res.body as? [[String: Any]] {
        print("  Total: \(devices.count) device(s)")
        for dev in devices {
            let id = dev["id"] as? Int ?? 0
            let code = dev["code"] as? String ?? ""
            let name = dev["name"] as? String ?? ""
            let channels = (dev["linkedChannel"] as? [Int])?.map(String.init).joined(separator: ", ") ?? ""
            print("  id=\(id)  code=\(code)  name=\(name)  linkedChannel=[\(channels)]")
        }
    } else if res.status == 404 {
        print("  Emergency Call not enabled on this server (license required)")
    } else {
        print("  Unexpected status: \(res.status)")
    }
  }
}
