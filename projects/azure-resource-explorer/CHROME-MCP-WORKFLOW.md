# Chrome MCP Screenshot Capture Workflow

**Project**: azure-resource-explorer  
**Tool**: Chrome DevTools MCP Server  
**Date**: December 10, 2025

## Workflow Overview

This document explains the automated Chrome MCP workflow for capturing sanitized Azure Portal screenshots.

## Chrome MCP Tools Used

1. **mcp_chrome-devtoo_list_pages** - List open browser pages
2. **mcp_chrome-devtoo_navigate_page** - Navigate to URLs
3. **mcp_chrome-devtoo_take_snapshot** - Get accessibility tree of page (for verification)
4. **mcp_chrome-devtoo_evaluate_script** - Execute JavaScript for sanitization
5. **mcp_chrome-devtoo_take_screenshot** - Capture screenshot to file

## Step-by-Step Process

### Step 1: Verify Browser Connection
```
mcp_chrome-devtoo_list_pages
```
- Confirms Edge browser is running with remote debugging on port 9222
- Shows currently open pages

### Step 2: Navigate to Target URL
```
mcp_chrome-devtoo_navigate_page
  type: "url"
  url: "https://portal.azure.com/#view/..."
```
- Navigates to specific Azure Portal blade
- Wait 3-5 seconds for page to load (Azure Portal is slow)

### Step 3: Take Snapshot (Optional Verification)
```
mcp_chrome-devtoo_take_snapshot
```
- Returns accessibility tree showing page structure
- Useful for verifying page loaded and finding elements
- NOT required for screenshot capture

### Step 4: Apply Sanitization
```
mcp_chrome-devtoo_evaluate_script
  function: "() => { ... sanitization logic ... }"
```
- Executes JavaScript function in page context
- Replaces PII using patterns from .env
- Returns count of replacements made

### Step 5: Capture Screenshot
```
mcp_chrome-devtoo_take_screenshot
  filePath: "projects/azure-resource-explorer/outputs/filename-sanitized.png"
  format: "png"
  quality: 95
```
- Captures viewport screenshot
- Saves directly to specified path
- Returns confirmation message

## Sanitization JavaScript Function

The sanitization function is auto-generated from `.env` by `Sanitize-AzurePortal-FromEnv.ps1`.

### Key Features:
- **19 replacement patterns** from .env variables
- **DOM traversal** - Replaces text in all text nodes
- **Attribute sanitization** - Replaces in aria-label, title, etc.
- **Monaco editor support** - Special handling for code editors
- **Returns stats** - Total replacements and patterns applied

### Example Function Structure:
```javascript
() => {
  const replacements = [
    {regex: /Your-Subscription-Name/gi, replacement: "Demo-Subscription-001"},
    {regex: /admin@YourTenant\\.onmicrosoft\\.com/gi, replacement: "admin@contoso.com"},
    // ... 17 more patterns
  ];

  function replaceInNode(node, replacements) {
    // Recursive DOM traversal and replacement
  }

  replaceInNode(document.body, replacements);
  
  return {
    success: true,
    totalReplacements: count,
    patternsApplied: 19
  };
}
```

## Timing Considerations

### Azure Portal Load Times:
- **Overview pages**: 3-4 seconds
- **Resource Explorer**: 5-8 seconds (tree loads dynamically)
- **ARM API Playground**: 4-5 seconds
- **Complex blades**: Up to 10 seconds

### Best Practice:
- Always wait after navigation before taking snapshot/screenshot
- Use `Start-Sleep -Seconds X` between navigation and capture
- Verify page loaded before sanitization (check snapshot)

## Screenshot Naming Convention

Format: `##-descriptive-name-sanitized.png`

### Examples:
- `01-resource-manager-overview-sanitized.png`
- `02-resource-explorer-navigation-sanitized.png`
- `03-resource-explorer-new-buttons-sanitized.png`
- `04-resource-explorer-get-request-sanitized.png`

### Numbering:
- Prefix with 01-10 to maintain order
- Matches screenshot plan sequence
- Makes it easy to identify missing screenshots

## Common Issues and Solutions

### Issue: Page Not Fully Loaded
**Symptom**: Screenshot shows loading spinner or partial content  
**Solution**: Increase wait time after navigation, check snapshot for content

### Issue: Sanitization Returns 0 Replacements
**Symptom**: PII visible in screenshot  
**Solution**: 
- Verify .env has correct values
- Check that patterns match actual PII on page
- May need to add MngEnvMCAP706013 pattern (discovered in testing)

### Issue: Screenshot Saved to Wrong Location
**Symptom**: Can't find screenshot file  
**Solution**: Use absolute path in filePath parameter, check for typos

### Issue: Monaco Editor Not Sanitized
**Symptom**: Code editor shows real values  
**Solution**: Sanitization function includes Monaco-specific logic, verify it's executing

## Progress Tracking

### Completed (2/10):
- ✅ Screenshot 1: Resource Manager Overview
- ✅ Screenshot 2: Resource Explorer (loading state)

### Remaining (8/10):
- ⏸️ Screenshot 2 (retry): Resource Explorer with tree expanded
- ⏸️ Screenshot 3: Resource Explorer GET/EDIT/PUT/PATCH buttons (CRITICAL)
- ⏸️ Screenshot 4: Resource Explorer GET request
- ⏸️ Screenshot 5: Resource Explorer EDIT mode
- ⏸️ Screenshot 6: Resource Explorer PUT execution
- ⏸️ Screenshot 7: ARM API Playground workflow
- ⏸️ Screenshot 8: ARM API GET request
- ⏸️ Screenshot 9: ARM API PUT request
- ⏸️ Screenshot 10: Portal Resource JSON view

## Next Steps

### Option 1: Manual Navigation + MCP Capture
User manually navigates to each page, agent uses MCP to sanitize and capture

### Option 2: Full MCP Automation
Agent navigates, waits, sanitizes, and captures fully automatically

### Option 3: Hybrid Approach
User navigates to complex pages (Resource Explorer with tree expanded),  
Agent handles sanitization and capture

## Advantages of Chrome MCP Approach

✅ **Fully Automated** - No manual screenshot tools needed  
✅ **Consistent Quality** - Same resolution, format, quality every time  
✅ **Integrated Sanitization** - PII replaced before capture  
✅ **Repeatable** - Can recreate any screenshot with exact same process  
✅ **Scriptable** - Can batch process multiple screenshots  
✅ **Version Controlled** - Screenshots saved directly to project  

## Documentation Requirements

After screenshot capture complete:
1. Update README in outputs/ directory with screenshot descriptions
2. Create screenshot inventory mapping (old → new)
3. Document any manual steps required (e.g., expanding tree nodes)
4. Note any PII patterns discovered during testing
