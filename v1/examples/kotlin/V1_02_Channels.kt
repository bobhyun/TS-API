/**
 * v1 API - Channel List & Status
 *
 * Endpoints:
 *   GET /api/v1/channel                           - List all channels
 *   GET /api/v1/channel?staticSrc                 - Include static stream URLs
 *   GET /api/v1/channel?caps                      - Include channel capabilities
 *   GET /api/v1/channel/status?recordingStatus     - Per-channel recording status
 *   GET /api/v1/channel/{chid}/info?caps          - Individual channel capabilities
 *
 * Channel fields: chid, title, displayName (NOT 'name')
 *
 * Compile: kotlinc TsApiClient.kt V1_02_Channels.kt -include-runtime -d V1_02_Channels.jar
 * Run:     java -jar V1_02_Channels.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- List all channels --
    // GET /api/v1/channel
    // Response: [{chid, title, displayName, ...}, ...]
    var r = client.get("/api/v1/channel")
    println("=== Channels === status=${r.status}")
    println(r.body)

    // -- Static source URLs --
    // GET /api/v1/channel?staticSrc
    // Includes RTMP/FLV addresses
    r = client.get("/api/v1/channel?staticSrc")
    println("\n=== Channels with staticSrc ===")
    println(r.body)

    // -- Channel capabilities --
    // GET /api/v1/channel?caps
    r = client.get("/api/v1/channel?caps")
    println("\n=== Channels with caps ===")
    println(r.body)

    // -- Recording status --
    // GET /api/v1/channel/status?recordingStatus
    r = client.get("/api/v1/channel/status?recordingStatus")
    println("\n=== Recording Status ===")
    println(r.body)

    // -- Single channel capabilities --
    // GET /api/v1/channel/{chid}/info?caps
    val chid = 1
    r = client.get("/api/v1/channel/$chid/info?caps")
    println("\n=== Channel $chid Capabilities === status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }
}
