/**
 * v1 API - LPR / License Plate Recognition
 *
 * Endpoints:
 *   GET /api/v1/lpr/source
 *       - List LPR-enabled cameras
 *
 *   GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
 *       - Search recognition log
 *       - timeBegin, timeEnd REQUIRED
 *
 *   GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
 *       - Similar/fuzzy plate search
 *
 * WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
 *   errors. For bulk exports, narrow the time range or use pagination
 *   (at/maxCount) to keep each request under a manageable size.
 *
 * Compile: kotlinc TsApiClient.kt V1_06_LprSearch.kt -include-runtime -d V1_06_LprSearch.jar
 * Run:     java -jar V1_06_LprSearch.jar
 */

import java.net.URLEncoder

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- LPR Sources --
    // GET /api/v1/lpr/source
    println("=== LPR Sources ===")
    var r = client.get("/api/v1/lpr/source")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- LPR Log --
    // GET /api/v1/lpr/log?timeBegin=...&timeEnd=...
    // timeBegin, timeEnd REQUIRED
    val timeBegin = "20260101"
    val timeEnd = "20260201"

    println("\n=== LPR Log ($timeBegin ~ $timeEnd) ===")
    r = client.get("/api/v1/lpr/log" +
        "?timeBegin=$timeBegin" +
        "&timeEnd=$timeEnd")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Similar Plate Search --
    // GET /api/v1/lpr/similar?keyword=...&timeBegin=...&timeEnd=...
    // Partial/fuzzy plate match
    val keyword = "3456"
    println("\n=== Similar Plates (keyword=\"$keyword\") ===")
    r = client.get("/api/v1/lpr/similar" +
        "?keyword=${URLEncoder.encode(keyword, "UTF-8")}" +
        "&timeBegin=$timeBegin" +
        "&timeEnd=$timeEnd")
    println("  status=${r.status}")
    if (r.status == 200) {
        println(r.body)
    }

    // -- Export --
    // GET /api/v1/lpr/log?timeBegin=...&timeEnd=...&export=true
    // Adding export=true returns file download (CSV, etc.)
    println("\n=== Export LPR Log ===")
    r = client.get("/api/v1/lpr/log" +
        "?timeBegin=$timeBegin" +
        "&timeEnd=$timeEnd" +
        "&export=true")
    println("  status=${r.status}")
    if (r.status == 200) {
        println("  body length: ${r.body.length} chars")
        // To save to file:
        // java.nio.file.Files.writeString(
        //     java.nio.file.Path.of("lpr_export.csv"), r.body)
    }
}
