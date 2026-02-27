/**
 * v1 API - Emergency Call Device List
 *
 * Endpoint:
 *   GET /api/v1/emergency  - Emergency call device list
 *
 * Response: [{ id, code, name, linkedChannel }, ...]
 * Note: Requires Emergency Call license. Returns 404 if not supported.
 *
 * Compile: kotlinc TsApiClient.kt V1_11_Emergency.kt -include-runtime -d V1_11_Emergency.jar
 * Run:     java -jar V1_11_Emergency.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- Emergency call device list --
    // GET /api/v1/emergency
    val r = client.get("/api/v1/emergency")
    println("=== Emergency Call Devices === status=${r.status}")

    if (r.status == 404) {
        println("  Emergency Call not enabled on this server (license required)")
    } else if (r.status == 200) {
        println(r.body)
    }
}
