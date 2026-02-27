/**
 * v1 API - WebSocket Parking Lot Count Monitoring
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingCount
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filter: &lot=1,2 (filter by parking lot ID)
 *
 * See also: V1_14_WebSocketParkingSpot.java for individual spot monitoring
 *
 * Compile: javac NvrClient.java V1_13_WebSocketParkingLot.java
 * Run:     java V1_13_WebSocketParkingLot
 */

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class V1_13_WebSocketParkingLot {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        System.out.println("=== WebSocket Parking Count Monitoring (30 seconds) ===");

        // Auth via X-API-Key header
        // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

        // Optional filter: &lot=1,2
        String wsBase = client.baseUrl.replace("https://", "wss://").replace("http://", "ws://");
        String wsUrl = wsBase + "/wsapi/v1/events?topics=parkingCount";

        CountDownLatch latch = new CountDownLatch(1);
        final int[] msgCount = {0};

        WebSocket ws = HttpClient.newBuilder().sslContext(NvrClient.trustAllContext()).build()
                .newWebSocketBuilder()
                .header("X-API-Key", client.getApiKey())
                .buildAsync(URI.create(wsUrl), new WebSocket.Listener() {

                    private final StringBuilder sb = new StringBuilder();

                    @Override
                    public void onOpen(WebSocket webSocket) {
                        System.out.println("  Connected! Waiting for parking count events...\n");
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

                        // First message is subscription confirmation
                        if (json.contains("\"subscriberId\"")) {
                            String subId = extractField(json, "subscriberId");
                            System.out.println("  Subscribed (id=" + subId + ")");
                            webSocket.request(1);
                            return CompletableFuture.completedFuture(null);
                        }

                        // parkingCount: {topic, updated: [{id, name, type, maxCount, count}, ...]}
                        int updStart = json.indexOf("\"updated\":[");
                        if (updStart >= 0) {
                            updStart = json.indexOf("[", updStart) + 1;
                            int updEnd = json.lastIndexOf("]");
                            if (updEnd > updStart) {
                                String arrayContent = json.substring(updStart, updEnd);
                                // Split by },{ to get individual lot objects
                                String[] lots = arrayContent.split("\\},\\s*\\{");
                                for (String lot : lots) {
                                    if (!lot.startsWith("{")) lot = "{" + lot;
                                    if (!lot.endsWith("}")) lot = lot + "}";
                                    String id = extractField(lot, "id");
                                    String name = extractField(lot, "name");
                                    String type = extractField(lot, "type");
                                    String count = extractField(lot, "count");
                                    String maxCount = extractField(lot, "maxCount");
                                    int avail = 0;
                                    try { avail = Integer.parseInt(maxCount) - Integer.parseInt(count); }
                                    catch (NumberFormatException ignored) {}
                                    System.out.println("  [" + id + "] " + name + " (" + type + "): "
                                            + count + "/" + maxCount + " (available=" + avail + ")");
                                }
                            }
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
        String numKey = "\"" + field + "\":";
        start = json.indexOf(numKey);
        if (start >= 0) {
            start += numKey.length();
            int end = start;
            while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '-'))
                end++;
            return end > start ? json.substring(start, end) : "";
        }
        return "";
    }
}
