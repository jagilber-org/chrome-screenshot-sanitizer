<#
.SYNOPSIS
    Load sanitization mappings from .env file and generate replacement patterns.

.DESCRIPTION
    Reads .env file (or creates from .env.example), validates required fields,
    and returns a hashtable of regex patterns for PII replacement.
    
    Supports both direct pattern mapping and auto-generation from USER_* → DEMO_* pairs.

.PARAMETER EnvFile
    Path to .env file. Default: .env in script directory

.PARAMETER ValidateOnly
    Only validate .env exists and has required fields, don't return mappings

.PARAMETER ShowMappings
    Display generated mappings to console for review

.EXAMPLE
    $mappings = .\Get-SanitizationMappings.ps1
    # Returns hashtable ready for Invoke-AzurePortalScreenshotSanitizer.ps1

.EXAMPLE
    .\Get-SanitizationMappings.ps1 -ValidateOnly
    # Checks if .env is properly configured

.EXAMPLE
    .\Get-SanitizationMappings.ps1 -ShowMappings
    # Displays all pattern mappings for review

.NOTES
    Author: GitHub Copilot
    Version: 2.0
    Requires: .env file with USER_* and DEMO_* variables
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$EnvFile = "$PSScriptRoot\.env",
    
    [Parameter()]
    [switch]$ValidateOnly,
    
    [Parameter()]
    [switch]$ShowMappings
)

$ErrorActionPreference = 'Stop'

function Write-ColorOutput {
    param([string]$Message, [string]$Color = 'White')
    Write-Host $Message -ForegroundColor $Color
}

# Check if .env exists, if not create from example
if (!(Test-Path $EnvFile)) {
    $exampleFile = "$PSScriptRoot\.env.example"
    
    if (Test-Path $exampleFile) {
        Write-ColorOutput "⚠️  .env file not found. Creating from .env.example..." 'Yellow'
        Copy-Item $exampleFile $EnvFile
        Write-ColorOutput "✓ Created $EnvFile" 'Green'
        Write-ColorOutput "📝 Please edit .env with your actual values before proceeding." 'Cyan'
        
        if ($ValidateOnly) {
            Write-ColorOutput "❌ Validation failed: .env needs to be configured" 'Red'
            exit 1
        }
        
        # Open in default editor
        if ($IsWindows -or $env:OS -match 'Windows') {
            Start-Process $EnvFile
        }
        
        return $null
    } else {
        throw ".env file not found and .env.example is missing. Cannot proceed."
    }
}

# Parse .env file
Write-ColorOutput "📂 Loading environment from: $EnvFile" 'Cyan'

$envVars = @{}
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    
    # Skip comments and empty lines
    if ($line -and !$line.StartsWith('#')) {
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            $value = $value -replace '^["'']|["'']$', ''
            
            $envVars[$key] = $value
        }
    }
}

Write-ColorOutput "✓ Loaded $($envVars.Count) environment variables" 'Green'

# Validate required fields
$requiredUserFields = @('USER_EMAIL', 'USER_TENANT_NAME', 'USERNAME')
$requiredDemoFields = @('DEMO_EMAIL', 'DEMO_TENANT_NAME', 'DEMO_USERNAME')

$missingFields = @()
foreach ($field in ($requiredUserFields + $requiredDemoFields)) {
    if (!$envVars.ContainsKey($field) -or [string]::IsNullOrWhiteSpace($envVars[$field])) {
        $missingFields += $field
    }
}

if ($missingFields.Count -gt 0) {
    Write-ColorOutput "❌ Missing or empty required fields in .env:" 'Red'
    $missingFields | ForEach-Object { Write-ColorOutput "   - $_" 'Yellow' }
    
    if ($ValidateOnly) {
        exit 1
    }
    
    throw "Configuration validation failed. Please update .env file."
}

if ($ValidateOnly) {
    Write-ColorOutput "✓ Validation passed: All required fields present" 'Green'
    return $null
}

# Build replacement mappings
# Pattern: Most specific to least specific (order matters!)
$mappings = [ordered]@{}

# 1. Compound patterns first (e.g., subscription names with username)
if ($envVars['SUBSCRIPTION_NAME'] -and $envVars['USERNAME']) {
    $compoundPattern = $envVars['SUBSCRIPTION_NAME'] -replace '\\', '\\\\'
    $compoundReplacement = $envVars['DEMO_SUBSCRIPTION_NAME']
    $mappings[$compoundPattern] = $compoundReplacement
}

