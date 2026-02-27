// 06_LprSearch.cs - v1 API License Plate Recognition Search Example
//
// Endpoints:
//   GET /api/v1/lpr/source                                            - LPR source list
//   GET /api/v1/lpr/log?timeBegin=...&timeEnd=...                     - Plate number search
//   GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...     - Similar plate search
//
// Note: timeBegin and timeEnd are REQUIRED parameters.
//
// WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
//   errors. For bulk exports, narrow the time range or use pagination
//   (at/maxCount) to keep each request under a manageable size.

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class LprSearch
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

            // ── Get LPR sources ──
            Console.WriteLine("=== LPR Sources ===");
            var sr = await client.GetAsync("/api/v1/lpr/source");
            if (!sr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)sr.StatusCode}");
                return;
            }

            using var sdoc = await NvrClient.ReadJsonAsync(sr);
            foreach (var src in sdoc.RootElement.EnumerateArray())
            {
                Console.WriteLine($"  {src}");
            }

            // ── Search plate numbers ──
            var now = DateTime.Now;
            var weekAgo = now.AddDays(-7);
            var timeBegin = weekAgo.ToString("yyyyMMddHHmmss");
            var timeEnd = now.ToString("yyyyMMddHHmmss");

            Console.WriteLine($"\n=== Plate Number Search ===");
            Console.WriteLine($"  Period: {weekAgo:yyyy-MM-dd} ~ {now:yyyy-MM-dd}");

            var lr = await client.GetAsync(
                $"/api/v1/lpr/log?timeBegin={timeBegin}&timeEnd={timeEnd}");
            if (!lr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)lr.StatusCode}");
                return;
            }

            // Response: {totalCount: N, at: N, data: [...]}
            using var ldoc = await NvrClient.ReadJsonAsync(lr);
            var lroot = ldoc.RootElement;
            var results = lroot.TryGetProperty("data", out var dataProp)
                ? dataProp : lroot;
            int totalCount = lroot.TryGetProperty("totalCount", out var tcProp)
                ? tcProp.GetInt32() : results.GetArrayLength();
            Console.WriteLine($"  Results: {totalCount}");

            int shown = 0;
            foreach (var item in results.EnumerateArray())
            {
                if (++shown > 5) break;
                Console.WriteLine($"  [{shown}] {item}");
            }
            if (totalCount > 5)
                Console.WriteLine($"  ... {totalCount - 5} more");

            // ── Similar plate search ──
            string keyword = args.Length > 0 ? args[0] : "1234";
            Console.WriteLine($"\n=== Similar Plate Search (keyword: {keyword}) ===");

            var smr = await client.GetAsync(
                $"/api/v1/lpr/similar?keyword={keyword}&timeBegin={timeBegin}&timeEnd={timeEnd}");
            if (!smr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)smr.StatusCode}");
                return;
            }

            // Response: flat array of plate strings (e.g. ["12A3456", "78B9012"])
            using var smdoc = await NvrClient.ReadJsonAsync(smr);
            var simRoot = smdoc.RootElement;
            var simResults = simRoot.ValueKind == JsonValueKind.Array
                ? simRoot
                : simRoot.TryGetProperty("data", out var simData) ? simData : simRoot;
            Console.WriteLine($"  Results: {simResults.GetArrayLength()}");

            shown = 0;
            foreach (var item in simResults.EnumerateArray())
            {
                if (++shown > 5) break;
                Console.WriteLine($"  [{shown}] {item}");
            }
        }
    }
}
