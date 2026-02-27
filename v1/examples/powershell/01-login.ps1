<#
.SYNOPSIS
  01-login.ps1 - TS-API v1 Authentication Methods

.DESCRIPTION
  Three authentication methods:
    1. Session Login   - POST /api/v1/auth/login (JSON body, cookie-based)
    2. JWT Token       - POST /api/v1/auth/login (JSON body, token-based)
    3. API Key         - X-API-Key header (v1 endpoints only)

  NOTE: JWT tokens only work on /api/v1/auth/* endpoints.
        For data endpoints (channels, events, etc.), use Legacy Session or API Key.
  NOTE: API Key authentication is supported on v1 endpoints only.
        v0 endpoints (/api/*) reject X-API-Key with 401 Unauthorized.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"


function Demo-SessionLogin {
    <# Method 1: Session Login (POST with JSON body).

    POST /api/v1/auth/login with {"auth": "base64(username:password)"}
    The server sets a session cookie on successful login.
    All subsequent requests carry the cookie automatically.
    #>
    Write-Host '=== Session Login ==='

    $ok = Invoke-NvrLogin $NVR_USER $NVR_PASS
    Write-Host "Login: $(if ($ok) { 'OK' } else { 'FAILED' })"

    if ($ok) {
        # Session cookie is now set; data endpoints work
        $r = Invoke-NvrGet '/api/v1/channel'
        Write-Host "GET /api/v1/channel -> $($r.Count) channels"

        # Always logout to release the session
        Invoke-NvrLogout
        Write-Host 'Logged out'
    }
}


function Demo-Jwt {
    <# Method 2: JWT Token (accessToken + refreshToken).

    POST /api/v1/auth/login -> {accessToken, refreshToken, expiresIn, tokenType}
    POST /api/v1/auth/refresh -> {accessToken, expiresIn, tokenType}
    POST /api/v1/auth/logout  (revoke refreshToken)
    #>
    Write-Host "`n=== JWT Login ==="

    # 1) Login -> get accessToken + refreshToken
    $tokens = Invoke-NvrJwtLogin $NVR_USER $NVR_PASS
    if (-not $tokens) {
        Write-Host 'JWT login failed'
        return
    }

    $accessToken  = $tokens.accessToken
    $refreshToken = $tokens.refreshToken
    Write-Host "Access Token:  $($accessToken.Substring(0, [Math]::Min(30, $accessToken.Length)))..."
    Write-Host "Refresh Token: $($refreshToken.Substring(0, [Math]::Min(30, $refreshToken.Length)))..."
    Write-Host "Expires In:    $($tokens.expiresIn)s"

    # 2) Use accessToken for auth endpoints
    $r = Invoke-NvrGet '/api/v1/auth/apikey' -Headers @{ Authorization = "Bearer $accessToken" }
    Write-Host "GET /api/v1/auth/apikey -> $(if ($r) { 'OK' } else { 'FAILED' })"

    # 3) Refresh accessToken using refreshToken
    $newTokens = Invoke-NvrJwtRefresh $refreshToken
    if ($newTokens) {
        Write-Host "Refreshed:     $($newTokens.accessToken.Substring(0, [Math]::Min(30, $newTokens.accessToken.Length)))..."
    }

    # 4) Logout (revoke refreshToken)
    Invoke-NvrJwtLogout $refreshToken
    Write-Host 'JWT logged out (refreshToken revoked)'
}


function Demo-ApiKey {
    <# Method 3: API Key (Create -> Use -> List -> Delete).

    POST /api/v1/auth/apikey        (Create, admin JWT required)
    X-API-Key header                (Use, v1 endpoints only)
    GET /api/v1/auth/apikey         (List)
    DELETE /api/v1/auth/apikey/{id} (Delete)

    NOTE: API Key only works on v1 endpoints (/api/v1/*).
          v0 endpoints (/api/*) reject API Key with 401.
    #>
    Write-Host "`n=== API Key ==="

    # 1) Obtain admin token via JWT login
    $tokenData = Invoke-NvrJwtLogin $NVR_USER $NVR_PASS
    if (-not $tokenData) {
        Write-Host 'JWT login failed'
        return
    }
    $token = $tokenData.accessToken
    $auth = @{ Authorization = "Bearer $token" }

    # 2) Create API Key
    $r = Invoke-NvrPost '/api/v1/auth/apikey' -Body @{
        name = 'example-integration'
        # permissions = @('remote')          # Optional: specify permissions (default: remote)
        # channels = @(1, 2)                 # Optional: restrict accessible channels
        # ipWhitelist = @('192.168.0.0/24')  # Optional: IP restriction
    } -Headers $auth

    if (-not $r) {
        Write-Host 'Create API Key: FAILED'
        return
    }
    Write-Host "Create API Key: OK"

    $keyId  = $r.id
    $apiKey = $r.key
    Write-Host "  Key ID: $keyId"
    Write-Host "  API Key: $($apiKey.Substring(0, [Math]::Min(24, $apiKey.Length)))..."
    if ($r.message) {
        Write-Host "  WARNING: $($r.message)"
    }

    # 3) Access data endpoints using API Key (no login required)
    $r2 = Invoke-NvrGet '/api/v1/channel' -Headers @{ 'X-API-Key' = $apiKey }
    Write-Host "Use API Key -> GET /api/v1/channel: $(if ($r2) { 'OK' } else { 'FAILED' })"

    # 4) List API Keys
    $r3 = Invoke-NvrGet '/api/v1/auth/apikey' -Headers $auth
    Write-Host "List API Keys: $($r3.Count) keys"

    # 5) Delete API Key
    $r4 = Invoke-NvrDelete "/api/v1/auth/apikey/$keyId" -Headers $auth
    Write-Host 'Delete API Key: OK'
}


Demo-SessionLogin
Demo-Jwt
Demo-ApiKey
