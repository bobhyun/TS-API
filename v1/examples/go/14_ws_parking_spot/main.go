// 14_ws_parking_spot - WebSocket Parking Spot Monitoring
//
// Endpoint:
//   ws://host:port/wsapi/v1/events?topics=parkingSpot
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Optional filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
//
// Events:
//   currentStatus  - initial full state on connect
//   statusChanged  - only changed spots
//
// See also: 13_ws_parking_lot for lot-level count monitoring
//
// REQUIRES: go get github.com/gorilla/websocket
//
// Run: cd examples/go && go run ./v1/14_ws_parking_spot/
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

	fmt.Println("=== WebSocket Parking Spot Monitoring (30 seconds) ===")

	// Auth via X-API-Key header
	// Alt: use ?apikey=tsapi_key_... query param (browser fallback)

	// Filters (OR logic): &ch=1,2  &lot=1,2  &spot=100,200
	wsURL := cfg.WsURL + "/wsapi/v1/events?topics=parkingSpot"

	dialer := websocket.Dialer{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	headers := http.Header{"X-API-Key": {cfg.ApiKey}}
	conn, _, err := dialer.Dial(wsURL, headers)
	if err != nil {
		log.Fatal("connect failed:", err)
	}
	defer conn.Close()

	fmt.Println("  Connected! Waiting for spot events...\n")

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

		event, _ := msg["event"].(string)
		spots, _ := msg["spots"].([]interface{})

		switch event {
		case "currentStatus":
			fmt.Printf("  [currentStatus] %d spots\n", len(spots))
			for _, s := range spots {
				spot, _ := s.(map[string]interface{})
				spotId := spot["id"]
				spotName, _ := spot["name"].(string)
				category, _ := spot["category"].(string)
				occupied, _ := spot["occupied"].(bool)
				if occupied {
					vehicle, _ := spot["vehicle"].(map[string]interface{})
					plateNo, _ := vehicle["plateNo"].(string)
					score, _ := vehicle["score"].(float64)
					fmt.Printf("    [%v] %s (%s): occupied [%s %.1f%%]\n",
						spotId, spotName, category, plateNo, score)
				} else {
					fmt.Printf("    [%v] %s (%s): empty\n", spotId, spotName, category)
				}
			}

		case "statusChanged":
			for _, s := range spots {
				spot, _ := s.(map[string]interface{})
				spotId := spot["id"]
				occupied, _ := spot["occupied"].(bool)
				status := "empty"
				if occupied {
					status = "occupied"
				}
				fmt.Printf("  [statusChanged] spot %v -> %s\n", spotId, status)
				if occupied {
					if vehicle, ok := spot["vehicle"].(map[string]interface{}); ok {
						plateNo, _ := vehicle["plateNo"].(string)
						score, _ := vehicle["score"].(float64)
						fmt.Printf("    plate: %s  score: %.1f%%\n", plateNo, score)
					}
				}
			}
		}
	}

	fmt.Printf("\n  Received %d events\n", msgCount)
}
