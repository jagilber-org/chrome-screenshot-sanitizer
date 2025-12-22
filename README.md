# Azure Portal Screenshot Sanitizer

> **Portfolio Project** | [View Full Portfolio](https://github.com/jagilber-org) | [Specifications](docs/specs/)

Automated PII/sensitive data replacement for Azure Portal screenshots using Chrome DevTools MCP Server.

## Multi-Project Support

This repository supports **multiple screenshot projects** using a **single shared .env file** for PII patterns:

```powershell
# Create a new project
.\New-SanitizationProject.ps1 -ProjectName "azure-devops" -BaseUrl "https://dev.azure.com"

# Capture sanitized screenshot for project
.\Sanitize-Project.ps1 -Project "azure-devops"
```

**Benefits**:
- ✅ Single .env file for all projects (configure PII once)
- ✅ Organized outputs by project (projects/azure-portal/outputs/, projects/github/outputs/)
- ✅ Project-specific settings (viewport, format, URLs)
- ✅ Easy to share/archive individual projects

See [Multi-Project Guide](docs/MULTI-PROJECT-GUIDE.md) for complete documentation.

## 📚 Documentation

### Specifications

- **[Product Specification](docs/specs/spec.md)** - User scenarios, functional requirements, success criteria, integration points
- **[Technical Plan](docs/specs/plan.md)** - Architecture, implementation phases, performance benchmarks

### Project Documentation

- [Full Documentation Index](docs/) - Comprehensive guides and references
## Quick Start

1. **Start debuggable Edge/Chrome**:
   ```powershell
   Start-Process "msedge.exe" -ArgumentList "--remote-debugging-port=9222", "--user-data-dir=$env:TEMP\EdgeDebug"
   ```

2. **Navigate to Azure Portal** and open the page you want to capture

3. **Run sanitizer**:
   ```powershell
   cd tools
   .\Sanitize-AzurePortal.ps1
   ```

4. **The script will output JavaScript** - tell Copilot to execute it and take screenshot

## Configuration

1. **Copy the template**:
   ```powershell
   Copy-Item replacements-azure-portal.template.json replacements-azure-portal.json
   ```

2. **Edit** `replacements-azure-portal.json` with your key-value pairs:

```json
{
  "replacements": {
    "your-email@company\\.com": "demo@contoso.com",
    "subscription-guid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "your-username": "demouser"
  }
}
```

**Important**: Use regex patterns (escape special characters like `.` with `\\.`)

## What Gets Replaced

✅ **Regular DOM Content**:
- Text nodes
- Attributes (aria-label, title, placeholder, value, alt)
- Input/textarea values

✅ **Monaco Editors** (Azure Portal JSON editors):
- View lines (visible text)
- Hidden textarea (underlying content)

✅ **All Nested Elements** - recursively processes entire page

## Advanced Usage

### Custom Replacements Programmatically

```powershell
$customReplacements = @{
    'prod-server-01' = 'demo-server'
    'secret-key-\w+' = 'xxxxx-xxxxx'
    '192\.168\.\d+\.\d+' = '10.0.0.x'
}

# Generate the JavaScript
$jsFunction = .\Sanitize-AzurePortal.ps1 -ReplacementMap $customReplacements
```

### Full-Page Screenshots

After sanitization, tell Copilot:
```
Take a full-page screenshot with fullPage=true and save to ./docs/images/full-page.png
```

### Multiple Pages Workflow

```powershell
# Sanitize and screenshot multiple Azure Portal pages
$pages = @(
    'https://portal.azure.com/#home',
    'https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ServiceFabric%2Fclusters',
    'https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade'
)

foreach ($page in $pages) {
    # Navigate: Tell Copilot "Navigate to $page"
    # Wait: Start-Sleep -Seconds 3
    # Sanitize: .\Sanitize-AzurePortal.ps1
    # Screenshot: Tell Copilot "Take screenshot"
}
```

## Chrome MCP Commands Reference

### Execute Sanitization
```
@chrome-devtools evaluate_script with the JavaScript function from Sanitize-AzurePortal.ps1
```

### Take Screenshot
```
@chrome-devtools take_screenshot and save to ./docs/images/sanitized-{timestamp}.png
```

### List Pages
```
@chrome-devtools list_pages
```

### Navigate
```
@chrome-devtools navigate_page to https://portal.azure.com
```

## Common Replacement Patterns

### Emails
```json
"admin@company\\.com": "admin@contoso.com"
"[a-z]+@company\\.com": "user@contoso.com"
```

### GUIDs/Subscription IDs
```json
"d692f14b-8df6-4f72-ab7d-b4b2981a6b58": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Hostnames/URLs
```json
"cluster\\.eastus\\.cloudapp\\.azure\\.com": "democluster.region.cloudapp.azure.com"
"https://[a-z0-9]+\\.blob\\.core\\.windows\\.net": "https://democontent.blob.core.windows.net"
```

### Usernames
```json
"jagilber": "demouser"
"[a-z]{3,8}": "user"
```

### Tenant Names
```json
"MngEnvMCAP706013": "ContosoDemo"
"CompanyName": "Fabrikam"
```

## Troubleshooting

### No Replacements Applied
- Check regex patterns (use regex tester: regex101.com)
- Verify Chrome debugging port is 9222: `Invoke-RestMethod http://localhost:9222/json`
- Ensure page is fully loaded before sanitizing

### Monaco Editors Not Updating
- Wait 1-2 seconds after page load
- Try clicking into the editor first
- Monaco may need a re-render: press Ctrl+A to select all

### Screenshot Quality
- Use `fullPage: true` for complete capture
- Increase browser window size before screenshot
- Use `format: "png"` for lossless quality

## Files

- **Sanitize-AzurePortal.ps1** - Quick wrapper script (recommended)
- **Invoke-AzurePortalScreenshotSanitizer.ps1** - Full-featured sanitizer with options
- **replacements-azure-portal.template.json** - Template configuration file
- **replacements-azure-portal.json** - Your customized replacements (gitignored, create from template)

## Examples

### Basic Workflow
```powershell
# 1. Start debuggable browser
Start-Process msedge.exe -ArgumentList "--remote-debugging-port=9222"

# 2. Open Azure Portal and navigate to page

# 3. Run sanitizer
.\tools\Sanitize-AzurePortal.ps1

# 4. Tell Copilot to execute the JavaScript and take screenshot
```

### Custom Replacements
```powershell
# Create custom replacements
$replacements = @{
    'prod-cluster' = 'demo-cluster'
    'prod-rg' = 'demo-rg'
}

# Save to custom file
$replacements | ConvertTo-Json | Out-File my-replacements.json

# Edit Sanitize-AzurePortal.ps1 to use your file
```

## Getting Started

### First-Time Setup

**Option 1: Use .env System (Recommended)**

```powershell
# 1. Create .env from example
Copy-Item .env.example .env

# 2. Edit with your actual values
code .env

# 3. Validate configuration
.\Get-SanitizationMappings.ps1 -ValidateOnly

# 4. Generate sanitization script
.\Sanitize-AzurePortal-FromEnv.ps1
```

**Option 2: Use JSON System (Legacy)**

```powershell
# 1. Copy the template configuration
Copy-Item replacements-azure-portal.template.json replacements-azure-portal.json

# 2. Edit with your patterns
code replacements-azure-portal.json

# 3. Generate sanitization script
.\Sanitize-AzurePortal.ps1
```

See [ENV-BASED-SANITIZATION.md](ENV-BASED-SANITIZATION.md) for complete .env system documentation.

### Set up Chrome MCP Server

See [.vscode/README.md](.vscode/README.md) for Chrome MCP configuration.

### Verified Working Workflow

The complete workflow has been tested and verified on December 10, 2025:

1. ✅ Start Edge with remote debugging
2. ✅ Navigate to Azure Portal via Chrome MCP
3. ✅ Execute sanitization JavaScript (21 replacements verified)
4. ✅ Capture screenshot with all PII removed
5. ✅ Example screenshot available: [images/examples/azure-portal-home-sanitized.png](images/examples/azure-portal-home-sanitized.png)

See [docs/sessions/2025-12-10-successful-chrome-mcp-test.md](docs/sessions/2025-12-10-successful-chrome-mcp-test.md) for complete test details and learnings.

## Tips

1. **Test patterns first**: Use regex101.com to validate before adding to JSON
2. **Order matters**: More specific patterns should come before general ones
3. **Escape special chars**: `.` → `\\.`, `\\` → `\\\\`, `[` → `\\[`
4. **Case insensitive**: All patterns use `/gi` flag (global, case-insensitive)
5. **Preview before saving**: Review the sanitized page in browser before taking screenshot

## Portfolio Context

This project is part of the [jagilber-org portfolio](https://github.com/jagilber-org), demonstrating practical MCP (Model Context Protocol) integration patterns.

**Cross-Project Integration**:
- Works with **obfuscate-mcp-server** for comprehensive PII removal workflows
- Integrates with **chrome-devtools MCP** for browser automation
- Complements **kusto-dashboard-manager** for Azure Portal screenshot documentation
- Part of enterprise-grade data sanitization workflow

**Portfolio Highlights**:
- Real-world MCP server integration (Chrome DevTools Protocol)
- Production-ready PII sanitization patterns
- Multi-project configuration system (.env based)
- Automated documentation screenshot workflows

[View Full Portfolio](https://github.com/jagilber-org) | [Integration Examples](https://github.com/jagilber-org#cross-project-integration)

## Integration with Documentation Workflows

This tool pairs perfectly with:
- **Markdown documentation** with embedded screenshots
- **Confluence/Wiki** pages
- **GitHub README** files
- **Technical presentations**
- **Training materials**

Simply sanitize → screenshot → embed in your docs! 📸
