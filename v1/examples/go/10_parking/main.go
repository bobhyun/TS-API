// 10_parking - Parking lot & spot status
// Parking lot: entry/exit counter based, Parking spot: AI video analysis based
//
// Run: cd examples/go && go run ./v1/10_parking/
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

	// ── 1. Parking lot list ──
	fmt.Println("=== GET /api/v1/parking/lot ===")
	r, err := client.Get("/api/v1/parking/lot")
	if err != nil {
		log.Fatal(err)
	}
	var lots []struct {
		ID           int    `json:"id"`
		Name         string `json:"name"`
		Type         string `json:"type"`
		MaxCount     int    `json:"maxCount"`
		Member       []int  `json:"member"`
		ParkingSpots []int  `json:"parkingSpots"`
	}
	r.JSON(&lots)
	for _, l := range lots {
		fmt.Printf("  [%d] %s (type=%s, max=%d", l.ID, l.Name, l.Type, l.MaxCount)
		if len(l.ParkingSpots) > 0 {
			fmt.Printf(", spots=%v", l.ParkingSpots)
		}
		if len(l.Member) > 0 {
			fmt.Printf(", member=%v", l.Member)
		}
		fmt.Println(")")
	}

	// ── 2. Parking lot real-time status ──
	fmt.Println("\n=== GET /api/v1/parking/lot/status ===")
	r, _ = client.Get("/api/v1/parking/lot/status")
	var lotStatus []struct {
		ID        int    `json:"id"`
		Name      string `json:"name"`
		MaxCount  int    `json:"maxCount"`
		Count     int    `json:"count"`
		Available int    `json:"available"`
	}
	r.JSON(&lotStatus)
	for _, s := range lotStatus {
		fmt.Printf("  [%d] %s: %d/%d (available=%d)\n",
			s.ID, s.Name, s.Count, s.MaxCount, s.Available)
	}

	// ── 3. Parking spot list ──
	fmt.Println("\n=== GET /api/v1/parking/spot ===")
	r, _ = client.Get("/api/v1/parking/spot")
	var spots []struct {
		ID       int    `json:"id"`
		Chid     int    `json:"chid"`
		Name     string `json:"name"`
		Category string `json:"category"`
	}
	r.JSON(&spots)
	for _, s := range spots {
		fmt.Printf("  [%d] CH%d %s (%s)\n", s.ID, s.Chid, s.Name, s.Category)
	}

	// ── 4. Parking spot real-time occupancy status ──
	fmt.Println("\n=== GET /api/v1/parking/spot/status ===")
	r, _ = client.Get("/api/v1/parking/spot/status")
	var spotStatus []struct {
		ID       int    `json:"id"`
		Chid     int    `json:"chid"`
		Name     string `json:"name"`
		Category string `json:"category"`
		Occupied bool   `json:"occupied"`
		Vehicle  struct {
			PlateNo string  `json:"plateNo"`
			Score   float64 `json:"score"`
			Since   string  `json:"since"`
		} `json:"vehicle"`
	}
	r.JSON(&spotStatus)
	occupied := 0
	for _, s := range spotStatus {
		status := "empty"
		if s.Occupied {
			status = fmt.Sprintf("occupied [%s %.0f%%]", s.Vehicle.PlateNo, s.Vehicle.Score)
			occupied++
		}
		fmt.Printf("  [%d] %s: %s\n", s.ID, s.Name, status)
	}
	fmt.Printf("\nSummary: %d/%d spots occupied\n", occupied, len(spotStatus))
}
