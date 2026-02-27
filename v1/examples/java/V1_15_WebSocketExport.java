/**
 * v1 API - WebSocket Recording Export
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Flow:
 *   ready   -> task ID, channel info
 *   fileEnd -> download URL, send {task, cmd:"next"}
 *   end     -> export complete
 *   error   -> error message
 *
 * Compile: javac NvrClient.java V1_15_WebSocketExport.java
 * Run:     java V1_15_WebSocketExport
 */

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.time.LocalDate;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class V1_15_WebSocketExport {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // Time range: yesterday 00:00 ~ 00:10
        String yesterday = LocalDate.now().minusDays(1).toString();
        String timeBegin = yesterday + "T00:00:00";
        String timeEnd = yesterday + "T00:10:00";

        System.out.println("=== WebSocket Recording Export ===");
        System.out.println("  Channel: 1,  " + timeBegin + " ~ " + timeEnd);

        // Auth via X-API-Key header
        // Alt: use ?apikey=tsapi_key_... query param (browser fallback)
        String wsBase = client.baseUrl.replace("https://", "wss://").replace("http://", "ws://");
        String wsUrl = wsBase + "/wsapi/v1/export?ch=1"
                + "&timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd;

        CountDownLatch latch = new CountDownLatch(1);
        final String[] taskIdHolder = {null};

        WebSocket ws = HttpClient.newBuilder().sslContext(NvrClient.trustAllContext()).build()
                .newWebSocketBuilder()
                .header("X-API-Key", client.getApiKey())
                .buildAsync(URI.create(wsUrl), new WebSocket.Listener() {

                    private final StringBuilder sb = new StringBuilder();

                    @Override
                    public void onOpen(WebSocket webSocket) {
                        System.out.println("  Connected");
                        WebSocket.Listener.super.onOpen(webSocket);
                    }

                    @Override
                    public CompletionStage<?> onText(WebSocket webSocket, CharSequence data, boolean last) {
                        sb.append(data);
                        if (!last) {
                            webSocket.request(1);
                            return CompletableFuture.completedFuture(null);
                        }

                        String json = sb.toString();
                        sb.setLength(0);

                        // Simple JSON field extraction
                        String stage = extractField(json, "stage");

                        switch (stage) {
                            case "ready":
                                // Check status code (code:-1 = no recording in range)
                                if (json.contains("\"code\"") && !json.contains("\"code\":0")) {
                                    String errMsg = extractField(json, "message");
                                    System.out.println("  Ready - Error: " + (errMsg.isEmpty() ? json : errMsg));
                                    latch.countDown();
                                    break;
                                }
                                taskIdHolder[0] = extractField(json, "id");
                                System.out.println("  Ready - Task ID: " + taskIdHolder[0]);
                                break;

                            case "fileEnd":
                                // download: [{fileName, src}, ...]
                                String src = extractField(json, "src");
                                System.out.println("  File ready: " + (src.isEmpty() ? "N/A" : src));
                                if (taskIdHolder[0] != null) {
                                    webSocket.sendText("{\"task\":\"" + taskIdHolder[0] + "\",\"cmd\":\"next\"}", true);
                                }
                                break;

                            case "end":
                                System.out.println("  Export complete!");
                                webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "done");
                                latch.countDown();
                                break;

                            case "error":
                                String message = extractField(json, "message");
                                System.out.println("  Error: " + (message.isEmpty() ? json : message));
                                webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "error");
                                latch.countDown();
                                break;

                            default:
                                System.out.println("  [" + stage + "] " + json);
                        }

                        webSocket.request(1);
                        return CompletableFuture.completedFuture(null);
                    }

                    @Override
                    public CompletionStage<?> onClose(WebSocket webSocket, int statusCode, String reason) {
                        System.out.println("  Disconnected");
                        latch.countDown();
                        return CompletableFuture.completedFuture(null);
                    }

                    @Override
                    public void onError(WebSocket webSocket, Throwable error) {
                        System.out.println("  Error: " + error.getMessage());
                        latch.countDown();
                    }
                }).join();

        // Wait up to 60 seconds
        if (!latch.await(60, TimeUnit.SECONDS)) {
            System.out.println("  Timeout - cancelling...");
            if (taskIdHolder[0] != null) {
                ws.sendText("{\"task\":\"" + taskIdHolder[0] + "\",\"cmd\":\"cancel\"}", true);
                Thread.sleep(1000);
            }
            ws.sendClose(WebSocket.NORMAL_CLOSURE, "timeout");
        }
    }

    /** Extract a simple JSON string field value. */
    private static String extractField(String json, String field) {
        String key = "\"" + field + "\":\"";
        int start = json.indexOf(key);
        if (start < 0) return "";
        start += key.length();
        int end = json.indexOf("\"", start);
        return end > start ? json.substring(start, end) : "";
    }
}
