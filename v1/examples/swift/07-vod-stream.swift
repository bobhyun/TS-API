/**
 * Example 07: VOD (Video on Demand) - Live & Playback Stream URLs
 *
 * Demonstrates:
 *   - Get live stream URLs (RTMP, FLV)
 *   - Get playback URLs for recorded video
 *   - Navigate between recording segments (next/prev)
 *   - Filter by protocol and stream quality
 *
 * NOTE: X-Host header is required. NvrClient sets it automatically.
 *
 * Response src format:
 *   src: [
 *     { protocol: "rtmp", profile: "main", src: "rtmp://...", label: "1080p", size: [1920, 1080] },
 *     { protocol: "flv", profile: "main", src: "http://.../.flv", label: "1080p", size: [1920, 1080] }
 *   ]
 */

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Find stream URL by protocol from src array
func findStream(_ src: Any?, protocol proto: String) -> String? {
    guard let arr = src as? [[String: Any]] else { return nil }
    for s in arr {
        if s["protocol"] as? String == proto {
            return s["src"] as? String
        }
    }
    return nil
}

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
    // 1. Get All Live Stream URLs
    //    Response: [{ chid, title, src: [{protocol, src, ...}] }]
    // -------------------------------------------------
    print("=== All Live Streams ===")
    let liveRes = try await client.get("/api/v1/vod")

    if liveRes.status == 200, let channels = liveRes.body as? [[String: Any]] {
        for ch in channels {
            let chid = ch["chid"] ?? ""
            let title = ch["title"] as? String ?? ""
            print("  CH\(chid): \(title)")
            if let rtmp = findStream(ch["src"], protocol: "rtmp") {
                print("    RTMP: \(rtmp)")
            }
            if let flv = findStream(ch["src"], protocol: "flv") {
                print("    FLV:  \(flv)")
            }
        }
        print("  Total: \(channels.count) streams\n")
    }

    // -------------------------------------------------
    // 2. Get Specific Channel Stream
    // -------------------------------------------------
    print("=== Channel 1 Live Stream ===")
    let ch1Res = try await client.get("/api/v1/vod?ch=1")
    if ch1Res.status == 200, let channels = ch1Res.body as? [[String: Any]], let ch = channels.first {
        let title = ch["title"] as? String ?? ""
        let rtmp = findStream(ch["src"], protocol: "rtmp") ?? "N/A"
        print("  \(title): \(rtmp)")
    }

    // -------------------------------------------------
    // 3. Filter by Protocol
    //    protocol=rtmp - RTMP only
    //    protocol=flv  - FLV only (HTTP-FLV)
    // -------------------------------------------------
    print("\n=== RTMP Only ===")
    let rtmpRes = try await client.get("/api/v1/vod?ch=1&protocol=rtmp")
    if rtmpRes.status == 200, let channels = rtmpRes.body as? [[String: Any]], let ch = channels.first {
        print("  \(findStream(ch["src"], protocol: "rtmp") ?? "N/A")")
    }

    // -------------------------------------------------
    // 4. Filter by Stream Quality
    //    stream=main - Main stream (high resolution)
    //    stream=sub  - Sub stream (low resolution, less bandwidth)
    // -------------------------------------------------
    print("\n=== Sub Stream (Low Resolution) ===")
    let subRes = try await client.get("/api/v1/vod?ch=1&stream=sub")
    if subRes.status == 200, let channels = subRes.body as? [[String: Any]], let ch = channels.first {
        let title = ch["title"] as? String ?? ""
        let rtmp = findStream(ch["src"], protocol: "rtmp") ?? "N/A"
        print("  \(title): \(rtmp)")
    }

    // -------------------------------------------------
    // 5. Playback (Recorded Video)
    //    when=<ISO 8601 datetime> to play recorded video
    // -------------------------------------------------
    print("\n=== Playback URL ===")
    let yesterday = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 24 * 60 * 60)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let when = formatter.string(from: yesterday)

    let playRes = try await client.get("/api/v1/vod?ch=1&when=\(when)")
    print("  Status: \(playRes.status)")
    if playRes.status == 200, let channels = playRes.body as? [[String: Any]], let ch = channels.first {
        let title = ch["title"] as? String ?? ""
        let rtmp = findStream(ch["src"], protocol: "rtmp") ?? "N/A"
        print("  \(title): \(rtmp)")

        // Navigate to next segment
        if let fileId = ch["fileId"] {
            print("  File ID: \(fileId)")

            let nextRes = try await client.get("/api/v1/vod?id=\(fileId)&next")
            if nextRes.status == 200, let channels = nextRes.body as? [[String: Any]], let ch = channels.first {
                let nextRtmp = findStream(ch["src"], protocol: "rtmp") ?? "N/A"
                print("  Next segment: \(nextRtmp)")
            }
        }
    }

    // -------------------------------------------------
    // 6. Multiple Channels at Once
    // -------------------------------------------------
    print("\n=== Multiple Channels ===")
    let multiRes = try await client.get("/api/v1/vod?ch=1,2,3,4")
    if multiRes.status == 200, let channels = multiRes.body as? [[String: Any]] {
        for ch in channels {
            let chid = ch["chid"] ?? ""
            let rtmp = findStream(ch["src"], protocol: "rtmp") ?? "no stream"
            print("  CH\(chid): \(rtmp)")
        }
    }
  }
}
