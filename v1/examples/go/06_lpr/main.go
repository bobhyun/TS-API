// 06_lpr - License plate recognition search (LPR source & log search)
// Demonstrates LPR source listing, recognition log search, and similar plate search.
//
// WARNING: Exporting large datasets (10,000+ records) may cause HTTP timeout
// errors. For bulk exports, narrow the time range or use pagination
// (at/maxCount) to keep each request under a manageable size.
//
// Run: cd examples/go && go run ./v1/06_lpr/
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

	// ── 1. LPR source (recognition point) list ──
	fmt.Println("=== GET /api/v1/lpr/source ===")
	r, err := client.Get("/api/v1/lpr/source")
	if err != nil {
		log.Fatal(err)
	}
	var sources []struct {
		ID            int    `json:"id"`
		Code          string `json:"code"`
		Name          string `json:"name"`
		LinkedChannel []int  `json:"linkedChannel"`
		Tag           string `json:"tag"`
	}
	r.JSON(&sources)
	for _, s := range sources {
		fmt.Printf("  [%d] %s (%s) channels=%v tag=%s\n",
			s.ID, s.Name, s.Code, s.LinkedChannel, s.Tag)
	}

	// ── 2. LPR log search (timeBegin/timeEnd required) ──
	now := time.Now()
	timeEnd := now.Format("2006-01-02T15:04:05")
	timeBegin := now.AddDate(0, 0, -7).Format("2006-01-02T15:04:05") // last 7 days

	fmt.Printf("\n=== GET /api/v1/lpr/log (%s ~ %s) ===\n", timeBegin[:10], timeEnd[:10])
	r, err = client.Get(fmt.Sprintf(
		"/api/v1/lpr/log?timeBegin=%s&timeEnd=%s&maxCount=5",
		timeBegin, timeEnd))
	if err != nil {
		log.Fatal(err)
	}
	var result struct {
		TotalCount int `json:"totalCount"`
		At         int `json:"at"`
		Data       []struct {
			ID        int      `json:"id"`
			PlateNo   string   `json:"plateNo"`
			Score     float64  `json:"score"`
			TimeRange []string `json:"timeRange"`
			SrcCode   string   `json:"srcCode"`
			SrcName   string   `json:"srcName"`
			Direction string   `json:"direction"`
		} `json:"data"`
	}
	r.JSON(&result)
	fmt.Printf("Total: %d\n", result.TotalCount)
	for _, d := range result.Data {
		t := ""
		if len(d.TimeRange) > 0 {
			t = d.TimeRange[0]
		}
		fmt.Printf("  [%d] %s (%.1f%%) %s %s %s\n",
			d.ID, d.PlateNo, d.Score, d.SrcName, d.Direction, t)
	}

	// ── 3. Keyword search (partial match) ──
	fmt.Println("\n=== LPR keyword search: '1234' ===")
	r, _ = client.Get(fmt.Sprintf(
		"/api/v1/lpr/log?keyword=1234&timeBegin=%s&timeEnd=%s&maxCount=3",
		timeBegin, timeEnd))
	r.JSON(&result)
	fmt.Printf("Found: %d\n", result.TotalCount)

	// ── 4. Similar plate search (for misrecognition handling) ──
	fmt.Println("\n=== GET /api/v1/lpr/similar ===")
	r, _ = client.Get(fmt.Sprintf(
		"/api/v1/lpr/similar?keyword=1234&timeBegin=%s&timeEnd=%s",
		timeBegin, timeEnd))
	fmt.Println("similar:", r.String())
}
