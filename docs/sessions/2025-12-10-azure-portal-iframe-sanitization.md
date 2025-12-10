# Azure Portal Iframe Sanitization - December 10, 2025

## Context
Working with Azure Portal Resource Explorer which uses cross-origin iframes (`sandbox-1.reactblade.portal.azure.net`) that cannot be accessed programmatically via Chrome MCP due to Same-Origin Policy.

## Problem
- Azure Portal Resource Explorer content lives in cross-origin iframe
- Chrome MCP `evaluate_script` cannot access iframe content (CORS blocked)
- Automated tree expansion impossible due to browser security
- Monaco editor content (JSON) requires special handling for sanitization

## Solution: Manual DevTools Console Approach

### Key Discovery: Monaco 50-Character Span Boundary Handling

**Critical Learning**: Monaco editor splits long strings at exactly 50 characters across multiple `<span>` elements. This causes subscription GUIDs in the "id" field to be split:

- Span 5: `"/subscriptions/d692f14b-8df6-4f72-ab7d-b4b2981a6b"` (50 chars)
- Span 6: `58/resourcegroups/sfjagilber1nt3so/providers/Micro"` (continues)

**Solution**: Use innerHTML replacement with partial GUID patterns that don't cross the 50-char boundary:

1. **First pattern**: Match 48 chars (before the split) - `/d692f14b-8df6-4f72-ab7d-b4b2981a6b/gi`
2. **Second pattern**: Match "58" only after replacement - `/(?<=bc311a87-c50e-4def-8d86-97f45e508b)58/gi`

This preserves Monaco's span structure and syntax highlighting while successfully replacing split GUIDs.

### Working Implementation

```javascript
// Handle Monaco editors (Azure Portal JSON editor)
let monacoEditorsModified = 0;
const editors = document.querySelectorAll('.monaco-editor');

editors.forEach(editorElement => {
  // Target view lines container
  const viewLines = editorElement.querySelector('.view-lines');
  if (viewLines) {
    const lines = viewLines.querySelectorAll('.view-line');
    
    lines.forEach(line => {
      // Get the full HTML of the line (preserves span tags and classes)
      let lineHTML = line.innerHTML;
      let originalHTML = lineHTML;
      
      // Apply replacements to the HTML content
      // Partial patterns (48 chars) avoid Monaco's 50-char span boundary
      replacements.forEach(({regex, replacement}) => {
        lineHTML = lineHTML.replace(regex, replacement);
      });
      
      // If changed, replace the HTML (keeps all span elements and their classes intact)
      if (lineHTML !== originalHTML) {
        line.innerHTML = lineHTML;
        monacoEditorsModified++;
        totalReplacements++;
      }
    });
  }
  
  // Also modify hidden textarea (Monaco's input area)
  const textarea = editorElement.querySelector('textarea.inputarea');
  if (textarea && textarea.value) {
    let originalValue = textarea.value;
    let value = originalValue;
    
    replacements.forEach(({regex, replacement}) => {
      value = value.replace(regex, replacement);
    });
    
    if (value !== originalValue) {
      textarea.value = value;
      monacoEditorsModified++;
    }
  }
});
```

### Script Location
**File**: `sanitize-iframe.js`
- Contains all PII replacement patterns from `.env`
- Handles both DOM elements and Monaco editor content
- Must be pasted manually in DevTools Console with iframe context selected

## Workflow

1. **Navigate to Azure Portal Resource Explorer**
   ```
   https://portal.azure.com/#view/Microsoft_Azure_Resources/ResourceManagerBlade/~/resourceexplorer
   ```

2. **Manually expand resource tree** (30 seconds)
   - Click through desired resources
   - Browser security prevents automation

3. **Open DevTools** (F12)

4. **Select iframe context**
   - Console dropdown (top-left)
   - Choose: `sandbox-1.reactblade.portal.azure.net`

5. **Paste sanitization script**
   - Copy contents of `sanitize-iframe.js`
   - Paste in Console
   - Press Enter

6. **Use Up Arrow for re-runs**
   - After script is in history, just press Up Arrow + Enter
   - No need to re-paste each time

7. **Take screenshot immediately**
   - Chrome MCP: `take_screenshot` with `filePath` parameter
   - Captures sanitized content before page refresh

## Key Learnings

### GUID Replacement Patterns

Must include both dashed and non-dashed formats:

```javascript
{regex: /d692f14b-8df6-4f72-ab7d-b4b2981a6b58/gi, replacement: "bc311a87-c50e-4def-8d86-97f45e508b58"},
{regex: /d692f14b8df64f72ab7db4b2981a6b58/gi, replacement: "bc311a87c50e4def8d8697f45e508b58"}
```

**Monaco Split GUID Pattern** (handles 50-char span boundary):

```javascript
// First pattern: Match first 48 chars (before span split)
{regex: /d692f14b-8df6-4f72-ab7d-b4b2981a6b/gi, replacement: "bc311a87-c50e-4def-8d86-97f45e508b"},
// Second pattern: Match "58" only after the replacement
{regex: /(?<=bc311a87-c50e-4def-8d86-97f45e508b)58/gi, replacement: "58"}
```

### Pattern Ordering Matters

Longest/most specific patterns must come first:

```javascript
// CORRECT ORDER:
{regex: /ME-MngEnvMCAP706013-jagilber-1/gi, replacement: "contoso-subscription-001"},  // Most specific
{regex: /MngEnvMCAP706013-jagilber-1/gi, replacement: "contoso-subscription-001"},
{regex: /ME-MngEnvMCAP706013/gi, replacement: "contosotenant"},  // Less specific
{regex: /MngEnvMCAP706013/gi, replacement: "contosotenant"},  // Least specific
{regex: /jagilber/gi, replacement: "cloudadmin"}  // Generic (last)
```

### Saving VS Code Chat Images

VS Code stores chat images temporarily:

```powershell
# Path pattern
C:\Users\{username}\AppData\Roaming\Code - Insiders\User\workspaceStorage\vscode-chat-images\image-{timestamp}.png

# Get most recent
Get-ChildItem -Path "C:\Users\jagilber\AppData\Roaming\Code - Insiders\User\workspaceStorage\vscode-chat-images" -Filter "image-*.png" | 
  Sort-Object LastWriteTime -Descending | 
  Select-Object -First 1 | 
  ForEach-Object { Copy-Item $_.FullName -Destination ".\images\desired-name.png" -Force }
```

## Technical Constraints (Documented)

### What Cannot Be Done
1. **Automated iframe tree expansion** - Same-Origin Policy prevents JavaScript execution in cross-origin iframe
2. **Chrome MCP iframe access** - Even with `--disable-web-security`, cannot reach iframe programmatically via MCP tools
3. **Keyboard event propagation** - Tab/Enter/Arrow keys don't cross iframe boundaries
4. **Perfect Monaco syntax highlighting** - Modifying span `textContent` breaks CSS class color mappings

### What Works
1. **Manual DevTools Console** - User selects iframe context, pastes script
2. **Monaco span modification** - Replaces PII in displayed JSON (colors may break)
3. **Immediate screenshot** - Captures sanitized content before refresh
4. **Up Arrow recall** - DevTools Console history makes re-runs quick

## Files Created/Updated

### New Files
- **`sanitize-iframe.js`** (122 lines) - Complete iframe sanitization script with Monaco support
- **`images/resource-explorer-vmss-default-view.png`** - Default Resource Explorer view (sanitized)
- **`images/resource-explorer-vmss-edit-view.png`** - Edit mode with Monaco editor (sanitized)

### Pattern
This approach should be applied to any Azure Portal page with cross-origin iframe content where automation is blocked by browser security.

## Success Metrics

- ✅ All PII replaced in tree navigation
- ✅ All GUIDs replaced in Monaco JSON editor (including split GUIDs)
- ✅ Subscription names/IDs sanitized
- ✅ Resource names replaced
- ✅ Monaco syntax highlighting preserved (innerHTML approach with partial patterns)

## References

- Original Monaco sanitization: `Invoke-AzurePortalScreenshotSanitizer.ps1` lines 133-186
- Chrome MCP limitations: `docs/CHROME-MCP-DEBUGGING-QUICK-REFERENCE.md`
- Browser security fundamentals: Same-Origin Policy, CORS

## Recommended Documentation Updates

1. Add "Cross-Origin Iframe Limitations" section to `CHROME-MCP-SERVER-REFERENCE.md`
2. Create `MANUAL-CONSOLE-SANITIZATION-GUIDE.md` with step-by-step workflow
3. Update README with iframe sanitization workflow example
4. Document VS Code chat image path for future reference
