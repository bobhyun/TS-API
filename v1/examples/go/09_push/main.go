// 09_push - External event push (Push: LPR & Emergency Call)
// Push license required. Returns 404 if not supported.
//
// WARNING: emergencyCall's callStart triggers a real emergency alarm!
//          You MUST send callEnd to stop the alarm.
//
// Run: cd examples/go && go run ./v1/09_push/
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

	now := time.Now().Format("2006-01-02T15:04:05")

	// ── 1. LPR Push (external LPR camera -> NVR) ──
	fmt.Println("=== POST /api/v1/push (LPR) ===")
	r, err := client.Post("/api/v1/push", map[string]string{
		"topic":   "LPR",
		"src":     "1",
		"plateNo": "12가3456",
		"when":    now,
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("LPR push: %d %s\n", r.Status, r.String())

	// ── 2. Emergency Call Push ──
	// WARNING: callStart triggers a real emergency alarm!
	fmt.Println("\n=== POST /api/v1/push (emergencyCall) ===")
	fmt.Println("WARNING: This triggers a real alarm! Use caution when testing.")

	// callStart - emergency call start
	r, err = client.Post("/api/v1/push", map[string]interface{}{
		"topic":  "emergencyCall",
		"device": "dev1",
		"src":    "1",
		"event":  "callStart",
		"camera": "1,2",
		"when":   now,
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("callStart: %d %s\n", r.Status, r.String())

	time.Sleep(2 * time.Second)

	// callEnd - MUST be sent to end the alarm!
	r, err = client.Post("/api/v1/push", map[string]interface{}{
		"topic":  "emergencyCall",
		"device": "dev1",
		"src":    "1",
		"event":  "callEnd",
		"camera": "1,2",
		"when":   time.Now().Format("2006-01-02T15:04:05"),
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("callEnd: %d %s\n", r.Status, r.String())
}
