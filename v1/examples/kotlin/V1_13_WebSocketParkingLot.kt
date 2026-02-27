/**
 * v1 API - WebSocket Parking Lot Count Monitoring
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingCount
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filter: &lot=1,2 (filter by parking lot ID)
 *
 * See also: V1_14_WebSocketParkingSpot.kt for individual spot monitoring
 *
 * Compile: kotlinc TsApiClient.kt V1_13_WebSocketParkingLot.kt -include-runtime -d V1_13_WebSocketParkingLot.jar
 * Run:     java -jar V1_13_WebSocketParkingLot.jar
 */

import java.net.URI
import java.net.http.HttpClient
import java.net.http.WebSocket
import java.util.concurrent.CompletableFuture
import java.util.concurrent.CompletionStage
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    println("=== WebSocket Parking Count Monitoring (30 seconds) ===")

    // Auth via X-API-Key header
    // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

    // Optional filter: &lot=1,2
    val wsUrl = "${client.wsUrl}/wsapi/v1/events?topics=parkingCount"

    val latch = CountDownLatch(1)
    var msgCount = 0

    val ws = HttpClient.newBuilder().sslContext(TsApiClient.trustAllContext()).build()
        .newWebSocketBuilder()
        .header("X-API-Key", client.apiKey)
        .buildAsync(URI.create(wsUrl), object : WebSocket.Listener {

            private val sb = StringBuilder()

            override fun onOpen(webSocket: WebSocket) {
                println("  Connected! Waiting for parking count events...\n")
                super.onOpen(webSocket)
            }

            override fun onText(webSocket: WebSocket, data: CharSequence, last: Boolean): CompletionStage<*> {
                sb.append(data)
                if (!last) {
                    webSocket.request(1)
                    return CompletableFuture.completedFuture(null)
                }

                val json = sb.toString()
                sb.clear()
                msgCount++

                // First message is subscription confirmation
                if (json.contains("\"subscriberId\"")) {
                    val subId = extractField(json, "subscriberId")
                    println("  Subscribed (id=$subId)")
                    webSocket.request(1)
                    return CompletableFuture.completedFuture(null)
                }

                // parkingCount: {topic, updated: [{id, name, type, maxCount, count}, ...]}
                val updStart = json.indexOf("\"updated\":[")
                if (updStart >= 0) {
                    val arrStart = json.indexOf("[", updStart) + 1
                    val arrEnd = json.lastIndexOf("]")
                    if (arrEnd > arrStart) {
                        val arrayContent = json.substring(arrStart, arrEnd)
                        val lots = arrayContent.split(Regex("\\},\\s*\\{"))
                        for (lot in lots) {
                            var obj = lot
                            if (!obj.startsWith("{")) obj = "{$obj"
                            if (!obj.endsWith("}")) obj = "$obj}"
                            val id = extractField(obj, "id")
                            val name = extractField(obj, "name")
                            val type = extractField(obj, "type")
                            val count = extractField(obj, "count")
                            val maxCount = extractField(obj, "maxCount")
                            val avail = try { maxCount.toInt() - count.toInt() } catch (_: Exception) { 0 }
                            println("  [$id] $name ($type): $count/$maxCount (available=$avail)")
                        }
                    }
                }

                webSocket.request(1)
                return CompletableFuture.completedFuture(null)
            }

            override fun onClose(webSocket: WebSocket, statusCode: Int, reason: String): CompletionStage<*> {
                latch.countDown()
                return CompletableFuture.completedFuture(null)
            }

            override fun onError(webSocket: WebSocket, error: Throwable) {
                println("  Error: ${error.message}")
                latch.countDown()
            }
        }).join()

    if (!latch.await(30, TimeUnit.SECONDS)) {
        println("\n  Received $msgCount events")
        ws.sendClose(WebSocket.NORMAL_CLOSURE, "timeout")
    }
}

private fun extractField(json: String, field: String): String {
    val strKey = "\"$field\":\""
    var start = json.indexOf(strKey)
    if (start >= 0) {
        start += strKey.length
        val end = json.indexOf("\"", start)
        return if (end > start) json.substring(start, end) else ""
    }
    val numKey = "\"$field\":"
    start = json.indexOf(numKey)
    if (start >= 0) {
        start += numKey.length
        var end = start
        while (end < json.length && (json[end].isDigit() || json[end] == '-')) end++
        return if (end > start) json.substring(start, end) else ""
    }
    return ""
}
