// 12_WebSocketEvents.cs - v1 API WebSocket Real-time Event Subscription Example
//
// Subscribes to real-time events (LPR, channelStatus, notice, etc.) via WebSocket.
//
// Two subscription modes:
//   1. URL query params:  ?topics=LPR,channelStatus,notice  (subscribe on connect)
//   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
//
// Endpoint:
//   ws://host:port/wsapi/v1/events
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)

using System;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class WebSocketEvents
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

            var wsUrl = client.BaseUrl.Replace("https://", "wss://").Replace("http://", "ws://");

            // ── Method 1: Subscribe via URL query params (classic) ──
            Console.WriteLine("=== Method 1: Subscribe via URL (10 seconds) ===");

            {
                var url = $"{wsUrl}/wsapi/v1/events?topics=LPR,channelStatus,notice&lang={Lang}";
                using var ws = new ClientWebSocket();
                ws.Options.RemoteCertificateValidationCallback = (_, _, _, _) => true;
                ws.Options.SetRequestHeader("X-API-Key", client.ApiKey);
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));

                await ws.ConnectAsync(new Uri(url), cts.Token);
                Console.WriteLine("  Connected!");

                var buffer = new byte[4096];
                var messageCount = 0;

                try
                {
                    while (ws.State == WebSocketState.Open)
                    {
                        var result = await ws.ReceiveAsync(
                            new ArraySegment<byte>(buffer), cts.Token);

                        if (result.MessageType == WebSocketMessageType.Close)
                            break;

                        var data = Encoding.UTF8.GetString(buffer, 0, result.Count);
                        messageCount++;

                        try
                        {
                            using var doc = JsonDocument.Parse(data);
                            var topic = doc.RootElement.TryGetProperty("topic", out var t)
                                ? t.GetString()
                                : doc.RootElement.TryGetProperty("type", out var tp)
                                    ? tp.GetString() : "?";
                            PrintEvent(topic, doc.RootElement, data);
                        }
                        catch
                        {
                            Console.WriteLine($"  Raw: {data}");
                        }
                    }
                }
                catch (OperationCanceledException) { }

                Console.WriteLine($"  Received {messageCount} events");

                if (ws.State == WebSocketState.Open)
                    await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "", CancellationToken.None);
            }

            // ── Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) ──
            //   - Connect WITHOUT topics
            //   - Subscribe/unsubscribe at any time
            //   - Per-topic filters (ch, objectTypes, lot, spot)
            //   - Re-subscribe to update filters
            Console.WriteLine("\n=== Method 2: Dynamic Subscribe (10 seconds) ===");

            {
                var url = $"{wsUrl}/wsapi/v1/events";
                using var ws = new ClientWebSocket();
                ws.Options.RemoteCertificateValidationCallback = (_, _, _, _) => true;
                ws.Options.SetRequestHeader("X-API-Key", client.ApiKey);
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));

                await ws.ConnectAsync(new Uri(url), cts.Token);
                Console.WriteLine("  Connected (no topics yet)");

                // Phase 1: Subscribe to initial topics with per-topic filters
                Console.WriteLine("  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)");
                await SendJson(ws, new { subscribe = "channelStatus" }, cts.Token);
                await SendJson(ws, new { subscribe = "LPR", ch = new[] { 1, 2 } }, cts.Token);

                var buffer = new byte[4096];
                var messageCount = 0;

                // Schedule mid-connection topic changes
                _ = Task.Run(async () =>
                {
                    // Phase 2 (3s): Add new topic + update existing filter
                    await Task.Delay(3000);
                    if (ws.State == WebSocketState.Open)
                    {
                        Console.WriteLine("  [Phase 2] Add object topic + expand LPR to ch 1-4");
                        await SendJson(ws, new { subscribe = "object", objectTypes = new[] { "human", "vehicle" } }, cts.Token);
                        await SendJson(ws, new { subscribe = "LPR", ch = new[] { 1, 2, 3, 4 } }, cts.Token);
                    }

                    // Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
                    await Task.Delay(3000);
                    if (ws.State == WebSocketState.Open)
                    {
                        Console.WriteLine("  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3");
                        await SendJson(ws, new { unsubscribe = "channelStatus" }, cts.Token);
                        await SendJson(ws, new { subscribe = "motionChanges", ch = new[] { 1 } }, cts.Token);
                        await SendJson(ws, new { subscribe = "LPR", ch = new[] { 1, 3 } }, cts.Token);  // re-subscribe replaces the filter (drops ch 2,4)
                    }
                });

                try
                {
                    while (ws.State == WebSocketState.Open)
                    {
                        var result = await ws.ReceiveAsync(
                            new ArraySegment<byte>(buffer), cts.Token);

                        if (result.MessageType == WebSocketMessageType.Close)
                            break;

                        var data = Encoding.UTF8.GetString(buffer, 0, result.Count);
                        messageCount++;

                        try
                        {
                            using var doc = JsonDocument.Parse(data);

                            // Handle control responses
                            if (doc.RootElement.TryGetProperty("type", out var typeProp))
                            {
                                var type = typeProp.GetString();
                                var topic = doc.RootElement.TryGetProperty("topic", out var tp)
                                    ? tp.GetString() : "";

                                if (type == "subscribed")
                                {
                                    Console.WriteLine($"  Subscribed to: {topic}");
                                    continue;
                                }
                                if (type == "unsubscribed")
                                {
                                    Console.WriteLine($"  Unsubscribed from: {topic}");
                                    continue;
                                }
                                if (type == "error")
                                {
                                    var msg = doc.RootElement.TryGetProperty("message", out var m)
                                        ? m.GetString() : "";
                                    Console.WriteLine($"  Error: {msg} (topic: {topic})");
                                    continue;
                                }
                            }

                            // Handle event data
                            var evTopic = doc.RootElement.TryGetProperty("topic", out var t)
                                ? t.GetString() : "?";
                            PrintEvent(evTopic, doc.RootElement, data);
                        }
                        catch
                        {
                            Console.WriteLine($"  Raw: {data}");
                        }
                    }
                }
                catch (OperationCanceledException) { }

                Console.WriteLine($"  Received {messageCount} messages");

                if (ws.State == WebSocketState.Open)
                    await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "", CancellationToken.None);
            }
        }

        const string Lang = "ko-KR";

        // Print LPR and notice events by field; other topics as raw JSON.
        static void PrintEvent(string topic, JsonElement root, string data)
        {
            if (topic == "LPR")
            {
                // id: record id for plate correction (absent when the record could not be saved)
                // direction: "entry" / "exit" (absent when unknown)
                var plates = root.TryGetProperty("plates", out var arr)
                    ? arr.EnumerateArray().ToArray() : new[] { root };
                foreach (var p in plates)
                {
                    var id = p.TryGetProperty("id", out var i) ? i.GetInt64().ToString() : "-";
                    var plateNo = p.TryGetProperty("plateNo", out var pn) && pn.ValueKind == JsonValueKind.String
                        ? pn.GetString() : "null";
                    var score = p.TryGetProperty("score", out var sc) ? sc.GetDouble() : 0;
                    var direction = p.TryGetProperty("direction", out var d) ? d.GetString() : "-";
                    Console.WriteLine($"  [LPR] id={id} plateNo={plateNo} score={score} direction={direction}");
                }
            }
            else if (topic == "notice")
            {
                // snapshot: current list once after subscribing; raised/updated/cleared: one notice
                // message is keyed by language code: en-US always, plus the requested lang
                var action = root.GetProperty("action").GetString();
                var notices = action == "snapshot"
                    ? root.GetProperty("notices").EnumerateArray().ToArray()
                    : new[] { root.GetProperty("notice") };
                if (notices.Length == 0)
                    Console.WriteLine("  [notice] snapshot: (no notices)");
                foreach (var n in notices)
                {
                    var msg = n.GetProperty("message");
                    var text = msg.TryGetProperty(Lang, out var l) ? l.GetString() : msg.GetProperty("en-US").GetString();
                    Console.WriteLine($"  [notice] {action} {n.GetProperty("id").GetString()} " +
                        $"{n.GetProperty("severity").GetString()}: {text}");
                }
            }
            else
            {
                Console.WriteLine($"  [{topic}] {data}");
            }
        }

        static async Task SendJson(ClientWebSocket ws, object obj, CancellationToken ct)
        {
            var json = JsonSerializer.Serialize(obj);
            var bytes = Encoding.UTF8.GetBytes(json);
            await ws.SendAsync(new ArraySegment<byte>(bytes),
                WebSocketMessageType.Text, true, ct);
        }
    }
}

/*
 * ─────────────────────────────────────────────────
 * LPR Event Compatibility
 * ─────────────────────────────────────────────────
 *
 * LPR events may arrive in two formats:
 *
 *   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
 *   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
 *
 * To handle both formats transparently:
 *
 *   using var doc = JsonDocument.Parse(data);
 *   var root = doc.RootElement;
 *   if (root.TryGetProperty("topic", out var t) && t.GetString() == "LPR")
 *   {
 *       JsonElement[] plates;
 *       if (root.TryGetProperty("plates", out var arr))
 *           plates = arr.EnumerateArray().ToArray();    // v1.0.1 batch format
 *       else
 *           plates = new[] { root };                    // v1.0.0 single-plate format
 *
 *       foreach (var p in plates)
 *       {
 *           var plateNo = p.TryGetProperty("plateNo", out var pn) ? pn.GetString() : "";
 *           var score = p.TryGetProperty("score", out var sc) ? sc.GetDouble() : 0;
 *           Console.WriteLine($"Plate: {plateNo}  Score: {score}");
 *       }
 *   }
 *
 * Each plate carries the record "id" (use it with POST /api/v1/lpr/log/{id}/plate)
 * and "direction" as a string ("entry" / "exit"), not a number.
 */
