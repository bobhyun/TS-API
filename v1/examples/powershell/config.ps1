<#
.SYNOPSIS
  TS-API Examples - Shared Configuration

.DESCRIPTION
  Environment variables:
    NVR_HOST    - NVR server hostname (default: localhost)
    NVR_SCHEME  - http or https (default: https)
    NVR_PORT    - NVR server port (default: 443 for https, 80 for http)
    NVR_USER    - Login username (default: admin)
    NVR_PASS    - Login password (default: 1234)
    NVR_API_KEY - API Key for v1 endpoints (used by examples 02-15)

.EXAMPLE
  $env:NVR_API_KEY = 'tsapi_key_...'; pwsh 02-channels.ps1
  $env:NVR_HOST = '192.168.0.100'; $env:NVR_API_KEY = 'tsapi_key_...'; pwsh 02-channels.ps1
  $env:NVR_SCHEME = 'http'; $env:NVR_PORT = '80'; pwsh 01-login.ps1
#>

# Fix console encoding for Korean text output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Script:NVR_HOST    = if ($env:NVR_HOST)    { $env:NVR_HOST }    else { 'localhost' }
$Script:NVR_SCHEME  = if ($env:NVR_SCHEME)  { $env:NVR_SCHEME }  else { 'https' }
$Script:NVR_PORT    = if ($env:NVR_PORT)    { $env:NVR_PORT }    else { if ($NVR_SCHEME -eq 'https') { '443' } else { '80' } }
$Script:NVR_USER    = if ($env:NVR_USER)    { $env:NVR_USER }    else { 'admin' }
$Script:NVR_PASS    = if ($env:NVR_PASS)    { $env:NVR_PASS }    else { '1234' }
$Script:NVR_API_KEY = if ($env:NVR_API_KEY) { $env:NVR_API_KEY } else { '' }

$_defaultPort = if ($NVR_SCHEME -eq 'https') { '443' } else { '80' }
$_portSuffix  = if ($NVR_PORT -eq $_defaultPort) { '' } else { ":$NVR_PORT" }

$Script:BASE_URL  = "${NVR_SCHEME}://${NVR_HOST}${_portSuffix}"
$Script:WS_SCHEME = if ($NVR_SCHEME -eq 'https') { 'wss' } else { 'ws' }
$Script:WS_URL    = "${WS_SCHEME}://${NVR_HOST}${_portSuffix}"

# --- SSL Certificate Handling ---
if ($NVR_SCHEME -eq 'https') {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        # PowerShell 7+: use -SkipCertificateCheck splatting
        $Script:SkipCertFlag = @{ SkipCertificateCheck = $true }
    } else {
        # PowerShell 5.1: bypass SSL validation globally
        $Script:SkipCertFlag = @{}
        try {
            Add-Type @"
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert,
        WebRequest req, int problem) { return true; }
}
"@
            [System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()
        } catch {
            # Type may already be added
        }
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
} else {
    $Script:SkipCertFlag = @{}
}
