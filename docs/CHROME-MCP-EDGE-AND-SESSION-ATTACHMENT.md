# Chrome MCP Server - Browser Attachment & Edge Support

**Created**: October 11, 2025  
**Topic**: Attaching to existing browser sessions, Edge support

---

## Can You Attach to Existing Browser Sessions?

### ✅ **YES - Chrome DevTools Protocol Supports This**

Chrome MCP Server is built on the **Chrome DevTools Protocol (CDP)**, which supports attaching to existing browser sessions through **remote debugging**.

### How It Works

#### Remote Debugging Port
Browsers can be launched with a remote debugging port that allows external tools to connect:

**Chrome:**
```bash
chrome.exe --remote-debugging-port=9222
```

**Edge (Chromium-based):**
```bash
msedge.exe --remote-debugging-port=9222
```

**Once the browser is running with remote debugging**, MCP tools can connect to:
- `http://localhost:9222` (default)
- View available targets at `http://localhost:9222/json`
- Attach to specific pages/tabs

---

## Edge Browser Support

### ✅ **YES - Edge is Fully Supported**

Microsoft Edge (Chromium-based) uses the **same Chrome DevTools Protocol** as Chrome, so Chrome MCP Server works identically with Edge.

### Why Edge Works
- **Same Engine**: Edge uses Chromium (same as Chrome)
- **Same Protocol**: Implements Chrome DevTools Protocol
- **Same APIs**: All CDP features available
- **Same Tools**: DevTools interface is identical

### Using Edge with Chrome MCP
You just need to launch Edge with the remote debugging port:

```bash
# Windows
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222

# Launch with specific user data directory (optional)
msedge.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\edge-debug"
```

---

## Configuration Patterns

### Method 1: Launch Browser with Remote Debugging

**Chrome:**
```bash
chrome.exe --remote-debugging-port=9222 --remote-allow-origins=*
```

**Edge:**
```bash
msedge.exe --remote-debugging-port=9222 --remote-allow-origins=*
```

**Benefits:**
- Full control from launch
- Clean debugging environment
- Isolated from regular browsing

### Method 2: Attach to Already Running Browser

**Note**: To attach to an existing browser that's already running, it **must have been launched with the remote debugging port enabled**.

You **cannot** attach to a browser that was launched normally without remote debugging.

### Method 3: Use Dedicated Profile

**Recommended for development:**
```bash
# Chrome
chrome.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\chrome-debug" --no-first-run

# Edge  
msedge.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\edge-debug" --no-first-run
```

**Benefits:**
- Isolated profile
- Won't interfere with regular browsing
- Clean state for testing

---

## Chrome MCP Server Connection

### How Chrome MCP Connects

The Chrome MCP Server likely connects to the remote debugging port internally. The connection parameters might be configured in the MCP server configuration.

### Typical Configuration (Hypothetical)
```json
{
  "chrome-devtools": {
    "type": "stdio",
    "command": "node",
    "args": ["path/to/chrome-mcp/server.js"],
    "env": {
      "CHROME_REMOTE_DEBUGGING_PORT": "9222",
      "CHROME_REMOTE_DEBUGGING_HOST": "localhost"
    }
  }
}
```

### Checking Connection
Navigate to `http://localhost:9222/json` to see:
- List of open tabs/pages
- WebSocket debugging URLs
- Available targets

---

## Practical Usage Scenarios

### Scenario 1: Debug Existing Browsing Session
```bash
# 1. Close all Edge/Chrome instances
# 2. Launch with debugging
msedge.exe --remote-debugging-port=9222

# 3. Browse normally in this window
# 4. Use Chrome MCP tools to inspect/debug
```

### Scenario 2: Automated Testing on Edge
```bash
# Launch Edge with debugging
msedge.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\edge-test"

# Use Chrome MCP to:
# - Navigate to test pages
# - Run automated tests
# - Monitor performance
# - Check console errors
```

### Scenario 3: Multi-Browser Testing
```bash
# Chrome on port 9222
chrome.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\chrome-test"

# Edge on port 9223
msedge.exe --remote-debugging-port=9223 --user-data-dir="C:\temp\edge-test"

# Connect Chrome MCP to different ports for parallel testing
```

---

## Remote Debugging Protocol Endpoints

### Discovery Endpoints
```
http://localhost:9222/json           # List all targets
http://localhost:9222/json/version   # Browser version info
http://localhost:9222/json/protocol  # Protocol definition
http://localhost:9222/devtools/page/<id>  # DevTools UI
```

### WebSocket Connection
```
ws://localhost:9222/devtools/page/<target-id>
```

The Chrome MCP Server uses these endpoints internally to communicate with the browser.

---

## Common Command-Line Flags

### Essential Flags
```bash
--remote-debugging-port=9222       # Enable remote debugging
--remote-allow-origins=*           # Allow connections (security consideration)
--user-data-dir="path"             # Isolated profile
--no-first-run                     # Skip first-run experience
--no-default-browser-check         # Skip default browser check
```

