/**
 * v1 API - Recording Search
 *
 * Endpoints:
 *   GET /api/v1/recording/days?ch=1           - List of days with recordings
 *   GET /api/v1/recording/minutes?ch=1&timeBegin=...&timeEnd=...
 *       - Minute-level recording timeline (1440-char string)
 *
 * Timeline string (1440 chars):
 *   - Index 0 = 00:00, Index 59 = 00:59, ..., Index 1439 = 23:59
 *   - '0' = no recording, '1' or higher = recording exists
 *
 * Use these endpoints to build a recording timeline calendar UI.
 *
 * Compile: javac NvrClient.java V1_04_RecordingSearch.java
 * Run:     java V1_04_RecordingSearch
 */
public class V1_04_RecordingSearch {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        int ch = 1;

        // ── Days with recordings ──
        // GET /api/v1/recording/days?ch={n}
        System.out.println("=== Recording Days (ch=" + ch + ") ===");
        NvrClient.Response r = client.get("/api/v1/recording/days?ch=" + ch);
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println("  " + r.body);
        }

        // ── Minute-level timeline ──
        // GET /api/v1/recording/minutes?ch={n}&timeBegin=YYYYMMDD&timeEnd=YYYYMMDD
        // Response: 1440-char string (1 char = 1 minute)
        String timeBegin = "20260115";
        String timeEnd   = "20260116";

        System.out.println("\n=== Recording Minutes (ch=" + ch
                + ", " + timeBegin + "~" + timeEnd + ") ===");
        r = client.get("/api/v1/recording/minutes?ch=" + ch
                + "&timeBegin=" + timeBegin
                + "&timeEnd=" + timeEnd);
        System.out.println("  status=" + r.status);

        if (r.status == 200) {
            String timeline = r.body;
            System.out.println("  Length: " + timeline.length()
                    + " chars (expected 1440)");

            if (timeline.length() >= 1440) {
                // First 60 chars (00:00~00:59)
                System.out.println("  00:00-00:59: " + timeline.substring(0, 60));
                // Last 60 chars (23:00~23:59)
                System.out.println("  23:00-23:59: "
                        + timeline.substring(1380, 1440));

                // Parse recording segments
                parseSegments(timeline.substring(0, 1440));
            } else {
                System.out.println("  Response: " + timeline);
            }
        }
    }

    /**
     * Parse 1440-char timeline into recording segments.
     */
    static void parseSegments(String timeline) {
        int count = 0;
        boolean inRec = false;
        int start = 0;

        System.out.println("\n  Recording segments:");

        for (int i = 0; i < timeline.length(); i++) {
            if (timeline.charAt(i) != '0' && !inRec) {
                inRec = true;
                start = i;
            } else if (timeline.charAt(i) == '0' && inRec) {
                inRec = false;
                if (count < 10) {
                    System.out.printf("    %02d:%02d - %02d:%02d%n",
                            start / 60, start % 60,
                            (i - 1) / 60, (i - 1) % 60);
                }
                count++;
            }
        }
        if (inRec) {
            int end = timeline.length() - 1;
            if (count < 10) {
                System.out.printf("    %02d:%02d - %02d:%02d%n",
                        start / 60, start % 60, end / 60, end % 60);
            }
            count++;
        }

        if (count > 10) {
            System.out.println("    ... and " + (count - 10) + " more segments");
        }
        System.out.println("  Total: " + count + " segments");
    }
}
