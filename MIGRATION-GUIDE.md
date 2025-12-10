# Chrome MCP Azure Portal Screenshot Package

**Created**: December 8, 2025  
**Purpose**: Comprehensive guide for moving Chrome MCP screenshot sanitization tools to a new repository

---

## 📦 Package Overview

This package contains all documentation, scripts, and processes for using Chrome MCP Server to capture and sanitize Azure Portal screenshots with PII/sensitive data replacement.

## 🎯 Primary Use Case

**Capture Azure Portal screenshots for documentation while automatically replacing:**
- Personal email addresses
- Subscription GUIDs  
- Tenant names
- Usernames
- Server/cluster names
- Storage account names
- Any sensitive identifiers

## 📂 Files to Move

### Core Scripts (3 files)
Located in: `tools/`

1. **`Sanitize-AzurePortal.ps1`** (Quick wrapper - RECOMMENDED)
   - Simple execution: `.\Sanitize-AzurePortal.ps1`
   - Generates JavaScript function for Copilot
   - Uses configuration from JSON file
   - Outputs copy-paste ready command

2. **`Invoke-AzurePortalScreenshotSanitizer.ps1`** (Full-featured)
   - Advanced script with parameters
   - Direct hashtable support
   - Customizable output paths
   - Includes detailed help documentation

3. **`replacements-azure-portal.template.json`** (Configuration template)
   - Contains example replacement patterns
   - Regex-based pattern matching
   - Copy to `replacements-azure-portal.json` and customize per project
   - User's customized `replacements-azure-portal.json` is gitignored

### Documentation (4 files)
Located in: `tools/` and `docs/`

1. **`tools/README-SANITIZER.md`** (Main documentation)
   - Quick start guide
   - Configuration examples
   - Common replacement patterns
   - Troubleshooting guide
   - Integration workflows

2. **`docs/CHROME-MCP-SERVER-REFERENCE.md`** (Complete reference)
   - All 26 Chrome MCP tools documented
   - Tool categories and usage
   - Best practices
   - Security considerations
   - Integration patterns

3. **`docs/CHROME-MCP-DEBUGGING-SETUP.md`** (Quick setup guide)
   - 3-step quick start
   - Essential debugging commands
   - Common workflows
   - Troubleshooting tips

4. **`docs/CHROME-MCP-EDGE-AND-SESSION-ATTACHMENT.md`** (Browser setup)
   - Edge browser support (works identically to Chrome)
   - Remote debugging configuration
   - Session attachment methods
   - Multi-browser testing

### Session Logs (Optional - for context)
Located in: `docs/sessions/`

- **`2025-10-11-chrome-mcp-server-learning.md`** - Discovery session notes
- **`2025-10-11-mcp-index-consolidation.md`** - Integration notes

### Examples (Optional but recommended)
Located in: `examples/chrome-mcp-examples/`

1. **`README.md`** - Learning guide
2. **`01-basic-navigation-snapshot.md`** - Getting started
3. **`02-form-interaction.md`** - Form automation  
4. **`03-network-monitoring.md`** - API testing
5. **`04-real-world-debugging.md`** - Complete debugging session

---

## 🚀 Quick Start (For New Repository)

### Prerequisites

1. **Chrome or Edge browser** with remote debugging enabled:
   ```powershell
   # Edge (recommended)
   Start-Process "msedge.exe" -ArgumentList "--remote-debugging-port=9222", "--user-data-dir=$env:TEMP\EdgeDebug"
   
   # Chrome
   Start-Process "chrome.exe" -ArgumentList "--remote-debugging-port=9222", "--user-data-dir=$env:TEMP\ChromeDebug"
   ```

2. **VS Code with GitHub Copilot** (or Claude Desktop with MCP support)

3. **Chrome MCP Server** configured in your MCP settings:
   ```json
   {
     "chrome-devtools": {
       "command": "npx",
       "args": ["-y", "chrome-devtools-mcp@latest"]
     }
   }
   ```

