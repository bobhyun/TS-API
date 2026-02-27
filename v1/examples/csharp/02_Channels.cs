// 02_Channels.cs - v1 API Channel List & Status Example
//
// Endpoints:
//   GET /api/v1/channel                          - Channel list
//   GET /api/v1/channel/status?recordingStatus    - Channel recording status

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class Channels
    {
        static async Task Main(string[] args)
        {
            using var client = new NvrClient();
            if (string.IsNullOrEmpty(client.ApiKey))
            {
                Console.WriteLine("NVR_API_KEY environment variable is required");
                return;
            }
            client.SetApiKey(client.ApiKey);

            // ── Get channel list ──
            Console.WriteLine("=== Channel List ===");
            var r = await client.GetAsync("/api/v1/channel");
            r.EnsureSuccessStatusCode();

            using var doc = await NvrClient.ReadJsonAsync(r);
            foreach (var ch in doc.RootElement.EnumerateArray())
            {
                var chid = ch.GetProperty("chid").GetInt32();
                var title = ch.GetProperty("title").GetString();
                var displayName = ch.TryGetProperty("displayName", out var dn)
                    ? dn.GetString() : title;
                Console.WriteLine($"  CH{chid}: {displayName} (title: {title})");
            }

            // ── Get channel recording status ──
            Console.WriteLine("\n=== Channel Recording Status ===");
            var sr = await client.GetAsync("/api/v1/channel/status?recordingStatus");
            sr.EnsureSuccessStatusCode();

            using var sdoc = await NvrClient.ReadJsonAsync(sr);
            var options = new JsonSerializerOptions { WriteIndented = true };
            var pretty = JsonSerializer.Serialize(sdoc.RootElement, options);
            Console.WriteLine(pretty);
        }
    }
}
