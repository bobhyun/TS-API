// 11_Emergency.cs - v1 API Emergency Call Device List Example
//
// Endpoint:
//   GET /api/v1/emergency  - Emergency call device list
//
// Note: Requires Emergency Call license. Returns 404 if not supported.

using System;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class Emergency
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

            // ── Emergency call device list ──
            Console.WriteLine("=== Emergency Call Devices ===");
            var r = await client.GetAsync("/api/v1/emergency");

            if ((int)r.StatusCode == 404)
            {
                Console.WriteLine("  Emergency Call not enabled on this server (license required)");
                return;
            }

            r.EnsureSuccessStatusCode();
            using var doc = await NvrClient.ReadJsonAsync(r);
            foreach (var dev in doc.RootElement.EnumerateArray())
            {
                var id = dev.GetProperty("id").GetInt32();
                var code = dev.GetProperty("code").GetString();
                var name = dev.GetProperty("name").GetString();
                var channels = dev.GetProperty("linkedChannel");
                Console.WriteLine($"  id={id}  code={code}  name={name}  linkedChannel={channels}");
            }
        }
    }
}
