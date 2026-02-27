// Package tsapi provides a minimal HTTP client for TS-API.
//
// No external dependencies - uses only Go standard library.
package tsapi

import (
	"bytes"
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

// Config holds NVR connection settings from environment variables.
type Config struct {
	Host    string
	Port    string
	Scheme  string
	User    string
	Pass    string
	ApiKey  string
	BaseURL string
	WsURL   string
}

// LoadConfig reads NVR settings from environment variables.
func LoadConfig() Config {
	scheme := envOr("NVR_SCHEME", "https")
	defaultPort := "443"
	if scheme == "http" {
		defaultPort = "80"
	}
	port := envOr("NVR_PORT", defaultPort)
	host := envOr("NVR_HOST", "localhost")

	portSuffix := ""
	if port != defaultPort {
		portSuffix = ":" + port
	}
	wsScheme := "wss"
	if scheme == "http" {
		wsScheme = "ws"
	}

	return Config{
		Host:    host,
		Port:    port,
		Scheme:  scheme,
		User:    envOr("NVR_USER", "admin"),
		Pass:    envOr("NVR_PASS", "1234"),
		ApiKey:  os.Getenv("NVR_API_KEY"),
		BaseURL: scheme + "://" + host + portSuffix,
		WsURL:   wsScheme + "://" + host + portSuffix,
	}
}

// Client is a simple HTTP client for TS-API.
// Uses JWT Bearer token or API Key authentication.
type Client struct {
	Config       Config
	HTTP         *http.Client
	accessToken  string
	refreshToken string
	apiKey       string
}

// Response wraps an HTTP response.
type Response struct {
	Status int
	Body   []byte
}

// JSON unmarshals the response body into v.
func (r *Response) JSON(v interface{}) error {
	return json.Unmarshal(r.Body, v)
}

// String returns the response body as string.
func (r *Response) String() string {
	return string(r.Body)
}

// NewClient creates a new NVR API client.
// Authenticates via JWT Bearer token or API Key.
func NewClient(cfg Config) *Client {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	return &Client{
		Config: cfg,
		HTTP:   &http.Client{Transport: tr},
	}
}

// SetApiKey sets the API key for X-API-Key header authentication.
// Setting an API Key allows access to v1 endpoints without login.
func (c *Client) SetApiKey(key string) {
	c.apiKey = key
}

// Get sends a GET request.
func (c *Client) Get(path string) (*Response, error) {
	return c.do("GET", path, nil)
}

// Post sends a POST request with JSON body.
func (c *Client) Post(path string, body interface{}) (*Response, error) {
	return c.do("POST", path, body)
}

// Put sends a PUT request with JSON body.
func (c *Client) Put(path string, body interface{}) (*Response, error) {
	return c.do("PUT", path, body)
}

// Delete sends a DELETE request.
func (c *Client) Delete(path string) (*Response, error) {
	return c.do("DELETE", path, nil)
}

// Login performs JWT login and stores tokens for subsequent requests.
func (c *Client) Login() error {
	auth := base64.StdEncoding.EncodeToString([]byte(c.Config.User + ":" + c.Config.Pass))
	r, err := c.Post("/api/v1/auth/login", map[string]string{
		"auth": auth,
	})
	if err != nil {
		return err
	}
	if r.Status != 200 {
		return fmt.Errorf("login failed: %d", r.Status)
	}
	var tp TokenPair
	if err := r.JSON(&tp); err != nil {
		return err
	}
	c.accessToken = tp.AccessToken
	c.refreshToken = tp.RefreshToken
	return nil
}

// Logout revokes refresh token and clears stored tokens.
func (c *Client) Logout() {
	c.Post("/api/v1/auth/logout", map[string]string{
		"refreshToken": c.refreshToken,
	})
	c.accessToken = ""
	c.refreshToken = ""
}

// TokenPair holds JWT tokens from login.
type TokenPair struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	ExpiresIn    int    `json:"expiresIn"`
	TokenType    string `json:"tokenType"`
}

// JwtLogin performs JWT login. Returns accessToken + refreshToken.
func (c *Client) JwtLogin() (*TokenPair, error) {
	auth := base64.StdEncoding.EncodeToString([]byte(c.Config.User + ":" + c.Config.Pass))
	r, err := c.Post("/api/v1/auth/login", map[string]string{
		"auth": auth,
	})
	if err != nil {
		return nil, err
	}
	if r.Status != 200 {
		return nil, fmt.Errorf("JWT login failed: %d", r.Status)
	}
	var tp TokenPair
	if err := r.JSON(&tp); err != nil {
		return nil, err
	}
	return &tp, nil
}

// JwtRefresh refreshes tokens using refresh token (token rotation).
func (c *Client) JwtRefresh(refreshToken string) (*TokenPair, error) {
	r, err := c.Post("/api/v1/auth/refresh", map[string]string{
		"refreshToken": refreshToken,
	})
	if err != nil {
		return nil, err
	}
	if r.Status != 200 {
		return nil, fmt.Errorf("refresh failed: %d", r.Status)
	}
	var tp TokenPair
	if err := r.JSON(&tp); err != nil {
		return nil, err
	}
	c.accessToken = tp.AccessToken
	c.refreshToken = tp.RefreshToken
	return &tp, nil
}

// JwtLogout revokes refresh token.
func (c *Client) JwtLogout(refreshToken string) error {
	_, err := c.Post("/api/v1/auth/logout", map[string]string{
		"refreshToken": refreshToken,
	})
	return err
}

func (c *Client) do(method, path string, body interface{}) (*Response, error) {
	var bodyReader io.Reader
	if body != nil {
		data, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		bodyReader = bytes.NewReader(data)
	}

	req, err := http.NewRequest(method, c.Config.BaseURL+path, bodyReader)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Host", c.Config.Host+":"+c.Config.Port)

	if c.apiKey != "" {
		req.Header.Set("X-API-Key", c.apiKey)
	} else if c.accessToken != "" {
		req.Header.Set("Authorization", "Bearer "+c.accessToken)
	}

	resp, err := c.HTTP.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return &Response{Status: resp.StatusCode, Body: data}, nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
