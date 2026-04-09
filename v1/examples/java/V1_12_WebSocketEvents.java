/**
 * v1 API - WebSocket Real-time Event Subscription
 *
 * Subscribes to real-time events via WebSocket.
 *
 * Two subscription modes:
 *   1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
 *   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Compile: javac NvrClient.java V1_12_WebSocketEvents.java
 * Run:     java V1_12_WebSocketEvents
 */

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class V1_12_WebSocketEvents {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        String wsUrl = client.baseUrl.replace("https://", "wss://").replace("http://", "ws://");

        // ── Method 1: Subscribe via URL query params (classic) ──
        System.out.println("=== Method 1: Subscribe via URL (10 seconds) ===");

        {
            String url = wsUrl + "/wsapi/v1/events?topics=LPR,channelStatus";
            AtomicInteger messageCount = new AtomicInteger(0);
            CountDownLatch closeLatch = new CountDownLatch(1);

            WebSocket ws = HttpClient.newBuilder().sslContext(NvrClient.trustAllContext()).build()
                    .newWebSocketBuilder()
                    .header("X-API-Key", client.getApiKey())
                    .buildAsync(URI.create(url), new WebSocket.Listener() {

                        @Override
                        public void onOpen(WebSocket webSocket) {
                            System.out.println("  Connected!");
                            WebSocket.Listener.super.onOpen(webSocket);
                        }

                        @Override
                        public CompletionStage<?> onText(WebSocket webSocket,
                                CharSequence data, boolean last) {
                            messageCount.incrementAndGet();
                            String text = data.toString();
                            String topic = extractField(text, "topic");
                            if (topic.isEmpty()) topic = extractField(text, "type");
                            System.out.println("  [" + topic + "] " + text);
                            return WebSocket.Listener.super.onText(webSocket, data, last);
                        }

                        @Override
                        public CompletionStage<?> onClose(WebSocket webSocket,
                                int statusCode, String reason) {
                            closeLatch.countDown();
                            return CompletableFuture.completedFuture(null);
                        }

                        @Override
                        public void onError(WebSocket webSocket, Throwable error) {
                            System.out.println("  Error: " + error.getMessage());
                            closeLatch.countDown();
                        }
                    }).join();

            closeLatch.await(10, TimeUnit.SECONDS);
            System.out.println("  Received " + messageCount.get() + " events");

            if (!ws.isOutputClosed()) {
                ws.sendClose(WebSocket.NORMAL_CLOSURE, "done").join();
            }
        }

        // ── Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) ──
        //   - Connect WITHOUT topics
        //   - Subscribe/unsubscribe at any time
        //   - Per-topic filters (ch, objectTypes, lot, spot)
        //   - Re-subscribe to update filters
        System.out.println("\n=== Method 2: Dynamic Subscribe (10 seconds) ===");

        {
            String url = wsUrl + "/wsapi/v1/events";
            AtomicInteger messageCount = new AtomicInteger(0);
            CountDownLatch closeLatch = new CountDownLatch(1);

            WebSocket ws = HttpClient.newBuilder().sslContext(NvrClient.trustAllContext()).build()
                    .newWebSocketBuilder()
                    .header("X-API-Key", client.getApiKey())
                    .buildAsync(URI.create(url), new WebSocket.Listener() {

                        @Override
                        public void onOpen(WebSocket webSocket) {
                            System.out.println("  Connected (no topics yet)");

                            // Phase 1: Subscribe to initial topics with per-topic filters
                            System.out.println("  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)");
                            webSocket.sendText("{\"subscribe\":\"channelStatus\"}", true);
                            webSocket.sendText("{\"subscribe\":\"LPR\",\"ch\":[1,2]}", true);

                            // Schedule mid-connection topic changes
                            new Thread(() -> {
                                try {
                                    // Phase 2 (3s): Add new topic + update existing filter
                                    Thread.sleep(3000);
                                    System.out.println("  [Phase 2] Add object topic + expand LPR to ch 1-4");
                                    webSocket.sendText("{\"subscribe\":\"object\",\"objectTypes\":[\"human\",\"vehicle\"]}", true);
                                    webSocket.sendText("{\"subscribe\":\"LPR\",\"ch\":[1,2,3,4]}", true);

                                    // Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
                                    Thread.sleep(3000);
                                    System.out.println("  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3");
                                    webSocket.sendText("{\"unsubscribe\":\"channelStatus\"}", true);
                                    webSocket.sendText("{\"subscribe\":\"motionChanges\",\"ch\":[1]}", true);
                                    webSocket.sendText("{\"subscribe\":\"LPR\",\"ch\":[1,3]}", true);  // re-subscribe with fewer ch drops ch 2,4
                                } catch (Exception e) { /* ignore */ }
                            }).start();

                            WebSocket.Listener.super.onOpen(webSocket);
                        }

                        @Override
                        public CompletionStage<?> onText(WebSocket webSocket,
                                CharSequence data, boolean last) {
                            messageCount.incrementAndGet();
                            String text = data.toString();
                            String type = extractField(text, "type");
                            String topic = extractField(text, "topic");

                            // Handle control responses
                            if ("subscribed".equals(type)) {
                                System.out.println("  Subscribed to: " + topic);
                            } else if ("unsubscribed".equals(type)) {
                                System.out.println("  Unsubscribed from: " + topic);
                            } else if ("error".equals(type)) {
                                String msg = extractField(text, "message");
                                System.out.println("  Error: " + msg + " (topic: " + topic + ")");
                            } else {
                                // Event data
                                if (topic.isEmpty()) topic = "?";
                                System.out.println("  [" + topic + "] " + text);
                            }
                            return WebSocket.Listener.super.onText(webSocket, data, last);
                        }

                        @Override
                        public CompletionStage<?> onClose(WebSocket webSocket,
                                int statusCode, String reason) {
                            closeLatch.countDown();
                            return CompletableFuture.completedFuture(null);
                        }

                        @Override
                        public void onError(WebSocket webSocket, Throwable error) {
                            System.out.println("  Error: " + error.getMessage());
                            closeLatch.countDown();
                        }
                    }).join();

            closeLatch.await(10, TimeUnit.SECONDS);
            System.out.println("  Received " + messageCount.get() + " messages");

            if (!ws.isOutputClosed()) {
                ws.sendClose(WebSocket.NORMAL_CLOSURE, "done").join();
            }
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
 * To handle both formats with org.json or Gson:
 *
 *   JSONObject msg = new JSONObject(text);
 *   if ("LPR".equals(msg.optString("topic"))) {
 *       JSONArray plates;
 *       if (msg.has("plates")) {
 *           plates = msg.getJSONArray("plates");       // v1.0.1 batch format
 *       } else {
 *           plates = new JSONArray();
 *           plates.put(msg);                           // v1.0.0 single-plate format
 *       }
 *       for (int i = 0; i < plates.length(); i++) {
 *           JSONObject p = plates.getJSONObject(i);
 *           System.out.println("Plate: " + p.optString("plateNo")
 *               + "  Score: " + p.optDouble("score"));
 *       }
 *   }
 */
