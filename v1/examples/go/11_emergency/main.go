// 11_emergency - Emergency call device list
//
// Endpoint: GET /api/v1/emergency
// Response: [{ id, code, name, linkedChannel }, ...]
// Note: Requires Emergency Call license. Returns 404 if not supported.
//
// Run: cd examples/go && go run ./v1/11_emergency/
package main

import (
	"fmt"
	"log"

	"tsapi-examples/tsapi"
)

func main() {
	cfg := tsapi.LoadConfig()
	if cfg.ApiKey == "" {
		log.Fatal("NVR_API_KEY environment variable is required")
	}
	client := tsapi.NewClient(cfg)
	client.SetApiKey(cfg.ApiKey)

	// ── Emergency call device list ──
	fmt.Println("=== GET /api/v1/emergency ===")
	r, err := client.Get("/api/v1/emergency")
	if err != nil {
		log.Fatal(err)
	}

	if r.Status == 404 {
		fmt.Println("  Emergency Call not enabled on this server (license required)")
		return
	}

	var devices []struct {
		ID            int    `json:"id"`
		Code          string `json:"code"`
		Name          string `json:"name"`
		LinkedChannel []int  `json:"linkedChannel"`
	}
	r.JSON(&devices)
	fmt.Printf("  Total: %d device(s)\n", len(devices))
	for _, dev := range devices {
		fmt.Printf("  id=%d  code=%s  name=%s  linkedChannel=%v\n",
			dev.ID, dev.Code, dev.Name, dev.LinkedChannel)
	}
}
