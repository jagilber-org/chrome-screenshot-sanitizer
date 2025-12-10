# Environment-Based Sanitization - Quick Reference

## 🚀 Quick Start (30 seconds)

```powershell
# 1. Setup
Copy-Item .env.example .env
code .env  # Fill in your values

# 2. Validate
.\Get-SanitizationMappings.ps1 -ValidateOnly

# 3. Run
.\Sanitize-AzurePortal-FromEnv.ps1
```

## 📝 .env Template (Minimum Required)

```bash
# === YOUR VALUES ===
USER_EMAIL=admin@YourTenant.onmicrosoft.com
USER_TENANT_NAME=YourTenantName
USERNAME=yourusername

# === DEMO VALUES (what replaces PII) ===
DEMO_EMAIL=admin@fabrikam.com
DEMO_TENANT_NAME=ContosoDemo
DEMO_USERNAME=demouser
```

## 🔧 Common Commands

```powershell
# Show what patterns will be generated
.\Get-SanitizationMappings.ps1 -ShowMappings

# Validate .env configuration
.\Get-SanitizationMappings.ps1 -ValidateOnly

# Generate sanitization script
.\Sanitize-AzurePortal-FromEnv.ps1

# Show patterns during generation
.\Sanitize-AzurePortal-FromEnv.ps1 -ShowMappings

# Validate only (no script generation)
.\Sanitize-AzurePortal-FromEnv.ps1 -ValidateEnv
```

## 📊 Pattern Order (Important!)

**Order matters to prevent partial replacements!**

1. Compound patterns (`ME-TenantName-username-1`)
2. Email addresses
3. Tenant domain (`.onmicrosoft.com`)
4. Tenant name
5. GUIDs (subscription/tenant IDs)
6. Resource names
7. Username (last!)

## 🎯 .env Variables (Complete List)

### Identity

```bash
USER_EMAIL=                    # Your email
USER_TENANT_NAME=              # Tenant short name
USER_TENANT_DOMAIN=            # Full domain
USERNAME=                      # Your username
DEMO_EMAIL=                    # Replacement email
DEMO_TENANT_NAME=              # Replacement tenant
DEMO_TENANT_DOMAIN=            # Replacement domain
DEMO_USERNAME=                 # Replacement username
```

### Subscriptions

```bash
SUBSCRIPTION_NAME=             # Subscription display name
SUBSCRIPTION_ID=               # Subscription GUID
TENANT_ID=                     # Tenant GUID
DEMO_SUBSCRIPTION_NAME=        # Replacement name
DEMO_SUBSCRIPTION_ID=          # Placeholder GUID (xxxxxxxx-...)
DEMO_TENANT_ID=                # Placeholder GUID (yyyyyyyy-...)
```

### Resources (up to 10 of each)

```bash
RESOURCE_GROUP_1=              # First resource group name
RESOURCE_GROUP_2=              # Second resource group (optional)
STORAGE_ACCOUNT_1=             # Storage account name
STORAGE_ACCOUNT_2=             # Second storage account (optional)
KEY_VAULT_1=                   # Key vault name
SERVICE_FABRIC_CLUSTER_1=      # SF cluster name

DEMO_RESOURCE_GROUP_1=         # Replacement RG name for RG #1
DEMO_RESOURCE_GROUP_2=         # Replacement RG name for RG #2 (optional)
DEMO_STORAGE_ACCOUNT_1=        # Replacement storage #1
DEMO_STORAGE_ACCOUNT_2=        # Replacement storage #2 (optional)
DEMO_KEY_VAULT_1=              # Replacement key vault
DEMO_SF_CLUSTER_1=             # Replacement SF cluster
```

## ⚠️ Security Checklist

### ✅ Safe to Commit

- `.env.example` (template only)
- `*.template.json` (template only)
- `Get-SanitizationMappings.ps1`
- `Sanitize-AzurePortal-FromEnv.ps1`
- Documentation files

### ❌ Never Commit

- `.env` (your actual secrets!)
- `replacements-*.json` (except template)
- Screenshots before sanitization
- `$env:TEMP\azure-portal-sanitize*.js`

## 🐛 Troubleshooting

### "Missing required fields"

```powershell
# Check what's missing
.\Get-SanitizationMappings.ps1 -ValidateOnly

# Fill in required fields in .env
code .env
```

### "0 replacements made"

```powershell
# 1. Verify patterns generated
.\Get-SanitizationMappings.ps1 -ShowMappings

# 2. Check if text exists in page
# Take snapshot first to see what PII is visible

# 3. Verify pattern escaping
# Script auto-escapes with [regex]::Escape()
```

### Pattern order wrong

```powershell
# Review generated order
.\Get-SanitizationMappings.ps1 -ShowMappings

# Check compound patterns come BEFORE individual components
# Example: "ME-Tenant-user-1" should be pattern #1
#          "user" should be pattern #7 (last)
```

## 📁 File Structure

```
.env.example                        # Template (committed)
.env                                # Your secrets (gitignored)
Get-SanitizationMappings.ps1       # Converts .env → patterns
Sanitize-AzurePortal-FromEnv.ps1   # Generates JS from .env
Sanitize-AzurePortal.ps1           # Legacy JSON-based
replacements-azure-portal.template.json  # Legacy template
replacements-azure-portal.json     # Legacy config (gitignored)
```

## 🔄 Workflow

```
1. Configure .env
   ↓
2. Validate patterns (Get-SanitizationMappings.ps1 -ShowMappings)
   ↓
3. Generate JS (Sanitize-AzurePortal-FromEnv.ps1)
   ↓
4. Execute via Chrome MCP (mcp_chrome-devtoo_evaluate_script)
   ↓
5. Take screenshot (mcp_chrome-devtoo_take_screenshot)
   ↓
6. Verify sanitization (mcp_chrome-devtoo_take_snapshot)
```

## 💡 Examples

### Example 1: Basic Setup

```bash
# .env
USER_EMAIL=admin@contoso123.onmicrosoft.com
USER_TENANT_NAME=Contoso123
USERNAME=jsmith

DEMO_EMAIL=admin@fabrikam.com
DEMO_TENANT_NAME=FabrikamDemo
DEMO_USERNAME=demouser
```

**Result**: 6 patterns generated (email, domain, tenant, username + compound variations)

### Example 2: With Subscriptions

```bash
# .env (in addition to basic)
SUBSCRIPTION_NAME=Production-EastUS-jsmith
SUBSCRIPTION_ID=a1b2c3d4-e5f6-7890-abcd-ef1234567890

DEMO_SUBSCRIPTION_NAME=Demo-Subscription-001
DEMO_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Result**: 8 patterns (adds subscription name + GUID)

### Example 3: Service Fabric Resources

```bash
# .env (in addition to above)
SERVICE_FABRIC_CLUSTER_1=sfjsmith1prod
RESOURCE_GROUP_1=sfjsmith1prod-rg

DEMO_SF_CLUSTER_1=demo-sf-cluster-001
DEMO_RESOURCE_GROUP_1=demo-rg-001
```

**Result**: 10 patterns (adds cluster + RG names)

## 📚 See Also

- [ENV-BASED-SANITIZATION.md](ENV-BASED-SANITIZATION.md) - Complete documentation
- [WORKFLOW-BEST-PRACTICES.md](docs/WORKFLOW-BEST-PRACTICES.md) - Sanitization workflows
- [.vscode/README.md](.vscode/README.md) - Chrome MCP setup

---

**Version**: 2.0  
**Status**: Production Ready  
**Last Updated**: December 10, 2025
