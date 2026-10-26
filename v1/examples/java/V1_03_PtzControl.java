/**
 * v1 API - PTZ Control (Pan/Tilt/Zoom)
 *
 * Endpoints:
 *   GET /api/v1/channel/{chid}/ptz?home           - Go to home position
 *   GET /api/v1/channel/{chid}/ptz?move=x,y       - Continuous move (x,y: -1.0 ~ 1.0; +x=right, +y=down)
 *   GET /api/v1/channel/{chid}/ptz?zoom=speed     - Zoom (positive=in, negative=out)
 *   GET /api/v1/channel/{chid}/ptz?focus=speed    - Focus (positive=far, negative=near)
 *   GET /api/v1/channel/{chid}/ptz?iris=speed     - Iris (positive=open, negative=close)
 *   GET /api/v1/channel/{chid}/ptz?stop           - Stop all PTZ movement
 *   GET /api/v1/channel/{chid}/preset             - List presets
 *   GET /api/v1/channel/{chid}/preset/{token}/go  - Go to preset
 *
 * NOTE: Returns HTTP 500 if the camera does not support ONVIF PTZ or is unreachable.
 *       Always call stop after move/zoom/focus/iris.
 *
 * Compile: javac NvrClient.java V1_03_PtzControl.java
 * Run:     java V1_03_PtzControl
 */
public class V1_03_PtzControl {

    static final int CHID = 1; // Target channel

    public static void main(String[] args) throws Exception {
        NvrClient client = new NvrClient();
        if (client.getApiKey() == null || client.getApiKey().isEmpty()) {
            System.err.println("NVR_API_KEY environment variable is required");
            return;
        }
        client.setApiKey(client.getApiKey());

        // ── Go Home ──
        System.out.println("=== PTZ Home ===");
        NvrClient.Response r = client.get(
                "/api/v1/channel/" + CHID + "/ptz?home");
        System.out.println("  home -> " + r.status);
        if (r.status == 500) {
            System.out.println("  PTZ unavailable (ONVIF not supported or camera offline)");
            return;
        }
        Thread.sleep(2000);

        // ── Continuous Move (pan right, tilt down) ──
        // x=0.5 (pan right at half speed), y=0.3 (tilt down at 30% speed)
        System.out.println("\n=== PTZ Move ===");
        r = client.get("/api/v1/channel/" + CHID + "/ptz?move=0.5,0.3");
        System.out.println("  move=0.5,0.3 -> " + r.status);
        Thread.sleep(1000);

        // ── Stop (required after move) ──
        r = client.get("/api/v1/channel/" + CHID + "/ptz?stop");
        System.out.println("  stop -> " + r.status);

        // ── Zoom In ──
        System.out.println("\n=== PTZ Zoom ===");
        r = client.get("/api/v1/channel/" + CHID + "/ptz?zoom=0.5");
        System.out.println("  zoom=0.5 (in) -> " + r.status);
        Thread.sleep(1000);
        client.get("/api/v1/channel/" + CHID + "/ptz?stop");

        // ── Zoom Out ──
        r = client.get("/api/v1/channel/" + CHID + "/ptz?zoom=-0.5");
        System.out.println("  zoom=-0.5 (out) -> " + r.status);
        Thread.sleep(1000);
        client.get("/api/v1/channel/" + CHID + "/ptz?stop");

        // ── Focus ──
        System.out.println("\n=== PTZ Focus ===");
        r = client.get("/api/v1/channel/" + CHID + "/ptz?focus=0.5");
        System.out.println("  focus=0.5 (far) -> " + r.status);
        Thread.sleep(1000);
        client.get("/api/v1/channel/" + CHID + "/ptz?stop");

        // ── Iris ──
        System.out.println("\n=== PTZ Iris ===");
        r = client.get("/api/v1/channel/" + CHID + "/ptz?iris=0.5");
        System.out.println("  iris=0.5 (open) -> " + r.status);
        Thread.sleep(1000);
        client.get("/api/v1/channel/" + CHID + "/ptz?stop");

        // ── List Presets ──
        System.out.println("\n=== Presets ===");
        r = client.get("/api/v1/channel/" + CHID + "/preset");
        System.out.println("  presets -> " + r.status);
        if (r.status == 200) {
            System.out.println(r.body);

            // ── Go to Preset ──
            // GET /api/v1/channel/{chid}/preset/{token}/go
            // Use a token value from the preset list above
            // Example: client.get("/api/v1/channel/" + CHID + "/preset/1/go");
        }
    }
}