### Basic Workflow

1. **Create and edit replacements config**:
   ```powershell
   # Copy template
   Copy-Item replacements-azure-portal.template.json replacements-azure-portal.json
   
   # Edit with your patterns
   code replacements-azure-portal.json
   ```
   
   Example (`replacements-azure-portal.json`):
   ```json
   {
     "replacements": {
       "your-email@company\\.com": "demo@contoso.com",
       "your-subscription-guid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
       "your-username": "demouser"
     }
   }
   ```

2. **Open Azure Portal** in the debuggable browser:
   - Navigate to the page you want to capture
   - Wait for page to fully load

3. **Run sanitizer**:
   ```powershell
   cd tools
   .\Sanitize-AzurePortal.ps1
   ```

4. **Copy the JavaScript output** and tell Copilot:
   ```
   @chrome-devtools Execute this JavaScript in the current page, then take a screenshot
   ```

5. **Screenshot saved!** The page is now sanitized and captured.

---

## 🔑 Key Features

### 1. Regex-Based Replacement
- Powerful pattern matching
- Case-insensitive by default
- Global replacements across entire page
- Supports complex patterns (GUIDs, emails, URLs)

### 2. Monaco Editor Support
**Critical for Azure Portal** - Many Azure Portal pages use Monaco editors (VS Code component):
- JSON configuration editors
- ARM template editors  
- Query editors
- Script editors

The sanitizer **automatically detects and sanitizes Monaco editors**, replacing sensitive data in both:
- Visible text (view lines)
- Hidden content (textarea values)

### 3. DOM Attribute Coverage
Replaces sensitive data in:
- Text nodes
- `aria-label`, `title`, `placeholder` attributes
- `value`, `alt`, `data-content` attributes
- Input/textarea field values
- All nested child elements (recursive)

### 4. Copilot Integration
- Generates copy-paste ready commands
- Works with `@chrome-devtools` in VS Code
- Compatible with Claude Desktop MCP
- No manual CDP API calls needed

---

## 📋 Recommended Folder Structure (New Repo)

```
azure-portal-screenshot-sanitizer/
├── README.md                          # Main documentation (use README-SANITIZER.md)
├── Sanitize-AzurePortal.ps1          # Quick wrapper (recommended entry point)
├── Invoke-AzurePortalScreenshotSanitizer.ps1  # Advanced script
├── replacements-azure-portal.json    # Configuration file
│
├── docs/
│   ├── CHROME-MCP-SERVER-REFERENCE.md
│   ├── CHROME-MCP-DEBUGGING-SETUP.md
│   └── CHROME-MCP-EDGE-AND-SESSION-ATTACHMENT.md
│
├── examples/
│   ├── README.md
│   ├── 01-basic-navigation-snapshot.md
│   ├── 02-form-interaction.md
│   ├── 03-network-monitoring.md
│   └── 04-real-world-debugging.md
│
└── images/                           # Sample sanitized screenshots
    └── .gitkeep
```

---

## 🎯 Common Replacement Patterns

### Emails
```json
"admin@company\\.com": "admin@contoso.com"
"[a-z]+@company\\.com": "user@contoso.com"
```

### GUIDs / Subscription IDs
```json
"d692f14b-8df6-4f72-ab7d-b4b2981a6b58": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
```

### Hostnames / URLs
```json
"cluster\\.eastus\\.cloudapp\\.azure\\.com": "democluster.region.cloudapp.azure.com"
"https://[a-z0-9]+\\.blob\\.core\\.windows\\.net": "https://democontent.blob.core.windows.net"
```

### Usernames
```json
"jagilber": "demouser"
"john\\.doe": "demo.user"
```

### Tenant / Organization Names
```json
"MngEnvMCAP706013": "ContosoDemo"
"CompanyName": "Fabrikam"
```

