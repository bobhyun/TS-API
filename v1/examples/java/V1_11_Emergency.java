/**
 * v1 API - Emergency Call Device List
 *
 * Endpoint:
 *   GET /api/v1/emergency  - Emergency call device list
 *
 * Response: [{ id, code, name, linkedChannel }, ...]
 * Note: Requires Emergency Call license. Returns 404 if not supported.
 *
 * Compile: javac NvrClient.java V1_11_Emergency.java
 * Run:     java V1_11_Emergency
 */
public class V1_11_Emergency {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── Emergency call device list ──
        // GET /api/v1/emergency
        NvrClient.Response r = client.get("/api/v1/emergency");
        System.out.println("=== Emergency Call Devices === status=" + r.status);

        if (r.status == 404) {
            System.out.println("  Emergency Call not enabled on this server (license required)");
        } else if (r.status == 200) {
            System.out.println(r.body);
        }
    }
}
