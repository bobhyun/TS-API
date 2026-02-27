// 13_ws_parking_lot - WebSocket Parking Lot Count Monitoring
//
// Endpoint:
//   ws://host:port/wsapi/v1/events?topics=parkingCount
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Optional filter: &lot=1,2 (filter by parking lot ID)
//
// See also: 14_ws_parking_spot for individual spot monitoring
//
// REQUIRES: go get github.com/gorilla/websocket
//
// Run: cd examples/go && go run ./v1/13_ws_parking_lot/
package main

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
	"tsapi-examples/tsapi"
)

func main() {
	cfg := tsapi.LoadConfig()
	if cfg.ApiKey == "" {
		log.Fatal("NVR_API_KEY environment variable is required")
	}
	client := tsapi.NewClient(cfg)
	client.SetApiKey(cfg.ApiKey)

	fmt.Println("=== WebSocket Parking Count Monitoring (30 seconds) ===")

	// Auth via X-API-Key header
	// Alt: use ?apikey=tsapi_key_... query param (browser fallback)

	// Optional filter: &lot=1,2
	wsURL := cfg.WsURL + "/wsapi/v1/events?topics=parkingCount"

	dialer := websocket.Dialer{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	headers := http.Header{"X-API-Key": {cfg.ApiKey}}
	conn, _, err := dialer.Dial(wsURL, headers)
	if err != nil {
		log.Fatal("connect failed:", err)
	}
	defer conn.Close()

	fmt.Println("  Connected! Waiting for parking count events...\n")

	msgCount := 0
	go func() {
		time.Sleep(30 * time.Second)
		conn.Close()
	}()

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			break
		}

		msgCount++
		var msg map[string]interface{}
		if err := json.Unmarshal(message, &msg); err != nil {
			fmt.Printf("  Raw: %s\n", string(message))
			continue
		}

		// First message is subscription confirmation
		if _, ok := msg["subscriberId"]; ok {
			fmt.Printf("  Subscribed (id=%v)\n", msg["subscriberId"])
			continue
		}

		// parkingCount messages: {topic, updated: [{id, name, type, maxCount, count}, ...]}
		updated, _ := msg["updated"].([]interface{})
		for _, u := range updated {
			lot, _ := u.(map[string]interface{})
			id := lot["id"]
			name, _ := lot["name"].(string)
			lotType, _ := lot["type"].(string)
			count, _ := lot["count"].(float64)
			maxCount, _ := lot["maxCount"].(float64)
			available := maxCount - count
			fmt.Printf("  [%v] %s (%s): %.0f/%.0f (available=%.0f)\n",
				id, name, lotType, count, maxCount, available)
		}
	}

	fmt.Printf("\n  Received %d events\n", msgCount)
}
