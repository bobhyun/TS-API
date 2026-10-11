// 10_Parking.cs - v1 API Parking Management Example
//
// Query parking lot and parking spot information and status.
//
// Endpoints:
//   GET /api/v1/parking/lot          - Parking lot list
//   GET /api/v1/parking/lot/status   - Lot status (occupancy)
//   GET /api/v1/parking/spot         - Parking spot list
//   GET /api/v1/parking/spot/status  - Spot status
//   GET /api/v1/info?license         - License check (parkingHistory extension token)
//   GET /api/v1/parking/session      - Parking session history
//
// Note: v0 API does not have parking-related endpoints.

using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class Parking
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

            // ── Parking lot list ──
            Console.WriteLine("=== Parking Lot List ===");
            var lr = await client.GetAsync("/api/v1/parking/lot");
            if (lr.IsSuccessStatusCode)
            {
                using var ldoc = await NvrClient.ReadJsonAsync(lr);
                foreach (var lot in ldoc.RootElement.EnumerateArray())
                {
                    Console.WriteLine($"  {JsonSerializer.Serialize(lot, options)}");
                }
            }
            else
            {
                Console.WriteLine($"  Response: {(int)lr.StatusCode} {lr.StatusCode}");
                Console.WriteLine("  Parking feature may not be configured.");
            }

            // ── Parking lot status (occupancy) ──
            Console.WriteLine("\n=== Parking Lot Status ===");
            var lsr = await client.GetAsync("/api/v1/parking/lot/status");
            if (lsr.IsSuccessStatusCode)
            {
                using var lsdoc = await NvrClient.ReadJsonAsync(lsr);
                foreach (var status in lsdoc.RootElement.EnumerateArray())
                {
                    Console.WriteLine($"  {JsonSerializer.Serialize(status, options)}");
                }
            }
            else
            {
                Console.WriteLine($"  Response: {(int)lsr.StatusCode}");
            }

            // ── Parking spot list ──
            Console.WriteLine("\n=== Parking Spot List ===");
            var spr = await client.GetAsync("/api/v1/parking/spot");
            if (spr.IsSuccessStatusCode)
            {
                using var spdoc = await NvrClient.ReadJsonAsync(spr);
                var spots = spdoc.RootElement;
                Console.WriteLine($"  Total spots: {spots.GetArrayLength()}");

                // Show up to 10
                int shown = 0;
                foreach (var spot in spots.EnumerateArray())
                {
                    if (++shown > 10) break;
                    Console.WriteLine($"  [{shown}] {JsonSerializer.Serialize(spot)}");
                }
                if (spots.GetArrayLength() > 10)
                    Console.WriteLine($"  ... {spots.GetArrayLength() - 10} more");
            }
            else
            {
                Console.WriteLine($"  Response: {(int)spr.StatusCode}");
            }

            // ── Parking spot status ──
            Console.WriteLine("\n=== Parking Spot Status ===");
            var ssr = await client.GetAsync("/api/v1/parking/spot/status");
            if (ssr.IsSuccessStatusCode)
            {
                using var ssdoc = await NvrClient.ReadJsonAsync(ssr);
                var spotStatuses = ssdoc.RootElement;
                Console.WriteLine($"  Total: {spotStatuses.GetArrayLength()}");

                // Count occupied/vacant
                int occupied = 0, vacant = 0, unknown = 0;
                foreach (var s in spotStatuses.EnumerateArray())
                {
                    if (s.TryGetProperty("occupied", out var occ))
                    {
                        if (occ.GetBoolean()) occupied++;
                        else vacant++;
                    }
                    else
                    {
                        unknown++;
                    }
                }
                Console.WriteLine($"  Occupied: {occupied}");
                Console.WriteLine($"  Vacant: {vacant}");
                if (unknown > 0)
                    Console.WriteLine($"  Unknown: {unknown}");
            }
            else
            {
                Console.WriteLine($"  Response: {(int)ssr.StatusCode}");
            }

            // --- Parking Session History ---
            // A session opens when a vehicle is confirmed present and closes when it is
            // gone. Needs the parking history license - 403 without it. Ask /api/v1/info
            // first: the "parkingHistory" extension token says whether the session
            // endpoints will answer (the array is omitted when no extension is active).
            var hasParkingHistory = false;
            var ir = await client.GetAsync("/api/v1/info?license");
            if (ir.IsSuccessStatusCode)
            {
                using var idoc = await NvrClient.ReadJsonAsync(ir);
                if (idoc.RootElement.TryGetProperty("license", out var lic) &&
                    lic.TryGetProperty("extension", out var ext))
                {
                    foreach (var token in ext.EnumerateArray())
                        if (token.GetString() == "parkingHistory") hasParkingHistory = true;
                }
            }
            if (!hasParkingHistory)
            {
                Console.WriteLine();
                Console.WriteLine("parking history license not found (no 'parkingHistory' in license.extension) - skipping session examples");
                return;
            }

            Console.WriteLine();
            Console.WriteLine("=== Currently Parked ===");
            var opr = await client.GetAsync("/api/v1/parking/session?open=true&maxCount=10");
            if (opr.IsSuccessStatusCode)
            {
                using var opdoc = await NvrClient.ReadJsonAsync(opr);
                var root = opdoc.RootElement;
                Console.WriteLine($"  total={root.GetProperty("totalCount").GetInt64()} asOf={root.GetProperty("asOf").GetString()}");
                foreach (var row in root.GetProperty("data").EnumerateArray())
                {
                    var mins = row.GetProperty("durationMs").GetInt64() / 60000;
                    var plateEl = row.GetProperty("plateNo");
                    var plate = plateEl.ValueKind == JsonValueKind.Null ? "(no plate)" : plateEl.GetString();
                    Console.WriteLine($"  [{row.GetProperty("id").GetInt64()}] {row.GetProperty("src").GetProperty("name").GetString()} {plate} {mins}m");
                }
            }
            else
            {
                Console.WriteLine($"  Response: {(int)opr.StatusCode}");
            }

            // --- Session Detail ---
            // outKind / outTimeMeans say HOW the exit time was decided. Only "observed"
            // is a measurement; the others are estimates whose error leans in different
            // directions, so bill from the basis, not from the number alone.
            //
            // inKind / inTimeMeans do the same for the entry, and the error leans the
            // OTHER way: firstSeen is an UPPER bound on the real entry (already there
            // when observation started). It is present on OPEN sessions too.
            Console.WriteLine();
            Console.WriteLine("=== Session Detail ===");
            var onr = await client.GetAsync("/api/v1/parking/session?maxCount=1");
            long sessionId = 0;
            if (onr.IsSuccessStatusCode)
            {
                using var ondoc = await NvrClient.ReadJsonAsync(onr);
                foreach (var row in ondoc.RootElement.GetProperty("data").EnumerateArray())
                {
                    sessionId = row.GetProperty("id").GetInt64();
                    break;
                }
            }
            if (sessionId > 0)
            {
                var dtr = await client.GetAsync($"/api/v1/parking/session/{sessionId}");
                if (dtr.IsSuccessStatusCode)
                {
                    using var dtdoc = await NvrClient.ReadJsonAsync(dtr);
                    var d = dtdoc.RootElement;
                    Console.WriteLine($"  {d.GetRawText()}");
                    Console.WriteLine($"  entry basis: {d.GetProperty("inKind").GetString()} ({d.GetProperty("inTimeMeans").GetString()})");
                    if (!d.GetProperty("open").GetBoolean())
                        Console.WriteLine($"  exit basis: {d.GetProperty("outKind").GetString()} ({d.GetProperty("outTimeMeans").GetString()})");
                }
            }
            else
            {
                Console.WriteLine("  (no sessions yet)");
            }

            // --- Scope: what the query is scoped to ---
            // Items omitted means "the whole scope", which is NOT the same as no
            // filter: scope=lot with no lot returns only sessions that belong to a
            // parking lot, so no-parking-zone history is excluded.
            Console.WriteLine("\n=== Scope ===");
            foreach (var qs in new[] { "scope=channel&ch=1,2", "scope=lot", "scope=noparking" })
            {
                var sr = await client.GetAsync($"/api/v1/parking/session?{qs}&maxCount=5");
                Console.WriteLine($"  {qs} => {(int)sr.StatusCode}");
            }

            // --- Video for a session: otherwise=nearBefore ---
            // A parked car does not move, so motion-triggered recording may have
            // stopped while it was still there. The car is in the same place, so the
            // preceding footage still shows the situation. Parking history only.
            // An empty result means there is no usable recording at all (never
            // recorded, or already recycled); the snapshots remain available.
            Console.WriteLine("\n=== Video at entry time (nearest earlier if none) ===");
            var vr = await client.GetAsync(
                "/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore");
            Console.WriteLine($"  => {(int)vr.StatusCode}");

            // --- Which car is it? the bounding box ---
            // A snapshot can hold several cars. `box` points at the one this
            // session is about. YOLO style: center based, all four values 0..1
            // (see 1.2), so you multiply by the size of whatever you draw on.
            // Entrance/exit sessions carry no vehicle box (a single plate read)
            // and the value is null; the key is always present.
            Console.WriteLine("\n=== Bounding box of the session vehicle ===");
            var bsr = await client.GetAsync("/api/v1/parking/session?maxCount=1");
            if (bsr.IsSuccessStatusCode)
            {
                using var bdoc = await NvrClient.ReadJsonAsync(bsr);
                var brows = bdoc.RootElement.GetProperty("data");
                if (brows.GetArrayLength() > 0)
                {
                    var sid = brows[0].GetProperty("id").GetInt64();
                    var dr = await client.GetAsync($"/api/v1/parking/session/{sid}");
                    using var ddoc = await NvrClient.ReadJsonAsync(dr);
                    if (ddoc.RootElement.TryGetProperty("box", out var box) &&
                        box.ValueKind == JsonValueKind.Object)
                    {
                        double cx = box.GetProperty("cx").GetDouble();
                        double cy = box.GetProperty("cy").GetDouble();
                        double bw = box.GetProperty("w").GetDouble();
                        double bh = box.GetProperty("h").GetDouble();
                        const int W = 1920, H = 1080;   // 그릴 대상 크기
                        Console.WriteLine($"  box = cx={cx} cy={cy} w={bw} h={bh}");
                        Console.WriteLine($"  on {W}x{H} -> left={(int)((cx - bw / 2) * W)} " +
                            $"top={(int)((cy - bh / 2) * H)} width={(int)(bw * W)} height={(int)(bh * H)}");
                    }
                    else Console.WriteLine("  (no box for this session)");
                }
            }

            // --- Writing history (Control permission) ---
            // Both change stored history, so they are not executed here.
            // Payment state (16.7): commit settles it, exempt records a decision not to
            // collect, undo reverts the most recent change (the response says which one).
            // Records are appended, never deleted.
            //
            // close (16.8) is a different axis: it clears the lingering "parked" state left
            // when an exit was never observed. Exempt takes a session out of billing and may
            // leave it parked; close ends the session. Do not conflate the two.
            //
            //   await client.PostAsync($"/api/v1/parking/session/{sessionId}/payment/commit?ref=POS-0042", null);
            //   await client.PostAsync($"/api/v1/parking/session/{sessionId}/payment/exempt", null);
            //   await client.PostAsync($"/api/v1/parking/session/{sessionId}/payment/undo", null);
            //   await client.PostAsync($"/api/v1/parking/session/{sessionId}/close", null);
        }
    }
}
