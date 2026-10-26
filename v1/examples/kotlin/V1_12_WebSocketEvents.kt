/**
 * v1 API - WebSocket Real-time Event Subscription
 *
 * Subscribes to real-time events (LPR, channelStatus, notice, etc.) via WebSocket.
 *
 * Two subscription modes:
 *   1. URL query params:  ?topics=LPR,channelStatus,notice  (subscribe on connect)
 *   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/events
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Compile: kotlinc TsApiClient.kt V1_12_WebSocketEvents.kt -include-runtime -d V1_12_WebSocketEvents.jar
 * Run:     java -jar V1_12_WebSocketEvents.jar
 */

import java.net.URI
import java.net.http.HttpClient
import java.net.http.WebSocket
import java.util.concurrent.CompletableFuture
import java.util.concurrent.CompletionStage
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger

const val LANG = "ko-KR"

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    val wsUrl = client.wsUrl

    // -- Method 1: Subscribe via URL query params (classic) --
    println("=== Method 1: Subscribe via URL (10 seconds) ===")

    run {
        val url = "$wsUrl/wsapi/v1/events?topics=LPR,channelStatus,notice&lang=$LANG"
        val messageCount = AtomicInteger(0)
        val closeLatch = CountDownLatch(1)

        val ws = HttpClient.newBuilder().sslContext(TsApiClient.trustAllContext()).build()
            .newWebSocketBuilder()
            .header("X-API-Key", client.apiKey)
            .buildAsync(URI.create(url), object : WebSocket.Listener {

                override fun onOpen(webSocket: WebSocket) {
                    println("  Connected!")
                    super.onOpen(webSocket)
                }

                override fun onText(
                    webSocket: WebSocket, data: CharSequence, last: Boolean
                ): CompletionStage<*> {
                    messageCount.incrementAndGet()
                    printEvent(data.toString())
                    webSocket.request(1)
                    return CompletableFuture.completedFuture(null)
                }

                override fun onClose(
                    webSocket: WebSocket, statusCode: Int, reason: String
                ): CompletionStage<*> {
                    closeLatch.countDown()
                    return CompletableFuture.completedFuture(null)
                }

                override fun onError(webSocket: WebSocket, error: Throwable) {
                    println("  Error: ${error.message}")
                    closeLatch.countDown()
                }
            }).join()

        closeLatch.await(10, TimeUnit.SECONDS)
        println("  Received ${messageCount.get()} events")

        if (!ws.isOutputClosed) {
            ws.sendClose(WebSocket.NORMAL_CLOSURE, "done").join()
        }
    }

    // -- Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) --
    //   - Connect WITHOUT topics
    //   - Subscribe/unsubscribe at any time
    //   - Per-topic filters (ch, objectTypes, lot, spot)
    //   - Re-subscribe to update filters
    println("\n=== Method 2: Dynamic Subscribe (10 seconds) ===")

    run {
        val url = "$wsUrl/wsapi/v1/events"
        val messageCount = AtomicInteger(0)
        val closeLatch = CountDownLatch(1)

        val ws = HttpClient.newBuilder().sslContext(TsApiClient.trustAllContext()).build()
            .newWebSocketBuilder()
            .header("X-API-Key", client.apiKey)
            .buildAsync(URI.create(url), object : WebSocket.Listener {

                override fun onOpen(webSocket: WebSocket) {
                    println("  Connected (no topics yet)")

                    // Phase 1: Subscribe to initial topics with per-topic filters
                    println("  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)")
                    webSocket.sendText("""{"subscribe":"channelStatus"}""", true)
                    webSocket.sendText("""{"subscribe":"LPR","ch":[1,2]}""", true)

                    // Schedule mid-connection topic changes
                    Thread {
                        try {
                            // Phase 2 (3s): Add new topic + update existing filter
                            Thread.sleep(3000)
                            println("  [Phase 2] Add object topic + expand LPR to ch 1-4")
                            webSocket.sendText("""{"subscribe":"object","objectTypes":["human","vehicle"]}""", true)
                            webSocket.sendText("""{"subscribe":"LPR","ch":[1,2,3,4]}""", true)

                            // Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
                            Thread.sleep(3000)
                            println("  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3")
                            webSocket.sendText("""{"unsubscribe":"channelStatus"}""", true)
                            webSocket.sendText("""{"subscribe":"motionChanges","ch":[1]}""", true)
                            webSocket.sendText("""{"subscribe":"LPR","ch":[1,3]}""", true)  // re-subscribe replaces the filter (drops ch 2,4)
                        } catch (_: Exception) { }
                    }.start()

                    super.onOpen(webSocket)
                }

                override fun onText(
                    webSocket: WebSocket, data: CharSequence, last: Boolean
                ): CompletionStage<*> {
                    messageCount.incrementAndGet()
                    val text = data.toString()
                    val typeRegex = """"type"\s*:\s*"([^"]+)"""".toRegex()
                    val topicRegex = """"topic"\s*:\s*"([^"]+)"""".toRegex()
                    val type = typeRegex.find(text)?.groupValues?.get(1) ?: ""
                    val topic = topicRegex.find(text)?.groupValues?.get(1) ?: ""

                    // Handle control responses
                    when (type) {
                        "subscribed" -> println("  Subscribed to: $topic")
                        "unsubscribed" -> println("  Unsubscribed from: $topic")
                        "error" -> {
                            val msgRegex = """"message"\s*:\s*"([^"]+)"""".toRegex()
                            val msg = msgRegex.find(text)?.groupValues?.get(1) ?: ""
                            println("  Error: $msg (topic: $topic)")
                        }
                        else -> {
                            // Event data
                            printEvent(text)
                        }
                    }
                    webSocket.request(1)
                    return CompletableFuture.completedFuture(null)
                }

                override fun onClose(
                    webSocket: WebSocket, statusCode: Int, reason: String
                ): CompletionStage<*> {
                    closeLatch.countDown()
                    return CompletableFuture.completedFuture(null)
                }

                override fun onError(webSocket: WebSocket, error: Throwable) {
                    println("  Error: ${error.message}")
                    closeLatch.countDown()
                }
            }).join()

        closeLatch.await(10, TimeUnit.SECONDS)
        println("  Received ${messageCount.get()} messages")

        if (!ws.isOutputClosed) {
            ws.sendClose(WebSocket.NORMAL_CLOSURE, "done").join()
        }
    }
}

