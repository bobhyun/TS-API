// 07_vod - Live/recording stream URL query (VOD stream URLs)
// Stream URLs are in the "src" field of the response (differs from v0's "streams").
//
// Run: cd examples/go && go run ./v1/07_vod/
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

	// ── 1. All channels live stream URLs ──
	fmt.Println("=== GET /api/v1/vod ===")
	r, err := client.Get("/api/v1/vod")
	if err != nil {
		log.Fatal(err)
	}
	// v1 response: src field (differs from v0's streams)
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

	// ── 3. Stream type filter (sub-stream = low resolution) ──
	fmt.Println("\n=== GET /api/v1/vod?stream=sub ===")
	r, _ = client.Get("/api/v1/vod?stream=sub")
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d sub: RTMP=%s\n", v.Chid, v.Src.RTMP)
	}

	// ── 4. Specific channel + protocol combination ──
	fmt.Println("\n=== GET /api/v1/vod?ch=1&protocol=flv&stream=main ===")
	r, _ = client.Get("/api/v1/vod?ch=1&protocol=flv&stream=main")
	r.JSON(&vods)
	for _, v := range vods {
		fmt.Printf("  CH%d main FLV: %s\n", v.Chid, v.Src.FLV)
	}

	// ── 5. Recording playback (specific time) ──
	fmt.Println("\n=== GET /api/v1/vod?ch=1&when=2024-01-08T09:30:00 ===")
	r, _ = client.Get("/api/v1/vod?ch=1&when=2024-01-08T09:30:00")
	fmt.Println("playback:", r.String())
}
