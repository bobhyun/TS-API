/**
 * v1 API - LPR / License Plate Recognition
 *
 * Endpoints:
 *   GET /api/v1/lpr/source
 *       - List LPR-enabled cameras
 *
 *   GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
 *       - Search recognition log
 *       - timeBegin, timeEnd REQUIRED
 *
 *   GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
 *       - Similar/fuzzy plate search
 *
 * WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
 *   errors. For bulk exports, narrow the time range or use pagination
 *   (at/maxCount) to keep each request under a manageable size.
 *
 * Compile: javac NvrClient.java V1_06_LprSearch.java
 * Run:     java V1_06_LprSearch
 */
public class V1_06_LprSearch {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── LPR Sources ──
        // GET /api/v1/lpr/source
        System.out.println("=== LPR Sources ===");
        NvrClient.Response r = client.get("/api/v1/lpr/source");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── LPR Log ──
        // GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
        // timeBegin, timeEnd REQUIRED
        String timeBegin = "20260101";
        String timeEnd   = "20260201";

        System.out.println("\n=== LPR Log (" + timeBegin + " ~ "
                + timeEnd + ") ===");
        r = client.get("/api/v1/lpr/log"
                + "?timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd);
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Similar Plate Search ──
        // GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
        // Partial/fuzzy plate match
        String keyword = "3456";
        System.out.println("\n=== Similar Plates (keyword=\""
                + keyword + "\") ===");
        r = client.get("/api/v1/lpr/similar"
                + "?keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8")
                + "&timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd);
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Export ──
        // GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
        // Adding export=true returns file download (CSV, etc.)
        System.out.println("\n=== Export LPR Log ===");
        r = client.get("/api/v1/lpr/log"
                + "?timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd
                + "&export=true");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println("  body length: " + r.body.length() + " chars");
            // To save as file:
            // java.nio.file.Files.writeString(
            //     java.nio.file.Path.of("lpr_export.csv"), r.body);
        }
    }
}
