/**
 * Example 06: LPR (License Plate Recognition) Search
 *
 * Demonstrates:
 *   - LPR source list
 *   - License plate log search (keyword, time range, pagination)
 *   - Similar plate search
 *   - Plate correction history (GET /api/v1/lpr/log/{id}/plate/history)
 *   - Plate correction (POST /api/v1/lpr/log/{id}/plate, Control permission, not executed)
 *   - CSV export
 *
 * NOTE: timeBegin and timeEnd are required for LPR log searches.
 *
 * WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
 *   Narrow the time range or page with at/maxCount.
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
    var firstRecordId: Int? = nil

    if logRes.status == 200, let body = logRes.body as? [String: Any] {
        print("  Total: \(body["totalCount"] ?? "N/A")")

        if let data = body["data"] as? [[String: Any]] {
            firstRecordId = data.first?["id"] as? Int
            for entry in data {
                let id = entry["id"] ?? "-"
                let timeRange = entry["timeRange"] as? [String] ?? []
                let time = timeRange.first ?? ""
                // plateNo is null when no plate was read; direction is "entry"/"exit" or absent
                let plateNo = (entry["plateNo"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "(unrecognized)"
                let direction = entry["direction"] as? String ?? "-"
                let score = entry["score"] ?? "N/A"
                let srcName = entry["srcName"] as? String ?? entry["srcCode"] as? String ?? ""
                var line = "  [\(id)] \(time) | \(plateNo) (score: \(score)) [\(srcName)] direction=\(direction)"
                if entry["plateEdited"] as? Bool == true {
                    let original = entry["originalPlateNo"] as? String ?? ""
                    line += " (corrected, originally \(original.isEmpty ? "(unrecognized)" : original))"
                }
                print(line)

                // VOD links for playback
                // v1 returns relative paths (e.g. "/watch?ch=1&when=..."); prepend baseURL for non-browser clients.
                if let vod = entry["vod"] as? [[String: Any]], let first = vod.first {
                    let videoSrc = first["videoSrc"] as? String ?? ""
                    let fullUrl = videoSrc.hasPrefix("http") ? videoSrc : "\(client.baseURL)\(videoSrc)"
                    print("    VOD: \(fullUrl)")
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
    //    Returns every plate containing the keyword, most recent first
    //    Useful for partial or misrecognized plates
    // -------------------------------------------------
    print("\n=== Similar Plate Search ===")
    let similarRes = try await client.get(
        "/api/v1/lpr/similar?keyword=\(keyword)&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)"
    )

    // Response: array of plate strings, most recent first
    if similarRes.status == 200, let plates = similarRes.body as? [String] {
        print("  Similar to \"\(keyword)\": \(plates.count) results")
        for plateNo in plates.prefix(5) {
            print("    \(plateNo)")
        }
    } else {
        print("  Status: \(similarRes.status)")
    }

    // -------------------------------------------------
    // 5. Plate Correction History (one record, by id)
    //    plateNo in the log is always the current value.
    //    edits[] lists corrections in recorded order; it is empty if the record was never corrected.
    // -------------------------------------------------
    if let recId = firstRecordId {
        print("\n=== Plate Correction History (id=\(recId)) ===")
        let histRes = try await client.get("/api/v1/lpr/log/\(recId)/plate/history")
        if histRes.status == 200, let h = histRes.body as? [String: Any] {
            let original = h["originalPlateNo"] as? String ?? "(never corrected)"
            print("  plateNo=\(h["plateNo"] ?? "") original=\(original)")
            for e in h["edits"] as? [[String: Any]] ?? [] {
                print("    \(e["time"] ?? "") \(e["user"] ?? ""): \(e["before"] ?? "") -> \(e["after"] ?? "") \(e["reason"] ?? "")")
            }
        } else {
            print("  Status: \(histRes.status)")
        }
    }

    // -------------------------------------------------
    // 6. Plate Correction (Control permission)
    //    Changes the stored record, so it is not executed here. The target is always
    //    one record id - from data[].id above, or the id a realtime LPR event carries
    //    next to each plateNo. 409 when plateNo equals the current plate.
    //
    //    Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
    //    Uncomment it to try it against a test record.
    //    _ = try await client.post("/api/v1/lpr/log/\(recId)/plate",
    //                              body: ["plateNo": "12가3456", "reason": "misread at night"])
    // -------------------------------------------------

    // -------------------------------------------------
    // 7. CSV Export
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
