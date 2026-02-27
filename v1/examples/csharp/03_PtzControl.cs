// 03_PtzControl.cs - v1 API PTZ Control Example
//
// v1 API uses RESTful path style. Channel ID is included in the path.
//
// Endpoints:
//   GET /api/v1/channel/{chid}/ptz?home          - Move to home
//   GET /api/v1/channel/{chid}/ptz?move=x,y      - Pan/tilt
//   GET /api/v1/channel/{chid}/ptz?zoom=z         - Zoom control
//   GET /api/v1/channel/{chid}/ptz?stop           - Stop PTZ
//   GET /api/v1/channel/{chid}/preset             - Preset list
//   GET /api/v1/channel/{chid}/preset/{token}/go  - Go to preset

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class PtzControl
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

            int ch = args.Length > 0 && int.TryParse(args[0], out var c) ? c : 1;
            Console.WriteLine($"Target channel: CH{ch}");

            // ── Get preset list ──
            Console.WriteLine("\n=== Preset List ===");
            var pr = await client.GetAsync($"/api/v1/channel/{ch}/preset");
            if (pr.IsSuccessStatusCode)
            {
                using var pdoc = await NvrClient.ReadJsonAsync(pr);
                if (pdoc.RootElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var preset in pdoc.RootElement.EnumerateArray())
                    {
                        Console.WriteLine($"  {preset}");
                    }
                }
                else
                {
                    Console.WriteLine($"  Response: {pdoc.RootElement}");
                }
            }
            else
            {
                Console.WriteLine($"  Failed: {(int)pr.StatusCode}");
            }

            // ── Move to home ──
            Console.WriteLine("\nMoving to home...");
            var hr = await client.GetAsync($"/api/v1/channel/{ch}/ptz?home");
            Console.WriteLine($"  Result: {(int)hr.StatusCode}");

            await Task.Delay(1000);

            // ── Pan/tilt ──
            // x: -100 ~ 100 (left/right), y: -100 ~ 100 (down/up)
            Console.WriteLine("\nMoving left-down...");
            var mr = await client.GetAsync($"/api/v1/channel/{ch}/ptz?move=-50,-50");
            Console.WriteLine($"  Result: {(int)mr.StatusCode}");

            await Task.Delay(500);

            // ── Stop PTZ ──
            Console.WriteLine("Stopping PTZ...");
            var stop = await client.GetAsync($"/api/v1/channel/{ch}/ptz?stop");
            Console.WriteLine($"  Result: {(int)stop.StatusCode}");

            // ── Zoom ──
            Console.WriteLine("\nZooming out...");
            var zr = await client.GetAsync($"/api/v1/channel/{ch}/ptz?zoom=-30");
            Console.WriteLine($"  Result: {(int)zr.StatusCode}");

            await Task.Delay(500);

            await client.GetAsync($"/api/v1/channel/{ch}/ptz?stop");
            Console.WriteLine("Zoom stopped");
        }
    }
}
