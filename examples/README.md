# Chrome MCP Examples - README

## Overview
This directory contains practical examples for using the Chrome DevTools MCP Server. Each example demonstrates specific capabilities and includes working code patterns.

## Prerequisites
- Chrome MCP Server installed and running
- VS Code with MCP integration enabled
- Basic understanding of JSON and JavaScript

## Example Files

### 1. Basic Navigation and Snapshot
**File**: `01-basic-navigation-snapshot.md`

**What You'll Learn:**
- Opening and navigating pages
- Taking text-based snapshots
- Extracting page content with JavaScript
- Understanding UIDs for element identification

**Best For**: Getting started with Chrome MCP basics

### 2. Form Interaction and Automation
**File**: `02-form-interaction.md`

**What You'll Learn:**
- Identifying form elements from snapshots
- Filling single and multiple form fields
- Clicking buttons and submitting forms
- Handling dynamic content and waiting
- Form validation and error handling

**Best For**: Automating web forms and user interactions

### 3. Network Request Monitoring
**File**: `03-network-monitoring.md`

**What You'll Learn:**
- Monitoring network requests (XHR, Fetch, etc.)
- Filtering requests by type
- Inspecting request/response details
- API endpoint testing
- Performance analysis
- Error detection

**Best For**: API testing, debugging, and performance analysis

## Quick Start

### Step 1: Verify Chrome MCP Server
```json
{
  "tool": "mcp_chrome-devtoo_list_pages"
}
```

### Step 2: Try Basic Navigation
```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://example.com"
  }
}
```

### Step 3: Take Your First Snapshot
```json
{
  "tool": "mcp_chrome-devtoo_take_snapshot"
}
```

## Common Workflow Pattern

All examples follow this general pattern:

```
1. Navigate      → Open target page
2. Wait          → Ensure content is loaded (if needed)
3. Snapshot      → Get page structure with UIDs
4. Interact      → Click, fill, or extract using UIDs
5. Validate      → Verify results with scripts or snapshots
6. Monitor       → Check network/console for issues
```

## Tool Categories Reference

### Page Management
- `list_pages` - See all open tabs
- `select_page` - Switch to a specific tab
- `new_page` - Open new tab with URL
- `close_page` - Close a tab
- `navigate_page` - Navigate current tab
- `navigate_page_history` - Go back/forward

### Content Inspection
- `take_snapshot` - Get text-based page structure (preferred)
- `take_screenshot` - Capture visual image
- `evaluate_script` - Run JavaScript in page

### Interaction
- `click` - Click element by UID
- `fill` - Fill single form field
- `fill_form` - Fill multiple fields at once
- `hover` - Hover over element
- `drag` - Drag-and-drop
- `upload_file` - Upload file through input

### Monitoring
- `list_network_requests` - Get all network requests
- `get_network_request` - Get specific request details
- `list_console_messages` - Get console logs

### Testing & Emulation
- `emulate_network` - Simulate network conditions
- `emulate_cpu` - Throttle CPU performance
- `resize_page` - Change viewport size
- `performance_start_trace` - Start performance recording
- `performance_stop_trace` - Stop and analyze trace

### Utilities
- `wait_for` - Wait for text to appear
- `handle_dialog` - Handle alerts/confirms/prompts

## Best Practices

### 1. Always Use Latest Snapshot
UIDs expire after DOM changes. Re-snapshot after:
- Page navigation
- AJAX content updates
- Form submissions
- Dynamic content changes

### 2. Wait for Dynamic Content
Use `wait_for` when dealing with:
- AJAX-loaded content
- Single-page applications
- Loading indicators
- Delayed responses

### 3. Prefer Snapshot Over Screenshot
- **Snapshot**: Fast, automatable, machine-readable
- **Screenshot**: Visual validation, documentation, debugging

### 4. Batch Operations When Possible
```json
// Good: Single call
{"tool": "fill_form", "elements": [...]}

// Less efficient: Multiple calls
{"tool": "fill", "uid": "1", "value": "..."}
{"tool": "fill", "uid": "2", "value": "..."}
```

### 5. Handle Errors Gracefully
```javascript
try {
  await click("btn-submit");
} catch (error) {
  // Check for dialogs
  await handle_dialog("dismiss");
  // Retry
  await click("btn-submit");
}
```

## Common Patterns

