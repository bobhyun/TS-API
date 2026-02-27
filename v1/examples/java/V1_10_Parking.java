/**
 * v1 API - Parking Management
 *
 * Endpoints:
 *   GET /api/v1/parking/lot           - List parking lots
 *   GET /api/v1/parking/lot/status    - Lot occupancy status
 *   GET /api/v1/parking/spot          - List parking spots
 *   GET /api/v1/parking/spot/status   - Individual spot status
 *
 * Compile: javac NvrClient.java V1_10_Parking.java
 * Run:     java V1_10_Parking
 */
public class V1_10_Parking {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── Parking Lots ──
        // GET /api/v1/parking/lot
        System.out.println("=== Parking Lots ===");
        NvrClient.Response r = client.get("/api/v1/parking/lot");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Lot Occupancy Status ──
        // GET /api/v1/parking/lot/status
        System.out.println("\n=== Parking Lot Status ===");
        r = client.get("/api/v1/parking/lot/status");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Parking Spots ──
        // GET /api/v1/parking/spot
        System.out.println("\n=== Parking Spots ===");
        r = client.get("/api/v1/parking/spot");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Spot Status ──
        // GET /api/v1/parking/spot/status
        System.out.println("\n=== Parking Spot Status ===");
        r = client.get("/api/v1/parking/spot/status");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }
    }
}
