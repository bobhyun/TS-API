// 04_recording - Recording search (days & minutes timeline)
// Useful for implementing calendar UI and timeline UI.
//
// Run: cd examples/go && go run ./v1/04_recording/
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

	// ── 1. Query recorded days (for calendar) ──
	fmt.Println("=== GET /api/v1/recording/days?ch=1 ===")
	r, err := client.Get("/api/v1/recording/days?ch=1")
	if err != nil {
		log.Fatal(err)
	}
	// When ch= filter is used, response wraps per-channel:
	//   {data: [{chid: 1, data: [{year, month, days}]}]}
	var days struct {
		TimeBegin string `json:"timeBegin"`
		TimeEnd   string `json:"timeEnd"`
		Data      []struct {
			Chid int `json:"chid"`
			Data []struct {
				Year  int   `json:"year"`
				Month int   `json:"month"`
				Days  []int `json:"days"`
			} `json:"data"`
		} `json:"data"`
	}
	r.JSON(&days)
	fmt.Printf("Range: %s ~ %s\n", days.TimeBegin, days.TimeEnd)
	for _, ch := range days.Data {
		for _, d := range ch.Data {
			fmt.Printf("  CH%d: %d-%02d: %v\n", ch.Chid, d.Year, d.Month, d.Days)
		}
	}

	// ── 2. Per-minute recording segments (for timeline) ──
	// minutes: 1440-char string (24h x 60min), '1'=recording exists, '0'=none
	now := time.Now()
	today := now.Format("2006-01-02")
	timeBegin := today + "T00:00:00"
	timeEnd := today + "T23:59:59"

	fmt.Printf("\n=== GET /api/v1/recording/minutes (today: %s) ===\n", today)
	r, err = client.Get(fmt.Sprintf(
		"/api/v1/recording/minutes?ch=1&timeBegin=%s&timeEnd=%s",
		timeBegin, timeEnd))
	if err != nil {
		log.Fatal(err)
	}
	var mins struct {
		TimeBegin string `json:"timeBegin"`
		TimeEnd   string `json:"timeEnd"`
		Data      []struct {
			Chid    int    `json:"chid"`
			Minutes string `json:"minutes"`
		} `json:"data"`
	}
	r.JSON(&mins)
	for _, m := range mins.Data {
		total := 0
		for _, c := range m.Minutes {
			if c == '1' {
				total++
			}
		}
		fmt.Printf("  CH%d: %d/%d minutes recorded (len=%d)\n",
			m.Chid, total, len(m.Minutes), len(m.Minutes))
		// Hourly summary output (4-hour blocks)
		if len(m.Minutes) < 1440 {
			continue
		}
		for h := 0; h < 24; h += 4 {
			start := h * 60
			end := start + 240
			if end > len(m.Minutes) {
				end = len(m.Minutes)
			}
			count := 0
			for _, c := range m.Minutes[start:end] {
				if c == '1' {
					count++
				}
			}
			fmt.Printf("    %02d:00-%02d:00: %d min\n", h, h+4, count)
		}
	}
}
