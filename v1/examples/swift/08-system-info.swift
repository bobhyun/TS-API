/**
 * Example 08: System & Server Information
 *
 * Demonstrates:
 *   - Server info (API version, product, license, timezone)
 *   - System info (OS, CPU, disk, network)
 *   - System health (CPU usage, memory, disk usage)
 *   - HDD S.M.A.R.T status
 *
 * NOTE: System info 'storage' parameter returns response field named 'disk'.
 */

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func formatBytes(_ bytes: Double) -> String {
    guard bytes > 0 else { return "0 B" }
    let units = ["B", "KB", "MB", "GB", "TB"]
    var val = bytes
    var i = 0
    while val >= 1024 && i < units.count - 1 {
        val /= 1024
        i += 1
    }
    return String(format: "%.1f %@", val, units[i])
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
    // 1. Server Info (all at once)
    // -------------------------------------------------
    print("=== Server Info ===")
    let infoRes = try await client.get("/api/v1/info?all")

    if infoRes.status == 200, let info = infoRes.body as? [String: Any] {
        let apiVersion = info["apiVersion"] ?? "N/A"
        let siteName = info["siteName"] ?? "N/A"
        print("  API Version: \(apiVersion)")
        print("  Site Name:   \(siteName)")

        if let product = info["product"] as? [String: Any] {
            let name = product["name"] ?? "N/A"
            let version = product["version"] ?? "N/A"
            print("  Product:     \(name) v\(version)")
        }
        if let tz = info["timezone"] as? [String: Any] {
            let name = tz["name"] ?? "N/A"
            let bias = tz["bias"] ?? "N/A"
            print("  Timezone:    \(name) (\(bias))")
        }
        if let license = info["license"] as? [String: Any] {
            let type = license["type"] ?? "N/A"
            let maxCh = license["maxChannels"] ?? "N/A"
            print("  License:     \(type) (max \(maxCh) channels)")
        }
        if let whoAmI = info["whoAmI"] as? [String: Any] {
            let uid = whoAmI["uid"] ?? "N/A"
            let name = whoAmI["name"] ?? "N/A"
            print("  User:        \(uid) (\(name))")
        }
    }

    // -------------------------------------------------
    // 2. System Info (individual items)
    //    Available items: os, cpu, storage, network
    //    NOTE: 'storage' request returns 'disk' field in response
    // -------------------------------------------------
    print("\n=== System Info ===")

    // OS info
    let osRes = try await client.get("/api/v1/system/info?item=os")
    if osRes.status == 200, let body = osRes.body as? [String: Any] {
        let osInfo = body["os"] ?? body
        print("  OS: \(client.toJsonString(osInfo as Any))")
    }

    // CPU info
    let cpuRes = try await client.get("/api/v1/system/info?item=cpu")
    if cpuRes.status == 200, let body = cpuRes.body as? [String: Any] {
        let cpuInfo = body["cpu"] ?? body
        print("  CPU: \(client.toJsonString(cpuInfo as Any))")
    }

    // Storage info (response field is 'disk', not 'storage')
    let storageRes = try await client.get("/api/v1/system/info?item=storage")
    if storageRes.status == 200, let body = storageRes.body as? [String: Any] {
        let disks = body["disk"] ?? body["storage"] ?? body
        print("  Disk: \(client.toJsonString(disks as Any))")
    }

    // Network info (includes lastUpdate field)
    let netRes = try await client.get("/api/v1/system/info?item=network")
    if netRes.status == 200, let body = netRes.body as? [String: Any] {
        let netInfo = body["network"] ?? body
        print("  Network: \(client.toJsonString(netInfo as Any))")
        if let lastUpdate = body["lastUpdate"] {
            print("  Last Update: \(lastUpdate)")
        }
    }

    // Multiple items at once
    print("\n--- Multiple items ---")
    let multiRes = try await client.get("/api/v1/system/info?item=os,cpu")
    if multiRes.status == 200, let body = multiRes.body {
        print("  \(client.toJsonString(body, pretty: true))")
    }

    // -------------------------------------------------
    // 3. System Health (real-time usage)
    //    Available items: cpu, memory, disk
    // -------------------------------------------------
    print("\n=== System Health ===")
    let healthRes = try await client.get("/api/v1/system/health")

    if healthRes.status == 200, let h = healthRes.body as? [String: Any] {
        if let cpuArr = h["cpu"] as? [[String: Any]] {
            for c in cpuArr {
                if let usage = c["usage"] as? [String: Any], let total = usage["total"] {
                    print("  CPU Usage: \(total)%")
                }
            }
        }
        if let memory = h["memory"] as? [String: Any] {
            let total = memory["totalPhysical"] as? Double ?? 0
            let free = memory["freePhysical"] as? Double ?? 0
            let used = total - free
            let pct = total > 0 ? String(format: "%.1f", (used / total) * 100) : "N/A"
            print("  Memory: \(pct)% (\(formatBytes(used)) / \(formatBytes(total)))")
        }
        if let diskArr = h["disk"] as? [[String: Any]] {
            for d in diskArr {
                let total = d["totalSpace"] as? Double ?? 0
                let free = d["freeSpace"] as? Double ?? 0
                let used = total - free
                let pct = total > 0 ? String(format: "%.1f", (used / total) * 100) : "N/A"
                let mount = d["mount"] as? String ?? ""
                print("  Disk \(mount): \(pct)% (\(formatBytes(used)) / \(formatBytes(total)))")
            }
        }
    }

    // -------------------------------------------------
    // 4. HDD S.M.A.R.T Status
    // -------------------------------------------------
    print("\n=== HDD S.M.A.R.T ===")
    let smartRes = try await client.get("/api/v1/system/hddsmart")
    print("  Status: \(smartRes.status)")

    if smartRes.status == 200, let body = smartRes.body {
        if let disks = body as? [[String: Any]] {
            for disk in disks {
                let model = disk["model"] as? String ?? disk["name"] as? String ?? "Disk"
                let health = disk["health"] as? String ?? disk["status"] as? String ?? "N/A"
                print("  \(model): \(health)")
            }
        } else {
            print("  \(client.toJsonString(body, pretty: true))")
        }
    }
  }
}
