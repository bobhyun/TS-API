// NvrClient.cs - Shared HTTP client for TS-API
//
// Environment variables:
//   NVR_HOST    - NVR host (default: localhost)
//   NVR_SCHEME  - Protocol (default: https)
//   NVR_PORT    - NVR port (default: protocol default port)
//   NVR_USER    - Username (default: admin)
//   NVR_PASS    - Password (default: 1234)
//   NVR_API_KEY - API Key (can be used instead of JWT)

using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples
{
    public class NvrClient : IDisposable
    {
        static string Env(string key, string fallback) =>
            Environment.GetEnvironmentVariable(key) ?? fallback;

        public string Host { get; }
        public string Scheme { get; }
        public string Port { get; }
        public string User { get; }
        public string Pass { get; }
        public string BaseUrl { get; }

        /// <summary>API Key from environment variable</summary>
        public string ApiKey { get; }

        /// <summary>Current access token (read-only)</summary>
        public string AccessToken => _accessToken;

        /// <summary>Current refresh token (read-only)</summary>
        public string RefreshToken => _refreshToken;

        private readonly HttpClient _http;
        private string _apiKey;
        private string _accessToken = "";
        private string _refreshToken = "";

        public NvrClient()
        {
            Host = Env("NVR_HOST", "localhost");
            Scheme = Env("NVR_SCHEME", "https");
            User = Env("NVR_USER", "admin");
            Pass = Env("NVR_PASS", "1234");
            ApiKey = Environment.GetEnvironmentVariable("NVR_API_KEY") ?? "";

            var defaultPort = Scheme == "https" ? "443" : "80";
            Port = Env("NVR_PORT", defaultPort);
            var portSuffix = Port == defaultPort ? "" : $":{Port}";
            BaseUrl = $"{Scheme}://{Host}{portSuffix}";

            var handler = new HttpClientHandler();
            handler.ServerCertificateCustomValidationCallback =
                HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
            _http = new HttpClient(handler) { BaseAddress = new Uri(BaseUrl) };
            _http.DefaultRequestHeaders.Add("X-Host", $"{Host}:{Port}");
        }

        /// <summary>
        /// Set API Key authentication via X-API-Key header
        /// Allows using v1 endpoints without JWT login
        /// </summary>
        public void SetApiKey(string key)
        {
            _apiKey = key;
            _http.DefaultRequestHeaders.Remove("X-API-Key");
            if (!string.IsNullOrEmpty(key))
                _http.DefaultRequestHeaders.Add("X-API-Key", key);
        }

        /// <summary>
        /// Set or remove Authorization header based on _accessToken
        /// </summary>
        private void SetAuth()
        {
            if (string.IsNullOrEmpty(_accessToken))
                _http.DefaultRequestHeaders.Authorization = null;
            else
                _http.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", _accessToken);
        }

        /// <summary>Send GET request</summary>
        public Task<HttpResponseMessage> GetAsync(string path) => _http.GetAsync(path);

        /// <summary>
        /// GET request for streaming responses like SSE (receive headers first)
        /// </summary>
        public Task<HttpResponseMessage> GetStreamAsync(string path) =>
            _http.GetAsync(path, HttpCompletionOption.ResponseHeadersRead);

        /// <summary>Send POST request with JSON body</summary>
        public Task<HttpResponseMessage> PostJsonAsync(string path, object body)
        {
            var json = JsonSerializer.Serialize(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            return _http.PostAsync(path, content);
        }

        /// <summary>Send DELETE request</summary>
        public Task<HttpResponseMessage> DeleteAsync(string path) => _http.DeleteAsync(path);

        /// <summary>Send custom HttpRequestMessage</summary>
        public Task<HttpResponseMessage> SendAsync(HttpRequestMessage request) => _http.SendAsync(request);

        // ── Authentication ──

        /// <summary>
        /// Login - obtain JWT Bearer tokens
        /// On success, stores accessToken/refreshToken and sets Authorization header
        /// </summary>
        public async Task<bool> LoginAsync()
        {
            var auth = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes($"{User}:{Pass}"));
            var r = await PostJsonAsync("/api/v1/auth/login", new { auth });
            if (!r.IsSuccessStatusCode) return false;

            using var doc = await ReadJsonAsync(r);
            _accessToken = doc.RootElement.GetProperty("accessToken").GetString() ?? "";
            _refreshToken = doc.RootElement.GetProperty("refreshToken").GetString() ?? "";
            SetAuth();
            return true;
        }

        /// <summary>
        /// Logout - revoke refresh token and clear stored tokens
        /// </summary>
        public async Task LogoutAsync()
        {
            if (!string.IsNullOrEmpty(_refreshToken))
                await PostJsonAsync("/api/v1/auth/logout", new { refreshToken = _refreshToken });

            _accessToken = "";
            _refreshToken = "";
            SetAuth();
        }

        /// <summary>JWT login - returns JsonDocument with tokens</summary>
        public async Task<JsonDocument> JwtLoginAsync()
        {
            var auth = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes($"{User}:{Pass}"));
            var r = await PostJsonAsync("/api/v1/auth/login", new { auth });
            if (!r.IsSuccessStatusCode) return null;
            return await ReadJsonAsync(r);
        }

        /// <summary>
        /// Refresh access token (token rotation)
        /// Response contains new accessToken and refreshToken
        /// </summary>
        public async Task<JsonDocument> JwtRefreshAsync(string refreshToken)
        {
            var r = await PostJsonAsync("/api/v1/auth/refresh",
                new { refreshToken });
            if (!r.IsSuccessStatusCode) return null;

            var doc = await ReadJsonAsync(r);
            _accessToken = doc.RootElement.GetProperty("accessToken").GetString() ?? "";
            _refreshToken = doc.RootElement.GetProperty("refreshToken").GetString() ?? "";
            SetAuth();
            return doc;
        }

        /// <summary>Revoke refresh token</summary>
        public Task JwtLogoutAsync(string refreshToken) =>
            PostJsonAsync("/api/v1/auth/logout", new { refreshToken });

        // ── Utilities ──

        /// <summary>Parse response body as JsonDocument</summary>
        public static async Task<JsonDocument> ReadJsonAsync(HttpResponseMessage response)
        {
            var body = await response.Content.ReadAsStringAsync();
            return JsonDocument.Parse(body);
        }

        /// <summary>Read response body as string</summary>
        public static Task<string> ReadStringAsync(HttpResponseMessage response) =>
            response.Content.ReadAsStringAsync();

        public void Dispose() => _http.Dispose();
    }
}
