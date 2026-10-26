// 10_parking - Parking lot & spot status
// Parking lot: entry/exit counter based, Parking spot: AI video analysis based
// License check via /api/v1/info extension token (parkingHistory) before session history
// Plate correction history via GET /api/v1/parking/session/{id}/plate/history
// (POST /api/v1/parking/session/{id}/plate corrects it - not executed here)
//
// Run: cd go && go run ./10_parking
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
	// A session opens when a vehicle is confirmed present and closes when it
	// leaves. Requires the parking history license (403 without it).
	// Check /api/v1/info first: the `parkingHistory` extension token tells
	// whether the session endpoints are available. license.extension is
	// omitted when no extension is active.
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
			ID          int64  `json:"id"`
			PlateNo     string `json:"plateNo"`
			PlateEdited bool   `json:"plateEdited"`
			DurationMs  int64  `json:"durationMs"`
			Src         struct {
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
		if s.PlateEdited {
			plate += " (corrected)"
		}
		fmt.Printf("  [%d] %s %s %dm\n", s.ID, s.Src.Name, plate, s.DurationMs/60000)
	}

	// --- Session Detail ---
	// outKind / outTimeMeans tell how the exit time was determined.
	// Only "observed" is a measurement; the others are estimates that can err
	// in different directions, so bill from the basis, not from the time alone.
	//
	// inKind / inTimeMeans do the same for the entry, but err the opposite way:
	// firstSeen is an upper bound on the real entry (the vehicle was already
	// there when observation started). Unlike the exit basis, it is present
	// on open sessions too.
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
	// Omitting the items means "the whole scope", not "no filter":
	// scope=lot without a lot list returns only sessions that belong to a
	// parking lot, so no-parking-zone sessions (which belong to no lot) are
	// excluded.
	fmt.Println("\n=== Scope ===")
	for _, qs := range []string{"scope=channel&ch=1,2", "scope=lot", "scope=noparking"} {
		r, _ = client.Get("/api/v1/parking/session?" + qs + "&maxCount=5")
		fmt.Printf("  %s => %d\n", qs, r.Status)
	}

	// --- Video for a session: otherwise=nearBefore ---
	// A parked car does not move, so motion-triggered recording may stop
	// while it is still there. Because the car stays in place, earlier
	// footage still shows it. Use otherwise=nearBefore for parking history only.
	// An empty result means no usable recording exists (never recorded, or
	// already recycled); the session snapshots are still available.
	fmt.Println("\n=== Video at entry time (nearest earlier if none) ===")
	r, _ = client.Get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00&otherwise=nearBefore")
	fmt.Printf("  => %d\n", r.Status)

	// --- Which car is it? the bounding box ---
	// A snapshot can contain several cars; `box` marks the one this session
	// is about. YOLO style: center-based, all four values in 0..1 (see 1.2).
	// Multiply by the size of the surface you draw on; the internal
	// coordinate space does not matter.
	// Entrance/exit sessions have no vehicle box (a single plate read):
	// the value is null, but the key is always present.
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
					const W, H = 1920.0, 1080.0 // drawing surface size
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

	// --- Plate correction history ---
	// Only the session's representative plate (plateNo) is corrected; per-shot
	// readings (snapshots[].plateNo) are kept as evidence.
	// Reading requires Playback permission.
	fmt.Println("\n=== Plate correction history ===")
	if len(list.Data) > 0 {
		r, _ = client.Get(fmt.Sprintf("/api/v1/parking/session/%d/plate/history", list.Data[0].ID))
		if r.Status == 200 {
			var h struct {
				ID              int64   `json:"id"`
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
			fmt.Printf("  session=%d plateNo=%s original=%s\n", h.ID, h.PlateNo, orig)
			for _, e := range h.Edits {
				fmt.Printf("    %s %s: %s -> %s %s\n", e.Time, e.User, e.Before, e.After, e.Reason)
			}
		} else {
			fmt.Printf("  Status: %d\n", r.Status)
		}
	}

	// --- Writing history (Control permission) ---
	// These calls change stored history, so they are not executed here.
	// Payment state (16.7): commit settles it, exempt records a decision not to
	// collect, and undo reverts the most recent change (the response says which).
	// Records are appended, never deleted.
	//
	// close (16.8) is separate: it ends a session whose exit was never observed
	// and would otherwise stay "parked". exempt removes a session from billing
	// but may leave it parked; close ends it. Do not confuse the two.
	//
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/commit?ref=POS-0042", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/exempt", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/payment/undo", id), nil)
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/close", id), nil)
	//
	// Plate correction (16.9): one session by id; no bulk correction or merging.
	// Payments stay with the session. Returns 409 when plateNo equals the current plate.
	//
	// Disabled by default: this call changes the stored plate number on the server, and the edit is permanently kept in the correction history.
	// Uncomment it to try it against a test record.
	//   client.Post(fmt.Sprintf("/api/v1/parking/session/%d/plate", id), map[string]string{
	//   	"plateNo": "12가3456",
	//   	"reason":  "misread at night",
	//   })
}
