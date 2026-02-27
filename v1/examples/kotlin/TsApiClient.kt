/**
 * TS-API Examples - Shared HTTP Client
 *
 * Kotlin + Java 11+ java.net.http.HttpClient with JWT Bearer authentication.
 * No external dependencies required.
 *
 * Environment variables:
 *   NVR_SCHEME  - http or https     (default: https)
 *   NVR_HOST    - NVR server host   (default: localhost)
 *   NVR_PORT    - NVR server port   (default: 443 for https, 80 for http)
 *   NVR_USER    - Login username    (default: admin)
 *   NVR_PASS    - Login password    (default: 1234)
 *   NVR_API_KEY - API Key auth      (default: "")
 *
 * Compile: kotlinc TsApiClient.kt -include-runtime -d TsApiClient.jar
 * Usage:   NVR_HOST=192.168.0.100 kotlin V0_01_LoginKt TsApiClient.jar
 */

import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager
class TsApiClient {

    /** Simple response holder. */
    data class Response(val status: Int, val body: String)

    // -- Configuration from environment variables --
    val scheme = env("NVR_SCHEME", "https")
    val host = env("NVR_HOST", "localhost")
    private val defaultPort = if (scheme == "https") "443" else "80"
    val port = env("NVR_PORT", defaultPort)
    val user = env("NVR_USER", "admin")
    val pass = env("NVR_PASS", "1234")
    private val portSuffix = if (port == defaultPort) "" else ":$port"
    val baseUrl = "$scheme://$host$portSuffix"
    val wsScheme = if (scheme == "https") "wss" else "ws"
    val wsUrl = "$wsScheme://$host$portSuffix"

    // API Key for X-API-Key header authentication (v1 endpoints only)
    var apiKey: String = env("NVR_API_KEY", "")
        private set

    // JWT tokens for Bearer authentication
    var accessToken: String = ""
        private set
    var refreshToken: String = ""
        private set

    val http: HttpClient = run {
        // Disable hostname verification for self-signed certificates
        System.setProperty("jdk.internal.httpclient.disableHostnameVerification", "true")
        HttpClient.newBuilder()
            .sslContext(trustAllContext())
            .build()
    }

    // -- HTTP Methods --

    /**
     * GET request. Returns Response with status code and body string.
     */
    fun get(path: String): Response {
        val req = requestBuilder(path).GET().build()
        val resp = http.send(req, HttpResponse.BodyHandlers.ofString())
        return Response(resp.statusCode(), resp.body())
    }

    /**
     * POST request with JSON body. Returns Response.
     */
    fun post(path: String, json: String = ""): Response {
        val req = requestBuilder(path)
            .POST(HttpRequest.BodyPublishers.ofString(json))
            .build()
        val resp = http.send(req, HttpResponse.BodyHandlers.ofString())
        return Response(resp.statusCode(), resp.body())
    }

    // -- Authentication (JWT Bearer token) --

    /**
     * Login: POST /api/v1/auth/login with JSON body.
     * On success (HTTP 200), parses accessToken and refreshToken from response and stores them.
     * Returns true on success.
     */
    fun login(): Boolean {
        val auth = java.util.Base64.getEncoder().encodeToString("$user:$pass".toByteArray())
        val json = """{"auth":"$auth"}"""
        val r = post("/api/v1/auth/login", json)
        if (r.status == 200) {
            accessToken = extractJsonValue(r.body, "accessToken")
            refreshToken = extractJsonValue(r.body, "refreshToken")
            return true
        }
        return false
    }

    /**
     * Logout: POST /api/v1/auth/logout with refreshToken in body.
     * Clears both tokens after request.
     */
    fun logout() {
        if (refreshToken.isNotEmpty()) {
            post("/api/v1/auth/logout", """{"refreshToken":"$refreshToken"}""")
        }
        accessToken = ""
        refreshToken = ""
    }

    /**
     * Set the API Key for X-API-Key header authentication.
     */
    fun setApiKey(key: String) {
        apiKey = key
    }

    /**
     * JWT login: POST /api/v1/auth/login with JSON body.
     * Returns Response containing {accessToken, refreshToken, expiresIn, tokenType}.
     */
    fun jwtLogin(): Response {
        val auth = java.util.Base64.getEncoder().encodeToString("$user:$pass".toByteArray())
        return post("/api/v1/auth/login", """{"auth":"$auth"}""")
    }

    /**
     * Refresh access token using refresh token (token rotation).
     * Returns Response containing {accessToken, refreshToken, expiresIn, tokenType}.
     */
    fun jwtRefresh(refreshToken: String): Response =
        post("/api/v1/auth/refresh", """{"refreshToken":"$refreshToken"}""")

    /**
     * JWT logout - revoke refresh token.
     */
    fun jwtLogout(refreshToken: String): Response =
        post("/api/v1/auth/logout", """{"refreshToken":"$refreshToken"}""")

    /**
     * Build an HttpRequest with standard headers for the given path.
     * If apiKey is set, adds X-API-Key header.
     * Otherwise, if accessToken is set, adds Authorization: Bearer header.
     */
    fun requestBuilder(path: String): HttpRequest.Builder {
        val builder = HttpRequest.newBuilder()
            .uri(URI.create("$baseUrl$path"))
            .header("Content-Type", "application/json")
            .header("X-Host", "$host:$port")
        if (apiKey.isNotEmpty()) {
            builder.header("X-API-Key", apiKey)
        } else if (accessToken.isNotEmpty()) {
            builder.header("Authorization", "Bearer $accessToken")
        }
        return builder
    }

    companion object {
        fun env(key: String, default: String): String =
            System.getenv(key)?.takeIf { it.isNotEmpty() } ?: default

        /**
         * Create an SSLContext that trusts all certificates (for self-signed NVR certs).
         */
        fun trustAllContext(): SSLContext {
            val ctx = SSLContext.getInstance("TLS")
            ctx.init(null, arrayOf<TrustManager>(object : X509TrustManager {
                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
                override fun checkClientTrusted(c: Array<X509Certificate>, t: String) {}
                override fun checkServerTrusted(c: Array<X509Certificate>, t: String) {}
            }), null)
            return ctx
        }

        /**
         * Simple JSON value extractor using String.split.
         * Extracts the value for a given key from a JSON string.
         */
        fun extractJsonValue(json: String, key: String): String {
            val parts = json.split("\"$key\"")
            if (parts.size < 2) return ""
            val after = parts[1].split("\"")
            // after[0] is typically `:` or `: `, after[1] is the value
            return if (after.size >= 3) after[1] else ""
        }
    }
}
