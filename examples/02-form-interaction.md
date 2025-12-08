# Chrome MCP Example 2: Form Interaction and Automation

## Objective
Automate form filling and submission using Chrome MCP Server.

## Scenario
Fill out a login form and verify successful submission.

## Workflow

### Step 1: Navigate to Form Page
```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://example.com/login"
  }
}
```

### Step 2: Take Snapshot to Identify Form Elements
```json
{
  "tool": "mcp_chrome-devtoo_take_snapshot"
}
```

**Example Snapshot Output:**
```
Page Structure:
- [uid:10] <input type="text" id="username">
- [uid:11] <input type="password" id="password">
- [uid:12] <button type="submit">Login</button>
```

### Step 3: Fill Form Using Multiple Methods

#### Method A: Fill Individual Fields
```json
{
  "tool": "mcp_chrome-devtoo_fill",
  "parameters": {
    "uid": "10",
    "value": "testuser@example.com"
  }
}
```

```json
{
  "tool": "mcp_chrome-devtoo_fill",
  "parameters": {
    "uid": "11",
    "value": "securepassword123"
  }
}
```

#### Method B: Fill Entire Form (Preferred)
```json
{
  "tool": "mcp_chrome-devtoo_fill_form",
  "parameters": {
    "elements": [
      {"uid": "10", "value": "testuser@example.com"},
      {"uid": "11", "value": "securepassword123"}
    ]
  }
}
```

### Step 4: Submit Form
```json
{
  "tool": "mcp_chrome-devtoo_click",
  "parameters": {
    "uid": "12"
  }
}
```

### Step 5: Wait for Response
```json
{
  "tool": "mcp_chrome-devtoo_wait_for",
  "parameters": {
    "text": "Welcome back",
    "timeout": 5000
  }
}
```

### Step 6: Verify Success
```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "() => { return document.body.innerText.includes('Dashboard'); }"
  }
}
```

## Advanced: Handling Dropdowns and Checkboxes

### Select from Dropdown
```json
{
  "tool": "mcp_chrome-devtoo_fill",
  "parameters": {
    "uid": "select-country",
    "value": "United States"
  }
}
```

### Check Checkbox
```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "(el) => { el.checked = true; }",
    "args": [{"uid": "checkbox-terms"}]
  }
}
```

## Error Handling

### Handle Alert Dialogs
```json
{
  "tool": "mcp_chrome-devtoo_handle_dialog",
  "parameters": {
    "action": "accept"
  }
}
```

### Verify Form Validation
```json
{
  "tool": "mcp_chrome-devtoo_list_console_messages"
}
```

## Key Concepts Learned

1. **Snapshot-First Approach**: Always snapshot before interaction
2. **UID Management**: Use UIDs from latest snapshot
3. **Batch Operations**: Use `fill_form` for multiple fields
4. **Wait Operations**: Use `wait_for` for dynamic content
5. **Verification**: Validate actions with `evaluate_script`

## Complete Example Script

```javascript
// Automated Login Flow
async function automateLogin() {
  // 1. Navigate
  await navigate_page("https://example.com/login");
  
  // 2. Identify elements
  const snapshot = await take_snapshot();
  
  // 3. Fill form
  await fill_form([
    {uid: "input-email", value: "user@example.com"},
    {uid: "input-password", value: "password123"}
  ]);
  
  // 4. Submit
  await click("btn-submit");
  
  // 5. Wait for success
  await wait_for("Welcome back", 5000);
  
  // 6. Verify
  const success = await evaluate_script(
    "() => location.pathname === '/dashboard'"
  );
  
  return success;
}
```

## Troubleshooting

**Issue**: Form not submitting
- Check if button is enabled
- Look for JavaScript validation errors
- Verify all required fields are filled

**Issue**: UID not found
- Re-take snapshot after DOM changes
- Check if element is visible on page
- Verify UID is from latest snapshot

**Issue**: Timeout waiting for response
- Increase timeout value
- Check network requests for errors
- Verify expected text actually appears

## Next Steps
- Automate multi-step forms
- Handle file uploads
- Implement retry logic for flaky elements

---

**Related Examples:**
- [01-basic-navigation-snapshot.md](01-basic-navigation-snapshot.md)
- [03-network-monitoring.md](03-network-monitoring.md)
- [04-performance-testing.md](04-performance-testing.md)
