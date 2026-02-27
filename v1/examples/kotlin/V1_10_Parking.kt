/**
 * v1 API - Parking Management
 *
 * Endpoints:
 *   GET /api/v1/parking/lot           - List parking lots
 *   GET /api/v1/parking/lot/status    - Lot occupancy status
 *   GET /api/v1/parking/spot          - List parking spots
 *   GET /api/v1/parking/spot/status   - Individual spot status
 *
 * Compile: kotlinc TsApiClient.kt V1_10_Parking.kt -include-runtime -d V1_10_Parking.jar
 * Run:     java -jar V1_10_Parking.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- Parking Lots --
    // GET /api/v1/parking/lot
    println("=== Parking Lots ===")
    var r = client.get("/api/v1/parking/lot")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Lot Occupancy Status --
    // GET /api/v1/parking/lot/status
    println("\n=== Parking Lot Status ===")
    r = client.get("/api/v1/parking/lot/status")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Parking Spots --
    // GET /api/v1/parking/spot
    println("\n=== Parking Spots ===")
    r = client.get("/api/v1/parking/spot")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Spot Status --
    // GET /api/v1/parking/spot/status
    println("\n=== Parking Spot Status ===")
    r = client.get("/api/v1/parking/spot/status")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }
}
