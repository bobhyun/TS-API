/**
 * v1 API - System Information
 *
 * Endpoints:
 *   GET /api/v1/info?all                   - All NVR info (version, license, etc.)
 *   GET /api/v1/system/info?item=os        - OS info
 *   GET /api/v1/system/info?item=cpu       - CPU usage
 *   GET /api/v1/system/info?item=storage   - Storage info (response field: 'disk')
 *   GET /api/v1/system/info?item=network   - Network interfaces
 *   GET /api/v1/system/health              - System health status
 *   GET /api/v1/system/health?item=systemDisk
 *                                          - System disk (database and logs) status
 *   GET /api/v1/system/hddsmart            - HDD S.M.A.R.T. data
 *   GET /api/v1/system/notices?lang=ko-KR  - Notices currently in effect
 *
 * NOTE: item=storage returns its data in the 'disk' field (NOT 'storage').
 *
 * Compile: javac NvrClient.java V1_08_SystemInfo.java
 * Run:     java V1_08_SystemInfo
 */
public class V1_08_SystemInfo {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── All NVR Info ──
        // GET /api/v1/info?all
        System.out.println("=== NVR Info ===");
        NvrClient.Response r = client.get("/api/v1/info?all");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── OS Info ──
        // GET /api/v1/system/info?item=os
        System.out.println("\n=== OS Info ===");
        r = client.get("/api/v1/system/info?item=os");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── CPU Info ──
        // GET /api/v1/system/info?item=cpu
        System.out.println("\n=== CPU Info ===");
        r = client.get("/api/v1/system/info?item=cpu");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── Storage Info ──
        // GET /api/v1/system/info?item=storage
        // NOTE: Response field is 'disk' (NOT 'storage')
        System.out.println("\n=== Storage Info ===");
        r = client.get("/api/v1/system/info?item=storage");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
            // Look for "disk" field in the JSON response
        }

        // ── Network Info ──
        // GET /api/v1/system/info?item=network
        System.out.println("\n=== Network Info ===");
        r = client.get("/api/v1/system/info?item=network");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── System Health ──
        // GET /api/v1/system/health
        System.out.println("\n=== System Health ===");
        r = client.get("/api/v1/system/health");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── System Disk ──
        // GET /api/v1/system/health?item=systemDisk
        // Holds the database and logs (normally C:), separate from the recording disks.
        // When it is full, records stop being saved even if the recording disks have room.
        // Watch status here, not only disk[].
        // Fields: drive, totalSpace, freeSpace, status (normal/low/critical), dataWriteFailed
        System.out.println("\n=== System Disk ===");
        r = client.get("/api/v1/system/health?item=systemDisk");
        System.out.println("  status=" + r.status);
        if (r.status == 200) System.out.println(r.body);

        // ── System Notices ──
        // GET /api/v1/system/notices?lang=ko-KR
        // Conditions in effect right now (raised, updated, cleared).
        // message is keyed by language code: en-US is always present,
        // plus the requested lang when it is not English.
        String lang = "ko-KR";
        System.out.println("\n=== System Notices ===");
        r = client.get("/api/v1/system/notices?lang=" + lang);
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            // No JSON parser here - match each notice's kind, severity and message object
            java.util.regex.Matcher m = java.util.regex.Pattern.compile(
                    "\"kind\":\"([^\"]*)\"[^{}]*?\"severity\":\"([^\"]*)\"[^{}]*?\"message\":\\{([^{}]*)\\}")
                    .matcher(r.body);
            int count = 0;
            while (m.find()) {
                count++;
                String text = messageText(m.group(3), lang);
                System.out.println("  [" + m.group(2) + "] " + m.group(1) + ": " + text);
            }
            if (count == 0) System.out.println("  (no notices)");
        }

        // ── HDD S.M.A.R.T. Info ──
        // GET /api/v1/system/hddsmart
        System.out.println("\n=== HDD S.M.A.R.T. ===");
        r = client.get("/api/v1/system/hddsmart");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        } else {
            System.out.println("  S.M.A.R.T. may not be available");
        }
    }

    /** message[lang], or message["en-US"] when that language is absent. */
    private static String messageText(String messageObject, String lang) {
        for (String code : new String[] {lang, "en-US"}) {
            java.util.regex.Matcher m = java.util.regex.Pattern
                    .compile("\"" + code + "\":\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(messageObject);
            if (m.find()) return m.group(1);
        }
        return "";
    }
}
