# Chrome MCP Example 1: Basic Navigation and Snapshot

## Objective
Learn fundamental Chrome MCP operations: opening pages, taking snapshots, and extracting content.

## Prerequisites
- Chrome MCP Server running and connected
- Basic understanding of MCP tool invocation

## Example Workflow

### Step 1: Check Available Pages
```json
{
  "tool": "mcp_chrome-devtoo_list_pages"
}
```

**Expected Response:**
```
Pages:
0: about:blank [selected]
```

### Step 2: Navigate to a Website
```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://example.com"
  }
}
```

### Step 3: Take a Snapshot
```json
{
  "tool": "mcp_chrome-devtoo_take_snapshot"
}
```

**Expected Response Format:**
```
Page Structure:
- [uid:1] <h1> Example Domain
- [uid:2] <p> This domain is for use in illustrative examples...
- [uid:3] <a href="..."> More information...
```

### Step 4: Extract Specific Content
```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "() => { return document.querySelector('h1').textContent; }"
  }
}
```

**Expected Response:**
```json
{
  "result": "Example Domain"
}
```

## Key Concepts Learned

1. **Page Management**: Use `list_pages` to see current tabs
2. **Navigation**: Use `navigate_page` to load URLs
3. **Content Inspection**: Use `take_snapshot` for structured page view
4. **Data Extraction**: Use `evaluate_script` for JavaScript execution

## Next Steps
- Try navigating to different websites
- Extract multiple elements using CSS selectors
- Experiment with `take_screenshot` for visual capture

## Common Issues

**Issue**: Navigation timeout
**Solution**: Increase timeout parameter or wait for specific content

**Issue**: Script execution fails
**Solution**: Ensure page is fully loaded before running scripts

---

**Related Examples:**
- [02-form-interaction.md](02-form-interaction.md)
- [03-network-monitoring.md](03-network-monitoring.md)
