/**
 * Example 03: PTZ Camera Control
 *
 * Demonstrates:
 *   - Home position
 *   - Pan/Tilt movement (move=x,y, range: -1.0 ~ 1.0)
 *   - Zoom control (zoom=z, range: -1.0 ~ 1.0)
 *   - Focus/Iris control
 *   - Stop movement
 *   - Preset management (list, go to)
 *
 * NOTE: PTZ commands are sent via ONVIF to the camera.
 *       Returns 500 if the camera doesn't support ONVIF or is unreachable.
 */

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let CHANNEL = 1

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
    // 1. Move to Home Position
    // -------------------------------------------------
    print("=== Home Position ===")
    let homeRes = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?home")
    print("  Status: \(homeRes.status)")
    await sleep(ms: 1000)

    // -------------------------------------------------
    // 2. Pan/Tilt Movement
    //    move=x,y where x=pan(-1~1), y=tilt(-1~1)
    //    Positive x = right, Positive y = up
    // -------------------------------------------------
    print("\n=== Pan/Tilt ===")

    // Move right and up
    var res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?move=0.3,0.3")
    print("  Move right+up (0.3, 0.3): \(res.status)")
    await sleep(ms: 500)

    // Stop
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?stop")
    print("  Stop: \(res.status)")
    await sleep(ms: 500)

    // Move left and down
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?move=-0.3,-0.3")
    print("  Move left+down (-0.3, -0.3): \(res.status)")
    await sleep(ms: 500)

    // Stop
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?stop")
    print("  Stop: \(res.status)")

    // -------------------------------------------------
    // 3. Zoom Control
    //    zoom > 0 = zoom in, zoom < 0 = zoom out
    // -------------------------------------------------
    print("\n=== Zoom ===")

    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?zoom=0.5")
    print("  Zoom in (0.5): \(res.status)")
    await sleep(ms: 1000)

    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?stop")
    print("  Stop: \(res.status)")
    await sleep(ms: 500)

    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?zoom=-0.5")
    print("  Zoom out (-0.5): \(res.status)")
    await sleep(ms: 1000)

    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?stop")
    print("  Stop: \(res.status)")

    // -------------------------------------------------
    // 4. Focus & Iris Control
    // -------------------------------------------------
    print("\n=== Focus & Iris ===")

    // Focus: -1.0=near, 1.0=far
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?focus=0.3")
    print("  Focus far (0.3): \(res.status)")

    // Iris: -1.0=close, 1.0=open
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?iris=0.3")
    print("  Iris open (0.3): \(res.status)")

    // -------------------------------------------------
    // 5. Preset List & Go
    // -------------------------------------------------
    print("\n=== Presets ===")

    let listRes = try await client.get("/api/v1/channel/\(CHANNEL)/preset")
    print("  List presets: \(listRes.status)")
    if listRes.status == 200, let presets = listRes.body as? [[String: Any]] {
        for preset in presets {
            let token = preset["token"] ?? ""
            let name = preset["name"] as? String ?? ""
            print("    - Token: \(token), Name: \(name)")
        }

        // Go to first preset if exists
        if let first = presets.first, let token = first["token"] {
            let name = first["name"] as? String ?? ""
            let goRes = try await client.get("/api/v1/channel/\(CHANNEL)/preset/\(token)/go")
            print("  Go to preset '\(name)': \(goRes.status)")
        }
    }

    // Return to home
    print("\n=== Return Home ===")
    res = try await client.get("/api/v1/channel/\(CHANNEL)/ptz?home")
    print("  Status: \(res.status)")
  }
}
