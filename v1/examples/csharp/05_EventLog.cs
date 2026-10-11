// 05_EventLog.cs - v1 API Event Log Example
//
// Query event types and event log via RESTful paths.
//
// Endpoints:
//   GET /api/v1/event/type                        - Event type list
//   GET /api/v1/event/log?maxCount=10&sort=desc   - Event log
//
// Note: The field name in eventType response is 'id' (NOT 'type').

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class EventLog
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

            // ── Get event types ──
            Console.WriteLine("=== Event Types ===");
            var tr = await client.GetAsync("/api/v1/event/type");
            if (!tr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)tr.StatusCode}");
                return;
            }

            using var tdoc = await NvrClient.ReadJsonAsync(tr);
            foreach (var evType in tdoc.RootElement.EnumerateArray())
            {
                var id = evType.GetProperty("id").GetInt32();
                var name = evType.GetProperty("name").GetString();
                Console.WriteLine($"  Event ID={id}: {name}");

                if (evType.TryGetProperty("code", out var codes))
                {
                    foreach (var code in codes.EnumerateArray())
                    {
                        var codeId = code.GetProperty("id").GetInt32();
                        var codeName = code.GetProperty("name").GetString();
                        Console.WriteLine($"    Code ID={codeId}: {codeName}");
                    }
                }
            }

            // ── Recent event log ──
            Console.WriteLine("\n=== Recent Event Log ===");
            var lr = await client.GetAsync("/api/v1/event/log?maxCount=10&sort=desc");
            if (!lr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)lr.StatusCode}");
                return;
            }

            using var ldoc = await NvrClient.ReadJsonAsync(lr);
            // 로그는 목록 봉투다: { totalCount, at, data: [...] }. 루트는 배열이 아니다.
            var levents = ldoc.RootElement.TryGetProperty("data", out var ldata)
                ? ldata : ldoc.RootElement;
            foreach (var evt in levents.EnumerateArray())
            {
                Console.WriteLine($"  {evt}");
            }

            // ── Time range + event type filter ──
            var today = DateTime.Today;
            var timeBegin = today.ToString("yyyyMMdd") + "000000";
            var timeEnd = today.ToString("yyyyMMdd") + "235959";

            Console.WriteLine($"\n=== Today's Events ({today:yyyy-MM-dd}) ===");
            var dr = await client.GetAsync(
                $"/api/v1/event/log?timeBegin={timeBegin}&timeEnd={timeEnd}&maxCount=20&sort=desc");
            if (!dr.IsSuccessStatusCode)
            {
                Console.WriteLine($"  Failed: {(int)dr.StatusCode}");
                return;
            }

            using var ddoc = await NvrClient.ReadJsonAsync(dr);
            // 위와 같은 목록 봉투다: { totalCount, at, data: [...] }.
            var devents = ddoc.RootElement.TryGetProperty("data", out var ddata)
                ? ddata : ddoc.RootElement;
            Console.WriteLine($"  Event count: {devents.GetArrayLength()}");
            foreach (var evt in devents.EnumerateArray())
            {
                Console.WriteLine($"  {evt}");
            }
        }
    }
}
