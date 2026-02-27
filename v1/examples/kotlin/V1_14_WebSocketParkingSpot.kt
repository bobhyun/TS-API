/**
 * v1 API - WebSocket Parking Spot Monitoring
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events?topics=parkingSpot
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Optional filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
 *
 * Events:
 *   currentStatus  - initial full state on connect
 *   statusChanged  - only changed spots
 *
 * Compile: kotlinc TsApiClient.kt V1_14_WebSocketParkingSpot.kt -include-runtime -d V1_14_WebSocketParkingSpot.jar
 * Run:     java -jar V1_14_WebSocketParkingSpot.jar
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

    println("=== WebSocket Parking Spot Monitoring (30 seconds) ===")

    // Auth via X-API-Key header
    // Alt: use ?apikey=tsapi_key_... query param (browser fallback)

    // Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
    val wsUrl = "${client.wsUrl}/wsapi/v1/events?topics=parkingSpot"

    val latch = CountDownLatch(1)
    var msgCount = 0

    val ws = HttpClient.newBuilder().sslContext(TsApiClient.trustAllContext()).build()
        .newWebSocketBuilder()
        .header("X-API-Key", client.apiKey)
        .buildAsync(URI.create(wsUrl), object : WebSocket.Listener {

            private val sb = StringBuilder()

            override fun onOpen(webSocket: WebSocket) {
                println("  Connected! Waiting for spot events...\n")
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

                val event = extractField(json, "event")

                when (event) {
                    "currentStatus" -> {
                        println("  [currentStatus] initial state")
                        println("    $json")
                    }
                    "statusChanged" -> {
                        println("  [statusChanged]")
                        println("    $json")
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
    val key = "\"$field\":\""
    val start = json.indexOf(key)
    if (start >= 0) {
        val s = start + key.length
        val end = json.indexOf("\"", s)
        return if (end > s) json.substring(s, end) else ""
    }
    return ""
}
