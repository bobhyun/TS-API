/**
 * v1 API - Channel List & Status
 *
 * Endpoints:
 *   GET /api/v1/channel                           - List all channels
 *   GET /api/v1/channel?staticSrc                 - Include static stream URLs
 *   GET /api/v1/channel?caps                      - Include channel capabilities
 *   GET /api/v1/channel/status?recordingStatus     - Per-channel recording status
 *   GET /api/v1/channel/{chid}/info?caps          - Single channel capabilities
 *
 * Channel fields: chid, title, displayName (NOT 'name')
 *
 * Compile: javac NvrClient.java V1_02_Channels.java
 * Run:     java V1_02_Channels
 */
public class V1_02_Channels {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── List all channels ──
        // GET /api/v1/channel
        // Response: [{chid, title, displayName, ...}, ...]
        NvrClient.Response r = client.get("/api/v1/channel");
        System.out.println("=== Channels === status=" + r.status);
        System.out.println(r.body);

        // ── Static source URLs ──
        // GET /api/v1/channel?staticSrc
        // Includes RTMP/FLV addresses
        r = client.get("/api/v1/channel?staticSrc");
        System.out.println("\n=== Channels with staticSrc ===");
        System.out.println(r.body);

        // ── Channel capabilities ──
        // GET /api/v1/channel?caps
        r = client.get("/api/v1/channel?caps");
        System.out.println("\n=== Channels with caps ===");
        System.out.println(r.body);

        // ── Recording status ──
        // GET /api/v1/channel/status?recordingStatus
        r = client.get("/api/v1/channel/status?recordingStatus");
        System.out.println("\n=== Recording Status ===");
        System.out.println(r.body);

        // ── Single channel capabilities ──
        // GET /api/v1/channel/{chid}/info?caps
        int chid = 1;
        r = client.get("/api/v1/channel/" + chid + "/info?caps");
        System.out.println("\n=== Channel " + chid + " Capabilities === status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }
    }
}
