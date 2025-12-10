# Environment-Based Sanitization System

## Overview

This repository now uses a **dual-system approach** for PII sanitization:

1. **Legacy JSON System** (`replacements-azure-portal.json`) - Manual regex patterns
2. **New .env System** (`.env` + `Get-SanitizationMappings.ps1`) - Auto-generated patterns from environment variables

## File Structure

```
.env.example                           # Template with all supported variables
.env                                   # Your actual secrets (gitignored)
Get-SanitizationMappings.ps1          # Converts .env to sanitization patterns
Sanitize-AzurePortal-FromEnv.ps1      # Uses .env for sanitization
Sanitize-AzurePortal.ps1              # Uses JSON file (legacy)
replacements-azure-portal.template.json # JSON template (legacy)
replacements-azure-portal.json        # Your JSON patterns (gitignored)
```

## Quick Start

### Option 1: Use .env System (Recommended)

```powershell
# 1. Create .env from example
Copy-Item .env.example .env

# 2. Edit .env with your actual values
code .env

# 3. Validate configuration
.\Get-SanitizationMappings.ps1 -ValidateOnly

# 4. Preview mappings
.\Get-SanitizationMappings.ps1 -ShowMappings

# 5. Generate sanitization script
.\Sanitize-AzurePortal-FromEnv.ps1
```

### Option 2: Use JSON System (Legacy)

```powershell
# 1. Create JSON from template
Copy-Item replacements-azure-portal.template.json replacements-azure-portal.json

# 2. Edit JSON with your patterns
code replacements-azure-portal.json

# 3. Generate sanitization script
.\Sanitize-AzurePortal.ps1
```

## .env Configuration

### Required Variables

```bash
# User Identity
USER_EMAIL=admin@YourTenant.onmicrosoft.com
USER_TENANT_NAME=YourTenantName
USERNAME=yourusername

# Demo Values
DEMO_EMAIL=admin@fabrikam.com
DEMO_TENANT_NAME=ContosoDemo
DEMO_USERNAME=demouser
```

### Optional Variables

```bash
# Subscriptions
SUBSCRIPTION_NAME=Your-Subscription-Name
SUBSCRIPTION_ID=guid-here
DEMO_SUBSCRIPTION_NAME=Demo-Subscription-001
DEMO_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Azure Resources (supports up to 10 of each type, indexed)
RESOURCE_GROUP_1=your-rg-name
STORAGE_ACCOUNT_1=yourstorageacct
STORAGE_ACCOUNT_2=yourstorageacct2
KEY_VAULT_1=your-keyvault
SERVICE_FABRIC_CLUSTER_1=your-sf-cluster

# Demo Resources (indexed to match source resources)
DEMO_RESOURCE_GROUP_1=demo-rg-001
DEMO_STORAGE_ACCOUNT_1=demostorage001
DEMO_STORAGE_ACCOUNT_2=demostorage002
DEMO_KEY_VAULT_1=demo-keyvault-001
DEMO_SF_CLUSTER_1=demo-sf-cluster-001
```

## Pattern Order (Critical!)

The `Get-SanitizationMappings.ps1` script generates patterns in this order:

1. **Compound patterns** (e.g., `ME-TenantName-username-1`)
2. **Email addresses** (exact match)
3. **Tenant domain** (e.g., `tenant.onmicrosoft.com`)
4. **Tenant name** (e.g., `TenantName`)
5. **GUIDs** (subscription ID, tenant ID)
6. **Resource names** (resource groups, storage, etc.)
7. **Username** (last to avoid over-replacement)

This order prevents issues like:
- ❌ `ME-TenantName-username-1` → `ME-DemoTenant-demouser-1` (wrong!)
- ✅ `ME-TenantName-username-1` → `Demo-Subscription-001` (correct!)

## Validation & Testing

### Check .env Configuration

```powershell
# Validate all required fields present
.\Get-SanitizationMappings.ps1 -ValidateOnly

# Show what patterns will be generated
.\Get-SanitizationMappings.ps1 -ShowMappings
```

### Test Sanitization

```powershell
# Generate script and review output
$result = .\Sanitize-AzurePortal-FromEnv.ps1 -ShowMappings

# Check pattern count
Write-Host "Patterns generated: $($result.ReplacementCount)"

# Review JavaScript function
$result.JavaScriptFunction | Out-File test-sanitize.js
code test-sanitize.js
```

## Security Best Practices

### What's Gitignored

```gitignore
.env                    # Your actual secrets
.env.local
.env.production
replacements-*.json     # All JSON configs (except template)
```

### What's Committed

```
.env.example           # Template with placeholder values
*.template.json        # Template files only
Get-SanitizationMappings.ps1
Sanitize-AzurePortal-FromEnv.ps1
```

### Never Commit

- ❌ `.env` file with real values
- ❌ `replacements-azure-portal.json` with real patterns
- ❌ Screenshots with unsanitized PII
- ❌ Temp files from `$env:TEMP\azure-portal-sanitize*.js`

