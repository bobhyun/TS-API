// v1 API - Authentication Methods
//
// Three authentication methods:
//   1. Client login - TsApiClient logs in with JWT and sends the Bearer token automatically
//   2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
//   3. API Key      - X-API-Key header, for external integrations
//
// NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
// NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.
//
// Compile: kotlinc TsApiClient.kt V1_01_Login.kt -include-runtime -d V1_01_Login.jar
// Run:     java -jar V1_01_Login.jar

import java.net.http.HttpRequest
import java.net.http.HttpResponse

fun main() {
    demoSessionLogin()
    demoJwt()
    demoApiKey()
}

/**
 * Method 1: Client login.
 * TsApiClient stores the JWT and sends it as a Bearer token.
 */
private fun demoSessionLogin() {
    println("=== Session Login ===")
    val client = TsApiClient()

    // POST /api/v1/auth/login  {"auth":"base64(username:password)"}
    val ok = client.login()
    println("Login: ${if (ok) "OK" else "FAILED"}")

    if (ok) {
        // Token is stored; data endpoints are accessible
        val r = client.get("/api/v1/channel")
        println("GET /api/v1/channel -> ${r.status}")

        // Log out to revoke the refreshToken
        client.logout()
        println("Logged out")
    }
}

/**
 * Method 2: JWT Token (accessToken + refreshToken).
 * POST /api/v1/auth/login    -> {accessToken, refreshToken, expiresIn, tokenType}
 * POST /api/v1/auth/refresh  -> {accessToken, refreshToken, expiresIn, tokenType} (rotates refreshToken)
 * POST /api/v1/auth/logout   (revoke refreshToken)
 */
private fun demoJwt() {
    println("\n=== JWT Login ===")
    val client = TsApiClient()

    // 1) Login -> accessToken + refreshToken
    val r = client.jwtLogin()
    if (r.status != 200) {
        println("JWT login failed: ${r.status}")
        return
    }

    val accessToken = r.body.split("\"accessToken\":\"")[1].split("\"")[0]
    val refreshToken = r.body.split("\"refreshToken\":\"")[1].split("\"")[0]
    println("Access Token:  ${accessToken.substring(0, 30)}...")
    println("Refresh Token: ${refreshToken.substring(0, 30)}...")

    // 2) Refresh accessToken
    val rr = client.jwtRefresh(refreshToken)
    if (rr.status == 200) {
        val newToken = rr.body.split("\"accessToken\":\"")[1].split("\"")[0]
        println("Refreshed:     ${newToken.substring(0, 30)}...")
    }

    // 3) Logout (revoke refreshToken)
    client.jwtLogout(refreshToken)
    println("JWT logged out (refreshToken revoked)")
}

/**
 * Method 3: API Key (create -> use -> list -> delete).
 *
 * POST /api/v1/auth/apikey        (create, requires admin JWT)
 * X-API-Key header                (use, v1 endpoints only)
 * GET /api/v1/auth/apikey         (list)
 * DELETE /api/v1/auth/apikey/{id} (delete)
 */
private fun demoApiKey() {
    println("\n=== API Key ===")
    val client = TsApiClient()

    // 1) Get an admin token via JWT login
    val jr = client.jwtLogin()
    if (jr.status != 200) {
        println("JWT login failed: ${jr.status}")
        return
    }
    val token = jr.body.split("\"accessToken\":\"")[1].split("\"")[0]
    val auth = "Bearer $token"

    // 2) Create API Key
    var req = client.requestBuilder("/api/v1/auth/apikey")
        .header("Authorization", auth)
        .POST(HttpRequest.BodyPublishers.ofString("""{"name":"example-integration"}"""))
        .build()
    var resp = client.http.send(req, HttpResponse.BodyHandlers.ofString())
    println("Create API Key: ${resp.statusCode()}")
    if (resp.statusCode() != 200) return

    val respBody = resp.body()
    val keyId = respBody.split("\"id\":\"")[1].split("\"")[0]
    val apiKey = respBody.split("\"key\":\"")[1].split("\"")[0]
    println("  Key ID: $keyId")
    println("  API Key: ${apiKey.substring(0, 24)}...")

    // 3) Call a data endpoint with the API Key (no login required)
    req = client.requestBuilder("/api/v1/channel")
        .header("X-API-Key", apiKey)
        .GET()
        .build()
    resp = client.http.send(req, HttpResponse.BodyHandlers.ofString())
    println("Use API Key -> GET /api/v1/channel: ${resp.statusCode()}")

    // 4) List API Keys
    req = client.requestBuilder("/api/v1/auth/apikey")
        .header("Authorization", auth)
        .GET()
        .build()
    resp = client.http.send(req, HttpResponse.BodyHandlers.ofString())
    println("List API Keys: ${resp.statusCode()}")

    // 5) Delete API Key
    req = client.requestBuilder("/api/v1/auth/apikey/$keyId")
        .header("Authorization", auth)
        .DELETE()
        .build()
    resp = client.http.send(req, HttpResponse.BodyHandlers.ofString())
    println("Delete API Key: ${resp.statusCode()}")
}
