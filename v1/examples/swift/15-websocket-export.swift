/**
 * Example 15: WebSocket - Recording Data Export
 *
 * Demonstrates recording data backup/export via WebSocket.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
 *
 * Auth:
 *   Header: X-API-Key: {apiKey}                  (primary)
 *   Header: Authorization: Bearer {accessToken}   (alternative)
 *   Query:  ?apikey={apiKey}                      (browser fallback)
 *   Query:  ?token={accessToken}                  (browser fallback)
 *
 * Flow:
 *   Client --connect--> Server
 *   Client <--ready---- Server   { stage:"ready", task:{id}, channel:{...} }
 *   Client <--fileEnd-- Server   { stage:"fileEnd", channel:{file:{download}} }
 *   Client --{cmd:"next"}--> Server
 *   Client <--end------ Server   { stage:"end" }
 *   (on error) Client <--error-- Server   { stage:"error", message }
 *   (to cancel) Client --{cmd:"cancel"}--> Server
 *
 * Build: swiftc -o 15-websocket-export NvrClient.swift 15-websocket-export.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./15-websocket-export
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

    // Time range: yesterday 00:00 ~ 00:10
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateStr = formatter.string(from: yesterday)
    let timeBegin = "\(dateStr)T00:00:00"
    let timeEnd = "\(dateStr)T00:10:00"

    print("=== WebSocket Recording Export ===")
    print("  Channel: 1,  \(timeBegin) ~ \(timeEnd)")

    let wsTask = client.websocket(
        path: "/wsapi/v1/export?ch=1&timeBegin=\(timeBegin)&timeEnd=\(timeEnd)"
    )

    wsTask.resume()
    print("  Connected")

    var taskId: String? = nil
    var done = false

    // Timeout after 60 seconds
    let deadline = Date().addingTimeInterval(60.0)

    while !done && Date() < deadline {
        do {
            let message = try await withThrowingTaskGroup(of: URLSessionWebSocketTask.Message?.self) { group in
                group.addTask {
                    try await wsTask.receive()
                }
                group.addTask {
                    let remaining = deadline.timeIntervalSinceNow
                    if remaining > 0 {
                        try await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                    }
                    return nil
                }

                let result = try await group.next()
                group.cancelAll()
                return result ?? nil
            }

            guard let message = message else { break }

            switch message {
            case .string(let text):
                guard let data = text.data(using: .utf8),
                      let msg = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let stage = msg["stage"] as? String else {
                    print("  Raw: \(text)")
                    continue
                }

                switch stage {
                case "ready":
                    // Check error status
                    if let status = msg["status"] as? [String: Any],
                       let code = status["code"] as? Int, code != 0 {
                        let message = status["message"] as? String ?? text
                        print("  Ready - Error: \(message)")
                        done = true
                        break
                    }
                    if let task = msg["task"] as? [String: Any] {
                        taskId = task["id"] as? String
                    }
                    print("  Ready - Task ID: \(taskId ?? "N/A")")

                case "fileEnd":
                    let channel = msg["channel"] as? [String: Any]
                    let file = channel?["file"] as? [String: Any]
                    let downloads = file?["download"] as? [[String: Any]]
                    let src = downloads?.first?["src"] as? String ?? "N/A"
                    print("  File ready: \(src)")
                    // Request next file
                    if let tid = taskId {
                        let cmd = try JSONSerialization.data(withJSONObject: ["task": tid, "cmd": "next"])
                        try await wsTask.send(.string(String(data: cmd, encoding: .utf8)!))
                    }

                case "end":
                    print("  Export complete!")
                    done = true

                case "error":
                    let errMsg = msg["message"] as? String ?? text
                    print("  Error: \(errMsg)")
                    done = true

                default:
                    print("  [\(stage)] \(text)")
                }

            case .data(let data):
                print("  Binary: \(data.count) bytes")

            @unknown default:
                break
            }
        } catch {
            break
        }
    }

    if !done {
        print("  Timeout - cancelling...")
        if let tid = taskId {
            let cmd = try JSONSerialization.data(withJSONObject: ["task": tid, "cmd": "cancel"])
            try await wsTask.send(.string(String(data: cmd, encoding: .utf8)!))
        }
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    wsTask.cancel(with: .normalClosure, reason: nil)
    try await Task.sleep(nanoseconds: 500_000_000)
  }
}
