/**
 * v1 API - Event Log Search
 *
 * Endpoints:
 *   GET /api/v1/event/type
 *       - List event types with nested codes
 *       - Response: [{id, name, code: [{id, name}]}, ...]
 *       - NOTE: field is 'id' (NOT 'type'), nested array is 'code'
 *
 *   GET /api/v1/event/log?maxCount=10
 *       - Query event log
 *       - Optional: timeBegin, timeEnd, offset, limit
 *
 * Compile: kotlinc TsApiClient.kt V1_05_EventLog.kt -include-runtime -d V1_05_EventLog.jar
 * Run:     java -jar V1_05_EventLog.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- Event Types --
    // GET /api/v1/event/type
    // Response: [{id, name, code: [{id, name}]}, ...]
    // Uses 'id' field (NOT "type")
    println("=== Event Types ===")
    var r = client.get("/api/v1/event/type")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Event Log --
    // GET /api/v1/event/log?maxCount={n}
    // Returns up to n most recent events
    println("\n=== Event Log (maxCount=10) ===")
    r = client.get("/api/v1/event/log?maxCount=10")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Time-ranged Event Log --
    // GET /api/v1/event/log?timeBegin=YYYYMMDD&timeEnd=YYYYMMDD&maxCount=20
    val timeBegin = "20260101"
    val timeEnd = "20260201"
    println("\n=== Event Log ($timeBegin ~ $timeEnd) ===")
    r = client.get("/api/v1/event/log" +
        "?timeBegin=$timeBegin" +
        "&timeEnd=$timeEnd" +
        "&maxCount=20")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Pagination --
    // Use offset and limit for pagination
    // Example:
    //   page 1: /api/v1/event/log?offset=0&limit=20
    //   page 2: /api/v1/event/log?offset=20&limit=20
}
