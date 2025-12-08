# Chrome MCP Server Reference Guide

**Last Updated**: October 11, 2025  
**Status**: Active Learning Document

## Overview

The Chrome DevTools MCP Server provides programmatic access to Chrome browser automation through the Model Context Protocol. It enables AI agents to:
- Navigate and interact with web pages
- Inspect page content and structure
- Monitor network requests and console messages
- Analyze performance metrics
- Debug and test web applications

## Core Capabilities

### 1. Page Management
Control browser tabs and navigation.

#### Available Commands:
- **`mcp_chrome-devtoo_list_pages`** - List all open browser tabs
- **`mcp_chrome-devtoo_select_page`** - Switch to a specific tab
- **`mcp_chrome-devtoo_new_page`** - Open a new tab with URL
- **`mcp_chrome-devtoo_close_page`** - Close a specific tab
- **`mcp_chrome-devtoo_navigate_page`** - Navigate current tab to URL
- **`mcp_chrome-devtoo_navigate_page_history`** - Go back/forward in history

#### Example Usage:
```json
// List all pages
{"command": "list_pages"}

// Open new page
{"command": "new_page", "url": "https://example.com"}

// Navigate current page
{"command": "navigate_page", "url": "https://github.com"}

// Go back
{"command": "navigate_page_history", "navigate": "back"}
```

### 2. Page Content Inspection

#### Snapshot System (Preferred Method)
- **`mcp_chrome-devtoo_take_snapshot`** - Get text-based page structure with unique identifiers (UIDs)
- Returns hierarchical element list with UIDs for precise interaction
- **Always use latest snapshot** for accurate element references
- More efficient than screenshots for automation

#### Visual Inspection
- **`mcp_chrome-devtoo_take_screenshot`** - Capture page/element as image
  - Formats: PNG, JPEG, WebP
  - Full page or viewport capture
  - Element-specific screenshots via UID

#### Example:
```json
// Take snapshot (preferred)
{"command": "take_snapshot"}

// Take screenshot
{"command": "take_screenshot", "fullPage": true, "format": "png"}

// Screenshot specific element
{"command": "take_screenshot", "uid": "element-123"}
```

### 3. Page Interaction

#### Mouse Operations
- **`mcp_chrome-devtoo_click`** - Click element (single/double)
- **`mcp_chrome-devtoo_hover`** - Hover over element
- **`mcp_chrome-devtoo_drag`** - Drag element to another element

#### Form Input
- **`mcp_chrome-devtoo_fill`** - Fill single form field
- **`mcp_chrome-devtoo_fill_form`** - Fill multiple fields at once
- **`mcp_chrome-devtoo_upload_file`** - Upload file through input

#### Example:
```json
// Click button
{"command": "click", "uid": "btn-submit"}

// Fill input field
{"command": "fill", "uid": "input-email", "value": "user@example.com"}

// Fill entire form
{
  "command": "fill_form",
  "elements": [
    {"uid": "input-email", "value": "user@example.com"},
    {"uid": "input-password", "value": "secure123"}
  ]
}
```

### 4. JavaScript Execution
- **`mcp_chrome-devtoo_evaluate_script`** - Run JavaScript in page context
- Returns JSON-serializable results
- Can reference elements by UID

#### Example:
```json
{
  "command": "evaluate_script",
  "function": "() => { return document.title; }"
}

// With element reference
{
  "command": "evaluate_script",
  "function": "(el) => { return el.innerText; }",
  "args": [{"uid": "element-123"}]
}
```

### 5. Network Monitoring

#### Available Commands:
- **`mcp_chrome-devtoo_list_network_requests`** - List all network requests since navigation
- **`mcp_chrome-devtoo_get_network_request`** - Get specific request details by URL

#### Filtering Options:
- Resource types: document, stylesheet, image, media, font, script, xhr, fetch, websocket, etc.
- Pagination support for large result sets

#### Example:
```json
// List all XHR/Fetch requests
{
  "command": "list_network_requests",
  "resourceTypes": ["xhr", "fetch"]
}

// Get specific request
{
  "command": "get_network_request",
  "url": "https://api.example.com/data"
}
```

