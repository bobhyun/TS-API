/**
 * Example 04: Recording Search
 *
 * Demonstrates:
 *   - Recording days (calendar view - which dates have recordings)
 *   - Recording minutes (timeline view - minute-by-minute recording status)
 *
 * These APIs are typically used to build:
 *   - Calendar UI: highlight dates that have recorded video
 *   - Timeline UI: show recording segments on a time bar
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
    // 1. Recording Days (Calendar)
    //    Returns which dates have recordings for given channels
    // -------------------------------------------------
    print("=== Recording Days (All Channels) ===")
    let daysRes = try await client.get("/api/v1/recording/days")
    print("  Status: \(daysRes.status)")

    if daysRes.status == 200, let body = daysRes.body as? [String: Any] {
        if let timeBegin = body["timeBegin"], let timeEnd = body["timeEnd"] {
            print("  Range: \(timeBegin) ~ \(timeEnd)")
        }
        if let data = body["data"] as? [[String: Any]] {
            for entry in data {
                let year = entry["year"] ?? ""
                let month = entry["month"] as? Int ?? 0
                let days = entry["days"] as? [Int] ?? []
                let daysStr = days.map { String($0) }.joined(separator: ", ")
                print("  \(year)-\(String(format: "%02d", month)): \(daysStr)")
            }
        }
    }

    // -------------------------------------------------
    // 2. Recording Days (Specific Channel)
    // -------------------------------------------------
    print("\n=== Recording Days (Channel 1) ===")
    let ch1Days = try await client.get("/api/v1/recording/days?ch=1")
    print("  Status: \(ch1Days.status)")

    if ch1Days.status == 200, let body = ch1Days.body as? [String: Any],
       let data = body["data"] as? [[String: Any]] {
        for chEntry in data {
            let months = chEntry["data"] as? [[String: Any]] ?? [chEntry]
            for entry in months {
                let year = entry["year"] ?? ""
                let month = entry["month"] as? Int ?? 0
                let days = entry["days"] as? [Int] ?? []
                print("  \(year)-\(String(format: "%02d", month)): [\(days.count) days]")
            }
        }
    }

    // -------------------------------------------------
    // 3. Recording Minutes (Timeline)
    //    Returns 1440-char string per channel (24h x 60min)
    //    '1' = recording exists, '0' = no recording
    // -------------------------------------------------
    print("\n=== Recording Minutes (Timeline) ===")

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateStr = formatter.string(from: Date())
    let timeBegin = "\(dateStr)T00:00:00"
    let timeEnd = "\(dateStr)T23:59:59"

    let minsRes = try await client.get("/api/v1/recording/minutes?ch=1&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)")
    print("  Status: \(minsRes.status)")
    print("  Date: \(dateStr)")

    if minsRes.status == 200, let body = minsRes.body as? [String: Any],
       let data = body["data"] as? [[String: Any]] {
        for entry in data {
            let chid = entry["chid"] ?? ""
            let minutes = entry["minutes"] as? String ?? ""
            let recordedMinutes = minutes.filter { $0 == "1" }.count
            let totalMinutes = minutes.count

            print("  CH\(chid): \(recordedMinutes)/\(totalMinutes) minutes recorded")

            // Show hourly summary
            if minutes.count == 1440 {
                var hourly: [Character] = []
                for h in 0..<24 {
                    let start = minutes.index(minutes.startIndex, offsetBy: h * 60)
                    let end = minutes.index(start, offsetBy: 60)
                    let hourSlice = String(minutes[start..<end])
                    let recMins = hourSlice.filter { $0 == "1" }.count
                    hourly.append(recMins > 0 ? "#" : ".")
                }
                print("    Timeline: [\(String(hourly))]")
                print("              0         1         2   ")
                print("              0123456789012345678901234")
                print("              (#=recorded, .=empty)")
            }
        }
    }
  }
}
