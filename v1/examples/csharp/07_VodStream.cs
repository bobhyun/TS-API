// 07_VodStream.cs - v1 API VOD (Recorded Video) Stream Example
//
// Endpoints:
//   GET /api/v1/vod  -> [{chid, title, src: [{protocol, profile, src, type, label, size}]}]
//
// Note: Response field is 'src' (NOT 'streams').

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class VodStream
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

            Console.WriteLine("=== VOD Stream List ===");
            var r = await client.GetAsync("/api/v1/vod");
            r.EnsureSuccessStatusCode();

            using var doc = await NvrClient.ReadJsonAsync(r);
            foreach (var vod in doc.RootElement.EnumerateArray())
            {
                var chid = vod.GetProperty("chid").GetInt32();
                var title = vod.GetProperty("title").GetString();
                Console.WriteLine($"\n  CH{chid}: {title}");

                // Extract stream URLs from src array
                // src: [{protocol, profile, src, type, label, size}, ...]
                if (vod.TryGetProperty("src", out var srcArr))
                {
                    foreach (var s in srcArr.EnumerateArray())
                    {
                        var protocol = s.GetProperty("protocol").GetString();
                        var url = s.GetProperty("src").GetString();
                        var label = s.TryGetProperty("label", out var lbl) ? lbl.GetString() : "";
                        Console.WriteLine($"    {protocol?.ToUpper()}: {url} ({label})");
                    }
                }
            }

            // ── Usage examples ──
            Console.WriteLine("\n=== How to Use Streams ===");
            Console.WriteLine("  RTMP: Play in web browser (flv.js) or VLC");
            Console.WriteLine("  FLV: Play in VLC, ffplay, or other media players");
        }
    }
}
