/**
 * Example 12: WebSocket - Real-time Event Subscription
 *
 * Demonstrates subscribing to real-time events via WebSocket.
 * Topics: LPR, channelStatus, emergencyCall, object, recording
 *
 * Two subscription modes:
 *   1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
 *   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events
 *
 * Auth:
 *   Header: X-API-Key: {apiKey}                  (primary)
 *   Header: Authorization: Bearer {accessToken}   (alternative)
 *   Query:  ?apikey={apiKey}                      (browser fallback)
 *   Query:  ?token={accessToken}                  (browser fallback)
 *
 * Build: swiftc -o 12-websocket-events NvrClient.swift 12-websocket-events.swift
 * Run:   NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... ./12-websocket-events
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
    // Method 1: Subscribe via URL query params (classic)
    // -------------------------------------------------
    print("=== Method 1: Subscribe via URL (10 seconds) ===")

    let wsTask1 = client.websocket(
        path: "/wsapi/v1/events?topics=LPR,channelStatus"
    )

    wsTask1.resume()
    print("  Connected!")

    var messageCount1 = 0
    let deadline1 = Date().addingTimeInterval(10.0)
    var wsError1: Error? = nil

    while Date() < deadline1 {
        do {
            let message = try await withThrowingTaskGroup(of: URLSessionWebSocketTask.Message?.self) { group in
                group.addTask {
                    try await wsTask1.receive()
                }
                group.addTask {
                    let remaining = deadline1.timeIntervalSinceNow
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
                messageCount1 += 1
                if let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let topic = json["topic"] ?? json["type"] ?? "?"
                    print("  [\(topic)] \(text)")
                } else {
                    print("  Raw: \(text)")
                }
            case .data(let data):
                messageCount1 += 1
                print("  Binary: \(data.count) bytes")
            @unknown default:
                break
            }
        } catch {
            wsError1 = error
            break
        }
    }

    if let err = wsError1 {
        let desc = "\(err)"
        if desc.contains("SEC_E_") || desc.contains("certificate") || desc.contains("SSL") {
            print("  WebSocket SSL error (self-signed cert not supported on this platform)")
            print("  Use NVR_SCHEME=http for WebSocket examples on Windows")
        } else {
            print("  WebSocket error: \(err)")
        }
    }
    print("  Received \(messageCount1) events")
    wsTask1.cancel(with: .normalClosure, reason: nil)
    try await Task.sleep(nanoseconds: 500_000_000)

    // -------------------------------------------------
    // Method 2: Dynamic subscribe/unsubscribe via send() (v1 only)
    //   - Connect WITHOUT topics
    //   - Subscribe/unsubscribe at any time
    //   - Per-topic filters (ch, objectTypes, lot, spot)
    //   - Re-subscribe to update filters
    // -------------------------------------------------
    print("\n=== Method 2: Dynamic Subscribe (10 seconds) ===")

    let wsTask2 = client.websocket(
        path: "/wsapi/v1/events"
    )

    wsTask2.resume()
    print("  Connected (no topics yet)")

    // Dynamically subscribe to topics with per-topic filters
    do {
        try await wsTask2.send(.string("{\"subscribe\":\"channelStatus\"}"))
        try await wsTask2.send(.string("{\"subscribe\":\"LPR\",\"ch\":[1,2]}"))
        try await wsTask2.send(.string("{\"subscribe\":\"object\",\"objectTypes\":[\"human\",\"vehicle\"]}"))
    } catch {
        let desc = "\(error)"
        if desc.contains("SEC_E_") || desc.contains("certificate") || desc.contains("SSL") {
            print("  WebSocket SSL error (self-signed cert not supported on this platform)")
            print("  Use NVR_SCHEME=http for WebSocket examples on Windows")
        } else {
            print("  WebSocket send error: \(error)")
        }
        wsTask2.cancel(with: .normalClosure, reason: nil)
        try await Task.sleep(nanoseconds: 500_000_000)
        return
    }

    var messageCount2 = 0
    let deadline2 = Date().addingTimeInterval(10.0)
    var didUpdateFilters = false

    while Date() < deadline2 {
        // After 3 seconds: unsubscribe channelStatus, update LPR filter
        if !didUpdateFilters && Date().addingTimeInterval(-3.0) > deadline2.addingTimeInterval(-10.0) {
            didUpdateFilters = true
            print("  --- Unsubscribing channelStatus, updating LPR filter ---")
            try? await wsTask2.send(.string("{\"unsubscribe\":\"channelStatus\"}"))
            try? await wsTask2.send(.string("{\"subscribe\":\"LPR\",\"ch\":[1,2,3,4]}"))
        }

        do {
            let message = try await withThrowingTaskGroup(of: URLSessionWebSocketTask.Message?.self) { group in
                group.addTask {
                    try await wsTask2.receive()
                }
                group.addTask {
                    let remaining = deadline2.timeIntervalSinceNow
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
                messageCount2 += 1
                if let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let type = json["type"] as? String ?? ""
                    let topic = json["topic"] as? String ?? ""

                    // Handle control responses
                    switch type {
                    case "subscribed":
                        print("  Subscribed to: \(topic)")
                    case "unsubscribed":
                        print("  Unsubscribed from: \(topic)")
                    case "error":
                        let msg = json["message"] as? String ?? ""
                        print("  Error: \(msg) (topic: \(topic))")
                    default:
                        // Event data
                        let t = topic.isEmpty ? "?" : topic
                        print("  [\(t)] \(text)")
                    }
                } else {
                    print("  Raw: \(text)")
                }
            case .data(let data):
                messageCount2 += 1
                print("  Binary: \(data.count) bytes")
            @unknown default:
                break
            }
        } catch {
            break
        }
    }

    print("  Received \(messageCount2) messages")
    wsTask2.cancel(with: .normalClosure, reason: nil)

    try await Task.sleep(nanoseconds: 500_000_000)
  }
}

/*
 * ─────────────────────────────────────────────────
 * LPR Event Compatibility
 * ─────────────────────────────────────────────────
 *
 * LPR events may arrive in two formats:
 *
 *   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
 *   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
 *
 * To handle both formats transparently:
 *
 *   if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
 *      json["topic"] as? String == "LPR" {
 *       let plates: [[String: Any]]
 *       if let arr = json["plates"] as? [[String: Any]] {
 *           plates = arr           // v1.0.1 batch format
 *       } else {
 *           plates = [json]        // v1.0.0 single-plate format
 *       }
 *       for p in plates {
 *           let plateNo = p["plateNo"] as? String ?? ""
 *           let score = p["score"] as? Double ?? 0
 *           print("Plate: \(plateNo)  Score: \(score)")
 *       }
 *   }
 */
