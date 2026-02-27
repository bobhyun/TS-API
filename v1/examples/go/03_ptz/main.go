// 03_ptz - PTZ camera control & presets
// Controls cameras via ONVIF protocol.
//
// Run: cd examples/go && go run ./v1/03_ptz/
package main

import (
	"fmt"
	"log"
	"time"

	"tsapi-examples/tsapi"
)

func main() {
	cfg := tsapi.LoadConfig()
	if cfg.ApiKey == "" {
		log.Fatal("NVR_API_KEY environment variable is required")
	}
	client := tsapi.NewClient(cfg)
	client.SetApiKey(cfg.ApiKey)

	chid := 1 // target channel number

	// ── 1. Go to Home position ──
	fmt.Printf("=== CH%d PTZ Home ===\n", chid)
	r, _ := client.Get(fmt.Sprintf("/api/v1/channel/%d/ptz?home", chid))
	fmt.Println("home:", r.Status)

	time.Sleep(time.Second)

	// ── 2. Pan/Tilt move (move=x,y  range: -1.0 ~ 1.0) ──
	fmt.Println("\n=== PTZ Move (upper right) ===")
	r, _ = client.Get(fmt.Sprintf("/api/v1/channel/%d/ptz?move=0.3,-0.2", chid))
	fmt.Println("move:", r.Status)

	time.Sleep(500 * time.Millisecond)

	// ── 3. Zoom In (zoom: -1.0=zoom out, 1.0=zoom in) ──
	fmt.Println("\n=== PTZ Zoom In ===")
	r, _ = client.Get(fmt.Sprintf("/api/v1/channel/%d/ptz?zoom=0.5", chid))
	fmt.Println("zoom:", r.Status)

	time.Sleep(500 * time.Millisecond)

	// ── 4. Stop (stop all PTZ movement) ──
	fmt.Println("\n=== PTZ Stop ===")
	r, _ = client.Get(fmt.Sprintf("/api/v1/channel/%d/ptz?stop", chid))
	fmt.Println("stop:", r.Status)

	// ── 5. List presets ──
	fmt.Println("\n=== Preset List ===")
	r, err := client.Get(fmt.Sprintf("/api/v1/channel/%d/preset", chid))
	if err != nil {
		log.Fatal(err)
	}
	var presets []struct {
		Token string `json:"token"`
		Name  string `json:"name"`
	}
	r.JSON(&presets)
	for _, p := range presets {
		fmt.Printf("  [%s] %s\n", p.Token, p.Name)
	}

	// ── 6. Go to preset ──
	if len(presets) > 0 {
		token := presets[0].Token
		fmt.Printf("\n=== Go to Preset '%s' ===\n", presets[0].Name)
		r, _ = client.Get(fmt.Sprintf("/api/v1/channel/%d/preset/%s/go", chid, token))
		fmt.Println("preset go:", r.Status)
	}
}
