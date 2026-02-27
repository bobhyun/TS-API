/**
 * TS-API Examples - Shared HTTP Client
 *
 * Java 11+ java.net.http.HttpClient with JWT Bearer token and API Key authentication.
 * No external dependencies required.
 *
 * Environment variables:
 *   NVR_SCHEME  - http or https        (default: https)
 *   NVR_HOST    - NVR server hostname  (default: localhost)
 *   NVR_PORT    - NVR server port      (default: 443 for https, 80 for http)
 *   NVR_USER    - Login username        (default: admin)
 *   NVR_PASS    - Login password        (default: 1234)
 *   NVR_API_KEY - API Key for v1 endpoints (optional, used by data examples)
 *
 * Compile:  javac NvrClient.java
 * Usage:    NVR_HOST=192.168.0.100 NVR_API_KEY=tsapi_key_... java V1_02_Channels
 */

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;

public class NvrClient {

    /** Simple response holder. */
    public static class Response {
        public final int status;
        public final String body;

        public Response(int status, String body) {
            this.status = status;
            this.body = body;
        }

        @Override
        public String toString() {
            return "Response{status=" + status + ", body=" + body + "}";
        }
    }

    // ── Configuration from environment variables ──
    private static final String SCHEME = env("NVR_SCHEME", "https");
    private static final String DEFAULT_PORT = SCHEME.equals("https") ? "443" : "80";
    private static final String WS_SCHEME = SCHEME.equals("https") ? "wss" : "ws";

    public final String host;
    public final String port;
    public final String user;
    public final String pass;
    public final String baseUrl;
    public final String wsScheme = WS_SCHEME;

    private final HttpClient http;

    // JWT tokens for Bearer authentication
    private String accessToken = "";
    private String refreshToken = "";

    // API Key for v1 endpoint authentication
    private String apiKey = "";

