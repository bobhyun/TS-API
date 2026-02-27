/**
 * v1 API - PTZ Control (Pan/Tilt/Zoom)
 *
 * Endpoints:
 *   GET /api/v1/channel/{chid}/ptz?home            - Move to home position
 *   GET /api/v1/channel/{chid}/ptz?move=x,y        - Continuous move (x,y: -1.0 ~ 1.0)
 *   GET /api/v1/channel/{chid}/ptz?zoom=speed       - Zoom (positive=in, negative=out)
 *   GET /api/v1/channel/{chid}/ptz?focus=speed      - Focus (positive=far, negative=near)
 *   GET /api/v1/channel/{chid}/ptz?iris=speed       - Iris (positive=open, negative=close)
 *   GET /api/v1/channel/{chid}/ptz?stop             - Stop all PTZ movement
 *   GET /api/v1/channel/{chid}/preset               - List presets
 *   GET /api/v1/channel/{chid}/preset/{token}/go    - Go to preset
 *
 * NOTE: PTZ may return HTTP 500 if camera does not support ONVIF PTZ.
 *       Always call stop after move/zoom commands.
 *
 * Compile: kotlinc TsApiClient.kt V1_03_PtzControl.kt -include-runtime -d V1_03_PtzControl.jar
 * Run:     java -jar V1_03_PtzControl.jar
 */

private const val CHID = 1 // Target channel

fun main() {
    val client = TsApiClient()
    if (client.apiKey.isEmpty()) {
        System.err.println("NVR_API_KEY environment variable is required")
        return
    }
    client.setApiKey(client.apiKey)

    // -- Go Home --
    println("=== PTZ Home ===")
    var r = client.get("/api/v1/channel/$CHID/ptz?home")
    println("  home -> ${r.status}")
    if (r.status == 500) {
        println("  PTZ unavailable (ONVIF not supported or camera offline)")
        return
    }
    Thread.sleep(2000)

    // -- Continuous Move (pan right, tilt up) --
    // x=0.5 (pan right at half speed), y=0.3 (tilt up at 30%)
    println("\n=== PTZ Move ===")
    r = client.get("/api/v1/channel/$CHID/ptz?move=0.5,0.3")
    println("  move=0.5,0.3 -> ${r.status}")
    Thread.sleep(1000)

    // -- Stop (Must call) --
    r = client.get("/api/v1/channel/$CHID/ptz?stop")
    println("  stop -> ${r.status}")

    // -- Zoom In --
    println("\n=== PTZ Zoom ===")
    r = client.get("/api/v1/channel/$CHID/ptz?zoom=0.5")
    println("  zoom=0.5 (in) -> ${r.status}")
    Thread.sleep(1000)
    client.get("/api/v1/channel/$CHID/ptz?stop")

    // -- Zoom Out --
    r = client.get("/api/v1/channel/$CHID/ptz?zoom=-0.5")
    println("  zoom=-0.5 (out) -> ${r.status}")
    Thread.sleep(1000)
    client.get("/api/v1/channel/$CHID/ptz?stop")

    // -- Focus --
    println("\n=== PTZ Focus ===")
    r = client.get("/api/v1/channel/$CHID/ptz?focus=0.5")
    println("  focus=0.5 (far) -> ${r.status}")
    Thread.sleep(1000)
    client.get("/api/v1/channel/$CHID/ptz?stop")

    // -- Iris --
    println("\n=== PTZ Iris ===")
    r = client.get("/api/v1/channel/$CHID/ptz?iris=0.5")
    println("  iris=0.5 (open) -> ${r.status}")
    Thread.sleep(1000)
    client.get("/api/v1/channel/$CHID/ptz?stop")

    // -- List Presets --
    println("\n=== Presets ===")
    r = client.get("/api/v1/channel/$CHID/preset")
    println("  presets -> ${r.status}")
    if (r.status == 200) {
        println(r.body)

        // -- Go to Preset --
        // GET /api/v1/channel/{chid}/preset/{token}/go
        // Use a token value from the preset list above
        // Example: client.get("/api/v1/channel/$CHID/preset/1/go")
    }
}
