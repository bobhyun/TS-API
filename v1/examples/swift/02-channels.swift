/**
 * Example 02: Channel Management
 *
 * Demonstrates:
 *   - List channels (basic info, static source, capabilities)
 *   - Channel status (connection state, recording status)
 *   - Channel detailed info
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
    // 1. List Channels (basic info)
    // -------------------------------------------------
    print("=== Channel List ===")
    let channelRes = try await client.get("/api/v1/channel")

    if channelRes.status == 200, let channels = channelRes.body as? [[String: Any]] {
        for ch in channels {
            let chid = ch["chid"] ?? ""
            let title = ch["title"] as? String ?? ""
            let displayName = ch["displayName"] as? String ?? ""
            print("  CH\(chid): \(title) (\(displayName))")
        }
        print("Total: \(channels.count) channels\n")
    }

    // -------------------------------------------------
    // 2. List Channels with static source URLs
    // -------------------------------------------------
    print("=== Channel List with Sources ===")
    let srcRes = try await client.get("/api/v1/channel?staticSrc")

    if srcRes.status == 200, let channels = srcRes.body as? [[String: Any]] {
        for ch in channels {
            let chid = ch["chid"] ?? ""
            let title = ch["title"] as? String ?? ""
            print("  CH\(chid): \(title)")
            if let src = ch["src"] {
                print("    Source: \(client.toJsonString(src))")
            }
        }
        print("")
    }

    // -------------------------------------------------
    // 3. List Channels with capabilities
    // -------------------------------------------------
    print("=== Channel Capabilities ===")
    let capsRes = try await client.get("/api/v1/channel?caps")

    if capsRes.status == 200, let channels = capsRes.body as? [[String: Any]] {
        for ch in channels {
            let chid = ch["chid"] ?? ""
            let title = ch["title"] as? String ?? ""
            var features: [String] = []
            if let caps = ch["caps"] as? [String: Any] {
                if caps["pantilt"] as? Bool == true { features.append("Pan/Tilt") }
                if caps["zoom"] as? Bool == true { features.append("Zoom") }
                if caps["relay"] as? Bool == true { features.append("Relay") }
            }
            let featureStr = features.isEmpty ? "No PTZ" : features.joined(separator: ", ")
            print("  CH\(chid): \(title) [\(featureStr)]")
        }
        print("")
    }

    // -------------------------------------------------
    // 4. Channel Status
    // -------------------------------------------------
    print("=== Channel Status ===")
    let statusRes = try await client.get("/api/v1/channel/status?recordingStatus")

    if statusRes.status == 200, let channels = statusRes.body as? [[String: Any]] {
        // Status codes: 0=Connected, -1=Disconnected, -2=Connecting, -3=Auth Failed
        let statusMap: [Int: String] = [0: "Connected", -1: "Disconnected", -2: "Connecting", -3: "Auth Failed"]

        for ch in channels {
            let chid = ch["chid"] ?? ""
            var statusText = "Unknown"
            if let status = ch["status"] as? [String: Any], let code = status["code"] as? Int {
                statusText = statusMap[code] ?? "Unknown(\(code))"
            }
            let recording = ch["recording"] as? Bool ?? false
            let recText = recording ? " [REC]" : ""
            print("  CH\(chid): \(statusText)\(recText)")
        }
        print("")
    }

    // -------------------------------------------------
    // 5. Specific Channel Info
    // -------------------------------------------------
    print("=== Channel 1 Detailed Info ===")
    let infoRes = try await client.get("/api/v1/channel/1/info?caps")
    print("  Status: \(infoRes.status)")
    if infoRes.status == 200, let body = infoRes.body {
        print("  Data: \(client.toJsonString(body, pretty: true))")
    }
  }
}
