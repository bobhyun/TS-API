<#
.SYNOPSIS
  01-login.ps1 - TS-API v1 Authentication Methods

.DESCRIPTION
  Three authentication methods:
    1. Client login - http.ps1 logs in with JWT and sends the Bearer token automatically
    2. JWT          - POST /api/v1/auth/login; manage accessToken/refreshToken yourself
    3. API Key      - X-API-Key header, for external integrations

  NOTE: v1 endpoints accept a JWT Bearer token or an API Key. Session cookies are not supported.
  NOTE: v0 endpoints (/api/*) reject X-API-Key with 401.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"
. "$PSScriptRoot/http.ps1"


function Demo-SessionLogin {
    <# Method 1: Client login.

    POST /api/v1/auth/login with {"auth": "base64(username:password)"}
    http.ps1 stores the JWT and sends it as a Bearer token.
    #>
    Write-Host '=== Session Login ==='

    $ok = Invoke-NvrLogin $NVR_USER $NVR_PASS
    Write-Host "Login: $(if ($ok) { 'OK' } else { 'FAILED' })"

    if ($ok) {
        # Token is stored; data endpoints are accessible
        $r = Invoke-NvrGet '/api/v1/channel'
        Write-Host "GET /api/v1/channel -> $($r.Count) channels"

        # Log out to revoke the refreshToken
        Invoke-NvrLogout
        Write-Host 'Logged out'
    }
}


function Demo-Jwt {
    <# Method 2: JWT Token (accessToken + refreshToken).

    POST /api/v1/auth/login -> {accessToken, refreshToken, expiresIn, tokenType}
    POST /api/v1/auth/refresh -> {accessToken, refreshToken, expiresIn, tokenType} (rotates refreshToken)
    POST /api/v1/auth/logout  (revoke refreshToken)
    #>
    Write-Host "`n=== JWT Login ==="

    # 1) Login -> accessToken + refreshToken
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

    # 2) Use accessToken for API calls
    $r = Invoke-NvrGet '/api/v1/auth/apikey' -Headers @{ Authorization = "Bearer $accessToken" }
    Write-Host "GET /api/v1/auth/apikey -> $(if ($r) { 'OK' } else { 'FAILED' })"

    # 3) Refresh accessToken
    $newTokens = Invoke-NvrJwtRefresh $refreshToken
    if ($newTokens) {
        Write-Host "Refreshed:     $($newTokens.accessToken.Substring(0, [Math]::Min(30, $newTokens.accessToken.Length)))..."
    }

    # 4) Logout (revoke refreshToken)
    Invoke-NvrJwtLogout $refreshToken
    Write-Host 'JWT logged out (refreshToken revoked)'
}


function Demo-ApiKey {
    <# Method 3: API Key (create -> use -> list -> delete).

    POST /api/v1/auth/apikey        (create, requires admin JWT)
    X-API-Key header                (use, v1 endpoints only)
    GET /api/v1/auth/apikey         (list)
    DELETE /api/v1/auth/apikey/{id} (delete)
    #>
    Write-Host "`n=== API Key ==="

    # 1) Get an admin token via JWT login
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
        # permissions = @('remote')          # optional: permissions (default: remote)
        # channels = @(1, 2)                 # optional: allowed channels
        # ipWhitelist = @('192.168.0.0/24')  # optional: allowed client IPs
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

    # 3) Call a data endpoint with the API Key (no login required)
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
