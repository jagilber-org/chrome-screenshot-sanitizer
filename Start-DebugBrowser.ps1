<#
.SYNOPSIS
    Start Chrome/Edge with debugging enabled and CORS disabled for screenshot sanitization.

.DESCRIPTION
    Intelligently starts a debug browser instance with web security disabled.
    - Auto-detects Edge/Chrome installation
    - Closes existing instances to avoid port conflicts
    - Uses isolated temp profile for safety
    - Validates debugging port availability
    - Waits for browser to be ready

.PARAMETER Port
    Remote debugging port. Default: 9222

.PARAMETER Browser
    Browser to use: 'edge' or 'chrome'. Default: auto-detect (prefers Edge)

.PARAMETER Url
    Initial URL to open. Default: https://portal.azure.com

.PARAMETER NoCloseExisting
    Don't close existing browser instances (may cause port conflicts)

.EXAMPLE
    .\Start-DebugBrowser.ps1
    
.EXAMPLE
    .\Start-DebugBrowser.ps1 -Browser chrome -Port 9223

.EXAMPLE
    .\Start-DebugBrowser.ps1 -Url "https://google.com" -NoCloseExisting
#>

[CmdletBinding()]
param(
    [Parameter()]
    [int]$Port = 9222,
    
    [Parameter()]
    [ValidateSet('edge', 'chrome', 'auto')]
    [string]$Browser = 'auto',
    
    [Parameter()]
    [string]$Url = 'https://portal.azure.com',
    
    [Parameter()]
    [switch]$NoCloseExisting
)

$ErrorActionPreference = 'Stop'

# Browser detection
function Find-Browser {
    param([string]$Preference)
    
    $browsers = @{
        edge = @(
            "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
            "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
        )
        chrome = @(
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
        )
    }
    
    if ($Preference -eq 'auto') {
        # Try Edge first, then Chrome
        foreach ($path in $browsers.edge) {
            if (Test-Path $path) {
                return @{ Path = $path; Name = 'Edge' }
            }
        }
        foreach ($path in $browsers.chrome) {
            if (Test-Path $path) {
                return @{ Path = $path; Name = 'Chrome' }
            }
        }
    } else {
        foreach ($path in $browsers[$Preference]) {
            if (Test-Path $path) {
                return @{ Path = $path; Name = $Preference }
            }
        }
    }
    
    throw "No browser found. Please install Edge or Chrome."
}

# Check if port is in use
function Test-PortInUse {
    param([int]$PortNumber)
    
    $connections = Get-NetTCPConnection -LocalPort $PortNumber -ErrorAction SilentlyContinue
    return $null -ne $connections
}

# Close existing browser instances
function Stop-BrowserInstances {
    param([string]$BrowserName)
    
    $processName = if ($BrowserName -eq 'Edge') { 'msedge' } else { 'chrome' }
    
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "Found $($processes.Count) existing $BrowserName process(es)" -ForegroundColor Yellow
        Write-Host "Closing them to free port $Port..." -ForegroundColor Yellow
        
        $processes | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        # Verify closed
        $remaining = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($remaining) {
            Write-Warning "Some $BrowserName processes still running. May cause issues."
        } else {
            Write-Host "✓ Closed all $BrowserName instances" -ForegroundColor Green
        }
    }
}

# Wait for browser to start responding
function Wait-BrowserReady {
    param([int]$PortNumber, [int]$TimeoutSeconds = 10)
    
    $endpoint = "http://localhost:$PortNumber/json/version"
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    Write-Host "Waiting for browser debugging endpoint..." -NoNewline
    
    while ($stopwatch.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
        try {
            $response = Invoke-RestMethod -Uri $endpoint -TimeoutSec 1 -ErrorAction Stop
            if ($response.Browser) {
                Write-Host " Ready!" -ForegroundColor Green
                Write-Host "Browser: $($response.Browser)" -ForegroundColor Cyan
                Write-Host "WebSocket: $($response.webSocketDebuggerUrl)" -ForegroundColor Cyan
                return $true
            }
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Milliseconds 500
        }
    }
    
    Write-Host " Timeout!" -ForegroundColor Red
    return $false
}

