<#
.SYNOPSIS
    Copy authentication cookies from normal Edge to debug Edge instance.

.DESCRIPTION
    Copies Azure Portal authentication cookies from your normal Edge profile
    to the debug browser, allowing you to work authenticated with CORS disabled.

.EXAMPLE
    .\Copy-BrowserCookies.ps1
#>

[CmdletBinding()]
param()

Write-Host "=== Browser Cookie Transfer ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will copy Azure Portal authentication from your normal Edge" -ForegroundColor Yellow
Write-Host "to the debug browser (which can't login due to disabled CORS)." -ForegroundColor Yellow
Write-Host ""
Write-Host "Steps:" -ForegroundColor Cyan
Write-Host "  1. Login to portal.azure.com in your NORMAL Edge browser" -ForegroundColor White
Write-Host "  2. Close this normal Edge window" -ForegroundColor White
Write-Host "  3. Run this script to copy the cookies" -ForegroundColor White
Write-Host "  4. Refresh debug browser - you'll be logged in!" -ForegroundColor White
Write-Host ""

Write-Warning "You need to close ALL normal Edge windows before running this script."
Write-Host ""
$continue = Read-Host "Have you logged into portal.azure.com and closed normal Edge? (y/n)"

if ($continue -ne 'y') {
    Write-Host "Cancelled. Come back when ready!" -ForegroundColor Yellow
    exit 0
}

# Find normal Edge cookie database
$normalProfile = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
$cookieDbPath = Join-Path $normalProfile "Network\Cookies"

if (-not (Test-Path $cookieDbPath)) {
    Write-Error "Could not find Edge cookie database at: $cookieDbPath"
    Write-Host "Make sure Edge has been run at least once." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Found Edge cookie database" -ForegroundColor Green

# Find debug browser profile (look for recent temp dirs)
$debugProfiles = Get-ChildItem "$env:TEMP\debug-browser-*" -Directory -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $debugProfiles) {
    Write-Error "No debug browser profile found in $env:TEMP"
    Write-Host "Make sure you ran Start-DebugBrowser.ps1 first" -ForegroundColor Yellow
    exit 1
}

$debugProfile = $debugProfiles.FullName
$debugCookiePath = Join-Path $debugProfile "Default\Network\Cookies"

Write-Host "✓ Found debug profile: $debugProfile" -ForegroundColor Green

# Copy cookies
Write-Host "Copying cookies..." -NoNewline

try {
    # Ensure target directory exists
    $targetDir = Split-Path $debugCookiePath -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    Copy-Item -Path $cookieDbPath -Destination $debugCookiePath -Force
    Write-Host " Done!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "✓ Cookies copied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. In the debug browser, refresh the Azure Portal page" -ForegroundColor White
    Write-Host "  2. You should now be logged in!" -ForegroundColor White
    Write-Host "  3. Navigate to Resource Explorer and expand the tree" -ForegroundColor White
    Write-Host "  4. Run: clean page" -ForegroundColor White
    
} catch {
    Write-Error "Failed to copy cookies: $_"
    exit 1
}
