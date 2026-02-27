/**
 * Example 06: LPR (License Plate Recognition) Search
 *
 * Demonstrates:
 *   - LPR source list
 *   - License plate log search (keyword, time range, pagination)
 *   - Similar plate search
 *   - CSV export
 *
 * NOTE: timeBegin and timeEnd are required for LPR log searches.
 *
 * WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
 *   errors. For bulk exports, narrow the time range or use pagination
 *   (at/maxCount) to keep each request under a manageable size.
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
    // 1. LPR Source List
    //    Each source represents a recognition point (entrance, exit, etc.)
    // -------------------------------------------------
    print("=== LPR Sources ===")
    let srcRes = try await client.get("/api/v1/lpr/source")

    if srcRes.status == 200, let sources = srcRes.body as? [[String: Any]] {
        for src in sources {
            let id = src["id"] ?? ""
            let code = src["code"] as? String ?? ""
            let name = src["name"] as? String ?? ""
            let linked = src["linkedChannel"] as? [Int] ?? []
            let linkedStr = linked.map { String($0) }.joined(separator: ",")
            print("  [\(id)] \(code) - \(name) (cameras: \(linkedStr.isEmpty ? "none" : linkedStr))")
        }
        print("  Total: \(sources.count) sources\n")
    } else {
        print("  Status: \(srcRes.status)\n")
    }

    // -------------------------------------------------
    // 2. Recent LPR Logs
    // -------------------------------------------------
    print("=== Recent LPR Logs ===")

    // Search last 7 days
    let endDate = Date()
    let startDate = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 - 7 * 24 * 60 * 60)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let timeBegin = formatter.string(from: startDate)
    let timeEnd = formatter.string(from: endDate)

    let logRes = try await client.get("/api/v1/lpr/log?timeBegin=\(timeBegin)&timeEnd=\(timeEnd)&maxCount=10")

    if logRes.status == 200, let body = logRes.body as? [String: Any] {
        print("  Total: \(body["totalCount"] ?? "N/A")")

        if let data = body["data"] as? [[String: Any]] {
            for entry in data {
                let timeRange = entry["timeRange"] as? [String] ?? []
                let time = timeRange.first ?? ""
                let plateNo = entry["plateNo"] as? String ?? ""
                let score = entry["score"] ?? "N/A"
                let srcName = entry["srcName"] as? String ?? entry["srcCode"] as? String ?? ""
                print("  \(time) | \(plateNo) (score: \(score)) [\(srcName)]")

                // VOD links for playback
                if let vod = entry["vod"] as? [[String: Any]], let first = vod.first {
                    let videoSrc = first["videoSrc"] as? String ?? ""
                    print("    VOD: \(videoSrc)")
                }
            }
        }
    } else {
        print("  Status: \(logRes.status)")
    }

    // -------------------------------------------------
    // 3. Search by Keyword (partial plate match)
    // -------------------------------------------------
    print("\n=== Search by Keyword ===")
    let keyword = "1234"
    let searchRes = try await client.get(
        "/api/v1/lpr/log?keyword=\(keyword)&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)&maxCount=5"
    )

    if searchRes.status == 200, let body = searchRes.body as? [String: Any] {
        print("  Keyword: \"\(keyword)\", Found: \(body["totalCount"] ?? "N/A")")

        if let data = body["data"] as? [[String: Any]] {
            for entry in data {
                let plateNo = entry["plateNo"] as? String ?? ""
                let score = entry["score"] ?? "N/A"
                print("    \(plateNo) (score: \(score))")
            }
        }
    }

    // -------------------------------------------------
    // 4. Similar Plate Search
    //    Finds plates similar to the keyword (edit distance based)
    //    Useful for partial or misrecognized plates
    // -------------------------------------------------
    print("\n=== Similar Plate Search ===")
    let similarRes = try await client.get(
        "/api/v1/lpr/similar?keyword=\(keyword)&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)"
    )

    if similarRes.status == 200, let body = similarRes.body {
        let dict = body as? [String: Any]
        let totalCount = dict?["totalCount"] ?? "N/A"
        print("  Similar to \"\(keyword)\": \(totalCount) results")

        let data: [[String: Any]]
        if let d = dict?["data"] as? [[String: Any]] {
            data = d
        } else if let d = body as? [[String: Any]] {
            data = d
        } else {
            data = []
        }
        for entry in data.prefix(5) {
            let plateNo = entry["plateNo"] as? String ?? ""
            print("    \(plateNo)")
        }
    }

    // -------------------------------------------------
    // 5. CSV Export
    //    Returns LPR data in CSV format for spreadsheet import
    // -------------------------------------------------
    print("\n=== CSV Export ===")
    let exportRes = try await client.get(
        "/api/v1/lpr/log?export=true&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)&maxCount=5"
    )
    print("  Status: \(exportRes.status)")
    if !exportRes.rawBody.isEmpty {
        let lines = exportRes.rawBody.components(separatedBy: "\n").prefix(3)
        for line in lines {
            print("    \(line)")
        }
        print("    ...")
    }
  }
}