## Migration from JSON to .env

If you have existing `replacements-azure-portal.json`:

```powershell
# 1. Review your current JSON patterns
$json = Get-Content replacements-azure-portal.json | ConvertFrom-Json

# 2. Map to .env variables
# JSON: "admin@MngEnv123.onmicrosoft.com" → "admin@fabrikam.com"
# .env: USER_EMAIL=admin@MngEnv123.onmicrosoft.com
#       DEMO_EMAIL=admin@fabrikam.com

# 3. Create .env from example
Copy-Item .env.example .env

# 4. Fill in .env with values from JSON
code .env

# 5. Test both systems match
.\Sanitize-AzurePortal.ps1           # JSON-based
.\Sanitize-AzurePortal-FromEnv.ps1   # .env-based

# 6. Compare outputs
# Should generate similar JavaScript functions
```

## Advanced Usage

### Add Custom Resource Types

Edit `Get-SanitizationMappings.ps1` to support new resource types:

```powershell
# Example: Add Virtual Network support
if ($envVars['VNET_1']) {
    $vnetPattern = [regex]::Escape($envVars['VNET_1'])
    $mappings[$vnetPattern] = $envVars['DEMO_VNET'] ?? "demo-vnet-001"
}
```

Then add to `.env.example`:

```bash
# Virtual Networks
VNET_1=your-vnet-name
DEMO_VNET=demo-vnet-001
```

### Override Pattern Order

If you need custom ordering, modify the `$mappings` ordered hashtable in `Get-SanitizationMappings.ps1`.

### Use with Chrome MCP Server

```powershell
# Generate mappings
$mappings = .\Get-SanitizationMappings.ps1

# Use with full-featured script
.\Invoke-AzurePortalScreenshotSanitizer.ps1 -ReplacementMap $mappings -OutputPath .\images\examples\sanitized.png
```

## Troubleshooting

### "Missing required fields in .env"

**Problem**: `.env` missing USER_EMAIL, DEMO_EMAIL, etc.

**Solution**:
```powershell
# Check which fields are missing
.\Get-SanitizationMappings.ps1 -ValidateOnly

# Review .env.example for all required fields
code .env.example
```

### "No replacement mappings generated"

**Problem**: All .env values are empty or whitespace

**Solution**:
```powershell
# Edit .env with actual values
code .env

# Validate each required field is filled
.\Get-SanitizationMappings.ps1 -ShowMappings
```

### Patterns Not Replacing Expected Text

**Problem**: JavaScript shows 0 replacements

**Possible causes**:
1. Pattern escaping issue (check regex special characters)
2. Text appears in shadow DOM (not covered by script)
3. Text loaded after script execution (timing issue)

**Solutions**:
```powershell
# 1. Review generated patterns
.\Get-SanitizationMappings.ps1 -ShowMappings

# 2. Check for regex escaping
# Script automatically escapes with [regex]::Escape()

# 3. Add wait time before sanitization
# Use Start-Sleep -Seconds 3 before executing script
```

## Examples

### Example 1: Service Fabric Cluster Screenshot

```powershell
# .env configuration
USER_EMAIL=admin@MngEnvMCAP706013.onmicrosoft.com
USER_TENANT_NAME=MngEnvMCAP706013
USERNAME=jagilber
SERVICE_FABRIC_CLUSTER_1=sfjagilber1nt3so

DEMO_EMAIL=admin@fabrikam.com
DEMO_TENANT_NAME=FabrikamDemo
DEMO_USERNAME=demouser
DEMO_SF_CLUSTER=sfdemo1cluster

# Generate sanitization
.\Sanitize-AzurePortal-FromEnv.ps1

# Result: All occurrences replaced
# sfjagilber1nt3so → sfdemo1cluster
# jagilber → demouser
# admin@MngEnvMCAP706013.onmicrosoft.com → admin@fabrikam.com
```

### Example 2: Multiple Resource Groups

```bash
# .env configuration
RESOURCE_GROUP_1=sfjagilber1nt3so
RESOURCE_GROUP_2=sfjagilber1nt3d
RESOURCE_GROUP_3=vaults

DEMO_RESOURCE_GROUP=demo-rg-eastus

# All RGs will map to demo-rg-eastus
```

## See Also

- [WORKFLOW-BEST-PRACTICES.md](docs/WORKFLOW-BEST-PRACTICES.md) - Complete sanitization workflow
- [2025-12-10-successful-chrome-mcp-test.md](docs/sessions/2025-12-10-successful-chrome-mcp-test.md) - Proven test results
- [CHROME-MCP-SERVER-REFERENCE.md](docs/CHROME-MCP-SERVER-REFERENCE.md) - MCP server reference

---

**Status**: Production-ready .env system  
**Version**: 2.0  
**Last Updated**: December 10, 2025
