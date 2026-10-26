// 08_SystemInfo.cs - v1 API System Info Example
//
// Endpoints:
//   GET /api/v1/info?all                     - All system info
//   GET /api/v1/system/info?item=storage     - Storage info
//   GET /api/v1/system/health                - System health
//   GET /api/v1/system/health?item=systemDisk - System disk (database and logs) status
//   GET /api/v1/system/notices?lang=ko-KR    - Notices currently in effect
//
// Note: item=storage returns its data in the 'disk' field (NOT 'storage').

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

            // ── System disk ──
            // Holds the database and logs (normally C:), separate from the recording disks.
            // When it is full, records stop being saved even if the recording disks have room.
            // Watch status here, not only disk[].
            Console.WriteLine("\n=== System Disk ===");
            var dr = await client.GetAsync("/api/v1/system/health?item=systemDisk");
            dr.EnsureSuccessStatusCode();

            using var ddoc = await NvrClient.ReadJsonAsync(dr);
            var sd = ddoc.RootElement.GetProperty("systemDisk");
            Console.WriteLine($"  drive={sd.GetProperty("drive").GetString()} " +
                $"free={sd.GetProperty("freeSpace").GetInt64()}/{sd.GetProperty("totalSpace").GetInt64()} " +
                $"status={sd.GetProperty("status").GetString()} " +
                $"dataWriteFailed={sd.GetProperty("dataWriteFailed").GetBoolean()}");

            // ── System notices ──
            // Conditions in effect right now (raised, updated, cleared).
            // message is keyed by language code: en-US is always present,
            // plus the requested lang when it is not English.
            Console.WriteLine("\n=== System Notices ===");
            var lang = "ko-KR";
            var nr = await client.GetAsync($"/api/v1/system/notices?lang={lang}");
            nr.EnsureSuccessStatusCode();

            using var ndoc = await NvrClient.ReadJsonAsync(nr);
            if (ndoc.RootElement.GetArrayLength() == 0)
                Console.WriteLine("  (no notices)");
            foreach (var n in ndoc.RootElement.EnumerateArray())
            {
                var msg = n.GetProperty("message");
                var text = msg.TryGetProperty(lang, out var t) ? t.GetString() : msg.GetProperty("en-US").GetString();
                Console.WriteLine($"  [{n.GetProperty("severity").GetString()}] {n.GetProperty("kind").GetString()}: {text}");
            }
        }
    }
}
