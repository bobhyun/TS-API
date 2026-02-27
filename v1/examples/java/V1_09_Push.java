/**
 * v1 API - Push Notification
 *
 * Endpoint:
 *   POST /api/v1/push
 *       - Push external events into the NVR
 *       - Requires Push license enabled on the server
 *
 * Event types:
 *   1. LPR - Push plate recognition result
 *   2. emergencyCall - Trigger emergency alarm
 *
 * WARNING: emergencyCall with action=callStart triggers a REAL alarm on the NVR.
 *          The alarm persists until callEnd is sent.
 *          ALWAYS send callEnd after callStart.
 *
 *
 * Compile: javac NvrClient.java V1_09_Push.java
 * Run:     java V1_09_Push
 */
public class V1_09_Push {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        pushLprEvent(client);
        pushEmergencyCall(client);
    }

    /**
     * Push a license plate recognition event.
     */
    static void pushLprEvent(NvrClient client) throws Exception {
        System.out.println("=== Push LPR Event ===");

        String payload = "{"
                + "\"type\":\"LPR\","
                + "\"plate\":\"12AB3456\","
                + "\"chid\":1,"
                + "\"time\":\"2026-01-15 10:30:00\""
                + "}";

        NvrClient.Response r = client.post("/api/v1/push", payload);
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println("  " + r.body);
        } else {
            System.out.println("  Ensure Push license is enabled");
        }
    }

    /**
     * Push an emergency call event.
     *
     * WARNING: callStart triggers a REAL alarm on the NVR!
     * You MUST send callEnd to stop it.
     */
    static void pushEmergencyCall(NvrClient client) throws Exception {
        System.out.println("\n=== Push Emergency Call ===");
        System.out.println("  WARNING: This triggers a REAL alarm on the NVR!");

        // Uncomment the code below to actually trigger the alarm.
        // Make sure you always send callEnd after callStart.
        // Uncomment the code below to actually trigger the alarm.
        // Make sure you always send callEnd after callStart.

        /*
        // ── callStart: Start alarm ──
        System.out.println("  Sending callStart...");
        String callStart = "{"
                + "\"type\":\"emergencyCall\","
                + "\"action\":\"callStart\","
                + "\"chid\":1"
                + "}";
        NvrClient.Response r = client.post("/api/v1/push", callStart);
        System.out.println("  callStart -> " + r.status);

        Thread.sleep(3000); // Alarm active for 3 seconds

        // ── callEnd: Stop alarm (REQUIRED!) ──
        System.out.println("  Sending callEnd...");
        String callEnd = "{"
                + "\"type\":\"emergencyCall\","
                + "\"action\":\"callEnd\","
                + "\"chid\":1"
                + "}";
        r = client.post("/api/v1/push", callEnd);
        System.out.println("  callEnd -> " + r.status);
        */

        System.out.println("  (Commented out for safety - uncomment to test)");
        System.out.println("  IMPORTANT: Always send callEnd after callStart!");
    }
}
