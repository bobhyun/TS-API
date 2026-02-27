// 10_Parking.cs - v1 API Parking Management Example
//
// Query parking lot and parking spot information and status.
//
// Endpoints:
//   GET /api/v1/parking/lot          - Parking lot list
//   GET /api/v1/parking/lot/status   - Lot status (occupancy)
//   GET /api/v1/parking/spot         - Parking spot list
//   GET /api/v1/parking/spot/status  - Spot status
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
        }
    }
}
