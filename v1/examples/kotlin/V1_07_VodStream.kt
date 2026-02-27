/**
 * v1 API - VOD (Video on Demand / Playback)
 *
 * Endpoints:
 *   GET /api/v1/vod
 *       - List available VOD streams
 *       - Response: [{chid, title, src: {rtmp, flv}}, ...]
 *       - NOTE: stream URLs are in 'src' field (NOT 'streams')
 *
 *   GET /api/v1/vod?protocol=rtmp   - Filter by RTMP protocol only
 *   GET /api/v1/vod?stream=sub      - Filter by sub stream only
 *
 * VOD playback requires specifying a time range via the stream URL parameters.
 *
 * Compile: kotlinc TsApiClient.kt V1_07_VodStream.kt -include-runtime -d V1_07_VodStream.jar
 * Run:     java -jar V1_07_VodStream.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- List all VOD streams --
    // GET /api/v1/vod
    // Response: [{chid, title, src: {rtmp, flv}}, ...]
    // Stream URLs in 'src' field (NOT "streams")
    println("=== VOD Streams ===")
    var r = client.get("/api/v1/vod")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Filter by protocol --
    // GET /api/v1/vod?protocol=rtmp
    println("\n=== VOD - RTMP only ===")
    r = client.get("/api/v1/vod?protocol=rtmp")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Filter by stream type --
    // GET /api/v1/vod?stream=sub
    println("\n=== VOD - Sub stream ===")
    r = client.get("/api/v1/vod?stream=sub")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Playback URL Example --
    // Append time parameters to the stream URL for playback
    //
    // RTMP playback:
    //   rtmp://host:port/live/1
    //       ?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
    //
    // FLV playback:
    //   http://host:port/live/1.flv
    //       ?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00
    println("\n=== Playback URL Example ===")
    println("  RTMP: rtmp://${client.host}:${client.port}" +
        "/live/1" +
        "?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00")
    println("  FLV:  http://${client.host}:${client.port}" +
        "/live/1.flv" +
        "?begin=2026-01-15T10:00:00&end=2026-01-15T11:00:00")
}