### Pattern: Login Flow
```javascript
await navigate_page("https://app.com/login");
await fill_form([
  {uid: "email", value: "user@example.com"},
  {uid: "password", value: "pass123"}
]);
await click("btn-login");
await wait_for("Dashboard", 5000);
```

### Pattern: Data Scraping
```javascript
await navigate_page("https://data-site.com");
const data = await evaluate_script(`
  () => {
    return Array.from(document.querySelectorAll('.item'))
      .map(el => ({
        title: el.querySelector('.title').textContent,
        value: el.querySelector('.value').textContent
      }));
  }
`);
```

### Pattern: API Testing
```javascript
await navigate_page("https://app.com");
await click("btn-fetch-data");
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});
const apiRequest = requests.find(r => r.url.includes("/api/data"));
console.assert(apiRequest.status === 200, "API failed");
```

### Pattern: Performance Check
```javascript
await performance_start_trace({reload: true, autoStop: true});
// Page reloads and trace runs
const trace = await performance_stop_trace();
console.log(`LCP: ${trace.metrics.LCP}ms`);
```

## Troubleshooting Guide

### Problem: "UID not found"
- **Solution**: Take fresh snapshot before using UIDs

### Problem: "Element not clickable"
- **Solution**: Check if element is visible, try `hover` first

### Problem: "Timeout waiting for content"
- **Solution**: Increase timeout or check if expected text exists

### Problem: "Network requests empty"
- **Solution**: Ensure you list requests before navigating away

### Problem: "Dialog blocks interaction"
- **Solution**: Use `handle_dialog` to dismiss/accept

### Problem: "Script execution fails"
- **Solution**: Check console messages for JavaScript errors

## Advanced Topics

### Multi-Page Testing
Work with multiple tabs simultaneously by using `select_page` to switch context.

### File Upload Automation
Use `upload_file` with element UID and local file path.

### WebSocket Monitoring
WebSocket connections appear in `list_network_requests` with type "websocket".

### Custom JavaScript Injection
Use `evaluate_script` to inject custom logic, analytics, or data extraction.

### Responsive Design Testing
Use `resize_page` to test different viewport sizes systematically.

## Integration Examples

### With Kusto MCP
```javascript
// Scrape web data
const data = await chrome_extract_data();

// Store in Kusto
await kusto_query({
  query: `.set-or-append WebScrapedData <| print data='${JSON.stringify(data)}'`
});
```

### With PowerShell MCP
```javascript
// Get data from web
const config = await chrome_extract_config();

// Process with PowerShell
await run_powershell({
  script: `$config = '${JSON.stringify(config)}' | ConvertFrom-Json; Process-Config $config`
});
```

### With File Obfuscation MCP
```javascript
// Extract sensitive data
const logs = await chrome_extract_logs();

// Obfuscate before saving
const obfuscated = await obfuscate_text({
  text: JSON.stringify(logs),
  security_level: "metadata_only"
});
```

## Learning Path

**Beginner** (Start here):
1. Read: 01-basic-navigation-snapshot.md
2. Practice: Navigate to 3 different websites
3. Practice: Extract title and main heading from each

**Intermediate**:
1. Read: 02-form-interaction.md
2. Practice: Automate a login flow
3. Practice: Fill and submit a multi-field form

**Advanced**:
1. Read: 03-network-monitoring.md
2. Practice: Monitor API calls from a web app
3. Practice: Build complete API test suite

**Expert**:
1. Combine all techniques
2. Build multi-page automation workflows
3. Integrate with other MCP servers

## Additional Resources

- **Main Reference**: `../docs/CHROME-MCP-SERVER-REFERENCE.md`
- **MCP Protocol**: https://modelcontextprotocol.io/
- **Chrome DevTools**: https://chromedevtools.github.io/devtools-protocol/

## Contributing

When adding new examples:
1. Follow existing naming pattern: `##-topic-name.md`
2. Include objective, workflow, and troubleshooting sections
3. Provide working JSON examples
4. Link to related examples
5. Update this README

## Support

For Chrome MCP Server issues:
- Check `list_console_messages` for JavaScript errors
- Verify page is fully loaded before interaction
- Re-snapshot after DOM changes
- Use `wait_for` for dynamic content

---

**Status**: Ready for learning
**Last Updated**: October 11, 2025
**Examples**: 3 complete workflows
