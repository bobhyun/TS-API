// 02_channels - Channel (camera) list & status
//
// Run: cd examples/go && go run ./v1/02_channels/
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

	// ── 1. Channel list ──
	fmt.Println("=== GET /api/v1/channel ===")
	r, err := client.Get("/api/v1/channel")
	if err != nil {
		log.Fatal(err)
	}
	var channels []struct {
		Chid        int    `json:"chid"`
		Title       string `json:"title"`
		DisplayName string `json:"displayName"`
	}
	r.JSON(&channels)
	for _, ch := range channels {
		fmt.Printf("  CH%d: %s (%s)\n", ch.Chid, ch.DisplayName, ch.Title)
	}

	// ── 2. Channel list + camera capabilities (?caps) ──
	fmt.Println("\n=== GET /api/v1/channel?caps ===")
	r, err = client.Get("/api/v1/channel?caps")
	if err != nil {
		log.Fatal(err)
	}
	var chWithCaps []struct {
		Chid int    `json:"chid"`
		Title string `json:"title"`
		Caps struct {
			Pantilt bool `json:"pantilt"`
			Zoom    bool `json:"zoom"`
		} `json:"caps"`
	}
	r.JSON(&chWithCaps)
	for _, ch := range chWithCaps {
		fmt.Printf("  CH%d: pantilt=%v zoom=%v\n", ch.Chid, ch.Caps.Pantilt, ch.Caps.Zoom)
	}

	// ── 3. Channel status + recording status (?recordingStatus) ──
	fmt.Println("\n=== GET /api/v1/channel/status?recordingStatus ===")
	r, err = client.Get("/api/v1/channel/status?recordingStatus")
	if err != nil {
		log.Fatal(err)
	}
	var statuses []struct {
		Chid   int `json:"chid"`
		Status struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"status"`
		Recording bool `json:"recording"`
	}
	r.JSON(&statuses)
	for _, s := range statuses {
		fmt.Printf("  CH%d: %s (code=%d) recording=%v\n",
			s.Chid, s.Status.Message, s.Status.Code, s.Recording)
	}
	// status code: 0=Connected, -1=Disconnected, -2=Connecting, -3=Auth Failed
}
