/**
 * v1 API - WebSocket Recording Export
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Flow:
 *   ready   -> task ID, channel info
 *   fileEnd -> download URL, send {task, cmd:"next"}
 *   end     -> export complete
 *   error   -> error message
 *
 * Compile: kotlinc TsApiClient.kt V1_15_WebSocketExport.kt -include-runtime -d V1_15_WebSocketExport.jar
 * Run:     java -jar V1_15_WebSocketExport.jar
 */

import java.net.URI
import java.net.http.HttpClient
import java.net.http.WebSocket
import java.time.LocalDate
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

    // Time range: yesterday 00:00 ~ 00:10
    val yesterday = LocalDate.now().minusDays(1).toString()
    val timeBegin = "${yesterday}T00:00:00"
    val timeEnd = "${yesterday}T00:10:00"

    println("=== WebSocket Recording Export ===")
    println("  Channel: 1,  $timeBegin ~ $timeEnd")

    // Auth via X-API-Key header
    // Alt: use ?apikey=tsapi_key_... query param (browser fallback)
    val wsUrl = "${client.wsUrl}/wsapi/v1/export" +
            "?ch=1&timeBegin=$timeBegin&timeEnd=$timeEnd"

    val latch = CountDownLatch(1)
    var taskId: String? = null

    val ws = HttpClient.newBuilder().sslContext(TsApiClient.trustAllContext()).build()
        .newWebSocketBuilder()
        .header("X-API-Key", client.apiKey)
        .buildAsync(URI.create(wsUrl), object : WebSocket.Listener {

            private val sb = StringBuilder()

            override fun onOpen(webSocket: WebSocket) {
                println("  Connected")
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

                val stage = extractField(json, "stage")

                when (stage) {
                    "ready" -> {
                        // Check status code (code:-1 = no recording in range)
                        if (json.contains("\"code\"") && !json.contains("\"code\":0")) {
                            val errMsg = extractField(json, "message")
                            println("  Ready - Error: ${if (errMsg.isEmpty()) json else errMsg}")
                            latch.countDown()
                        } else {
                            taskId = extractField(json, "id")
                            println("  Ready - Task ID: $taskId")
                        }
                    }
                    "fileEnd" -> {
                        // download: [{fileName, src}, ...]
                        val src = extractField(json, "src")
                        println("  File ready: ${if (src.isEmpty()) "N/A" else src}")
                        taskId?.let {
                            webSocket.sendText("""{"task":"$it","cmd":"next"}""", true)
                        }
                    }
                    "end" -> {
                        println("  Export complete!")
                        webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "done")
                        latch.countDown()
                    }
                    "error" -> {
                        val message = extractField(json, "message")
                        println("  Error: ${if (message.isEmpty()) json else message}")
                        webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "error")
                        latch.countDown()
                    }
                    else -> println("  [$stage] $json")
                }

                webSocket.request(1)
                return CompletableFuture.completedFuture(null)
            }

            override fun onClose(webSocket: WebSocket, statusCode: Int, reason: String): CompletionStage<*> {
                println("  Disconnected")
                latch.countDown()
                return CompletableFuture.completedFuture(null)
            }

            override fun onError(webSocket: WebSocket, error: Throwable) {
                println("  Error: ${error.message}")
                latch.countDown()
            }
        }).join()

    // Wait up to 60 seconds
    if (!latch.await(60, TimeUnit.SECONDS)) {
        println("  Timeout - cancelling...")
        taskId?.let { ws.sendText("""{"task":"$it","cmd":"cancel"}""", true) }
        Thread.sleep(1000)
        ws.sendClose(WebSocket.NORMAL_CLOSURE, "timeout")
    }
}

/** Extract a simple JSON string field value. */
private fun extractField(json: String, field: String): String {
    val key = "\"$field\":\""
    val start = json.indexOf(key)
    if (start < 0) return ""
    val valueStart = start + key.length
    val end = json.indexOf("\"", valueStart)
    return if (end > valueStart) json.substring(valueStart, end) else ""
}
