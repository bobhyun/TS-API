// 07_vod - Live and recorded stream URLs
// Stream URLs are in the "src" field (v0 used "streams").
//
// Run: cd go && go run ./07_vod
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

	// ── 1. Live stream URLs for all channels ──
	fmt.Println("=== GET /api/v1/vod ===")
	r, err := client.Get("/api/v1/vod")
	if err != nil {
		log.Fatal(err)
	}
	var vods []struct {
		Chid  int    `json:"chid"`
		Title string `json:"title"`
		Src   struct {
			RTMP string `json:"rtmp"`
			FLV  string `json:"flv"`
		} `json:"src"`
	}
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d (%s)\n", v.Chid, v.Title)
		fmt.Printf("    RTMP: %s\n", v.Src.RTMP)
		fmt.Printf("    FLV:  %s\n", v.Src.FLV)
	}

	// ── 2. Protocol filter (RTMP only) ──
	fmt.Println("\n=== GET /api/v1/vod?protocol=rtmp ===")
	r, _ = client.Get("/api/v1/vod?protocol=rtmp")
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d: %s\n", v.Chid, v.Src.RTMP)
	}

	// ── 3. Stream filter (sub = low resolution) ──
	fmt.Println("\n=== GET /api/v1/vod?stream=sub ===")
	r, _ = client.Get("/api/v1/vod?stream=sub")
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d sub: RTMP=%s\n", v.Chid, v.Src.RTMP)
	}

	// ── 4. Channel + protocol + stream filters combined ──
	fmt.Println("\n=== GET /api/v1/vod?ch=1&protocol=flv&stream=main ===")
	r, _ = client.Get("/api/v1/vod?ch=1&protocol=flv&stream=main")
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d main FLV: %s\n", v.Chid, v.Src.FLV)
	}

	// ── 5. Recorded video at a given time ──
	fmt.Println("\n=== GET /api/v1/vod?ch=1&when=2024-01-08T09:30:00 ===")
	r, _ = client.Get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00")
	fmt.Println("playback:", r.String())
}
