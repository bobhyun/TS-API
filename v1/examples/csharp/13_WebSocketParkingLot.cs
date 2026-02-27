// 13_WebSocketParkingLot.cs - v1 API WebSocket Parking Lot Count Monitoring
//
// Endpoint:
//   ws://host:port/wsapi/v1/events?topics=parkingCount
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Optional filter: &lot=1,2 (filter by parking lot ID)
//
// See also: 14_WebSocketParkingSpot.cs for individual spot monitoring

using System;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class WebSocketParkingLot
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

            try
            {
                Console.WriteLine("=== WebSocket Parking Count Monitoring (30 seconds) ===");

                // Auth via X-API-Key header
                // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

                // Optional filter: &lot=1,2
                var wsBase = client.BaseUrl.Replace("https://", "wss://").Replace("http://", "ws://");
                var wsUrl = $"{wsBase}/wsapi/v1/events?topics=parkingCount";

                using var ws = new ClientWebSocket();
                ws.Options.RemoteCertificateValidationCallback = (_, _, _, _) => true;
                ws.Options.SetRequestHeader("X-API-Key", client.ApiKey);
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));

                await ws.ConnectAsync(new Uri(wsUrl), cts.Token);
                Console.WriteLine("  Connected! Waiting for parking count events...\n");

                var buffer = new byte[8192];
                var msgCount = 0;

                while (ws.State == WebSocketState.Open)
                {
                    var result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), cts.Token);

                    if (result.MessageType == WebSocketMessageType.Close)
                        break;

                    var json = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    using var doc = JsonDocument.Parse(json);
                    var root = doc.RootElement;
                    msgCount++;

                    // First message is subscription confirmation
                    if (root.TryGetProperty("subscriberId", out var subId))
                    {
                        Console.WriteLine($"  Subscribed (id={subId})");
                        continue;
                    }

                    // parkingCount: {topic, updated: [{id, name, type, maxCount, count}, ...]}
                    if (root.TryGetProperty("updated", out var updated))
                    {
                        foreach (var lot in updated.EnumerateArray())
                        {
                            var id = lot.GetProperty("id").GetInt32();
                            var name = lot.GetProperty("name").GetString();
                            var lotType = lot.TryGetProperty("type", out var t) ? t.GetString() : "";
                            var count = lot.GetProperty("count").GetInt32();
                            var maxCount = lot.GetProperty("maxCount").GetInt32();
                            var available = maxCount - count;
                            Console.WriteLine($"  [{id}] {name} ({lotType}): {count}/{maxCount} (available={available})");
                        }
                    }
                }

                Console.WriteLine($"\n  Received {msgCount} events");
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("\n  Timeout (30 seconds)");
            }
            catch (WebSocketException ex)
            {
                Console.WriteLine($"  WebSocket error: {ex.Message}");
            }
        }
    }
}
