<#
.SYNOPSIS
    Create a new screenshot sanitization project

.DESCRIPTION
    Creates a new project directory structure with config, outputs folder, and README.
    All projects share the same .env file for PII sanitization.

.PARAMETER ProjectName
    Name of the project (will be used as directory name)

.PARAMETER Description
    Description of what screenshots this project captures

.PARAMETER BaseUrl
    Default URL for this project (e.g., https://portal.azure.com)

.EXAMPLE
    .\New-SanitizationProject.ps1 -ProjectName "azure-devops" -Description "Azure DevOps pipeline screenshots" -BaseUrl "https://dev.azure.com"
    
.EXAMPLE
    .\New-SanitizationProject.ps1 -ProjectName "github" -Description "GitHub workflow documentation" -BaseUrl "https://github.com"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$Description = "Screenshot sanitization project",
    
    [string]$BaseUrl = ""
)

$ErrorActionPreference = 'Stop'

# Validate project name
if ($ProjectName -notmatch '^[a-z0-9-]+$') {
    Write-Error "Project name must contain only lowercase letters, numbers, and hyphens"
    exit 1
}

# Create project directory structure
$projectDir = Join-Path $PSScriptRoot "projects\$ProjectName"
if (Test-Path $projectDir) {
    Write-Warning "Project '$ProjectName' already exists at: $projectDir"
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -ne 'y') {
        Write-Host "Cancelled" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "📁 Creating project: $ProjectName" -ForegroundColor Cyan

# Create directories
$outputsDir = Join-Path $projectDir "outputs"
New-Item -ItemType Directory -Path $outputsDir -Force | Out-Null

# Create config.json
$config = @{
    projectName = $ProjectName
    description = $Description
    baseUrl = $BaseUrl
    outputDir = "projects/$ProjectName/outputs"
    chromeSettings = @{
        debugPort = 9222
        browserType = "msedge"
        viewport = @{
            width = 1920
            height = 1080
        }
        waitBeforeScreenshot = 2000
    }
    screenshotDefaults = @{
        format = "png"
        quality = 95
        fullPage = $false
    }
    additionalPatterns = @()
}

$configPath = Join-Path $projectDir "config.json"
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

# Create README
$readmeContent = @"
# $ProjectName Screenshot Project

**Purpose**: $Description

## Quick Start

``````powershell
# 1. Start browser with remote debugging
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ``
  --remote-debugging-port=9222 ``
  --user-data-dir="`$env:TEMP\edge-remote-debug"

# 2. Navigate to the page you want to capture
$(if ($BaseUrl) { "# Base URL: $BaseUrl" })

# 3. Run sanitization and capture
.\Sanitize-Project.ps1 -Project "$ProjectName"
``````

## Configuration

See [config.json](config.json) for project-specific settings:
- Chrome/Edge settings
- Screenshot defaults (format, quality)
- Additional sanitization patterns (optional)

## PII Sanitization

This project uses the shared `.env` file at the repository root for PII patterns.
All sanitization happens automatically based on your configured values.

## Output Organization

Screenshots are saved to `outputs/` with naming pattern:
``````
[description]-sanitized-[timestamp].png
``````

## Examples

Add sanitized screenshot examples to the `outputs/` directory demonstrating:
- Different pages/views
- Various PII types being sanitized
- Before/after comparisons (in documentation only)
"@

$readmePath = Join-Path $projectDir "README.md"
Set-Content $readmePath -Value $readmeContent -Encoding UTF8

# Create .gitkeep in outputs
$gitkeepPath = Join-Path $outputsDir ".gitkeep"
Set-Content $gitkeepPath -Value "# Outputs directory for $ProjectName sanitized screenshots" -Encoding UTF8

Write-Host "`n✅ Project created successfully!" -ForegroundColor Green
Write-Host "`n📋 Project Details:" -ForegroundColor Cyan
Write-Host "  Name: $ProjectName" -ForegroundColor Gray
Write-Host "  Description: $Description" -ForegroundColor Gray
Write-Host "  Location: $projectDir" -ForegroundColor Gray
Write-Host "  Config: $configPath" -ForegroundColor Gray
Write-Host "  Outputs: $outputsDir" -ForegroundColor Gray

Write-Host "`n📝 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review and customize config.json if needed" -ForegroundColor Gray
Write-Host "  2. Ensure .env is configured with your PII values" -ForegroundColor Gray
Write-Host "  3. Run: .\Sanitize-Project.ps1 -Project '$ProjectName'" -ForegroundColor Gray

return @{
    ProjectName = $ProjectName
    ProjectDir = $projectDir
    ConfigPath = $configPath
    OutputDir = $outputsDir
}
