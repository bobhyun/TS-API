// 06_LprSearch.cs - v1 API License Plate Recognition Search Example
//
// Endpoints:
//   GET /api/v1/lpr/source                                            - LPR source list
//   GET /api/v1/lpr/log?timeBegin=...&timeEnd=...                     - Plate number search
//   GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...     - Similar plate search
//   GET /api/v1/lpr/log/{id}/plate/history                            - Plate correction history (Playback)
//   POST /api/v1/lpr/log/{id}/plate                                   - Correct one record's plate (Control, not executed here)
//
// Note: timeBegin and timeEnd are REQUIRED parameters.
//
// WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
//   Narrow the time range or page with at/maxCount.

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
            long firstId = 0;
            foreach (var item in results.EnumerateArray())
            {
                if (++shown > 5) break;
                // plateNo is null when no plate was read; direction is "entry"/"exit" or absent
                long id = item.GetProperty("id").GetInt64();
                if (firstId == 0) firstId = id;
                var plateNo = item.TryGetProperty("plateNo", out var pn) && pn.ValueKind == JsonValueKind.String && pn.GetString() != ""
                    ? pn.GetString() : "(unrecognized)";
                var direction = item.TryGetProperty("direction", out var dir) ? dir.GetString() : "-";
                var line = $"  [{id}] plateNo={plateNo} direction={direction}";
                if (item.TryGetProperty("plateEdited", out var pe) && pe.GetBoolean())
                {
                    var orig = item.TryGetProperty("originalPlateNo", out var op) ? op.GetString() : "";
                    line += $" (corrected, originally {(string.IsNullOrEmpty(orig) ? "(unrecognized)" : orig)})";
                }
                Console.WriteLine(line);
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

            // Response: array of plate strings, most recent first (e.g. ["12A3456", "78B9012"])
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

            // ── Plate correction history (one record, by id) ──
            // plateNo in the log is always the current value.
            // edits[] lists corrections in recorded order; it is empty if the record was never corrected.
            if (firstId > 0)
            {
                Console.WriteLine($"\n=== Plate Correction History (id={firstId}) ===");
                var hr = await client.GetAsync($"/api/v1/lpr/log/{firstId}/plate/history");
                if (hr.IsSuccessStatusCode)
                {
                    using var hdoc = await NvrClient.ReadJsonAsync(hr);
                    var h = hdoc.RootElement;
                    var orig = h.TryGetProperty("originalPlateNo", out var op) ? op.GetString() : "(never corrected)";
                    Console.WriteLine($"  plateNo={h.GetProperty("plateNo").GetString()} original={orig}");
                    foreach (var e in h.GetProperty("edits").EnumerateArray())
                    {
                        Console.WriteLine($"    {e.GetProperty("time").GetString()} {e.GetProperty("user").GetString()}: " +
                            $"{e.GetProperty("before").GetString()} -> {e.GetProperty("after").GetString()} " +
                            $"{e.GetProperty("reason").GetString()}");
                    }
                }
                else
                {
                    Console.WriteLine($"  Failed: {(int)hr.StatusCode}");
                }
            }

            // ── Plate correction (Control permission) ──
            // Changes the stored record, so it is not executed here. The target is always
            // one record id - from data[].id above, or the id a realtime LPR event carries
            // next to each plateNo. 409 when plateNo equals the current plate.
            //
            // Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
            // Uncomment it to try it against a test record.
            //   await client.PostJsonAsync($"/api/v1/lpr/log/{firstId}/plate",
            //       new { plateNo = "12가3456", reason = "misread at night" });
        }
    }
}
