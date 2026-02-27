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
 *   GET /api/v1/system/hddsmart            - HDD S.M.A.R.T. data
 *
 * NOTE: The 'storage' query returns data with response field named 'disk' (NOT 'storage').
 *
 * Compile: kotlinc TsApiClient.kt V1_08_SystemInfo.kt -include-runtime -d V1_08_SystemInfo.jar
 * Run:     java -jar V1_08_SystemInfo.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- All NVR Info --
    // GET /api/v1/info?all
    println("=== NVR Info ===")
    var r = client.get("/api/v1/info?all")
    println("  status=${r.status}")
    if (r.status == 200) println(r.body)

    // -- OS Info --
    // GET /api/v1/system/info?item=os
    println("\n=== OS Info ===")
    r = client.get("/api/v1/system/info?item=os")
    println("  status=${r.status}")
    if (r.status == 200) println(r.body)

    // -- CPU Info --
    // GET /api/v1/system/info?item=cpu
    println("\n=== CPU Info ===")
    r = client.get("/api/v1/system/info?item=cpu")
    println("  status=${r.status}")
    if (r.status == 200) println(r.body)

    // -- Storage Info --
    // GET /api/v1/system/info?item=storage
    // NOTE: Response field is 'disk' (NOT 'storage')
    println("\n=== Storage Info ===")
    r = client.get("/api/v1/system/info?item=storage")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
        // Look for "disk" field in the JSON response
    }

    // -- Network Info --
    // GET /api/v1/system/info?item=network
    println("\n=== Network Info ===")
    r = client.get("/api/v1/system/info?item=network")
    println("  status=${r.status}")
    if (r.status == 200) println(r.body)

    // -- System Health --
    // GET /api/v1/system/health
    println("\n=== System Health ===")
    r = client.get("/api/v1/system/health")
    println("  status=${r.status}")
    if (r.status == 200) println(r.body)

    // -- HDD S.M.A.R.T. Info --
    // GET /api/v1/system/hddsmart
    println("\n=== HDD S.M.A.R.T. ===")
    r = client.get("/api/v1/system/hddsmart")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    } else {
        println("  S.M.A.R.T. may not be available")
    }
}
