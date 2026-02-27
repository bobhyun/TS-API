/**
 * Example 05: Event Log Search
 *
 * Demonstrates:
 *   - Event type enumeration
 *   - Event log search with filters (time, type, channel)
 *   - Pagination (at, maxCount)
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
    // 1. List Event Types
    //    Each type has id, name, and an array of sub-codes
    // -------------------------------------------------
    print("=== Event Types ===")
    let typeRes = try await client.get("/api/v1/event/type")

    if typeRes.status == 200, let types = typeRes.body as? [[String: Any]] {
        for eventType in types {
            let id = eventType["id"] ?? ""
            let name = eventType["name"] as? String ?? ""
            let codes = eventType["code"] as? [[String: Any]] ?? []
            print("  [\(id)] \(name) (\(codes.count) codes)")

            for code in codes.prefix(3) {
                let codeId = code["id"] ?? ""
                let codeName = code["name"] as? String ?? ""
                print("    - [\(codeId)] \(codeName)")
            }
            if codes.count > 3 {
                print("    ... and \(codes.count - 3) more")
            }
        }
    }

    // -------------------------------------------------
    // 2. List Event Types in English
    // -------------------------------------------------
    print("\n=== Event Types (English) ===")
    let typeEnRes = try await client.get("/api/v1/event/type?lang=en-US")

    if typeEnRes.status == 200, let types = typeEnRes.body as? [[String: Any]] {
        for eventType in types {
            let id = eventType["id"] ?? ""
            let name = eventType["name"] as? String ?? ""
            print("  [\(id)] \(name)")
        }
    }

    // -------------------------------------------------
    // 3. Search Recent Events
    // -------------------------------------------------
    print("\n=== Recent Events (latest 10) ===")
    let logRes = try await client.get("/api/v1/event/log?maxCount=10&sort=desc")

    if logRes.status == 200, let body = logRes.body as? [String: Any] {
        let totalCount = body["totalCount"] ?? "N/A"
        let at = body["at"] ?? "N/A"
        print("  Total: \(totalCount), Showing from: \(at)")

        if let data = body["data"] as? [[String: Any]] {
            for event in data {
                let timeRange = event["timeRange"] as? [String] ?? []
                let time = timeRange.first ?? ""
                let typeName = event["typeName"] as? String ?? ""
                let codeName = event["codeName"] as? String ?? ""
                let chid = event["chid"] ?? ""
                print("  \(time) | [\(typeName)] \(codeName) (CH\(chid))")
            }
        }
    }

    // -------------------------------------------------
    // 4. Search Events with Time Range
    // -------------------------------------------------
    print("\n=== Events from Today ===")
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.string(from: Date())
    let todayRes = try await client.get("/api/v1/event/log?timeBegin=\(today)T00:00:00&timeEnd=\(today)T23:59:59&maxCount=5")

    if todayRes.status == 200, let body = todayRes.body as? [String: Any] {
        print("  Total today: \(body["totalCount"] ?? "N/A")")

        if let data = body["data"] as? [[String: Any]] {
            for event in data {
                let timeRange = event["timeRange"] as? [String] ?? []
                let time = timeRange.first ?? ""
                let typeName = event["typeName"] as? String ?? ""
                let codeName = event["codeName"] as? String ?? ""
                print("  \(time) | [\(typeName)] \(codeName)")
            }
        }
    }

    // -------------------------------------------------
    // 5. Pagination Example
    //    at=0 (start index), maxCount=5 (page size)
    // -------------------------------------------------
    print("\n=== Pagination ===")
    let page1 = try await client.get("/api/v1/event/log?at=0&maxCount=5")
    if let body1 = page1.body as? [String: Any], let data1 = body1["data"] as? [[String: Any]] {
        print("  Page 1 (at=0): \(data1.count) items")
    }

    let page2 = try await client.get("/api/v1/event/log?at=5&maxCount=5")
    if let body2 = page2.body as? [String: Any], let data2 = body2["data"] as? [[String: Any]] {
        print("  Page 2 (at=5): \(data2.count) items")
    }

    // -------------------------------------------------
    // 6. Filter by Channel
    // -------------------------------------------------
    print("\n=== Events for Channel 1 ===")
    let ch1Res = try await client.get("/api/v1/event/log?ch=1&maxCount=5")

    if ch1Res.status == 200, let body = ch1Res.body as? [String: Any] {
        print("  Total for CH1: \(body["totalCount"] ?? "N/A")")
    }
  }
}
