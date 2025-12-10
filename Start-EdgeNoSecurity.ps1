# Launch Edge with web security disabled for Azure Portal sanitization
# WARNING: Only use for local development/testing. DO NOT browse untrusted sites with this.

$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$userDataDir = "$env:TEMP\edge-no-cors-$(Get-Random)"

# Close existing Edge instances (optional - comment out if you want to keep them)
# Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "Launching Edge with CORS disabled..." -ForegroundColor Yellow
Write-Host "User data dir: $userDataDir" -ForegroundColor Gray
Write-Host ""
Write-Host "WARNING: This browser instance has NO web security." -ForegroundColor Red
Write-Host "Only use for Azure Portal screenshot sanitization!" -ForegroundColor Red
Write-Host ""

& $edgePath `
    --disable-web-security `
    --disable-site-isolation-trials `
    --user-data-dir="$userDataDir" `
    --remote-debugging-port=9222 `
    "https://portal.azure.com"

Write-Host "`nEdge closed. Cleaning up temp profile..." -ForegroundColor Gray
Remove-Item -Path $userDataDir -Recurse -Force -ErrorAction SilentlyContinue