### Storage Accounts
```json
"o4gb6ue2hhjuq2": "demostorage01"
```

### Service Fabric Clusters
```json
"servicefabriccluster\\.centralus\\.cloudapp\\.azure\\.com:19080": "democluster.eastus.cloudapp.azure.com:19080"
```

---

## ⚙️ Chrome MCP Configuration

### VS Code (`mcp.json`)
```json
{
  "servers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest"
      ]
    }
  }
}
```

### Claude Desktop
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

---

## 🔍 Testing the Setup

### Step 1: Verify Remote Debugging
```powershell
# Check if browser is accessible
Invoke-RestMethod -Uri "http://localhost:9222/json"
```

**Expected**: JSON array with browser tabs

### Step 2: Test Chrome MCP Connection
In VS Code Copilot Chat:
```
@chrome-devtools list_pages
```

**Expected**: List of open browser tabs

### Step 3: Navigate to Test Page
```
@chrome-devtools navigate to https://portal.azure.com
```

### Step 4: Take Test Screenshot
```
@chrome-devtools take_screenshot and save to test.png
```

**Expected**: Screenshot file created

### Step 5: Run Sanitizer
```powershell
.\Sanitize-AzurePortal.ps1
```

**Expected**: JavaScript function output for Copilot

---

## 🎓 Learning Path

### Beginner (Getting Started)
1. Read `docs/CHROME-MCP-DEBUGGING-SETUP.md` (Quick Start)
2. Read `tools/README-SANITIZER.md` (Basic workflow)
3. Try `Sanitize-AzurePortal.ps1` with default config
4. Capture your first sanitized screenshot

### Intermediate (Customization)
1. Customize `replacements-azure-portal.json` for your needs
2. Test regex patterns at regex101.com
3. Read `docs/CHROME-MCP-SERVER-REFERENCE.md` (All tools)
4. Explore `examples/` directory

### Advanced (Automation)
1. Study `Invoke-AzurePortalScreenshotSanitizer.ps1` parameters
2. Build automated screenshot workflows
3. Integrate with documentation pipelines
4. Create custom replacement pattern libraries

---

## 🛠️ Troubleshooting

### Issue: "Cannot connect to Chrome DevTools"
**Solution**: 
- Verify browser launched with `--remote-debugging-port=9222`
- Check `http://localhost:9222/json` in another browser
- Ensure no other process using port 9222

### Issue: "No replacements applied"
**Solution**:
- Verify regex patterns (use regex101.com)
- Check for typos in JSON config
- Ensure page fully loaded before sanitizing
- Check browser console for JavaScript errors

### Issue: "Monaco editors not sanitized"
**Solution**:
- Wait 1-2 seconds after page load
- Try clicking into the editor first
- Some editors need re-render (press Ctrl+A)

### Issue: "Screenshot quality poor"
**Solution**:
- Increase browser window size
- Use `fullPage: true` for complete capture
- Use `format: "png"` for lossless quality
- Disable browser zoom (100% zoom level)

### Issue: "Chrome MCP tools not available"
**Solution**:
- Verify MCP server configured in VS Code
- Restart VS Code after adding MCP config
- Check Chrome MCP server running: `@chrome-devtools list_pages`

---

## 📚 Additional Resources

### MCP Protocol
- **Official MCP Docs**: https://modelcontextprotocol.io/
- **Chrome DevTools Protocol**: https://chromedevtools.github.io/devtools-protocol/

### Browser Automation
- **Edge DevTools**: https://docs.microsoft.com/en-us/microsoft-edge/devtools-guide-chromium/
- **Chrome Remote Debugging**: https://developer.chrome.com/blog/devtools-tips-25/

### Regex Resources
- **Regex101**: https://regex101.com/ (Test patterns)
- **RegExr**: https://regexr.com/ (Interactive learning)
- **MDN Regex Guide**: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions

---

## 🔐 Security Considerations

