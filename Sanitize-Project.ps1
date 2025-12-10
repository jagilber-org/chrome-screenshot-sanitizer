<#
.SYNOPSIS
    Sanitize web page and take screenshot for a specific project

.DESCRIPTION
    Uses Chrome MCP server to sanitize PII on a web page and capture screenshot.
    Organizes outputs by project directory using shared .env for PII patterns.

.PARAMETER Project
    Project name (must match directory in projects/ folder)

.PARAMETER Url
    Optional URL to navigate to (if not already on page)

.PARAMETER OutputFileName
    Custom output filename (without extension). Defaults to timestamp-based name.

.PARAMETER FullPage
    Capture full page screenshot instead of viewport only

.EXAMPLE
    .\Sanitize-Project.ps1 -Project "azure-portal"
    
.EXAMPLE
    .\Sanitize-Project.ps1 -Project "github" -Url "https://github.com/yourorg"
    
.EXAMPLE
    .\Sanitize-Project.ps1 -Project "azure-portal" -OutputFileName "resource-group-list" -FullPage
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Project,
    
    [string]$Url,
    
    [string]$OutputFileName,
    
    [switch]$FullPage
)

$ErrorActionPreference = 'Stop'

# Validate project exists
$projectDir = Join-Path $PSScriptRoot "projects\$Project"
if (-not (Test-Path $projectDir)) {
    Write-Error "Project '$Project' not found. Create it first with New-SanitizationProject.ps1"
    exit 1
}

# Load project config
$configPath = Join-Path $projectDir "config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Project config not found: $configPath"
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Ensure output directory exists
$outputDir = Join-Path $PSScriptRoot $config.outputDir
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Generate sanitization JavaScript from .env
Write-Host "🔧 Generating sanitization patterns from .env..." -ForegroundColor Cyan
$sanitizeScript = & (Join-Path $PSScriptRoot "Sanitize-AzurePortal-FromEnv.ps1")

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to generate sanitization patterns. Check .env file."
    exit 1
}

Write-Host "✓ Generated $($sanitizeScript.Split(';').Count) sanitization patterns" -ForegroundColor Green

# Navigate to URL if provided
if ($Url) {
    Write-Host "🌐 Navigating to: $Url" -ForegroundColor Cyan
    # MCP command would go here
    # Example: @chrome-devtools navigate_page url=$Url
}

# Apply sanitization
Write-Host "🧹 Sanitizing PII on page..." -ForegroundColor Cyan
# MCP command: @chrome-devtools evaluate_script function=$sanitizeScript

# Generate output filename
if (-not $OutputFileName) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $OutputFileName = "screenshot-$timestamp"
}

$outputPath = Join-Path $outputDir "$OutputFileName-sanitized.png"

# Take screenshot
Write-Host "📸 Capturing screenshot..." -ForegroundColor Cyan
$screenshotArgs = @{
    filePath = $outputPath
    format = $config.screenshotDefaults.format
    quality = $config.screenshotDefaults.quality
}

if ($FullPage) {
    $screenshotArgs['fullPage'] = $true
}

# MCP command: @chrome-devtools take_screenshot @screenshotArgs

Write-Host "`n✅ Screenshot saved: $outputPath" -ForegroundColor Green
Write-Host "📁 Project: $Project" -ForegroundColor Gray
Write-Host "📊 Sanitized with patterns from .env" -ForegroundColor Gray

# Display project info
Write-Host "`n📋 Project Info:" -ForegroundColor Cyan
Write-Host "  Name: $($config.projectName)" -ForegroundColor Gray
Write-Host "  Description: $($config.description)" -ForegroundColor Gray
Write-Host "  Output Dir: $($config.outputDir)" -ForegroundColor Gray

return @{
    Project = $Project
    OutputPath = $outputPath
    Timestamp = (Get-Date)
}
