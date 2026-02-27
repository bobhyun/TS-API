// 14_WebSocketParkingSpot.cs - v1 API WebSocket Parking Spot Monitoring
//
// Endpoint:
//   ws://host:port/wsapi/v1/events?topics=parkingSpot
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Optional filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
//
// Events:
//   currentStatus  - initial full state on connect
//   statusChanged  - only changed spots

using System;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class WebSocketParkingSpot
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
                Console.WriteLine("=== WebSocket Parking Spot Monitoring (30 seconds) ===");

                // Auth via X-API-Key header
                // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

                // Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
                var wsBase = client.BaseUrl.Replace("https://", "wss://").Replace("http://", "ws://");
                var wsUrl = $"{wsBase}/wsapi/v1/events?topics=parkingSpot";

                using var ws = new ClientWebSocket();
                ws.Options.RemoteCertificateValidationCallback = (_, _, _, _) => true;
                ws.Options.SetRequestHeader("X-API-Key", client.ApiKey);
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));

                await ws.ConnectAsync(new Uri(wsUrl), cts.Token);
                Console.WriteLine("  Connected! Waiting for spot events...\n");

                var buffer = new byte[65536]; // larger buffer for currentStatus
                var msgCount = 0;

                while (ws.State == WebSocketState.Open)
                {
                    var result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), cts.Token);

                    if (result.MessageType == WebSocketMessageType.Close)
                        break;

                    var json = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    using var doc = JsonDocument.Parse(json);
                    var root = doc.RootElement;

                    // First message is subscription confirmation
                    if (root.TryGetProperty("subscriberId", out var subId))
                    {
                        Console.WriteLine($"  Subscribed (id={subId})");
                        continue;
                    }

                    if (!root.TryGetProperty("event", out var evtProp))
                        continue;
                    var evt = evtProp.GetString();
                    if (!root.TryGetProperty("spots", out var spots))
                        continue;
                    msgCount++;

                    if (evt == "currentStatus")
                    {
                        Console.WriteLine($"  [currentStatus] {spots.GetArrayLength()} spots");
                        foreach (var spot in spots.EnumerateArray())
                        {
                            var spotId = spot.TryGetProperty("id", out var idEl) ? idEl.GetInt32() : 0;
                            var spotName = spot.TryGetProperty("name", out var nameEl) ? nameEl.GetString() : "";
                            var category = spot.TryGetProperty("category", out var catEl) ? catEl.GetString() : "";
                            var occupied = spot.TryGetProperty("occupied", out var occEl) && occEl.GetBoolean();
                            if (occupied && spot.TryGetProperty("vehicle", out var v)
                                && v.ValueKind == JsonValueKind.Object)
                            {
                                var plateNo = v.TryGetProperty("plateNo", out var pEl) ? pEl.GetString() : "";
                                var score = v.TryGetProperty("score", out var sEl) ? sEl.GetDouble() : 0;
                                Console.WriteLine($"    [{spotId}] {spotName} ({category}): occupied [{plateNo} {score:F1}%]");
                            }
                            else
                            {
                                Console.WriteLine($"    [{spotId}] {spotName} ({category}): {(occupied ? "occupied" : "empty")}");
                            }
                        }
                    }
                    else if (evt == "statusChanged")
                    {
                        foreach (var spot in spots.EnumerateArray())
                        {
                            var spotId = spot.TryGetProperty("id", out var idEl) ? idEl.GetInt32() : 0;
                            var occupied = spot.TryGetProperty("occupied", out var occEl) && occEl.GetBoolean();
                            Console.WriteLine($"  [statusChanged] spot {spotId} -> {(occupied ? "occupied" : "empty")}");
                            if (occupied && spot.TryGetProperty("vehicle", out var v)
                                && v.ValueKind == JsonValueKind.Object)
                            {
                                var plateNo = v.TryGetProperty("plateNo", out var pEl) ? pEl.GetString() : "";
                                var score = v.TryGetProperty("score", out var sEl) ? sEl.GetDouble() : 0;
                                Console.WriteLine($"    plate: {plateNo}  score: {score:F1}%");
                            }
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
