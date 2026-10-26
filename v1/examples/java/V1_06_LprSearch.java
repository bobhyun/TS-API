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
 *       - Plates containing the keyword (partial or misread plates)
 *
 *   GET  /api/v1/lpr/log/{id}/plate/history
 *       - Plate correction history of one record (Playback permission)
 *   POST /api/v1/lpr/log/{id}/plate   {"plateNo": "...", "reason": "..."}
 *       - Correct the plate of one record (Control permission, not executed here)
 *
 * WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
 *   Narrow the time range or page with at/maxCount.
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
        // Each data[] item: id, plateNo (null when no plate was read), direction
        // ("entry"/"exit", absent when unknown), plateEdited, and originalPlateNo
        // when plateEdited is true. plateNo is always the current value.
        String timeBegin = "20260101";
        String timeEnd   = "20260201";

        System.out.println("\n=== LPR Log (" + timeBegin + " ~ "
                + timeEnd + ") ===");
        r = client.get("/api/v1/lpr/log"
                + "?timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd);
        System.out.println("  status=" + r.status);
        String recId = null;
        if (r.status == 200) {
            System.out.println(r.body);
            // First record id (no JSON parser here)
            java.util.regex.Matcher m = java.util.regex.Pattern
                    .compile("\"data\"\\s*:\\s*\\[\\s*\\{\\s*\"id\"\\s*:\\s*(\\d+)").matcher(r.body);
            if (m.find()) recId = m.group(1);
        }

        // ── Similar Plate Search ──
        // GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
        // Returns every plate containing the keyword, most recent first
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

        // ── Plate Correction History (one record, by id) ──
        // GET /api/v1/lpr/log/{id}/plate/history
        // edits[] (time, user, before, after, reason) lists corrections in recorded order.
        // If the record was never corrected, edits[] is empty and originalPlateNo is absent.
        if (recId != null) {
            System.out.println("\n=== Plate Correction History (id=" + recId + ") ===");
            r = client.get("/api/v1/lpr/log/" + recId + "/plate/history");
            System.out.println("  status=" + r.status);
            if (r.status == 200) {
                System.out.println(r.body);
            }
        }

        // ── Plate Correction (Control permission) ──
        // POST /api/v1/lpr/log/{id}/plate
        // Changes the stored record, so it is not executed here. The target is always
        // one record id - from data[].id above, or the id a realtime LPR event carries
        // next to each plateNo. 409 when plateNo equals the current plate.
        //
        // Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
        // Uncomment it to try it against a test record.
        //   client.post("/api/v1/lpr/log/" + recId + "/plate",
        //       "{\"plateNo\":\"12가3456\",\"reason\":\"misread at night\"}");

        // ── Export ──
        // GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
        // export=true returns the log as CSV
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
