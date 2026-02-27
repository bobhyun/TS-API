/**
 * v1 API - Recording Search
 *
 * Endpoints:
 *   GET /api/v1/recording/days?ch=1           - List days with recordings
 *   GET /api/v1/recording/minutes?ch=1&timeBegin=...&timeEnd=...
 *       - Minute-level recording timeline (1440-char string)
 *
 * Timeline string (1440 chars):
 *   - Index 0 = 00:00, Index 59 = 00:59, ..., Index 1439 = 23:59
 *   - '0' = no recording, '1' or higher = recording exists
 *
 * Use these endpoints to build a recording timeline calendar UI.
 *
 * Compile: kotlinc TsApiClient.kt V1_04_RecordingSearch.kt -include-runtime -d V1_04_RecordingSearch.jar
 * Run:     java -jar V1_04_RecordingSearch.jar
 */

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    val ch = 1

    // -- Days with recordings --
    // GET /api/v1/recording/days?ch={n}
    println("=== Recording Days (ch=$ch) ===")
    var r = client.get("/api/v1/recording/days?ch=$ch")
    println("  status=${r.status}")
    if (r.status == 200) {
        println("  ${r.body}")
    }

    // -- Minute-level timeline --
    // GET /api/v1/recording/minutes?ch={n}&timeBegin=YYYYMMDD&timeEnd=YYYYMMDD
    // Response: 1440-char string (1 char = 1 minute)
    val timeBegin = "20260115"
    val timeEnd = "20260116"

    println("\n=== Recording Minutes (ch=$ch, $timeBegin~$timeEnd) ===")
    r = client.get("/api/v1/recording/minutes?ch=$ch" +
        "&timeBegin=$timeBegin" +
        "&timeEnd=$timeEnd")
    println("  status=${r.status}")

    if (r.status == 200) {
        val timeline = r.body
        println("  Length: ${timeline.length} chars (expected 1440)")

        if (timeline.length >= 1440) {
            // First 60 chars (00:00~00:59)
            println("  00:00-00:59: ${timeline.substring(0, 60)}")
            // Last 60 chars (23:00~23:59)
            println("  23:00-23:59: ${timeline.substring(1380, 1440)}")

            // Parse recording segments
            parseSegments(timeline.substring(0, 1440))
        } else {
            println("  Response: $timeline")
        }
    }
}

/**
 * Parse 1440-char timeline into recording segments.
 */
private fun parseSegments(timeline: String) {
    var count = 0
    var inRec = false
    var start = 0

    println("\n  Recording segments:")

    for (i in timeline.indices) {
        if (timeline[i] != '0' && !inRec) {
            inRec = true
            start = i
        } else if (timeline[i] == '0' && inRec) {
            inRec = false
            if (count < 10) {
                println("    %02d:%02d - %02d:%02d".format(
                    start / 60, start % 60,
                    (i - 1) / 60, (i - 1) % 60))
            }
            count++
        }
    }
    if (inRec) {
        val end = timeline.length - 1
        if (count < 10) {
            println("    %02d:%02d - %02d:%02d".format(
                start / 60, start % 60, end / 60, end % 60))
        }
        count++
    }

    if (count > 10) {
        println("    ... and ${count - 10} more segments")
    }
    println("  Total: $count segments")
}