### Useful for Testing
```bash
--headless=new                     # Headless mode (new implementation)
--disable-gpu                      # Disable GPU (sometimes needed in headless)
--disable-dev-shm-usage            # Overcome limited resource problems
--disable-extensions               # Disable extensions
--disable-popup-blocking           # Allow popups
--incognito                        # Start in incognito mode
```

### Security Considerations
```bash
--remote-allow-origins=http://localhost:*   # Restrict to localhost
--remote-allow-origins=*                    # Allow all (development only!)
```

---

## Verifying Connection

### Step 1: Launch Browser with Debugging
```bash
msedge.exe --remote-debugging-port=9222
```

### Step 2: Check Endpoint
Open in another browser (or curl):
```
http://localhost:9222/json
```

**Expected Response:**
```json
[
  {
    "description": "",
    "devtoolsFrontendUrl": "/devtools/inspector.html?ws=localhost:9222/devtools/page/...",
    "id": "page-id-123",
    "title": "Example Domain",
    "type": "page",
    "url": "https://example.com/",
    "webSocketDebuggerUrl": "ws://localhost:9222/devtools/page/page-id-123"
  }
]
```

### Step 3: Use Chrome MCP Tools
The Chrome MCP tools should now be able to interact with this browser session.

---

## Limitations & Considerations

### Cannot Attach to Regular Browser
- If you launch Edge/Chrome **without** `--remote-debugging-port`, you **cannot** attach to it later
- Must restart browser with debugging enabled

### Port Conflicts
- Only one browser instance can use a specific port
- Use different ports for multiple browsers
- Check if port is already in use

### Security Warning
- Remote debugging exposes browser control
- Only use on trusted networks
- Use `--remote-allow-origins` to restrict access
- Never expose debugging port to internet

### Profile Isolation
- Using `--user-data-dir` creates isolated profile
- Won't have your bookmarks, extensions, history
- Good for testing, not for daily browsing

---

## Chrome MCP Server Configuration

### Likely Internal Behavior
The Chrome MCP Server probably:
1. Launches a browser with `--remote-debugging-port` (or connects to existing)
2. Queries `http://localhost:9222/json` for available targets
3. Opens WebSocket connection to specific pages
4. Sends CDP commands over WebSocket
5. Returns results through MCP protocol

### Environment Variables (Potential)
```bash
CHROME_EXECUTABLE_PATH=/path/to/chrome
CHROME_REMOTE_PORT=9222
CHROME_HEADLESS=false
```

---

## Edge-Specific Notes

### Edge Locations
**Windows:**
- `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`
- `C:\Program Files\Microsoft\Edge\Application\msedge.exe`

**macOS:**
- `/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge`

**Linux:**
- `/usr/bin/microsoft-edge`

### Edge DevTools
Edge DevTools are identical to Chrome DevTools, so all debugging features work the same.

### Edge Extensions
Edge supports Chrome extensions, so debugging extension behavior works identically.

---

## Testing the Setup

### Quick Test Script (PowerShell)
```powershell
# Launch Edge with debugging
Start-Process "msedge.exe" -ArgumentList @(
    "--remote-debugging-port=9222",
    "--user-data-dir=C:\temp\edge-debug",
    "https://example.com"
)

# Wait a moment
Start-Sleep -Seconds 3

# Check connection
$targets = Invoke-RestMethod -Uri "http://localhost:9222/json"
Write-Host "Connected to $($targets.Count) targets"
$targets | ForEach-Object {
    Write-Host "  - $($_.title): $($_.url)"
}
```

---

## Summary

### ✅ **Yes, You Can Attach to Existing Sessions**
- Browser must be launched with `--remote-debugging-port`
- Cannot attach to regularly-launched browsers
- Use dedicated profile for isolation

### ✅ **Yes, Edge is Fully Supported**
- Same Chromium engine as Chrome
- Same DevTools Protocol
- Same debugging capabilities
- Just use `msedge.exe` instead of `chrome.exe`

### 🔧 **Recommended Setup**
```bash
# Development/Testing
msedge.exe --remote-debugging-port=9222 --user-data-dir="C:\temp\edge-debug"

# Production Automation (Headless)
msedge.exe --remote-debugging-port=9222 --headless=new --user-data-dir="C:\temp\edge-headless"
```

### 📚 **Resources**
- **Chrome DevTools Protocol**: https://chromedevtools.github.io/devtools-protocol/
- **Edge DevTools**: https://docs.microsoft.com/en-us/microsoft-edge/devtools-guide-chromium/
- **Remote Debugging**: https://developer.chrome.com/blog/devtools-tips-25/

---

**Status**: ✅ **Confirmed - Edge & Session Attachment Supported**  
**Method**: Chrome DevTools Protocol with remote debugging port  
**Limitation**: Browser must be launched with debugging enabled  

Would you like help setting up Edge with remote debugging for your specific use case?
