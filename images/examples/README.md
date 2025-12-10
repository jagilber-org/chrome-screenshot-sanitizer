# Screenshot Examples Gallery

This directory contains example sanitized Azure Portal screenshots demonstrating the capabilities of this tool.

## Guidelines for Adding Examples

1. **Always sanitize before adding** - Never commit screenshots with real PII/sensitive data
2. **Use descriptive filenames** - Format: `azure-portal-{service}-{page}-sanitized.png`
3. **Add descriptions** - Update this README with each example

## Current Examples

### Azure Portal Home
**File**: `azure-portal-home-sanitized.png`  
**Date**: December 10, 2025  
**Description**: Azure Portal home page with all PII sanitized including email addresses, tenant names, subscription IDs, usernames, and resource names. Demonstrates successful sanitization of account menu, subscription list, and recent resources.

**Sanitization verified**:
- ✅ Email: `admin@MngEnvMCAP706013.onmicrosoft.com` → `admin@fabrikam.com`
- ✅ Tenant: `MngEnvMCAP706013` → `FabrikamDemo`
- ✅ Username: `jagilber` → `demouser`
- ✅ Subscription: `ME-MngEnvMCAP706013-jagilber-1` → `Demo-Subscription-001`
- ✅ GUIDs: Real subscription IDs replaced with placeholder values
- ✅ 21 total replacements across page

### Service Fabric Cluster Overview
*Coming soon - example of sanitized Service Fabric cluster details*

### Resource Group Details
*Coming soon - example of sanitized resource group overview*

## How to Add Your Example

1. Sanitize the page using the tool:
   ```powershell
   .\Sanitize-AzurePortal.ps1
   ```

2. Take screenshot and save to this directory:
   ```
   @chrome-devtools take_screenshot and save to ./images/examples/azure-portal-{service}-{page}-sanitized.png
   ```

3. Update this README with description of what's shown

## Screenshot Standards

- **Format**: PNG (lossless quality)
- **Resolution**: 1920x1080 or higher
- **Browser**: Edge or Chrome at 100% zoom
- **Viewport**: Maximize browser window for consistency
