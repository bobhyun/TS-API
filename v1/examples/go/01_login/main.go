// 01_login - Authentication methods
// Demonstrates three authentication methods: Legacy Session, JWT, API Key.
// NOTE: API Key only works with v1 endpoints (/api/v1/*). v0 returns 401.
//
// Run: cd examples/go && go run ./v1/01_login/
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"tsapi-examples/tsapi"
)

func main() {
	cfg := tsapi.LoadConfig()
	client := tsapi.NewClient(cfg)

	// ── 1. Session Login (for data API access, recommended) ──
	// POST /api/v1/auth/login  {"auth":"base64(username:password)"}
	// Server sets session cookie, automatically sent with subsequent requests.
	fmt.Println("=== Session Login ===")
	if err := client.Login(); err != nil {
		log.Fatal("Legacy login failed:", err)
	}
	fmt.Println("Legacy session OK (cookie-based)")

	// Verify session - whoAmI
	r, err := client.Get("/api/v1/info?whoAmI")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("whoAmI:", r.String())

	client.Logout()
	fmt.Println("Logged out")

	// ── 2. JWT authentication (accessToken + refreshToken) ──
	// POST /api/v1/auth/login   → {accessToken, refreshToken, expiresIn, tokenType}
	// POST /api/v1/auth/refresh → {accessToken, expiresIn, tokenType}
	// POST /api/v1/auth/logout  (revoke refreshToken)
	fmt.Println("\n=== JWT Login ===")
	tp, err := client.JwtLogin()
	if err != nil {
		log.Fatal("JWT login failed:", err)
	}
	fmt.Printf("Access Token:  %s...\n", tp.AccessToken[:30])
	fmt.Printf("Refresh Token: %s...\n", tp.RefreshToken[:30])
	fmt.Printf("Expires In:    %ds\n", tp.ExpiresIn)

	// Refresh accessToken using refreshToken
	newToken, err := client.JwtRefresh(tp.RefreshToken)
	if err == nil {
		fmt.Printf("Refreshed:     %s...\n", newToken.AccessToken[:30])
	}

	// JWT logout (revoke refreshToken) - skip here, need token for API Key demo
	// client.JwtLogout(tp.RefreshToken)

	// ── 3. API Key (create -> use -> list -> delete) ──
	// POST /api/v1/auth/apikey        (create, requires admin JWT)
	// X-API-Key header                (use, v1 endpoints only. v0 returns 401)
	// GET /api/v1/auth/apikey         (list)
	// DELETE /api/v1/auth/apikey/{id} (delete)
	fmt.Println("\n=== API Key ===")

	// 1) Use JWT token obtained above
	bearerAuth := "Bearer " + tp.AccessToken

	// 2) Create API Key
	createBody, _ := json.Marshal(map[string]string{"name": "example-integration"})
	createReq, _ := http.NewRequest("POST", cfg.BaseURL+"/api/v1/auth/apikey",
		bytes.NewReader(createBody))
	createReq.Header.Set("Authorization", bearerAuth)
	createReq.Header.Set("Content-Type", "application/json")
	createReq.Header.Set("X-Host", cfg.Host+":"+cfg.Port)
	createResp, err := client.HTTP.Do(createReq)
	if err != nil {
		log.Fatal("create apikey:", err)
	}
	defer createResp.Body.Close()
	createData, _ := io.ReadAll(createResp.Body)
	fmt.Println("Create API Key:", createResp.StatusCode)

	if createResp.StatusCode != 200 {
		return
	}

	var keyResult struct {
		ID      string `json:"id"`
		APIKey  string `json:"key"`
		Message string `json:"message"`
	}
	json.Unmarshal(createData, &keyResult)
	fmt.Printf("  Key ID: %s\n", keyResult.ID)
	fmt.Printf("  API Key: %s...\n", keyResult.APIKey[:24])
	if keyResult.Message != "" {
		fmt.Printf("  WARNING: %s\n", keyResult.Message)
	}

	// 3) Access data endpoints with API Key (no login required)
	useReq, _ := http.NewRequest("GET", cfg.BaseURL+"/api/v1/channel", nil)
	useReq.Header.Set("X-API-Key", keyResult.APIKey)
	useReq.Header.Set("X-Host", cfg.Host+":"+cfg.Port)
	useResp, _ := client.HTTP.Do(useReq)
	useResp.Body.Close()
	fmt.Println("Use API Key -> GET /api/v1/channel:", useResp.StatusCode)

	// 4) List API Keys
	listReq, _ := http.NewRequest("GET", cfg.BaseURL+"/api/v1/auth/apikey", nil)
	listReq.Header.Set("Authorization", bearerAuth)
	listReq.Header.Set("X-Host", cfg.Host+":"+cfg.Port)
	listResp, _ := client.HTTP.Do(listReq)
	listResp.Body.Close()
	fmt.Println("List API Keys:", listResp.StatusCode)

	// 5) Delete API Key
	delReq, _ := http.NewRequest("DELETE", cfg.BaseURL+"/api/v1/auth/apikey/"+keyResult.ID, nil)
	delReq.Header.Set("Authorization", bearerAuth)
	delReq.Header.Set("X-Host", cfg.Host+":"+cfg.Port)
	delResp, _ := client.HTTP.Do(delReq)
	delResp.Body.Close()
	fmt.Println("Delete API Key:", delResp.StatusCode)
}