### 6. Console Monitoring
- **`mcp_chrome-devtoo_list_console_messages`** - Get console logs since navigation
- Captures: log, warn, error, info, debug messages
- Useful for debugging web application issues

### 7. Performance Analysis

#### Tracing Commands:
- **`mcp_chrome-devtoo_performance_start_trace`** - Start performance recording
- **`mcp_chrome-devtoo_performance_stop_trace`** - Stop and analyze recording
- **`mcp_chrome-devtoo_performance_analyze_insight`** - Get detailed insight analysis

#### Metrics Provided:
- Core Web Vitals (CWV) scores
- Performance insights (LCP, FCP, etc.)
- Detailed timing breakdowns

#### Example:
```json
// Start trace with page reload
{
  "command": "performance_start_trace",
  "reload": true,
  "autoStop": true
}

// Analyze specific insight
{
  "command": "performance_analyze_insight",
  "insightName": "LCPBreakdown"
}
```

### 8. Emulation & Testing

#### Network Emulation
- **`mcp_chrome-devtoo_emulate_network`** - Simulate network conditions
- Options: No emulation, Offline, Slow 3G, Fast 3G, Slow 4G, Fast 4G

#### CPU Throttling
- **`mcp_chrome-devtoo_emulate_cpu`** - Slow down CPU execution (1-20x)
- Test performance on slower devices

#### Viewport Resizing
- **`mcp_chrome-devtoo_resize_page`** - Set page dimensions
- Test responsive designs

#### Example:
```json
// Test offline mode
{"command": "emulate_network", "throttlingOption": "Offline"}

// Throttle CPU 4x
{"command": "emulate_cpu", "throttlingRate": 4}

// Mobile viewport
{"command": "resize_page", "width": 375, "height": 667}
```

### 9. Dialog Handling
- **`mcp_chrome-devtoo_handle_dialog`** - Handle alert/confirm/prompt dialogs
- Actions: accept, dismiss
- Optional prompt text input

#### Example:
```json
// Accept alert
{"command": "handle_dialog", "action": "accept"}

// Dismiss with prompt
{
  "command": "handle_dialog",
  "action": "accept",
  "promptText": "User input"
}
```

### 10. Wait Operations
- **`mcp_chrome-devtoo_wait_for`** - Wait for text to appear on page
- Configurable timeout
- Essential for dynamic content

#### Example:
```json
{
  "command": "wait_for",
  "text": "Loading complete",
  "timeout": 5000
}
```

## Best Practices

### 1. Workflow Pattern
```
1. Open/Navigate → new_page or navigate_page
2. Wait for Load → wait_for (if needed)
3. Inspect → take_snapshot (get UIDs)
4. Interact → click/fill using UIDs from snapshot
5. Validate → take_snapshot again or evaluate_script
6. Monitor → list_console_messages, list_network_requests
```

### 2. Snapshot vs Screenshot
- **Use Snapshot**: For automation, element interaction, content extraction
- **Use Screenshot**: For visual validation, bug reports, documentation

### 3. Element Identification
- Always use **latest snapshot** for UIDs
- UIDs are ephemeral and change after DOM updates
- Re-take snapshot after navigation or dynamic content changes

### 4. Error Handling
- Check for dialogs that may block interaction
- Use wait_for for dynamic content
- Monitor console messages for JavaScript errors
- Validate network requests completed successfully

### 5. Performance Testing
- Use network emulation for real-world conditions
- Enable CPU throttling for device simulation
- Analyze Core Web Vitals for user experience metrics

## Common Use Cases

### Web Scraping
```
1. navigate_page → target URL
2. wait_for → content loaded
3. take_snapshot → get structure
4. evaluate_script → extract data
```

### Form Automation
```
1. navigate_page → form URL
2. take_snapshot → get field UIDs
3. fill_form → populate all fields
4. click → submit button
5. wait_for → success message
```

### API Testing
```
1. navigate_page → web app
2. Trigger actions → click/fill
3. list_network_requests → verify API calls
4. get_network_request → inspect payloads
```

### Performance Audit
```
1. performance_start_trace → begin recording
2. navigate_page → test page
3. performance_stop_trace → get results
4. performance_analyze_insight → detailed analysis
```

