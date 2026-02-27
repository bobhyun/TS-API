<#
.SYNOPSIS
  TS-API Examples - HTTP Client Helper

.DESCRIPTION
  Provides helper functions for TS-API v1 REST calls.
  v1 API supports JWT Bearer token and API Key authentication.

  Functions:
    Set-NvrApiKey       - Set API Key for X-API-Key header authentication
    Get-NvrHeaders      - Build authentication headers
    Invoke-NvrGet       - GET request (returns parsed JSON)
    Invoke-NvrPost      - POST request
    Invoke-NvrPut       - PUT request
    Invoke-NvrDelete    - DELETE request
    Invoke-NvrGetRaw    - GET request returning full WebResponse
    Invoke-NvrLogin     - Login via JWT and store tokens
    Invoke-NvrLogout    - Logout and clear stored tokens
    Invoke-NvrJwtLogin  - JWT login (returns token dict)
    Invoke-NvrJwtRefresh - Refresh access token
    Invoke-NvrJwtLogout - Revoke refresh token
#>

$Script:_AccessToken  = ''
$Script:_RefreshToken = ''
$Script:_ApiKey       = ''

function Set-NvrApiKey([string]$Key) {
    $Script:_ApiKey = $Key
}

function Get-NvrHeaders {
    $h = @{
        'Content-Type' = 'application/json'
        'X-Host'       = "${NVR_HOST}:${NVR_PORT}"
    }
    if ($Script:_ApiKey) {
        $h['X-API-Key'] = $Script:_ApiKey
    }
    if ($Script:_AccessToken) {
        $h['Authorization'] = "Bearer $($Script:_AccessToken)"
    }
    return $h
}

function Invoke-NvrGet([string]$Path, [hashtable]$Headers = @{}) {
    $h = Get-NvrHeaders
    foreach ($k in $Headers.Keys) { $h[$k] = $Headers[$k] }
    try {
        Invoke-RestMethod -Uri "${BASE_URL}${Path}" -Method Get -Headers $h @SkipCertFlag
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        Write-Host "  Error: HTTP $code - $($_.Exception.Message)"
        return $null
    }
}

function Invoke-NvrPost([string]$Path, $Body = $null, [hashtable]$Headers = @{}) {
    $h = Get-NvrHeaders
    foreach ($k in $Headers.Keys) { $h[$k] = $Headers[$k] }
    $params = @{
        Uri     = "${BASE_URL}${Path}"
        Method  = 'Post'
        Headers = $h
    }
    if ($null -ne $Body) {
        $params['Body'] = ($Body | ConvertTo-Json -Depth 10 -Compress)
    }
    try {
        Invoke-RestMethod @params @SkipCertFlag
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        Write-Host "  Error: HTTP $code - $($_.Exception.Message)"
        return $null
    }
}

function Invoke-NvrPut([string]$Path, $Body = $null, [hashtable]$Headers = @{}) {
    $h = Get-NvrHeaders
    foreach ($k in $Headers.Keys) { $h[$k] = $Headers[$k] }
    $params = @{
        Uri     = "${BASE_URL}${Path}"
        Method  = 'Put'
        Headers = $h
    }
    if ($null -ne $Body) {
        $params['Body'] = ($Body | ConvertTo-Json -Depth 10 -Compress)
    }
    try {
        Invoke-RestMethod @params @SkipCertFlag
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        Write-Host "  Error: HTTP $code - $($_.Exception.Message)"
        return $null
    }
}

function Invoke-NvrDelete([string]$Path, [hashtable]$Headers = @{}) {
    $h = Get-NvrHeaders
    foreach ($k in $Headers.Keys) { $h[$k] = $Headers[$k] }
    try {
        Invoke-RestMethod -Uri "${BASE_URL}${Path}" -Method Delete -Headers $h @SkipCertFlag
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        Write-Host "  Error: HTTP $code - $($_.Exception.Message)"
        return $null
    }
}

function Invoke-NvrGetRaw([string]$Path, [hashtable]$Headers = @{}) {
    $h = Get-NvrHeaders
    foreach ($k in $Headers.Keys) { $h[$k] = $Headers[$k] }
    try {
        Invoke-WebRequest -Uri "${BASE_URL}${Path}" -Method Get -Headers $h @SkipCertFlag
    } catch {
        return $_.Exception.Response
    }
}

function Invoke-NvrLogin([string]$Username, [string]$Password) {
    <# Login via JWT and store tokens for subsequent requests. #>
    $auth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${Username}:${Password}"))
    $body = @{ auth = $auth } | ConvertTo-Json -Compress
    $h = @{
        'Content-Type' = 'application/json'
        'X-Host'       = "${NVR_HOST}:${NVR_PORT}"
    }
    try {
        $r = Invoke-RestMethod -Uri "${BASE_URL}/api/v1/auth/login" -Method Post -Headers $h -Body $body @SkipCertFlag
        $Script:_AccessToken  = $r.accessToken
        $Script:_RefreshToken = $r.refreshToken
        return $true
    } catch {
        return $false
    }
}

function Invoke-NvrLogout {
    <# Logout - revoke refresh token and clear stored tokens. #>
    if ($Script:_RefreshToken) {
        $body = @{ refreshToken = $Script:_RefreshToken } | ConvertTo-Json -Compress
        $h = Get-NvrHeaders
        try {
            Invoke-RestMethod -Uri "${BASE_URL}/api/v1/auth/logout" -Method Post -Headers $h -Body $body @SkipCertFlag | Out-Null
        } catch { }
    }
    $Script:_AccessToken  = ''
    $Script:_RefreshToken = ''
}

function Invoke-NvrJwtLogin([string]$Username, [string]$Password) {
    <# JWT login. Returns object with accessToken, refreshToken, expiresIn, tokenType, user. #>
    $auth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${Username}:${Password}"))
    $body = @{ auth = $auth } | ConvertTo-Json -Compress
    $h = @{
        'Content-Type' = 'application/json'
        'X-Host'       = "${NVR_HOST}:${NVR_PORT}"
    }
    try {
        Invoke-RestMethod -Uri "${BASE_URL}/api/v1/auth/login" -Method Post -Headers $h -Body $body @SkipCertFlag
    } catch {
        return $null
    }
}

function Invoke-NvrJwtRefresh([string]$RefreshToken) {
    <# Refresh access token. Server performs token rotation: old refreshToken is revoked. #>
    $body = @{ refreshToken = $RefreshToken } | ConvertTo-Json -Compress
    $h = Get-NvrHeaders
    try {
        $r = Invoke-RestMethod -Uri "${BASE_URL}/api/v1/auth/refresh" -Method Post -Headers $h -Body $body @SkipCertFlag
        $Script:_AccessToken  = $r.accessToken
        $Script:_RefreshToken = $r.refreshToken
        return $r
    } catch {
        return $null
    }
}

function Invoke-NvrJwtLogout([string]$RefreshToken) {
    <# JWT logout - revoke refresh token. #>
    $body = @{ refreshToken = $RefreshToken } | ConvertTo-Json -Compress
    $h = Get-NvrHeaders
    try {
        Invoke-RestMethod -Uri "${BASE_URL}/api/v1/auth/logout" -Method Post -Headers $h -Body $body @SkipCertFlag | Out-Null
    } catch { }
}