### Remote Debugging Security
⚠️ **WARNING**: Remote debugging exposes browser control
- Only use on **trusted networks**
- Use `--user-data-dir` for isolated profile (no personal data)
- Never expose debugging port to internet
- Close debugging browser after use

### Replacement Pattern Security
- Store sensitive patterns in `.gitignore`d config files
- Don't commit real GUIDs/secrets to version control
- Use environment-specific config files
- Rotate patterns periodically

### Screenshot Storage
- Don't commit screenshots with real data
- Store sanitized screenshots in separate folder
- Use `.gitignore` for `screenshots/` directory
- Clean up old screenshots regularly

---

## 📝 Migration Checklist

When moving to new repository:

- [ ] Copy all files from **Files to Move** section
- [ ] Update `README.md` with repository-specific info
- [ ] Customize `replacements-azure-portal.json` for your environment
- [ ] Test browser remote debugging setup
- [ ] Verify Chrome MCP server configuration
- [ ] Run sanitizer on test page
- [ ] Capture test screenshot
- [ ] Document any custom patterns you add
- [ ] Add `.gitignore` entries:
  ```gitignore
  # Screenshots
  screenshots/
  images/*.png
  images/*.jpg
  
  # Sensitive configs
  replacements-production.json
  replacements-*.json
  
  # Browser debug profiles
  *Debug/
  ```

---

## 🎉 Success Criteria

You've successfully migrated when you can:

✅ Launch debuggable browser  
✅ Connect Chrome MCP tools  
✅ Navigate to Azure Portal page  
✅ Run `Sanitize-AzurePortal.ps1`  
✅ Execute JavaScript in browser  
✅ Capture sanitized screenshot  
✅ Verify sensitive data replaced  
✅ Save screenshot to documentation  

---

## 💡 Tips & Best Practices

### Pattern Development
1. **Start specific, then generalize** - Match exact values first, then create regex
2. **Test on regex101.com** - Validate before adding to config
3. **Escape special characters** - `.` → `\\.`, `\\` → `\\\\`
4. **Order matters** - More specific patterns before general ones

### Workflow Optimization
1. **Keep browser open** - Reuse debugging session for multiple pages
2. **Batch screenshots** - Navigate → Sanitize → Screenshot → Repeat
3. **Use templates** - Save common replacement sets
4. **Automate repetitive tasks** - PowerShell scripts for multi-page capture

### Documentation Integration
1. **Name screenshots descriptively** - `azure-portal-service-fabric-cluster-overview.png`
2. **Use consistent resolution** - Standard browser window size
3. **Maintain screenshot library** - Organized by Azure service
4. **Version screenshots** - Tag with date or version

---

## 📞 Support Resources

### Documentation
- All documentation included in `docs/` folder
- Examples in `examples/` folder
- Comments in scripts explain each section

### Testing
- Test patterns at https://regex101.com/
- Verify browser connection at http://localhost:9222/json
- Use Chrome DevTools to debug JavaScript errors

---

**Package Status**: ✅ **Ready for Migration**  
**Last Updated**: December 8, 2025  
**Compatibility**: Windows, macOS, Linux (Chrome/Edge with CDP support)  

---

## Quick Command Reference

```powershell
# Launch debuggable Edge
Start-Process "msedge.exe" -ArgumentList "--remote-debugging-port=9222", "--user-data-dir=$env:TEMP\EdgeDebug"

# Test connection
Invoke-RestMethod http://localhost:9222/json

# Run sanitizer (simple)
.\Sanitize-AzurePortal.ps1

# Run sanitizer (custom)
$map = @{'pattern' = 'replacement'}
.\Invoke-AzurePortalScreenshotSanitizer.ps1 -ReplacementMap $map

# VS Code Copilot commands
@chrome-devtools list_pages
@chrome-devtools navigate to https://portal.azure.com
@chrome-devtools take_screenshot
```

---

**Happy Screenshot Sanitization! 📸🔒**
