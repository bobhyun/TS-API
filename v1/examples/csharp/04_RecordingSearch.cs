// 04_RecordingSearch.cs - v1 API Recording Search Example
//
// v1 API searches recording data with RESTful path-style endpoints.
//
// Endpoints:
//   GET /api/v1/recording/days?ch={chid}
//       -> List of dates with recordings
//       -> Response: {data: [{chid, data: [{year, month, days: [1,5,...]}]}]}
//   GET /api/v1/recording/minutes?ch={chid}&timeBegin=...&timeEnd=...
//       -> JSON: {data: [{chid, minutes: "010101..."}]}
//       -> minutes: 1440-char string (each char = 1 minute, '0'=no rec, '1'=has rec)

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class RecordingSearch
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

            // ── Get recording days ──
            // When ch= filter is used, response wraps per-channel:
            //   {data: [{chid: 1, data: [{year: 2026, month: 1, days: [1, 5, 10]}]}]}
            Console.WriteLine($"=== CH{ch} Recording Days ===");
            var dr = await client.GetAsync($"/api/v1/recording/days?ch={ch}");
            if (!dr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)dr.StatusCode}");
                return;
            }

            using var ddoc = await NvrClient.ReadJsonAsync(dr);
            var root = ddoc.RootElement;

            if (root.TryGetProperty("timeBegin", out var tb))
                Console.WriteLine($"  Range: {tb} ~ {root.GetProperty("timeEnd")}");

            string lastDay = null;
            int dayCount = 0;

            if (root.TryGetProperty("data", out var data) &&
                data.ValueKind == JsonValueKind.Array)
            {
                foreach (var chEntry in data.EnumerateArray())
                {
                    int chid = chEntry.TryGetProperty("chid", out var chidProp)
                        ? chidProp.GetInt32() : ch;

                    // Nested format: chEntry.data = [{year, month, days}]
                    if (chEntry.TryGetProperty("data", out var months) &&
                        months.ValueKind == JsonValueKind.Array)
                    {
                        foreach (var m in months.EnumerateArray())
                        {
                            int year = m.GetProperty("year").GetInt32();
                            int month = m.GetProperty("month").GetInt32();
                            var days = m.GetProperty("days");
                            Console.WriteLine($"  CH{chid}: {year}-{month:D2} ({days.GetArrayLength()} days)");

                            foreach (var d in days.EnumerateArray())
                            {
                                lastDay = $"{year}-{month:D2}-{d.GetInt32():D2}";
                                dayCount++;
                            }
                        }
                    }
                }
            }

            if (dayCount == 0)
            {
                Console.WriteLine("  No recording data found");
                return;
            }

            // ── Get recording minutes ──
            // Response: {data: [{chid: 1, minutes: "010101..."}]}
            if (lastDay != null)
            {
                var timeBegin = $"{lastDay}T00:00:00";
                var timeEnd = $"{lastDay}T23:59:59";

                Console.WriteLine($"\n=== CH{ch} {lastDay} Recording Minutes ===");
                var mr = await client.GetAsync(
                    $"/api/v1/recording/minutes?ch={ch}&timeBegin={timeBegin}&timeEnd={timeEnd}");
                if (!mr.IsSuccessStatusCode)
                {
                    Console.WriteLine($"  Failed: {(int)mr.StatusCode}");
                    return;
                }

                using var mdoc = await NvrClient.ReadJsonAsync(mr);
                var mroot = mdoc.RootElement;

                if (mroot.TryGetProperty("data", out var mdata) &&
                    mdata.ValueKind == JsonValueKind.Array)
                {
                    foreach (var entry in mdata.EnumerateArray())
                    {
                        int chid = entry.TryGetProperty("chid", out var cidProp)
                            ? cidProp.GetInt32() : ch;
                        string minuteStr = entry.TryGetProperty("minutes", out var minProp)
                            ? minProp.GetString() ?? "" : "";

                        if (minuteStr.Length >= 1440)
                        {
                            int totalMinutes = 0;
                            for (int i = 0; i < 1440; i++)
                            {
                                if (minuteStr[i] != '0') totalMinutes++;
                            }
                            Console.WriteLine($"  CH{chid} Total: {totalMinutes}min ({totalMinutes / 60}h {totalMinutes % 60}m)");

                            Console.WriteLine("\n  Recording by time block:");
                            for (int block = 0; block < 6; block++)
                            {
                                int startMin = block * 240;
                                int blockTotal = 0;
                                for (int i = startMin; i < startMin + 240 && i < 1440; i++)
                                {
                                    if (minuteStr[i] != '0') blockTotal++;
                                }
                                int startH = block * 4;
                                int endH = startH + 4;
                                var bar = new string('#', blockTotal * 20 / 240);
                                Console.WriteLine($"    {startH:D2}:00~{endH:D2}:00  [{bar,-20}] {blockTotal}/240min");
                            }
                        }
                        else
                        {
                            Console.WriteLine($"  CH{chid} minutes length: {minuteStr.Length} (expected 1440)");
                        }
                    }
                }
            }
        }
    }
}
