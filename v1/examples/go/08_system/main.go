// 08_system - Server info & system health
//
// Endpoints:
//   GET /api/v1/system/health?item=systemDisk - System disk (database and logs) status
//   GET /api/v1/system/notices?lang=ko-KR     - Notices currently in effect
//
// Run: cd go && go run ./08_system
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

	// ── 1. Server info (all at once) ──
	fmt.Println("=== GET /api/v1/info?all ===")
	r, err := client.Get("/api/v1/info?all")
	if err != nil {
		log.Fatal(err)
	}
	var info struct {
		APIVersion string `json:"apiVersion"`
		SiteName   string `json:"siteName"`
		Timezone   struct {
			Name string `json:"name"`
			Bias string `json:"bias"`
		} `json:"timezone"`
		Product struct {
			Name    string `json:"name"`
			Version string `json:"version"`
		} `json:"product"`
		License struct {
			Type        string `json:"type"`
			MaxChannels int    `json:"maxChannels"`
		} `json:"license"`
	}
	r.JSON(&info)
	fmt.Printf("  API: %s\n", info.APIVersion)
	fmt.Printf("  Site: %s\n", info.SiteName)
	fmt.Printf("  TZ: %s (%s)\n", info.Timezone.Name, info.Timezone.Bias)
	fmt.Printf("  Product: %s %s\n", info.Product.Name, info.Product.Version)
	fmt.Printf("  License: %s (max %d ch)\n", info.License.Type, info.License.MaxChannels)

	// ── 2. OS and CPU info ──
	fmt.Println("\n=== GET /api/v1/system/info?item=os,cpu ===")
	r, _ = client.Get("/api/v1/system/info?item=os,cpu")
	fmt.Println(r.String())

	// ── 3. Storage information (item=storage but response field is "disk") ──
	fmt.Println("\n=== GET /api/v1/system/info?item=storage ===")
	r, _ = client.Get("/api/v1/system/info?item=storage")
	// disk[] = physical disks, each with partition[]
	var storage struct {
		Disk []struct {
			Name      string `json:"name"`
			Capacity  int64  `json:"capacity"`
			Partition []struct {
				Mount      string `json:"mount"`
				VolumeName string `json:"volumeName"`
				FileSystem string `json:"fileSystem"`
				Size       int64  `json:"size"`
			} `json:"partition"`
		} `json:"disk"`
	}
	r.JSON(&storage)
	for _, d := range storage.Disk {
		fmt.Printf("  %s (%dGB)\n", d.Name, d.Capacity/(1024*1024*1024))
		for _, p := range d.Partition {
			if p.Mount != "" {
				fmt.Printf("    %s (%s): %dGB %s\n",
					p.Mount, p.VolumeName, p.Size/(1024*1024*1024), p.FileSystem)
			}
		}
	}

	// ── 4. System health (real-time usage) ──
	fmt.Println("\n=== GET /api/v1/system/health ===")
	r, _ = client.Get("/api/v1/system/health")
	fmt.Println(r.String())

	// ── 5. System disk (database and logs, normally C:) ──
	// Separate from the recording disks.
	// When it is full, records stop being saved even if the recording disks have room.
	// Watch status here, not only disk[].
	fmt.Println("\n=== GET /api/v1/system/health?item=systemDisk ===")
	r, _ = client.Get("/api/v1/system/health?item=systemDisk")
	var health struct {
		SystemDisk struct {
			Drive           string `json:"drive"`
			TotalSpace      int64  `json:"totalSpace"`
			FreeSpace       int64  `json:"freeSpace"`
			Status          string `json:"status"` // normal / low / critical
			DataWriteFailed bool   `json:"dataWriteFailed"`
		} `json:"systemDisk"`
	}
	r.JSON(&health)
	sd := health.SystemDisk
	fmt.Printf("  drive=%s free=%d/%d status=%s dataWriteFailed=%v\n",
		sd.Drive, sd.FreeSpace, sd.TotalSpace, sd.Status, sd.DataWriteFailed)

	// ── 6. System notices (conditions in effect right now) ──
	// message is keyed by language code: en-US is always present,
	// plus the requested lang when it is not English.
	lang := "ko-KR"
	fmt.Println("\n=== GET /api/v1/system/notices?lang=" + lang + " ===")
	r, _ = client.Get("/api/v1/system/notices?lang=" + lang)
	var notices []struct {
		ID       string            `json:"id"`
		Kind     string            `json:"kind"`
		Severity string            `json:"severity"` // info / warning / critical
		Message  map[string]string `json:"message"`
	}
	r.JSON(&notices)
	if len(notices) == 0 {
		fmt.Println("  (no notices)")
	}
	for _, n := range notices {
		text, ok := n.Message[lang]
		if !ok {
			text = n.Message["en-US"]
		}
		fmt.Printf("  [%s] %s: %s\n", n.Severity, n.Kind, text)
	}
}
