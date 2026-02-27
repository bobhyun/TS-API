// 08_SystemInfo.cs - v1 API System Info Example
//
// Endpoints:
//   GET /api/v1/info?all                     - All system info
//   GET /api/v1/system/info?item=storage     - Storage info
//   GET /api/v1/system/health                - System health
//
// Note: The storage response field name is 'disk' (NOT 'storage').

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class SystemInfo
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

            var options = new JsonSerializerOptions { WriteIndented = true };

            // ── All system info ──
            Console.WriteLine("=== System Info ===");
            var ir = await client.GetAsync("/api/v1/info?all");
            ir.EnsureSuccessStatusCode();

            using var idoc = await NvrClient.ReadJsonAsync(ir);
            Console.WriteLine(JsonSerializer.Serialize(idoc.RootElement, options));

            // ── Storage info ──
            // v1 uses /api/v1/system/info?item=storage
            Console.WriteLine("\n=== Storage Info ===");
            var sr = await client.GetAsync("/api/v1/system/info?item=storage");
            sr.EnsureSuccessStatusCode();

            using var sdoc = await NvrClient.ReadJsonAsync(sr);
            // Response field is 'disk'
            if (sdoc.RootElement.TryGetProperty("disk", out var disk))
            {
                if (disk.ValueKind == JsonValueKind.Array)
                {
                    foreach (var d in disk.EnumerateArray())
                    {
                        Console.WriteLine($"  Disk: {JsonSerializer.Serialize(d, options)}");
                    }
                }
                else
                {
                    Console.WriteLine($"  disk: {JsonSerializer.Serialize(disk, options)}");
                }
            }
            else
            {
                Console.WriteLine(JsonSerializer.Serialize(sdoc.RootElement, options));
            }

            // ── System health ──
            Console.WriteLine("\n=== System Health ===");
            var hr = await client.GetAsync("/api/v1/system/health");
            hr.EnsureSuccessStatusCode();

            using var hdoc = await NvrClient.ReadJsonAsync(hr);
            Console.WriteLine(JsonSerializer.Serialize(hdoc.RootElement, options));
        }
    }
}
