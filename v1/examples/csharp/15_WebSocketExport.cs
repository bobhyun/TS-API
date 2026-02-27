// 15_WebSocketExport.cs - v1 API WebSocket Recording Export Example
//
// Endpoint:
//   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Flow:
//   ready   -> task ID and channel info
//   fileEnd -> download URL, send {task, cmd:"next"}
//   end     -> export complete
//   error   -> error message

using System;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace TsApiExamples.V1
{
    class WebSocketExport
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
                // Time range: yesterday 00:00 ~ 00:10
                var yesterday = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
                var timeBegin = $"{yesterday}T00:00:00";
                var timeEnd = $"{yesterday}T00:10:00";

                Console.WriteLine("=== WebSocket Recording Export ===");
                Console.WriteLine($"  Channel: 1,  {timeBegin} ~ {timeEnd}");

                // Auth via X-API-Key header
                // Alt: use ?apikey=tsapi_key_... query param (browser fallback)
                var wsBase = client.BaseUrl.Replace("https://", "wss://").Replace("http://", "ws://");
                var wsUrl = $"{wsBase}/wsapi/v1/export"
                          + $"?ch=1&timeBegin={timeBegin}&timeEnd={timeEnd}";

                using var ws = new ClientWebSocket();
                ws.Options.RemoteCertificateValidationCallback = (_, _, _, _) => true;
                ws.Options.SetRequestHeader("X-API-Key", client.ApiKey);
                var cts = new CancellationTokenSource(TimeSpan.FromSeconds(60));

                await ws.ConnectAsync(new Uri(wsUrl), cts.Token);
                Console.WriteLine("  Connected");

                string taskId = null;
                var buffer = new byte[8192];

                while (ws.State == WebSocketState.Open)
                {
                    var result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), cts.Token);

                    if (result.MessageType == WebSocketMessageType.Close)
                        break;

                    var json = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    using var doc = JsonDocument.Parse(json);
                    var root = doc.RootElement;
                    var stage = root.GetProperty("stage").GetString();

                    switch (stage)
                    {
                        case "ready":
                            // Check status code (code:-1 = no recording in range)
                            if (root.TryGetProperty("status", out var st)
                                && st.TryGetProperty("code", out var code)
                                && code.GetInt32() != 0)
                            {
                                var errMsg = st.TryGetProperty("message", out var m) ? m.GetString() : "unknown";
                                Console.WriteLine($"  Ready - Error: {errMsg}");
                                break;
                            }
                            if (root.TryGetProperty("task", out var task)
                                && task.TryGetProperty("id", out var tid))
                                taskId = tid.GetString();
                            Console.WriteLine($"  Ready - Task ID: {taskId}");
                            break;

                        case "fileEnd":
                            // download: [{fileName, src}, ...]
                            var download = "N/A";
                            if (root.TryGetProperty("channel", out var fch)
                                && fch.TryGetProperty("file", out var file)
                                && file.TryGetProperty("download", out var dlArr)
                                && dlArr.GetArrayLength() > 0
                                && dlArr[0].TryGetProperty("src", out var dlSrc))
                                download = dlSrc.GetString();
                            Console.WriteLine($"  File ready: {download}");
                            if (taskId != null)
                            {
                                var cmd = JsonSerializer.Serialize(new { task = taskId, cmd = "next" });
                                var bytes = Encoding.UTF8.GetBytes(cmd);
                                await ws.SendAsync(new ArraySegment<byte>(bytes),
                                    WebSocketMessageType.Text, true, cts.Token);
                            }
                            break;

                        case "end":
                            Console.WriteLine("  Export complete!");
                            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "", CancellationToken.None);
                            break;

                        case "error":
                            var message = root.TryGetProperty("message", out var msg) ? msg.GetString() : json;
                            Console.WriteLine($"  Error: {message}");
                            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "", CancellationToken.None);
                            break;

                        default:
                            Console.WriteLine($"  [{stage}] {json}");
                            break;
                    }
                }

                Console.WriteLine("  Disconnected");
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("  Timeout");
            }
        }
    }
}
