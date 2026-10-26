/**
 * v1 API - Authentication Methods
 *
 * Three authentication methods:
 *   1. Client login - NvrClient logs in with JWT and sends the Bearer token automatically
 *   2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
 *   3. API Key      - X-API-Key header, for external integrations
 *
 * NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
 * NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.
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
     * Method 1: Client login.
     * NvrClient stores the JWT and sends it as a Bearer token.
     */
    static void demoSessionLogin() throws Exception {
        System.out.println("=== Session Login ===");
        NvrClient client = new NvrClient();

        // POST /api/v1/auth/login  {"auth":"base64(username:password)"}
        boolean ok = client.login();
        System.out.println("Login: " + (ok ? "OK" : "FAILED"));

        if (ok) {
            // Token is stored; data endpoints are accessible
            NvrClient.Response r = client.get("/api/v1/channel");
            System.out.println("GET /api/v1/channel -> " + r.status);

            // Log out to revoke the refreshToken
            client.logout();
            System.out.println("Logged out");
        }
    }

    /**
     * Method 2: JWT Token (accessToken + refreshToken).
     * POST /api/v1/auth/login    -> {accessToken, refreshToken, expiresIn, tokenType}
     * POST /api/v1/auth/refresh  -> {accessToken, refreshToken, expiresIn, tokenType} (rotates refreshToken)
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

        // 2) Refresh accessToken
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
     * Method 3: API Key (create -> use -> list -> delete).
     *
     * POST /api/v1/auth/apikey        (create, requires admin JWT)
     * X-API-Key header                (use, v1 endpoints only)
     * GET /api/v1/auth/apikey         (list)
     * DELETE /api/v1/auth/apikey/{id} (delete)
     */
    static void demoApiKey() throws Exception {
        System.out.println("\n=== API Key ===");
        NvrClient client = new NvrClient();

        // 1) Get an admin token via JWT login
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

        // 3) Call a data endpoint with the API Key (no login required)
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
