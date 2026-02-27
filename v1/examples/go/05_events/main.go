// 05_events - Event types & log search
// Demonstrates event type listing and pagination-based log search.
//
// Run: cd examples/go && go run ./v1/05_events/
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

	// ── 1. Event type list ({id, name, code[]}) ──
	fmt.Println("=== GET /api/v1/event/type ===")
	r, err := client.Get("/api/v1/event/type")
	if err != nil {
		log.Fatal(err)
	}
	var types []struct {
		ID   int    `json:"id"`
		Name string `json:"name"`
		Code []struct {
			ID   int    `json:"id"`
			Name string `json:"name"`
		} `json:"code"`
	}
	r.JSON(&types)
	for _, t := range types {
		fmt.Printf("  [%d] %s\n", t.ID, t.Name)
		for _, c := range t.Code {
			fmt.Printf("      code %d: %s\n", c.ID, c.Name)
		}
	}

	// ── 2. Event log search (pagination) ──
	fmt.Println("\n=== GET /api/v1/event/log (page 1: at=0, maxCount=5) ===")
	r, err = client.Get("/api/v1/event/log?at=0&maxCount=5&sort=desc")
	if err != nil {
		log.Fatal(err)
	}
	var result struct {
		TotalCount int `json:"totalCount"`
		At         int `json:"at"`
		Data       []struct {
			ID        int      `json:"id"`
			Type      int      `json:"type"`
			TypeName  string   `json:"typeName"`
			Code      int      `json:"code"`
			CodeName  string   `json:"codeName"`
			Chid      int      `json:"chid"`
			TimeRange []string `json:"timeRange"`
		} `json:"data"`
	}
	r.JSON(&result)
	fmt.Printf("Total: %d, showing from: %d\n", result.TotalCount, result.At)
	for _, e := range result.Data {
		t := ""
		if len(e.TimeRange) > 0 {
			t = e.TimeRange[0]
		}
		fmt.Printf("  [%d] CH%d %s/%s  %s\n", e.ID, e.Chid, e.TypeName, e.CodeName, t)
	}

	// ── 3. Next page (page 2) ──
	if result.TotalCount > 5 {
		fmt.Println("\n=== Page 2: at=5 ===")
		r, _ = client.Get("/api/v1/event/log?at=5&maxCount=5&sort=desc")
		var page2 struct {
			At   int `json:"at"`
			Data []struct {
				ID       int    `json:"id"`
				CodeName string `json:"codeName"`
			} `json:"data"`
		}
		r.JSON(&page2)
		for _, e := range page2.Data {
			fmt.Printf("  [%d] %s\n", e.ID, e.CodeName)
		}
	}
}
