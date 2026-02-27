// 08_system - Server info & system health
//
// Run: cd examples/go && go run ./v1/08_system/
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

	// ── 2. OS, CPU information ──
	fmt.Println("\n=== GET /api/v1/system/info?item=os,cpu ===")
	r, _ = client.Get("/api/v1/system/info?item=os,cpu")
	fmt.Println(r.String())

	// ── 3. Storage information (item=storage but response field is "disk") ──
	fmt.Println("\n=== GET /api/v1/system/info?item=storage ===")
	r, _ = client.Get("/api/v1/system/info?item=storage")
	// storage response: disk[].partition[] (physical disk -> partition structure)
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

	// ── 4. System real-time health ──
	fmt.Println("\n=== GET /api/v1/system/health ===")
	r, _ = client.Get("/api/v1/system/health")
	fmt.Println(r.String())
}
