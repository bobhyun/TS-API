/**
 * v1 API - Video on Demand / Playback
 *
 * Endpoints:
 *   GET /api/v1/vod
 *       - List available VOD streams
 *       - Response: [{chid, title, src: {rtmp, flv}}, ...]
 *       - NOTE: stream URLs are in 'src' field (NOT 'streams')
 *
 *   GET /api/v1/vod?protocol=rtmp   - Filter RTMP protocol only
 *   GET /api/v1/vod?stream=sub      - Filter sub stream only
 *
 * VOD playback requires specifying a time range via the stream URL parameters.
 *
 * Compile: javac NvrClient.java V1_07_VodStream.java
 * Run:     java V1_07_VodStream
 */
public class V1_07_VodStream {

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── List all VOD streams ──
        // GET /api/v1/vod
        // Response: [{chid, title, src: {rtmp, flv}}, ...]
        // Stream URLs are in 'src' field (NOT "streams")
        System.out.println("=== VOD Streams ===");
        NvrClient.Response r = client.get("/api/v1/vod");
        System.out.println("  status=" + r.status);
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Filter by protocol (RTMP only) ──
        // GET /api/v1/vod?protocol=rtmp
        System.out.println("\n=== VOD - RTMP only ===");
        r = client.get("/api/v1/vod?protocol=rtmp");
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Filter by stream type (Sub stream only) ──
        // GET /api/v1/vod?stream=sub
        System.out.println("\n=== VOD - Sub stream ===");
        r = client.get("/api/v1/vod?stream=sub");
        if (r.status == 200) {
            System.out.println(r.body);
        }

        // ── Playback URL Example ──
        // Append time parameters to the stream URL for playback
        //
        // RTMP playback:
        //   rtmp://host:port/live/1
        //       ?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
        //
        // FLV playback:
        //   http://host:port/live/1.flv
        //       ?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
        System.out.println("\n=== Playback URL Example ===");
        System.out.println("  RTMP: rtmp://" + client.host + ":" + client.port
                + "/live/1"
                + "?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00");
        System.out.println("  FLV:  http://" + client.host + ":" + client.port
                + "/live/1.flv"
                + "?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00");
    }
}
