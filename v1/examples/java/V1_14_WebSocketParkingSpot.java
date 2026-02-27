/**
 * v1 API - WebSocket Parking Spot Monitoring
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingSpot
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
 *
 * Events:
 *   currentStatus  - initial full state on connect
 *   statusChanged  - only changed spots
 *
 * Compile: javac NvrClient.java V1_14_WebSocketParkingSpot.java
 * Run:     java V1_14_WebSocketParkingSpot
 */

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class V1_14_WebSocketParkingSpot {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        System.out.println("=== WebSocket Parking Spot Monitoring (30 seconds) ===");

        // Auth via X-API-Key header
        // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

        // Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
        String wsBase = client.baseUrl.replace("https://", "wss://").replace("http://", "ws://");
        String wsUrl = wsBase + "/wsapi/v1/events?topics=parkingSpot";

        CountDownLatch latch = new CountDownLatch(1);
        final int[] msgCount = {0};

        WebSocket ws = HttpClient.newBuilder().sslContext(NvrClient.trustAllContext()).build()
                .newWebSocketBuilder()
                .header("X-API-Key", client.getApiKey())
                .buildAsync(URI.create(wsUrl), new WebSocket.Listener() {

                    private final StringBuilder sb = new StringBuilder();

                    @Override
                    public void onOpen(WebSocket webSocket) {
                        System.out.println("  Connected! Waiting for spot events...\n");
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
                        msgCount[0]++;

                        String event = extractField(json, "event");

                        if ("currentStatus".equals(event)) {
                            System.out.println("  [currentStatus] initial state");
                            System.out.println("    " + json);
                        } else if ("statusChanged".equals(event)) {
                            System.out.println("  [statusChanged]");
                            System.out.println("    " + json);
                        }

                        webSocket.request(1);
                        return CompletableFuture.completedFuture(null);
                    }

                    @Override
                    public CompletionStage<?> onClose(WebSocket webSocket, int statusCode, String reason) {
                        latch.countDown();
                        return CompletableFuture.completedFuture(null);
                    }

                    @Override
                    public void onError(WebSocket webSocket, Throwable error) {
                        System.out.println("  Error: " + error.getMessage());
                        latch.countDown();
                    }
                }).join();

        if (!latch.await(30, TimeUnit.SECONDS)) {
            System.out.println("\n  Received " + msgCount[0] + " events");
            ws.sendClose(WebSocket.NORMAL_CLOSURE, "timeout");
        }
    }

    private static String extractField(String json, String field) {
        String strKey = "\"" + field + "\":\"";
        int start = json.indexOf(strKey);
        if (start >= 0) {
            start += strKey.length();
            int end = json.indexOf("\"", start);
            return end > start ? json.substring(start, end) : "";
        }
        return "";
    }
}