# 2. Email addresses (exact match)
if ($envVars['USER_EMAIL']) {
    $emailPattern = [regex]::Escape($envVars['USER_EMAIL'])
    $mappings[$emailPattern] = $envVars['DEMO_EMAIL']
}

# 3. Tenant domain
if ($envVars['USER_TENANT_DOMAIN']) {
    $domainPattern = [regex]::Escape($envVars['USER_TENANT_DOMAIN'])
    $mappings[$domainPattern] = $envVars['DEMO_TENANT_DOMAIN']
}

# 4. Tenant name
if ($envVars['USER_TENANT_NAME']) {
    $tenantPattern = [regex]::Escape($envVars['USER_TENANT_NAME'])
    $mappings[$tenantPattern] = $envVars['DEMO_TENANT_NAME']
}

# 5. GUIDs (subscription, tenant)
if ($envVars['SUBSCRIPTION_ID']) {
    $subIdPattern = [regex]::Escape($envVars['SUBSCRIPTION_ID'])
    $mappings[$subIdPattern] = $envVars['DEMO_SUBSCRIPTION_ID']
}

if ($envVars['TENANT_ID']) {
    $tenantIdPattern = [regex]::Escape($envVars['TENANT_ID'])
    $mappings[$tenantIdPattern] = $envVars['DEMO_TENANT_ID']
}

# 6. Resource names (use pattern matching for numbered resources)
for ($i = 1; $i -le 10; $i++) {
    $rgKey = "RESOURCE_GROUP_$i"
    $saKey = "STORAGE_ACCOUNT_$i"
    $kvKey = "KEY_VAULT_$i"
    $sfKey = "SERVICE_FABRIC_CLUSTER_$i"
    
    if ($envVars[$rgKey]) {
        $rgPattern = [regex]::Escape($envVars[$rgKey])
        $demoRgKey = "DEMO_RESOURCE_GROUP_$i"
        $mappings[$rgPattern] = if ($envVars[$demoRgKey]) { $envVars[$demoRgKey] } else { "demo-rg-$i" }
    }
    
    if ($envVars[$saKey]) {
        $saPattern = [regex]::Escape($envVars[$saKey])
        $demoSaKey = "DEMO_STORAGE_ACCOUNT_$i"
        $mappings[$saPattern] = if ($envVars[$demoSaKey]) { $envVars[$demoSaKey] } else { "demostorage$i" }
    }
    
    if ($envVars[$kvKey]) {
        $kvPattern = [regex]::Escape($envVars[$kvKey])
        $demoKvKey = "DEMO_KEY_VAULT_$i"
        $mappings[$kvPattern] = if ($envVars[$demoKvKey]) { $envVars[$demoKvKey] } else { "demo-keyvault-$i" }
    }
    
    if ($envVars[$sfKey]) {
        $sfPattern = [regex]::Escape($envVars[$sfKey])
        $demoSfKey = "DEMO_SF_CLUSTER_$i"
        $mappings[$sfPattern] = if ($envVars[$demoSfKey]) { $envVars[$demoSfKey] } else { "demo-sf-cluster-$i" }
    }
}

# 7. Username (should be last to avoid over-replacement)
if ($envVars['USERNAME']) {
    $usernamePattern = [regex]::Escape($envVars['USERNAME'])
    $mappings[$usernamePattern] = $envVars['DEMO_USERNAME']
}

# Remove any empty mappings
$cleanMappings = [ordered]@{}
$mappings.GetEnumerator() | Where-Object { 
    ![string]::IsNullOrWhiteSpace($_.Key) -and ![string]::IsNullOrWhiteSpace($_.Value) 
} | ForEach-Object {
    $cleanMappings[$_.Key] = $_.Value
}

if ($ShowMappings -or $VerbosePreference -eq 'Continue') {
    Write-ColorOutput "`n📋 Generated Sanitization Mappings ($($cleanMappings.Count) patterns):" 'Cyan'
    Write-ColorOutput ("=" * 80) 'DarkGray'
    
    $index = 1
    $cleanMappings.GetEnumerator() | ForEach-Object {
        Write-ColorOutput "`n[$index] Pattern (will be replaced):" 'Yellow'
        Write-ColorOutput "    $($_.Key)" 'White'
        Write-ColorOutput "    ⬇️" 'DarkGray'
        Write-ColorOutput "    $($_.Value)" 'Green'
        $index++
    }
    
    Write-ColorOutput ("`n" + ("=" * 80)) 'DarkGray'
}

Write-ColorOutput "✓ Generated $($cleanMappings.Count) replacement patterns" 'Green'

return $cleanMappings
