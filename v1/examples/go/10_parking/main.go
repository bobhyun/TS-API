// 10_parking - Parking lot & spot status
// Parking lot: entry/exit counter based, Parking spot: AI video analysis based
// License check via /api/v1/info extension token (parkingHistory) before session history
//
// Run: cd examples/go && go run ./v1/10_parking/
package main

import (
	"fmt"
	"log"
	"slices"

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

	// --- Parking Session History ---
	// A session opens when a vehicle is confirmed present and closes when it is
	// gone. Needs the parking history license - 403 without it. Ask /api/v1/info
	// first: the "parkingHistory" extension token says whether the session
	// endpoints will answer (the array is omitted when no extension is active).
	r, _ = client.Get("/api/v1/info?license")
	var info struct {
		License struct {
			Extension []string `json:"extension"`
		} `json:"license"`
	}
	r.JSON(&info)
	if !slices.Contains(info.License.Extension, "parkingHistory") {
		fmt.Println("\nparking history license not found (no 'parkingHistory' in license.extension) - skipping session examples")
		return
	}

	fmt.Println("\n=== Currently Parked ===")
	r, _ = client.Get("/api/v1/parking/session?open=true&maxCount=10")
	var openList struct {
		TotalCount int64  `json:"totalCount"`
		AsOf       string `json:"asOf"`
		Data       []struct {
			ID         int64  `json:"id"`
			PlateNo    string `json:"plateNo"`
			DurationMs int64  `json:"durationMs"`
			Src        struct {
				Name string `json:"name"`
			} `json:"src"`
		} `json:"data"`
	}
	r.JSON(&openList)
	fmt.Printf("  total=%d asOf=%s\n", openList.TotalCount, openList.AsOf)
	for _, s := range openList.Data {
		plate := s.PlateNo
		if plate == "" {
			plate = "(no plate)"
		}
		fmt.Printf("  [%d] %s %s %dm\n", s.ID, s.Src.Name, plate, s.DurationMs/60000)
	}

	// --- Session Detail ---
	// outKind / outTimeMeans say HOW the exit time was decided. Only "observed"
	// is a measurement; the others are estimates whose error leans in different
	// directions, so bill from the basis, not from the number alone.
	//
	// inKind / inTimeMeans do the same for the entry, and the error leans the OTHER
	// way: firstSeen is an UPPER bound on the real entry (already there when
	// observation started). It is present on OPEN sessions too.
	fmt.Println("\n=== Session Detail ===")
	if len(openList.Data) > 0 {
		r, _ = client.Get(fmt.Sprintf("/api/v1/parking/session/%d", openList.Data[0].ID))
		var detail struct {
			ID           int64  `json:"id"`
			Open         bool   `json:"open"`
			OutKind      string `json:"outKind"`
			OutTimeMeans string `json:"outTimeMeans"`
			InKind       string `json:"inKind"`
			InTimeMeans  string `json:"inTimeMeans"`
			DurationMs   int64  `json:"durationMs"`
		}
		r.JSON(&detail)
		fmt.Printf("  [%d] %dm open=%v\n", detail.ID, detail.DurationMs/60000, detail.Open)
		fmt.Printf("  entry basis: %s (%s)\n", detail.InKind, detail.InTimeMeans)
		if !detail.Open {
			fmt.Printf("  exit basis: %s (%s)\n", detail.OutKind, detail.OutTimeMeans)
		}
	} else {
		fmt.Println("  (no sessions yet)")
	}

	// --- Scope: what the query is scoped to ---
	// Items omitted means "the whole scope", which is NOT the same as no filter:
	// scope=lot with no lot returns only sessions that belong to a parking lot,
	// so no-parking-zone history is excluded (it belongs to no lot).
	fmt.Println("\n=== Scope ===")
	for _, qs := range []string{"scope=channel&ch=1,2", "scope=lot", "scope=noparking"} {
		r, _ = client.Get("/api/v1/parking/session?" + qs + "&maxCount=5")
		fmt.Printf("  %s => %d\n", qs, r.Status)
	}

	// --- Video for a session: otherwise=nearBefore ---
	// A parked car does not move, so motion-triggered recording may have stopped
	// while it was still there. The car is in the same place, so the preceding
	// footage still shows the situation. Use this for parking history only.
	// An empty result means there is no usable recording at all (never recorded,
	// or already recycled) — the session snapshots remain available either way.
	fmt.Println("\n=== Video at entry time (nearest earlier if none) ===")
	r, _ = client.Get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore")
	fmt.Printf("  => %d\n", r.Status)

	// --- Which car is it? the bounding box ---
	// A snapshot can hold several cars. `box` points at the one this session is
	// about. YOLO style: center based, all four values 0..1 (see 1.2), so you
	// multiply by the size of whatever you draw on. Entrance/exit sessions carry
	// no vehicle box (a single plate read) and the value is null; the key is
	// always present.
	fmt.Println("\n=== Bounding box of the session vehicle ===")
	var list struct {
		Data []struct {
			ID int64 `json:"id"`
		} `json:"data"`
	}
	if r, err := client.Get("/api/v1/parking/session?maxCount=1"); err == nil {
		if r.JSON(&list) == nil && len(list.Data) > 0 {
			var detail struct {
				Box *struct {
					Cx float64 `json:"cx"`
					Cy float64 `json:"cy"`
					W  float64 `json:"w"`
					H  float64 `json:"h"`
				} `json:"box"`
			}
			if dr, err := client.Get(fmt.Sprintf("/api/v1/parking/session/%d", list.Data[0].ID)); err == nil {
				if dr.JSON(&detail) == nil && detail.Box != nil {
					const W, H = 1920.0, 1080.0 // 그릴 대상 크기
					b := detail.Box
					fmt.Printf("  box = cx=%v cy=%v w=%v h=%v\n", b.Cx, b.Cy, b.W, b.H)
					fmt.Printf("  on %dx%d -> left=%d top=%d width=%d height=%d\n",
						int(W), int(H), int((b.Cx-b.W/2)*W), int((b.Cy-b.H/2)*H),
						int(b.W*W), int(b.H*H))
				} else {
					fmt.Println("  (no box for this session)")
				}
			}
		}
	}

	// --- Writing history (Control permission) ---
	// Both change stored history, so they are not executed here.
	// Payment state (16.7): commit settles it, exempt records a decision not to
	// collect, undo reverts the most recent change (the response says which one).
	// Records are appended, never deleted.
	//
	// close (16.8) is a different axis: it clears the lingering "parked" state left
	// when an exit was never observed. Exempt takes a session out of billing and may
	// leave it parked; close ends the session. Do not conflate the two.
	//
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/commit?ref=POS-0042", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/exempt", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/undo", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/close", id), nil)
}
