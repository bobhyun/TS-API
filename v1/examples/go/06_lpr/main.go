// 06_lpr - License plate recognition search (LPR source & log search)
// Demonstrates LPR source listing, recognition log search, similar plate search,
// and plate correction history.
//
// Endpoints:
//   GET  /api/v1/lpr/log/{id}/plate/history - Plate correction history of one record (Playback)
//   POST /api/v1/lpr/log/{id}/plate         - Correct the plate of one record (Control, not executed here)
//
// WARNING: Large exports (10,000+ records) can hit HTTP timeouts.
// Narrow the time range or page with at/maxCount.
//
// Run: cd go && go run ./06_lpr
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
			ID              int      `json:"id"`
			PlateNo         *string  `json:"plateNo"` // null when no plate was read
			PlateEdited     bool     `json:"plateEdited"`
			OriginalPlateNo string   `json:"originalPlateNo"`
			Score           float64  `json:"score"`
			TimeRange       []string `json:"timeRange"`
			SrcCode         string   `json:"srcCode"`
			SrcName         string   `json:"srcName"`
			Direction       string   `json:"direction"` // "entry" / "exit", absent when unknown
		} `json:"data"`
	}
	r.JSON(&result)
	fmt.Printf("Total: %d\n", result.TotalCount)
	for _, d := range result.Data {
		t := ""
		if len(d.TimeRange) > 0 {
			t = d.TimeRange[0]
		}
		plate := "(unrecognized)"
		if d.PlateNo != nil && *d.PlateNo != "" {
			plate = *d.PlateNo
		}
		dir := d.Direction
		if dir == "" {
			dir = "-"
		}
		fmt.Printf("  [%d] %s (%.1f%%) %s direction=%s %s",
			d.ID, plate, d.Score, d.SrcName, dir, t)
		if d.PlateEdited {
			orig := d.OriginalPlateNo
			if orig == "" {
				orig = "(unrecognized)"
			}
			fmt.Printf(" (corrected, originally %s)", orig)
		}
		fmt.Println()
	}
	firstID := 0
	if len(result.Data) > 0 {
		firstID = result.Data[0].ID
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

	// ── 5. Plate correction history (one record, by id) ──
	// plateNo in the log is always the current value.
	// edits[] lists corrections in recorded order; it is empty if the record was never corrected.
	if firstID > 0 {
		fmt.Printf("\n=== GET /api/v1/lpr/log/%d/plate/history ===\n", firstID)
		r, err = client.Get(fmt.Sprintf("/api/v1/lpr/log/%d/plate/history", firstID))
		if err != nil {
			log.Fatal(err)
		}
		if r.Status == 200 {
			var h struct {
				PlateNo         string  `json:"plateNo"`
				OriginalPlateNo *string `json:"originalPlateNo"`
				Edits           []struct {
					Time   string `json:"time"`
					User   string `json:"user"`
					Before string `json:"before"`
					After  string `json:"after"`
					Reason string `json:"reason"`
				} `json:"edits"`
			}
			r.JSON(&h)
			orig := "(never corrected)"
			if h.OriginalPlateNo != nil {
				orig = *h.OriginalPlateNo
			}
			fmt.Printf("  plateNo=%s original=%s\n", h.PlateNo, orig)
			for _, e := range h.Edits {
				fmt.Printf("    %s %s: %s -> %s %s\n", e.Time, e.User, e.Before, e.After, e.Reason)
			}
		} else {
			fmt.Printf("  Status: %d\n", r.Status)
		}
	}

	// ── 6. Plate correction (Control permission) ──
	// Changes the stored record, so it is not executed here. The target is always
	// one record id - from data[].id above, or the id a realtime LPR event carries
	// next to each plateNo. 409 when plateNo equals the current plate.
	//
	// Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
	// Uncomment it to try it against a test record.
	//   client.Post(fmt.Sprintf("/api/v1/lpr/log/%d/plate", firstID), map[string]string{
	//   	"plateNo": "12가3456",
	//   	"reason":  "misread at night",
	//   })
}
