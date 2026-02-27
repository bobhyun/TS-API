// 12_ws_events - WebSocket Real-time Event Subscription
//
// Receives real-time events (LPR, channelStatus, etc.) via WebSocket.
//
// Two subscription modes:
//   1. URL query params:  ?topics=LPR,channelStatus  (subscribe on connect)
//   2. Dynamic send():    {"subscribe":"LPR"}         (subscribe after connect, v1 only)
//
// Endpoint: ws://host:port/wsapi/v1/events
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// REQUIRES: go get github.com/gorilla/websocket
//
// Run: cd examples/go && go run ./v1/12_ws_events/
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

	dialer := websocket.Dialer{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	headers := http.Header{"X-API-Key": {cfg.ApiKey}}

	// ── Method 1: Subscribe via URL query params (classic) ──
	fmt.Println("=== Method 1: Subscribe via URL (10 seconds) ===")

	wsURL1 := cfg.WsURL + "/wsapi/v1/events?topics=LPR,channelStatus"
	conn1, _, err := dialer.Dial(wsURL1, headers)
	if err != nil {
		log.Fatal("Connect failed:", err)
	}
	fmt.Println("  Connected!")

	messageCount1 := 0
	done1 := make(chan struct{})

	go func() {
		defer close(done1)
		for {
			_, data, err := conn1.ReadMessage()
			if err != nil {
				return
			}
			messageCount1++
			var msg map[string]interface{}
			if err := json.Unmarshal(data, &msg); err == nil {
				topic, _ := msg["topic"].(string)
				if topic == "" {
					topic, _ = msg["type"].(string)
				}
				fmt.Printf("  [%s] %s\n", topic, string(data))
			} else {
				fmt.Printf("  Raw: %s\n", string(data))
			}
		}
	}()

	select {
	case <-done1:
	case <-time.After(10 * time.Second):
	}
	fmt.Printf("  Received %d events\n", messageCount1)
	conn1.WriteMessage(websocket.CloseMessage,
		websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
	conn1.Close()

	// ── Method 2: Dynamic subscribe/unsubscribe via send() (v1 only) ──
	//   - Connect WITHOUT topics
	//   - Subscribe/unsubscribe at any time
	//   - Per-topic filters (ch, objectTypes, lot, spot)
	//   - Re-subscribe to update filters
	fmt.Println("\n=== Method 2: Dynamic Subscribe (10 seconds) ===")

	wsURL2 := cfg.WsURL + "/wsapi/v1/events"
	conn2, _, err := dialer.Dial(wsURL2, headers)
	if err != nil {
		log.Fatal("Connect failed:", err)
	}
	fmt.Println("  Connected (no topics yet)")

	// Phase 1: Subscribe to initial topics with per-topic filters
	fmt.Println("  [Phase 1] Subscribe channelStatus + LPR (ch 1,2)")
	sendJSON(conn2, map[string]interface{}{"subscribe": "channelStatus"})
	sendJSON(conn2, map[string]interface{}{"subscribe": "LPR", "ch": []int{1, 2}})

	messageCount2 := 0
	done2 := make(chan struct{})

	go func() {
		defer close(done2)
		for {
			_, data, err := conn2.ReadMessage()
			if err != nil {
				return
			}
			messageCount2++
			var msg map[string]interface{}
			if err := json.Unmarshal(data, &msg); err != nil {
				fmt.Printf("  Raw: %s\n", string(data))
				continue
			}

			// Handle control responses
			if msgType, ok := msg["type"].(string); ok {
				topic, _ := msg["topic"].(string)
				switch msgType {
				case "subscribed":
					fmt.Printf("  Subscribed to: %s\n", topic)
					continue
				case "unsubscribed":
					fmt.Printf("  Unsubscribed from: %s\n", topic)
					continue
				case "error":
					message, _ := msg["message"].(string)
					fmt.Printf("  Error: %s (topic: %s)\n", message, topic)
					continue
				}
			}

			// Handle event data
			topic, _ := msg["topic"].(string)
			fmt.Printf("  [%s] %s\n", topic, string(data))
		}
	}()

	// Schedule mid-connection topic changes
	go func() {
		// Phase 2 (3s): Add new topic + update existing filter
		time.Sleep(3 * time.Second)
		fmt.Println("  [Phase 2] Add object topic + expand LPR to ch 1-4")
		sendJSON(conn2, map[string]interface{}{"subscribe": "object", "objectTypes": []string{"human", "vehicle"}})
		sendJSON(conn2, map[string]interface{}{"subscribe": "LPR", "ch": []int{1, 2, 3, 4}})

		// Phase 3 (6s): Unsubscribe topic + subscribe new topic + reduce channels
		time.Sleep(3 * time.Second)
		fmt.Println("  [Phase 3] Unsubscribe channelStatus + add motionChanges (ch 1) + reduce LPR to ch 1,3")
		sendJSON(conn2, map[string]interface{}{"unsubscribe": "channelStatus"})
		sendJSON(conn2, map[string]interface{}{"subscribe": "motionChanges", "ch": []int{1}})
		sendJSON(conn2, map[string]interface{}{"subscribe": "LPR", "ch": []int{1, 3}}) // re-subscribe with fewer ch drops ch 2,4
	}()

	select {
	case <-done2:
	case <-time.After(10 * time.Second):
	}
	fmt.Printf("  Received %d messages\n", messageCount2)
	conn2.WriteMessage(websocket.CloseMessage,
		websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
	conn2.Close()
}

func sendJSON(conn *websocket.Conn, v interface{}) {
	data, err := json.Marshal(v)
	if err != nil {
		return
	}
	conn.WriteMessage(websocket.TextMessage, data)
}
