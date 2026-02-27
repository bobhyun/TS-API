// 15_ws_export - WebSocket recording export
//
// Endpoint: ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
//
// Auth:
//   Header: Authorization: Bearer {accessToken}  (primary)
//   Header: X-API-Key: {apiKey}                  (alternative)
//   Query:  ?token={accessToken}                 (browser fallback)
//   Query:  ?apikey={apiKey}                     (browser fallback)
//
// Flow:
//   ready   -> task ID, channel info
//   fileEnd -> download URL, send {task, cmd:"next"}
//   end     -> export complete
//   error   -> error message
//
// Run: cd examples/go && go run ./v1/15_ws_export/
// go get github.com/gorilla/websocket
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

	// Time range: yesterday 00:00 ~ 00:10
	yesterday := time.Now().AddDate(0, 0, -1).Format("2006-01-02")
	timeBegin := yesterday + "T00:00:00"
	timeEnd := yesterday + "T00:10:00"

	fmt.Println("=== WebSocket Recording Export ===")
	fmt.Printf("  Channel: 1,  %s ~ %s\n", timeBegin, timeEnd)

	// Build WebSocket URL with X-API-Key header auth
	// Alt: use ?apikey=tsapi_key_... query param (browser fallback)
	wsURL := fmt.Sprintf("%s/wsapi/v1/export?ch=1&timeBegin=%s&timeEnd=%s",
		cfg.WsURL, timeBegin, timeEnd)

	dialer := websocket.Dialer{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	headers := http.Header{"X-API-Key": {cfg.ApiKey}}
	conn, _, err := dialer.Dial(wsURL, headers)
	if err != nil {
		log.Fatal("Connect failed:", err)
	}
	defer conn.Close()
	fmt.Println("  Connected")

	var taskId string
	done := make(chan struct{})

	// Timeout after 60 seconds
	go func() {
		select {
		case <-done:
		case <-time.After(60 * time.Second):
			fmt.Println("  Timeout - cancelling...")
			if taskId != "" {
				conn.WriteJSON(map[string]string{"task": taskId, "cmd": "cancel"})
				time.Sleep(time.Second)
			}
			conn.Close()
		}
	}()

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			if !websocket.IsCloseError(err, websocket.CloseNormalClosure) {
				fmt.Printf("  Read error: %v\n", err)
			}
			break
		}

		var msg map[string]interface{}
		if err := json.Unmarshal(message, &msg); err != nil {
			fmt.Printf("  Parse error: %v\n", err)
			continue
		}

		stage, _ := msg["stage"].(string)

		switch stage {
		case "ready":
			// Check status code (code:-1 = no recording in range)
			if status, ok := msg["status"].(map[string]interface{}); ok {
				if code, ok := status["code"].(float64); ok && code != 0 {
					message, _ := status["message"].(string)
					fmt.Printf("  Ready - Error: %s\n", message)
					close(done)
					return
				}
			}
			if task, ok := msg["task"].(map[string]interface{}); ok {
				taskId = fmt.Sprintf("%v", task["id"])
			}
			fmt.Printf("  Ready - Task ID: %s\n", taskId)

		case "fileEnd":
			download := "N/A"
			if ch, ok := msg["channel"].(map[string]interface{}); ok {
				if file, ok := ch["file"].(map[string]interface{}); ok {
					// download: [{fileName, src}, ...]
					if dlArr, ok := file["download"].([]interface{}); ok && len(dlArr) > 0 {
						if dlObj, ok := dlArr[0].(map[string]interface{}); ok {
							if src, ok := dlObj["src"].(string); ok {
								download = src
							}
						}
					}
				}
			}
			fmt.Printf("  File ready: %s\n", download)
			if taskId != "" {
				conn.WriteJSON(map[string]string{"task": taskId, "cmd": "next"})
			}

		case "end":
			fmt.Println("  Export complete!")
			close(done)
			conn.WriteMessage(websocket.CloseMessage,
				websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			return

		case "error":
			message, _ := msg["message"].(string)
			if message == "" {
				message = string(message)
			}
			fmt.Printf("  Error: %s\n", message)
			close(done)
			return

		default:
			fmt.Printf("  [%s] %s\n", stage, string(message))
		}
	}

	fmt.Println("  Disconnected")
}