# Main execution
Write-Host "=== Smart Debug Browser Launcher ===" -ForegroundColor Cyan
Write-Host ""

# 1. Find browser
Write-Host "[1/5] Detecting browser..." -ForegroundColor Yellow
$browserInfo = Find-Browser -Preference $Browser
Write-Host "✓ Found: $($browserInfo.Name) at $($browserInfo.Path)" -ForegroundColor Green
Write-Host ""

# 2. Check port availability
Write-Host "[2/5] Checking port $Port..." -ForegroundColor Yellow
if (Test-PortInUse -PortNumber $Port) {
    Write-Host "⚠ Port $Port is in use" -ForegroundColor Yellow
    
    if (-not $NoCloseExisting) {
        Stop-BrowserInstances -BrowserName $browserInfo.Name
        
        if (Test-PortInUse -PortNumber $Port) {
            throw "Port $Port still in use after closing browser. Another process may be using it."
        }
    } else {
        throw "Port $Port is in use. Use without -NoCloseExisting to close existing browsers."
    }
} else {
    Write-Host "✓ Port $Port is available" -ForegroundColor Green
}
Write-Host ""

# 3. Close existing instances if not already done
if (-not $NoCloseExisting) {
    Write-Host "[3/5] Ensuring clean state..." -ForegroundColor Yellow
    Stop-BrowserInstances -BrowserName $browserInfo.Name
} else {
    Write-Host "[3/5] Skipping cleanup (NoCloseExisting)" -ForegroundColor Gray
}
Write-Host ""

# 4. Create temp profile
Write-Host "[4/5] Creating isolated profile..." -ForegroundColor Yellow
$userDataDir = Join-Path $env:TEMP "debug-browser-$(Get-Random)"
New-Item -ItemType Directory -Path $userDataDir -Force | Out-Null
Write-Host "✓ Profile: $userDataDir" -ForegroundColor Green
Write-Host ""

# 5. Launch browser
Write-Host "[5/5] Launching $($browserInfo.Name) with CORS disabled..." -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠⚠⚠ SECURITY WARNING ⚠⚠⚠" -ForegroundColor Red
Write-Host "This browser has NO web security!" -ForegroundColor Red
Write-Host "ONLY use for Azure Portal screenshot sanitization!" -ForegroundColor Red
Write-Host "DO NOT browse untrusted sites!" -ForegroundColor Red
Write-Host ""

$arguments = @(
    "--remote-debugging-port=$Port",
    "--user-data-dir=`"$userDataDir`"",
    "--disable-web-security",
    "--disable-site-isolation-trials",
    "--disable-features=IsolateOrigins,site-per-process",
    "--no-first-run",
    "--no-default-browser-check",
    "`"$Url`""
)

$processArgs = @{
    FilePath = $browserInfo.Path
    ArgumentList = $arguments
    PassThru = $true
}

try {
    $process = Start-Process @processArgs
    
    # Wait for browser to be ready
    if (Wait-BrowserReady -PortNumber $Port) {
        Write-Host ""
        Write-Host "✓ Browser is ready for Chrome MCP!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Navigate to Resource Explorer in the browser" -ForegroundColor White
        Write-Host "  2. Expand the tree" -ForegroundColor White
        Write-Host "  3. In VS Code, run: clean page" -ForegroundColor White
        Write-Host ""
        Write-Host "Debugging endpoint: http://localhost:$Port" -ForegroundColor Cyan
        Write-Host "Process ID: $($process.Id)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Browser will run until closed. Temp profile will be cleaned up on exit." -ForegroundColor Gray
        
        # Return info for programmatic use
        return @{
            Success = $true
            ProcessId = $process.Id
            Port = $Port
            Browser = $browserInfo.Name
            UserDataDir = $userDataDir
            DebugUrl = "http://localhost:$Port"
        }
    } else {
        Write-Warning "Browser launched but debugging endpoint not responding. It may still work."
        return @{
            Success = $false
            ProcessId = $process.Id
            Port = $Port
            Browser = $browserInfo.Name
        }
    }
    
} catch {
    Write-Error "Failed to launch browser: $_"
    
    # Cleanup temp profile if browser didn't start
    if (Test-Path $userDataDir) {
        Remove-Item -Path $userDataDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    throw
}
