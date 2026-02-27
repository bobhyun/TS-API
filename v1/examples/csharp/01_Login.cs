// 01_Login.cs - v1 API Authentication Example
//
// v1 API supports two authentication methods:
//
// 1. JWT auth (POST with JSON body)
//    POST /api/v1/auth/login  {"auth":"base64(username:password)"}
//    POST /api/v1/auth/logout {"refreshToken":"..."}
//
// 2. JWT auth (token-based)
//    POST /api/v1/auth/login -> {accessToken, refreshToken, expiresIn, tokenType}
//
// 3. API Key (external integration)
//    POST /api/v1/auth/apikey (create, requires admin JWT)
//    X-API-Key header (use, v1 endpoints only)
//
// IMPORTANT: JWT only works on /api/v1/auth/* endpoints!
// API Key authentication is supported on v1 endpoints only. v0 returns 401.

using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class Login
    {
        static async Task Main(string[] args)
        {
            using var client = new NvrClient();
            Console.WriteLine($"NVR: {client.BaseUrl}");

            // ── Method 1: Session auth ──
            Console.WriteLine("\n=== Session Login ===");
            var ok = await client.LoginAsync();
            Console.WriteLine($"Login: {(ok ? "OK" : "FAILED")}");

            if (ok)
            {
                var r = await client.GetAsync("/api/v1/channel");
                Console.WriteLine($"GET /api/v1/channel -> {(int)r.StatusCode}");

                await client.LogoutAsync();
                Console.WriteLine("Logged out");
            }

            // ── Method 2: JWT auth (accessToken + refreshToken) ──
            Console.WriteLine("\n=== JWT Login ===");
            using var jwtDoc = await client.JwtLoginAsync();
            if (jwtDoc == null)
            {
                Console.WriteLine("JWT login failed");
                return;
            }

            var jwtRoot = jwtDoc.RootElement;
            var accessToken = jwtRoot.GetProperty("accessToken").GetString();
            var refreshToken = jwtRoot.GetProperty("refreshToken").GetString();
            Console.WriteLine($"Access Token:  {accessToken?.Substring(0, 20)}...");
            Console.WriteLine($"Refresh Token: {refreshToken?.Substring(0, 20)}...");
            Console.WriteLine($"Expires In:    {jwtRoot.GetProperty("expiresIn").GetInt32()}s");

            // Refresh accessToken using refreshToken
            using var refreshDoc = await client.JwtRefreshAsync(refreshToken);
            if (refreshDoc != null)
            {
                var newToken = refreshDoc.RootElement.GetProperty("accessToken").GetString();
                Console.WriteLine($"Refreshed:     {newToken?.Substring(0, 20)}...");
                accessToken = newToken;  // use new token
            }

            // JWT logout (revoke refreshToken)
            // await client.JwtLogoutAsync(refreshToken);  // skip: need token for API Key demo below

            // ── Method 3: API Key lifecycle (Create -> Use -> List -> Delete) ──
            Console.WriteLine("\n=== API Key ===");
            var bearer = new AuthenticationHeaderValue("Bearer", accessToken);

            // 1) Create API Key
            var createReq = new HttpRequestMessage(HttpMethod.Post, "/api/v1/auth/apikey");
            createReq.Headers.Authorization = bearer;
            createReq.Content = new StringContent(
                JsonSerializer.Serialize(new { name = "example-integration" }),
                Encoding.UTF8, "application/json");
            var createRes = await client.SendAsync(createReq);
            Console.WriteLine($"Create API Key: {(int)createRes.StatusCode}");

            if (!createRes.IsSuccessStatusCode) return;

            using var keyDoc = JsonDocument.Parse(await createRes.Content.ReadAsStringAsync());
            var keyRoot = keyDoc.RootElement;
            var keyId = keyRoot.GetProperty("id").GetString();
            var apiKey = keyRoot.GetProperty("key").GetString();
            Console.WriteLine($"  Key ID: {keyId}");
            Console.WriteLine($"  API Key: {apiKey?.Substring(0, Math.Min(24, apiKey?.Length ?? 0))}...");

            // 2) Use API Key (no login needed)
            var useReq = new HttpRequestMessage(HttpMethod.Get, "/api/v1/channel");
            useReq.Headers.Add("X-API-Key", apiKey);
            var useRes = await client.SendAsync(useReq);
            Console.WriteLine($"Use API Key -> GET /api/v1/channel: {(int)useRes.StatusCode}");

            // 3) List API Keys
            var listReq = new HttpRequestMessage(HttpMethod.Get, "/api/v1/auth/apikey");
            listReq.Headers.Authorization = bearer;
            var listRes = await client.SendAsync(listReq);
            Console.WriteLine($"List API Keys: {(int)listRes.StatusCode}");

            // 4) Delete API Key
            var delReq = new HttpRequestMessage(HttpMethod.Delete, $"/api/v1/auth/apikey/{keyId}");
            delReq.Headers.Authorization = bearer;
            var delRes = await client.SendAsync(delReq);
            Console.WriteLine($"Delete API Key: {(int)delRes.StatusCode}");
        }
    }
}
