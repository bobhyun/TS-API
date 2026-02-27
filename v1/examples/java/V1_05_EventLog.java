/**
 * v1 API - Event Log Search
 *
 * Endpoints:
 *   GET /api/v1/event/type
 *       - List event types with nested codes
 *       - Response: [{id, name, code: [{id, name}]}, ...]
 *       - NOTE: field is 'id' (NOT 'type'), nested array is 'code'
 *
 *   GET /api/v1/event/log?maxCount=10
 *       - Query event log
 *       - Optional: timeBegin, timeEnd, offset, limit
 *
 * Compile: javac NvrClient.java V1_05_EventLog.java
 * Run:     java V1_05_EventLog
 */
public class V1_05_EventLog {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── Event Types ──
        // GET /api/v1/event/type
        // Response: [{id, name, code: [{id, name}]}, ...]
        // Use 'id' field (NOT "type")
        System.out.println("=== Event Types ===");
        NvrClient.Response r = client.get("/api/v1/event/type");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Event Log ──
        // GET /api/v1/event/log?maxCount={n}
        // Returns up to n most recent events
        System.out.println("\n=== Event Log (maxCount=10) ===");
        r = client.get("/api/v1/event/log?maxCount=10");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Time-ranged Event Log ──
        // GET /api/v1/event/log?timeBegin=YYYYMMDD&timeEnd=YYYYMMDD&maxCount=20
        String timeBegin = "20260101";
        String timeEnd   = "20260201";
        System.out.println("\n=== Event Log (" + timeBegin + " ~ "
                + timeEnd + ") ===");
        r = client.get("/api/v1/event/log"
                + "?timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd
                + "&maxCount=20");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Pagination ──
        // Use offset and limit for pagination
        // Example:
        //   page 1: /api/v1/event/log?offset=0&limit=20
        //   page 2: /api/v1/event/log?offset=20&limit=20
    }
}