/** Print LPR and notice events by field; other topics as raw JSON (no JSON library). */
private fun printEvent(text: String) {
    fun match(s: String, regex: String, def: String) =
        regex.toRegex().find(s)?.groupValues?.get(1) ?: def

    when (val topic = extractField(text, "topic")) {
        "LPR" -> {
            // id: record id for plate correction (absent when the record could not be saved)
            // direction: "entry" / "exit" (absent when unknown)
            // Drop nested objects so each plate (plates[] item, or the message itself) is flat
            val flat = text.replace(""""(roi|parkingLot|channel)":\{[^{}]*\}""".toRegex(), "\"$1\":0")
            for (m in """\{[^{}]*"plateNo"[^{}]*\}""".toRegex().findAll(flat)) {
                val p = m.value
                println("  [LPR] id=${match(p, """"id":(\d+)""", "-")}" +
                    " plateNo=${match(p, """"plateNo":(null|"[^"]*")""", "-")}" +
                    " score=${match(p, """"score":([-0-9.eE+]+)""", "-")}" +
                    " direction=${match(p, """"direction":"([^"]*)"""", "-")}")
            }
        }
        "notice" -> {
            // snapshot: current list once after subscribing (notices[]);
            // raised/updated/cleared: one notice (notice).
            // message is keyed by language code: en-US always, plus the requested lang
            val action = extractField(text, "action")
            val notices = """"id":"([^"]*)"[^{}]*?"severity":"([^"]*)"[^{}]*?"message":\{([^{}]*)\}"""
                .toRegex().findAll(text).toList()
            if (notices.isEmpty()) println("  [notice] $action: (no notices)")
            for (n in notices) {
                val (id, severity, message) = n.destructured
                val msg = match(message, """"$LANG":"((?:[^"\\]|\\.)*)"""",
                    match(message, """"en-US":"((?:[^"\\]|\\.)*)"""", ""))
                println("  [notice] $action $id $severity: $msg")
            }
        }
        else -> {
            val t = topic.ifEmpty { extractField(text, "type") }.ifEmpty { "?" }
            println("  [$t] $text")
        }
    }
}

private fun extractField(json: String, field: String): String {
    val key = "\"$field\":\""
    val start = json.indexOf(key)
    if (start < 0) return ""
    val valueStart = start + key.length
    val end = json.indexOf("\"", valueStart)
    return if (end > valueStart) json.substring(valueStart, end) else ""
}

/*
 * ─────────────────────────────────────────────────
 * LPR Event Compatibility
 * ─────────────────────────────────────────────────
 *
 * LPR events may arrive in two formats:
 *
 *   v1.0.0 (single plate):  { "topic": "LPR", "plateNo": "12가3456", ... }
 *   v1.0.1 (batch/array):   { "topic": "LPR", "plates": [ { "plateNo": "12가3456", ... }, ... ] }
 *
 * To handle both formats with org.json or kotlinx.serialization:
 *
 *   val msg = JSONObject(text)
 *   if (msg.optString("topic") == "LPR") {
 *       val plates = if (msg.has("plates"))
 *           msg.getJSONArray("plates")            // v1.0.1 batch format
 *       else
 *           JSONArray().apply { put(msg) }        // v1.0.0 single-plate format
 *
 *       for (i in 0 until plates.length()) {
 *           val p = plates.getJSONObject(i)
 *           println("Plate: ${p.optString("plateNo")}  Score: ${p.optDouble("score")}")
 *       }
 *   }
 *
 * Each plate carries the record "id" (use it with POST /api/v1/lpr/log/{id}/plate)
 * and "direction" as a string ("entry" / "exit"), not a number.
 */