### Responsive Testing
```
1. resize_page → mobile dimensions
2. take_screenshot → capture mobile view
3. resize_page → desktop dimensions
4. take_screenshot → capture desktop view
5. Compare layouts
```

## Integration with MCP Workspace

### Typical Agent Workflow
```typescript
// 1. Initialize browser session
const pages = await mcp_chrome_devtoo_list_pages();

// 2. Navigate to target
await mcp_chrome_devtoo_navigate_page({
  url: "https://target-site.com"
});

// 3. Inspect content
const snapshot = await mcp_chrome_devtoo_take_snapshot();

// 4. Extract data
const data = await mcp_chrome_devtoo_evaluate_script({
  function: "() => { return document.querySelectorAll('.data-item').length; }"
});

// 5. Monitor network
const requests = await mcp_chrome_devtoo_list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});
```

## Security Considerations

### Input Validation
- Sanitize URLs before navigation
- Validate UIDs from trusted snapshots only
- Escape user input in evaluate_script

### Sensitive Data
- Be cautious with screenshot/snapshot in sensitive contexts
- Clear browser state after testing auth flows
- Use headless mode for automated testing

### Resource Management
- Close unused pages to free resources
- Limit concurrent page operations
- Set reasonable timeouts for wait operations

## Advanced Patterns

### Dynamic Content Handling
```javascript
// Wait and retry pattern
1. take_snapshot
2. If element not found → wait_for(text)
3. take_snapshot again
4. Proceed with interaction
```

### Multi-Page Testing
```javascript
// Open multiple pages for comparison
1. new_page(url1) → page 0
2. new_page(url2) → page 1
3. select_page(0) → test first
4. select_page(1) → test second
5. Compare results
```

### Error Recovery
```javascript
// Handle unexpected dialogs
try {
  await click(uid)
} catch (dialog_error) {
  await handle_dialog("dismiss")
  await click(uid) // retry
}
```

## Limitations & Workarounds

### Known Limitations
- UIDs expire after DOM changes
- Cannot close last page
- Screenshots may be large files
- Network logs cleared on navigation

### Workarounds
- Re-snapshot after DOM mutations
- Keep one page open, close others
- Use selective screenshots (elements only)
- Monitor network before navigation

## Troubleshooting

### Common Issues

**Issue**: Element not found by UID
- **Solution**: Take fresh snapshot, use updated UID

**Issue**: Click has no effect
- **Solution**: Check if element is visible, not overlapped, try hover first

**Issue**: Form fill fails
- **Solution**: Verify input element type, check for JavaScript validation

**Issue**: Network requests missing
- **Solution**: Ensure monitoring started before navigation

**Issue**: Performance trace empty
- **Solution**: Use reload:true or ensure page activity during trace

## Learning Resources

### Next Steps
1. **Practice**: Open a test page and explore snapshot/interaction
2. **Network**: Monitor API calls from a web application
3. **Performance**: Run trace on different sites, compare metrics
4. **Automation**: Build a simple scraper or form filler
5. **Testing**: Create a responsive design validator

### Related Documentation
- MCP Protocol: https://modelcontextprotocol.io/
- Chrome DevTools Protocol: https://chromedevtools.github.io/devtools-protocol/
- Workspace Agent Config: `config/agent-config.json`

## Tool Quick Reference

| Category | Tool | Primary Use |
|----------|------|-------------|
| **Page** | list_pages | Enumerate tabs |
| | select_page | Switch tab context |
| | new_page | Open URL in new tab |
| | navigate_page | Navigate current tab |
| **Content** | take_snapshot | Get page structure + UIDs |
| | take_screenshot | Visual capture |
| | evaluate_script | Run JavaScript |
| **Interact** | click | Click element |
| | fill/fill_form | Input data |
| | drag | Drag-and-drop |
| **Monitor** | list_network_requests | API/resource calls |
| | list_console_messages | Console logs |
| **Perf** | performance_start_trace | Begin recording |
| | performance_stop_trace | Get metrics |
| **Test** | emulate_network | Network conditions |
| | emulate_cpu | CPU throttling |
| | resize_page | Viewport dimensions |

---

**Status**: Ready for agent use. Chrome MCP server is active and accessible.

**Last Validated**: October 11, 2025
