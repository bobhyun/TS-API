// Example 01: Authentication
//
// Three authentication methods:
//   1. Client login - NvrClient logs in with JWT and sends the Bearer token automatically
//   2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
//   3. API Key      - X-API-Key header, for external integrations
//
// NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
// NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct App {
  static func main() async throws {
    let client = NvrClient()

    // -------------------------------------------------
    // Method 1: Client login (JWT stored by NvrClient)
    //   POST /api/v1/auth/login
    //   Subsequent requests send the Bearer token automatically
    // -------------------------------------------------
    print("=== Simple Login ===")

    let ok = try await client.login()
    print("Login: \(ok ? "OK" : "Failed")")
    if !client.accessToken.isEmpty {
        let prefix = String(client.accessToken.prefix(30))
        print("Access Token: \(prefix)...")
    }

    // Token is stored; data endpoints are accessible
    let channelRes = try await client.get("/api/v1/channel")
    if let channels = channelRes.body as? [[String: Any]] {
        print("Channels: \(channelRes.status) (\(channels.count) channels)")
    }

    try await client.logout()
    print("Logged out\n")

    // -------------------------------------------------
    // Method 2: JWT (manage tokens yourself)
    // -------------------------------------------------
    print("=== JWT Login ===")

    // 1) Login -> accessToken + refreshToken
    if let tokens = try await client.jwtLogin() {
        let accessToken = tokens["accessToken"] as? String ?? ""
        let refreshToken = tokens["refreshToken"] as? String ?? ""
        let expiresIn = tokens["expiresIn"] ?? "N/A"
        print("Access Token:  \(String(accessToken.prefix(30)))...")
        print("Refresh Token: \(String(refreshToken.prefix(30)))...")
        print("Expires In:    \(expiresIn) seconds")

        if let user = tokens["user"] as? [String: Any] {
            let username = user["username"] as? String ?? ""
            let role = user["role"] as? String ?? ""
            print("User:          \(username) (\(role))")
        }

        // 2) Use accessToken for API calls
        let apikeyList = try await client.get("/api/v1/auth/apikey")
        print("API Key List: \(apikeyList.status)")

        // 3) Refresh accessToken
        //    NOTE: The server rotates refreshToken: the old one is revoked
        let refreshed = try await client.jwtRefresh(refreshToken)
        if let refreshed = refreshed {
            let newAccess = refreshed["accessToken"] as? String ?? ""
            let newRefresh = refreshed["refreshToken"] as? String ?? ""
            print("Refreshed:     \(String(newAccess.prefix(30)))...")
            print("New Refresh:   \(String(newRefresh.prefix(30)))...")

            // 4) Logout (revoke refreshToken)
            //    Use the new refreshToken after rotation
            try await client.jwtLogout(newRefresh)
        } else {
            try await client.jwtLogout(refreshToken)
        }
        print("JWT logged out (refreshToken revoked)")
    } else {
        print("JWT Login failed")
    }

    print("")

    // -------------------------------------------------
    // Method 3: API Key (create -> use -> list -> delete)
    //   POST /api/v1/auth/apikey        (create, requires admin JWT)
    //   X-API-Key header                (use, v1 endpoints only)
    //   GET /api/v1/auth/apikey         (list)
    //   DELETE /api/v1/auth/apikey/{id} (delete)
    // -------------------------------------------------
    print("=== API Key ===")

    // 1) Get an admin token via JWT login
    guard let authTokens = try await client.jwtLogin() else {
        print("JWT login failed")
        return
    }

    // 2) Create API Key
    let createRes = try await client.post("/api/v1/auth/apikey", body: [
        "name": "example-integration",
    ])
    print("Create API Key: \(createRes.status)")
    guard createRes.status == 200, let createBody = createRes.body as? [String: Any] else { return }

    let keyId = createBody["id"] as? String ?? ""
    let newApiKey = createBody["key"] as? String ?? ""
    print("  Key ID: \(keyId)")
    print("  API Key: \(String(newApiKey.prefix(24)))...")
    if let message = createBody["message"] as? String {
        print("  WARNING: \(message)")
    }

    // 3) Call a data endpoint with the API Key (no login required)
    let savedAccessToken = client.accessToken
    client.accessToken = ""
    client.setApiKey(newApiKey)

    let dataRes = try await client.get("/api/v1/channel")
    print("Use API Key -> GET /api/v1/channel: \(dataRes.status)")

    // Restore JWT auth
    client.setApiKey("")
    client.accessToken = savedAccessToken

    // 4) List API Keys
    let listRes = try await client.get("/api/v1/auth/apikey")
    if let keys = listRes.body as? [[String: Any]] {
        print("List API Keys: \(listRes.status) (\(keys.count) keys)")
    }

    // 5) Delete API Key
    let delRes = try await client.delete("/api/v1/auth/apikey/\(keyId)")
    print("Delete API Key: \(delRes.status)")

    let authRefresh = authTokens["refreshToken"] as? String ?? ""
    try await client.jwtLogout(authRefresh)
  }
}
