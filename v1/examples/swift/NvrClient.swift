// TS-API Examples - Shared HTTP/WebSocket Client (Swift)
//
// Cross-platform client supporting macOS (URLSession) and
// Windows/Linux (curl process for self-signed certificate support).
//
// Environment variables:
//   NVR_HOST    - NVR server hostname (default: localhost)
//   NVR_SCHEME  - http or https (default: https)
//   NVR_PORT    - NVR server port (default: 443 for https, 80 for http)
//   NVR_USER    - Login username (default: admin)
//   NVR_PASS    - Login password (default: 1234)
//   NVR_API_KEY - API Key for v1 endpoint authentication
//
// Usage:
//   swiftc -parse-as-library -o example NvrClient.swift 02-channels.swift && ./example

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Response

struct Response {
    let status: Int
    let body: Any?
    let rawBody: String
}

// MARK: - NvrClient

class NvrClient: NSObject, URLSessionDelegate {
    let host: String
    let scheme: String
    let port: String
    let user: String
    let pass: String
    let baseURL: String
    let wsBaseURL: String

    var apiKey: String
    var accessToken: String = ""
    var refreshToken: String = ""

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    override init() {
        let env = ProcessInfo.processInfo.environment
        host = env["NVR_HOST"] ?? "localhost"
        scheme = env["NVR_SCHEME"] ?? "https"
        let defaultPort = (scheme == "https") ? "443" : "80"
        port = env["NVR_PORT"] ?? defaultPort
        user = env["NVR_USER"] ?? "admin"
        pass = env["NVR_PASS"] ?? "1234"
        apiKey = env["NVR_API_KEY"] ?? ""

        let portSuffix = (port == defaultPort) ? "" : ":\(port)"
        baseURL = "\(scheme)://\(host)\(portSuffix)"
        let wsScheme = (scheme == "https") ? "wss" : "ws"
        wsBaseURL = "\(wsScheme)://\(host)\(portSuffix)"
        super.init()
    }

