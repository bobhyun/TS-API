// 09_Push.cs - v1 API Push Notification Example
//
// Send events from an external system to the NVR.
//
// Endpoints:
//   POST /api/v1/push  - Send push event
//
// Supported topics:
//   - "LPR": License plate recognition event
//   - "emergencyCall": Emergency call event
//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !! WARNING:                                                       !!
// !! emergencyCall with callStart triggers an ACTUAL alarm!         !!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//
// Prerequisite: Push license must be enabled.

using System;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class Push
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

            // ── Send LPR event ──
            Console.WriteLine("=== Sending LPR Push Event ===");

            var lprEvent = new
            {
                topic = "LPR",
                src = "ExternalCam1",           // Source name
                plateNo = "12A3456",            // Plate number
                when = DateTime.Now.ToString("yyyyMMddHHmmss")
            };

            var lr = await client.PostJsonAsync("/api/v1/push", lprEvent);
            Console.WriteLine($"  Status: {(int)lr.StatusCode} {lr.StatusCode}");
            var lBody = await NvrClient.ReadStringAsync(lr);
            if (!string.IsNullOrEmpty(lBody))
                Console.WriteLine($"  Response: {lBody}");

            // ── Emergency call event ──
            Console.WriteLine("\n=== Emergency Call Event ===");
            Console.WriteLine("  WARNING: callStart triggers a real alarm!");

            // callStart example - triggers real alarm!
            var callStart = new
            {
                topic = "emergencyCall",
                device = "intercom-01",
                src = "Lobby",
                @event = "callStart",
                camera = 1
            };
            Console.WriteLine("  (callStart is commented out)");
            // Uncomment to trigger actual alarm!
            // var csr = await client.PostJsonAsync("/api/v1/push", callStart);
            // Console.WriteLine($"  callStart status: {(int)csr.StatusCode}");

            // callEnd example - end alarm
            var callEnd = new
            {
                topic = "emergencyCall",
                device = "intercom-01",
                src = "Lobby",
                @event = "callEnd",
                camera = 1
            };

            Console.WriteLine("  Sending callEnd...");
            var cer = await client.PostJsonAsync("/api/v1/push", callEnd);
            Console.WriteLine($"  Status: {(int)cer.StatusCode} {cer.StatusCode}");
        }
    }
}
