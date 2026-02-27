/**
 * v1 API - Push Notification
 *
 * Endpoint:
 *   POST /api/v1/push
 *       - Push external events into the NVR
 *       - Requires Push license enabled on the server
 *
 * Event types:
 *   1. LPR - Push plate recognition result
 *   2. emergencyCall - Trigger emergency alarm
 *
 * WARNING: emergencyCall with action=callStart triggers a REAL alarm on the NVR.
 *          The alarm persists until callEnd is sent.
 *          ALWAYS send callEnd after callStart.
 *
 * WARNING (repeated): emergencyCall callStart triggers a REAL alarm.
 *       You MUST send callEnd to stop the alarm.
 *
 * Compile: kotlinc TsApiClient.kt V1_09_Push.kt -include-runtime -d V1_09_Push.jar
 * Run:     java -jar V1_09_Push.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    pushLprEvent(client)
    pushEmergencyCall(client)
}

/**
 * LPR Push - Push a license plate recognition event.
 */
private fun pushLprEvent(client: TsApiClient) {
    println("=== Push LPR Event ===")

    val payload = """{"type":"LPR","plate":"12AB3456","chid":1,"time":"2026-01-15 10:30:00"}"""

    val r = client.post("/api/v1/push", payload)
    println("  status=${r.status}")
    if (r.status == 200) {
        println("  ${r.body}")
    } else {
        println("  Ensure Push license is enabled")
    }
}

/**
 * Emergency Call Push - Push an emergency call event.
 *
 * WARNING: callStart triggers a REAL alarm on the NVR!
 * You MUST send callEnd to stop it.
 */
private fun pushEmergencyCall(client: TsApiClient) {
    println("\n=== Push Emergency Call ===")
    println("  WARNING: This triggers a REAL alarm on the NVR!")

    // Uncomment the code below to actually trigger the alarm.
    // Make sure you always send callEnd after callStart.
    // Uncomment the code below to actually trigger the alarm.
    // Make sure you always send callEnd after callStart.

    /*
    // -- callStart: Start alarm --
    println("  Sending callStart...")
    val callStart = """{"type":"emergencyCall","action":"callStart","chid":1}"""
    var r = client.post("/api/v1/push", callStart)
    println("  callStart -> ${r.status}")

    Thread.sleep(3000) // Alarm active for 3 seconds

    // -- callEnd: Stop alarm (REQUIRED!) --
    println("  Sending callEnd...")
    val callEnd = """{"type":"emergencyCall","action":"callEnd","chid":1}"""
    r = client.post("/api/v1/push", callEnd)
    println("  callEnd -> ${r.status}")
    */

    println("  (Commented out for safety - uncomment to test)")
    println("  IMPORTANT: Always send callEnd after callStart!")
}