    // MARK: - URLSessionDelegate (trust all certificates for self-signed certs)

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        #if canImport(Security)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        #endif
        // Non-Apple platforms (Windows/Linux): accept all SSL certificates
        completionHandler(.useCredential, URLCredential(user: "", password: "", persistence: .forSession))
    }

    // MARK: - API Key

    func setApiKey(_ key: String) {
        apiKey = key
    }

    // MARK: - HTTP Methods

    func get(_ path: String) async throws -> Response {
        return try await request("GET", path: path)
    }

    func post(_ path: String, body: [String: Any]? = nil) async throws -> Response {
        return try await request("POST", path: path, body: body)
    }

    func put(_ path: String, body: [String: Any]? = nil) async throws -> Response {
        return try await request("PUT", path: path, body: body)
    }

    func delete(_ path: String) async throws -> Response {
        return try await request("DELETE", path: path)
    }

    // MARK: - Core Request

    private func request(_ method: String, path: String, body: [String: Any]? = nil,
                         extraHeaders: [String: String]? = nil) async throws -> Response {
        #if canImport(Security)
        return try await urlSessionRequest(method, path: path, body: body, extraHeaders: extraHeaders)
        #else
        return try curlRequest(method, path: path, body: body, extraHeaders: extraHeaders)
        #endif
    }

    #if canImport(Security)
    // macOS: Use URLSession with SSL trust delegate
    private func urlSessionRequest(_ method: String, path: String, body: [String: Any]? = nil,
                                   extraHeaders: [String: String]? = nil) async throws -> Response {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            return Response(status: 0, body: nil, rawBody: "Invalid URL: \(path)")
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("\(host):\(port)", forHTTPHeaderField: "X-Host")

        if !apiKey.isEmpty { req.setValue(apiKey, forHTTPHeaderField: "X-API-Key") }
        if !accessToken.isEmpty { req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") }
        if let extraHeaders = extraHeaders {
            for (key, value) in extraHeaders { req.setValue(value, forHTTPHeaderField: key) }
        }
        if let body = body { req.httpBody = try JSONSerialization.data(withJSONObject: body) }

        let (data, response) = try await session.data(for: req)
        let httpResponse = response as! HTTPURLResponse
        let rawBody = String(data: data, encoding: .utf8) ?? ""
        return Response(status: httpResponse.statusCode, body: parseJson(data), rawBody: rawBody)
    }
    #endif

    // Windows/Linux: Use curl process with -k flag for self-signed certificates
    private func curlRequest(_ method: String, path: String, body: [String: Any]? = nil,
                             extraHeaders: [String: String]? = nil) throws -> Response {
        let url = "\(baseURL)\(path)"
        // Use a unique separator to split body from status code
        let separator = "___HTTP_STATUS___"
        var args = ["-s", "-k", "-X", method,
                    "-H", "Content-Type: application/json",
                    "-H", "X-Host: \(host):\(port)",
                    "-w", separator + "%{http_code}"]

        if !apiKey.isEmpty { args += ["-H", "X-API-Key: \(apiKey)"] }
        if !accessToken.isEmpty { args += ["-H", "Authorization: Bearer \(accessToken)"] }
        if let extraHeaders = extraHeaders {
            for (key, value) in extraHeaders { args += ["-H", "\(key): \(value)"] }
        }
        if let body = body {
            let data = try JSONSerialization.data(withJSONObject: body)
            args += ["-d", String(data: data, encoding: .utf8)!]
        }
        args.append(url)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: findCurl())
        process.arguments = args

        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = FileHandle.nullDevice

        try process.run()

        // Read stdout before waitUntilExit to prevent pipe buffer deadlock
        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        let output = String(data: outData, encoding: .utf8) ?? ""

        // Split body from status code using separator
        let parts = output.components(separatedBy: separator)
        let bodyStr = parts.first ?? ""
        let statusCode = Int(parts.last ?? "0") ?? 0
        let bodyData = bodyStr.data(using: .utf8) ?? Data()

        return Response(status: statusCode, body: parseJson(bodyData), rawBody: bodyStr)
    }

    private func findCurl() -> String {
        #if os(Windows)
        // curl.exe ships with Windows 10+
        return "C:/Windows/System32/curl.exe"
        #else
        return "/usr/bin/curl"
        #endif
    }

    // MARK: - Authentication

    func login() async throws -> Bool {
        let auth = Data("\(user):\(pass)".utf8).base64EncodedString()
        let res = try await post("/api/v1/auth/login", body: [
            "auth": auth,
        ])
        if res.status == 200, let body = res.body as? [String: Any] {
            accessToken = body["accessToken"] as? String ?? ""
            refreshToken = body["refreshToken"] as? String ?? ""
            return true
        }
        return false
    }

    func logout() async throws {
        if !refreshToken.isEmpty {
            _ = try await post("/api/v1/auth/logout", body: ["refreshToken": refreshToken])
        }
        accessToken = ""
        refreshToken = ""
    }

    func jwtLogin() async throws -> [String: Any]? {
        let auth = Data("\(user):\(pass)".utf8).base64EncodedString()
        let res = try await post("/api/v1/auth/login", body: [
            "auth": auth,
        ])
        if res.status == 200, let body = res.body as? [String: Any] {
            accessToken = body["accessToken"] as? String ?? accessToken
            refreshToken = body["refreshToken"] as? String ?? refreshToken
            return body
        }
        return nil
    }

    func jwtRefresh(_ token: String) async throws -> [String: Any]? {
        let res = try await post("/api/v1/auth/refresh", body: ["refreshToken": token])
        if res.status == 200, let body = res.body as? [String: Any] {
            accessToken = body["accessToken"] as? String ?? accessToken
            refreshToken = body["refreshToken"] as? String ?? refreshToken
            return body
        }
        return nil
    }

    func jwtLogout(_ token: String) async throws {
        _ = try await post("/api/v1/auth/logout", body: ["refreshToken": token])
    }

    // MARK: - WebSocket

    func websocket(path: String) -> URLSessionWebSocketTask {
        let url = URL(string: "\(wsBaseURL)\(path)")!
        var req = URLRequest(url: url)
        if !apiKey.isEmpty { req.setValue(apiKey, forHTTPHeaderField: "X-API-Key") }
        if !accessToken.isEmpty { req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") }
        return session.webSocketTask(with: req)
    }

    // MARK: - JSON Helper

    func parseJson(_ data: Data) -> Any? {
        guard !data.isEmpty else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    }

    func toJsonString(_ obj: Any, pretty: Bool = false) -> String {
        guard JSONSerialization.isValidJSONObject(obj) else {
            return "\(obj)"
        }
        let opts: JSONSerialization.WritingOptions = pretty ? [.prettyPrinted, .sortedKeys] : []
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: opts),
              let str = String(data: data, encoding: .utf8) else {
            return "\(obj)"
        }
        return str
    }
}

// MARK: - Utility

func sleep(ms: Int) async {
    try? await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
}
