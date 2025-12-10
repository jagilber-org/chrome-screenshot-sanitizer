# Screenshot Examples Gallery

This directory contains example sanitized Azure Portal screenshots demonstrating the capabilities of this tool.

## Guidelines for Adding Examples

1. **Always sanitize before adding** - Never commit screenshots with real PII/sensitive data
2. **Use descriptive filenames** - Format: `azure-portal-{service}-{page}-sanitized.png`
3. **Add descriptions** - Update this README with each example

## Current Examples

### Azure Portal Home
*Coming soon - example of sanitized Azure Portal home page*

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