    /**
     * Create an SSLContext that trusts all certificates (for self-signed NVR certs).
     */
    public static SSLContext trustAllContext() {
        try {
            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(null, new TrustManager[]{new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
                public void checkClientTrusted(X509Certificate[] c, String t) {}
                public void checkServerTrusted(X509Certificate[] c, String t) {}
            }}, null);
            return ctx;
        } catch (Exception e) { throw new RuntimeException(e); }
    }

    public NvrClient() {
        host = env("NVR_HOST", "localhost");
        port = env("NVR_PORT", DEFAULT_PORT);
        user = env("NVR_USER", "admin");
        pass = env("NVR_PASS", "1234");
        apiKey = env("NVR_API_KEY", "");
        String portSuffix = port.equals(DEFAULT_PORT) ? "" : ":" + port;
        baseUrl = SCHEME + "://" + host + portSuffix;

        // Disable hostname verification for self-signed certificates
        System.setProperty("jdk.internal.httpclient.disableHostnameVerification", "true");
        http = HttpClient.newBuilder()
                .sslContext(trustAllContext())
                .build();
    }

    // ── Token accessors ──

    /**
     * Get the current access token.
     */
    public String getAccessToken() {
        return accessToken;
    }

    /**
     * Get the current refresh token.
     */
    public String getRefreshToken() {
        return refreshToken;
    }

    /**
     * Get the current API key.
     */
    public String getApiKey() {
        return apiKey;
    }

    /**
     * Set the API key for v1 endpoint authentication.
     */
    public void setApiKey(String key) {
        this.apiKey = (key != null) ? key : "";
    }

    // ── HTTP Methods ──

    /**
     * GET request. Returns Response with status code and body string.
     */
    public Response get(String path) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .header("Content-Type", "application/json")
                .header("X-Host", host + ":" + port);
        if (!apiKey.isEmpty()) {
            builder.header("X-API-Key", apiKey);
        } else if (!accessToken.isEmpty()) {
            builder.header("Authorization", "Bearer " + accessToken);
        }
        HttpRequest req = builder.GET().build();
        HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        return new Response(resp.statusCode(), resp.body());
    }

    /**
     * POST request with JSON body. Returns Response.
     */
    public Response post(String path, String jsonBody) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .header("Content-Type", "application/json")
                .header("X-Host", host + ":" + port);
        if (!apiKey.isEmpty()) {
            builder.header("X-API-Key", apiKey);
        } else if (!accessToken.isEmpty()) {
            builder.header("Authorization", "Bearer " + accessToken);
        }
        HttpRequest req = builder
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();
        HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
        return new Response(resp.statusCode(), resp.body());
    }

    // ── Authentication (JWT Bearer token based) ──

    /**
     * Login: POST /api/v1/auth/login with JSON body.
     * On success (HTTP 200), parses accessToken and refreshToken from response and stores them.
     * Returns true on success.
     *
     */
    public boolean login() throws Exception {
        String auth = java.util.Base64.getEncoder().encodeToString((user + ":" + pass).getBytes());
        String json = "{\"auth\":\"" + auth + "\"}";
        Response r = post("/api/v1/auth/login", json);
        if (r.status == 200) {
            accessToken = extractJsonValue(r.body, "accessToken");
            refreshToken = extractJsonValue(r.body, "refreshToken");
            return true;
        }
        return false;
    }

    /**
     * Logout: POST /api/v1/auth/logout with refreshToken in body. Clears both tokens.
     */
    public void logout() throws Exception {
        if (!refreshToken.isEmpty()) {
            post("/api/v1/auth/logout", "{\"refreshToken\":\"" + refreshToken + "\"}");
        }
        accessToken = "";
        refreshToken = "";
    }

    /**
     * JWT login: POST /api/v1/auth/login with JSON body.
     * Returns Response containing {accessToken, refreshToken, expiresIn, tokenType}.
     */
    public Response jwtLogin() throws Exception {
        String auth = java.util.Base64.getEncoder().encodeToString((user + ":" + pass).getBytes());
        String json = "{\"auth\":\"" + auth + "\"}";
        return post("/api/v1/auth/login", json);
    }

    /**
     * Refresh access token using refresh token.
     * Returns Response containing {accessToken, refreshToken, expiresIn, tokenType}.
     * Token rotation: refreshToken is also reissued.
     */
    public Response jwtRefresh(String refreshToken) throws Exception {
        return post("/api/v1/auth/refresh",
                "{\"refreshToken\":\"" + refreshToken + "\"}");
    }

    /**
     * JWT logout - revoke refresh token.
     */
    public Response jwtLogout(String refreshToken) throws Exception {
        return post("/api/v1/auth/logout",
                "{\"refreshToken\":\"" + refreshToken + "\"}");
    }

    // ── Expose underlying HttpClient for SSE streaming ──

    /**
     * Access the raw HttpClient for advanced use (e.g., SSE streaming).
     */
    public HttpClient httpClient() {
        return http;
    }

    /**
     * Build an HttpRequest with standard headers for the given path.
     * Includes X-API-Key header if apiKey is set, or Authorization header if accessToken is set.
     */
    public HttpRequest.Builder requestBuilder(String path) {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .header("Content-Type", "application/json")
                .header("X-Host", host + ":" + port);
        if (!apiKey.isEmpty()) {
            builder.header("X-API-Key", apiKey);
        } else if (!accessToken.isEmpty()) {
            builder.header("Authorization", "Bearer " + accessToken);
        }
        return builder;
    }

    // ── Utility ──

    static String env(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : def;
    }

    /**
     * Extract a string value from a JSON object by key name.
     * Simple parser without external dependencies - works for flat JSON objects.
     */
    private static String extractJsonValue(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return "";
        // Find the colon after the key
        int colonIdx = json.indexOf(':', keyIdx + search.length());
        if (colonIdx < 0) return "";
        // Find the opening quote of the value
        int startQuote = json.indexOf('"', colonIdx + 1);
        if (startQuote < 0) return "";
        // Find the closing quote of the value
        int endQuote = json.indexOf('"', startQuote + 1);
        if (endQuote < 0) return "";
        return json.substring(startQuote + 1, endQuote);
    }
}
