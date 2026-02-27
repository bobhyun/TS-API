/**
 * v1 API - Authentication Methods
 *
 * Three authentication methods:
 *   1. Session Login   - POST /api/v1/auth/login (JSON body, cookie-based)
 *   2. JWT Token       - POST /api/v1/auth/login (JSON body)
 *   3. API Key         - X-API-Key header (v1 endpoints only)
 *
 * IMPORTANT: JWT tokens only work on /api/v1/auth/* endpoints.
 *            For data endpoints (channel, event, etc.), use Legacy Session or API Key.
 * IMPORTANT: API Key authentication is supported on v1 endpoints only.
 *            v0 endpoints (/api/*) reject X-API-Key with 401 Unauthorized.
 *
 * Compile: javac NvrClient.java V1_01_Login.java
 * Run:     java V1_01_Login
 */
public class V1_01_Login {

    public static void main(String[] args) throws Exception {
        demoSessionLogin();
        demoJwt();
        demoApiKey();
    }

    /**
     * Method 1: Session Login (POST with JSON body).
     * Login via POST /api/v1/auth/login. Server sets a session cookie.
     */
    static void demoSessionLogin() throws Exception {
        System.out.println("=== Session Login ===");
        NvrClient client = new NvrClient();

        // POST /api/v1/auth/login  {"auth":"base64(username:password)"}
        boolean ok = client.login();
        System.out.println("Login: " + (ok ? "OK" : "FAILED"));

        if (ok) {
            // Session cookie is set; data endpoints are accessible
            NvrClient.Response r = client.get("/api/v1/channel");
            System.out.println("GET /api/v1/channel -> " + r.status);

            // Always logout to release session
            client.logout();
            System.out.println("Logged out");
        }
    }

    /**
     * Method 2: JWT Token (accessToken + refreshToken).
     * POST /api/v1/auth/login    -> {accessToken, refreshToken, expiresIn, tokenType}
     * POST /api/v1/auth/refresh  -> {accessToken, expiresIn, tokenType}
     * POST /api/v1/auth/logout   (revoke refreshToken)
     */
    static void demoJwt() throws Exception {
        System.out.println("\n=== JWT Login ===");
        NvrClient client = new NvrClient();

        // 1) Login -> accessToken + refreshToken
        NvrClient.Response r = client.jwtLogin();
        if (r.status != 200) {
            System.out.println("JWT login failed: " + r.status);
            return;
        }

        String body = r.body;
        String accessToken = body.split("\"accessToken\":\"")[1].split("\"")[0];
        String refreshToken = body.split("\"refreshToken\":\"")[1].split("\"")[0];
        System.out.println("Access Token:  " + accessToken.substring(0, 30) + "...");
        System.out.println("Refresh Token: " + refreshToken.substring(0, 30) + "...");

        // 2) Refresh accessToken using refreshToken
        NvrClient.Response rr = client.jwtRefresh(refreshToken);
        if (rr.status == 200) {
            String newToken = rr.body.split("\"accessToken\":\"")[1].split("\"")[0];
            System.out.println("Refreshed:     " + newToken.substring(0, 30) + "...");
        }

        // 3) Logout (revoke refreshToken)
        client.jwtLogout(refreshToken);
        System.out.println("JWT logged out (refreshToken revoked)");
    }

    /**
     * Method 3: API Key (Create -> Use -> List -> Delete).
     *
     * POST /api/v1/auth/apikey        (Create, requires admin JWT)
     * X-API-Key header                (Use, v1 endpoints only. v0 rejects with 401)
     * GET /api/v1/auth/apikey         (List)
     * DELETE /api/v1/auth/apikey/{id} (Delete)
     */
    static void demoApiKey() throws Exception {
        System.out.println("\n=== API Key ===");
        NvrClient client = new NvrClient();

        // 1) Obtain admin token via JWT login
        NvrClient.Response jr = client.jwtLogin();
        if (jr.status != 200) {
            System.out.println("JWT login failed: " + jr.status);
            return;
        }
        // Extract accessToken (simple string parsing)
        String body = jr.body;
        String token = body.split("\"accessToken\":\"")[1].split("\"")[0];
        String auth = "Bearer " + token;

        // 2) Create API Key
        java.net.http.HttpRequest req = client.requestBuilder("/api/v1/auth/apikey")
                .header("Authorization", auth)
                .POST(java.net.http.HttpRequest.BodyPublishers.ofString(
                        "{\"name\":\"example-integration\"}"))
                .build();
        java.net.http.HttpResponse<String> resp = client.httpClient()
                .send(req, java.net.http.HttpResponse.BodyHandlers.ofString());
        System.out.println("Create API Key: " + resp.statusCode());
        if (resp.statusCode() != 200) return;

        // Extract id and apiKey
        String respBody = resp.body();
        String keyId = respBody.split("\"id\":\"")[1].split("\"")[0];
        String apiKey = respBody.split("\"key\":\"")[1].split("\"")[0];
        System.out.println("  Key ID: " + keyId);
        System.out.println("  API Key: " + apiKey.substring(0, 24) + "...");

        // 3) Access data endpoints with API Key (no login required)
        req = client.requestBuilder("/api/v1/channel")
                .header("X-API-Key", apiKey)
                .GET()
                .build();
        resp = client.httpClient()
                .send(req, java.net.http.HttpResponse.BodyHandlers.ofString());
        System.out.println("Use API Key -> GET /api/v1/channel: " + resp.statusCode());

        // 4) List API Keys
        req = client.requestBuilder("/api/v1/auth/apikey")
                .header("Authorization", auth)
                .GET()
                .build();
        resp = client.httpClient()
                .send(req, java.net.http.HttpResponse.BodyHandlers.ofString());
        System.out.println("List API Keys: " + resp.statusCode());

        // 5) Delete API Key
        req = client.requestBuilder("/api/v1/auth/apikey/" + keyId)
                .header("Authorization", auth)
                .DELETE()
                .build();
        resp = client.httpClient()
                .send(req, java.net.http.HttpResponse.BodyHandlers.ofString());
        System.out.println("Delete API Key: " + resp.statusCode());
    }
}
