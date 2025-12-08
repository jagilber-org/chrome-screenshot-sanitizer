# Chrome MCP Debugging & Troubleshooting Quick Reference

**Purpose**: Essential patterns for using Chrome MCP Server for tracing, debugging, troubleshooting, and console access  
**Last Updated**: October 11, 2025  
**Status**: ✅ Production Ready

---

## Quick Access: Console Debugging

### Get Console Messages (Errors, Warnings, Logs)
```json
{
  "tool": "mcp_chrome-devtoo_list_console_messages"
}
```

**Returns**: All console.log, console.error, console.warn, console.info since last navigation

**Example Output**:
```json
{
  "messages": [
    {
      "level": "error",
      "text": "Uncaught TypeError: Cannot read property 'x' of undefined",
      "url": "https://app.com/script.js",
      "line": 42,
      "timestamp": 1234567890
    },
    {
      "level": "warn",
      "text": "API deprecation warning",
      "timestamp": 1234567891
    }
  ]
}
```

---

## Quick Access: Network Tracing

### List All Network Requests
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests"
}
```

### Filter Failed Requests Only
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests",
  "parameters": {
    "resourceTypes": ["xhr", "fetch", "document"]
  }
}
```

**Then filter for status >= 400 in results**

### Get Specific Request Details
```json
{
  "tool": "mcp_chrome-devtoo_get_network_request",
  "parameters": {
    "url": "https://api.example.com/endpoint"
  }
}
```

**Returns**: Headers, body, timing, status code

---

## Quick Access: Performance Tracing

### Start Performance Trace with Page Reload
```json
{
  "tool": "mcp_chrome-devtoo_performance_start_trace",
  "parameters": {
    "reload": true,
    "autoStop": true
  }
}
```

### Stop and Get Results
```json
{
  "tool": "mcp_chrome-devtoo_performance_stop_trace"
}
```

**Returns**: Core Web Vitals (LCP, FCP, CLS), timing breakdown, performance insights

### Analyze Specific Insight
```json
{
  "tool": "mcp_chrome-devtoo_performance_analyze_insight",
  "parameters": {
    "insightName": "LCPBreakdown"
  }
}
```

**Common Insights**:
- `LCPBreakdown` - Largest Contentful Paint analysis
- `DocumentLatency` - Document load timing
- `RenderBlocking` - Blocking resources

---

## Debugging Workflows

### Workflow 1: JavaScript Error Investigation

```javascript
// 1. Navigate to problem page
await navigate_page("https://app.com/broken-page");

// 2. Get console errors
const messages = await list_console_messages();
const errors = messages.filter(m => m.level === "error");

// 3. Analyze errors
errors.forEach(error => {
  console.log(`Error: ${error.text}`);
  console.log(`Location: ${error.url}:${error.line}`);
  console.log(`Time: ${new Date(error.timestamp)}`);
});

// 4. Execute diagnostic script
const debugInfo = await evaluate_script(`
  () => {
    return {
      globals: Object.keys(window),
      documentReady: document.readyState,
      errors: window.lastError || null
    };
  }
`);
```

### Workflow 2: Network Debugging

```javascript
// 1. Navigate to page
await navigate_page("https://app.com");

// 2. Trigger action that causes network issue
await click("btn-load-data");

// 3. Wait briefly for requests
await new Promise(resolve => setTimeout(resolve, 2000));

// 4. Get all requests
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});

// 5. Find failed requests
const failures = requests.filter(r => r.status >= 400);

// 6. Inspect each failure
for (const failure of failures) {
  const details = await get_network_request({url: failure.url});
  console.log(`Failed: ${failure.method} ${failure.url}`);
  console.log(`Status: ${failure.status}`);
  console.log(`Response: ${details.responseBody}`);
}
```

### Workflow 3: Performance Issue Diagnosis

```javascript
// 1. Start trace with reload
await performance_start_trace({reload: true, autoStop: true});

// 2. Wait for trace to complete (auto-stops)
await new Promise(resolve => setTimeout(resolve, 5000));

// 3. Get results
const trace = await performance_stop_trace();

// 4. Analyze metrics
console.log(`LCP: ${trace.metrics.LCP}ms`);
console.log(`FCP: ${trace.metrics.FCP}ms`);
console.log(`CLS: ${trace.metrics.CLS}`);

// 5. Get detailed insights
const lcpDetails = await performance_analyze_insight({
  insightName: "LCPBreakdown"
});

// 6. Identify slow resources
const requests = await list_network_requests();
const slowRequests = requests
  .filter(r => r.timing?.duration > 1000)
  .sort((a, b) => b.timing.duration - a.timing.duration);

console.log("Slowest requests:");
slowRequests.slice(0, 5).forEach(r => {
  console.log(`${r.url}: ${r.timing.duration}ms`);
});
```

### Workflow 4: Authentication/Session Debugging

```javascript
// 1. Navigate to login
await navigate_page("https://app.com/login");

// 2. Check initial state
const preAuth = await evaluate_script(`
  () => ({
    cookies: document.cookie,
    localStorage: Object.keys(localStorage),
    sessionStorage: Object.keys(sessionStorage)
  })
`);

// 3. Perform login
await fill_form([
  {uid: "email", value: "test@example.com"},
  {uid: "password", value: "test123"}
]);
await click("btn-login");

// 4. Wait for redirect
await wait_for("Dashboard", 5000);

// 5. Check auth request
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});
const authRequest = requests.find(r => r.url.includes("/auth"));

// 6. Verify auth response
const authDetails = await get_network_request({url: authRequest.url});
console.log("Auth response:", authDetails.responseBody);

// 7. Check post-auth state
const postAuth = await evaluate_script(`
  () => ({
    cookies: document.cookie,
    localStorage: localStorage.getItem("token"),
    sessionStorage: sessionStorage.getItem("session")
  })
`);

// 8. Compare states
console.log("Before auth:", preAuth);
console.log("After auth:", postAuth);
```

---

## Troubleshooting Patterns

### Pattern 1: Element Not Found
```javascript
// Take snapshot to inspect page
const snapshot = await take_snapshot();
console.log(snapshot); // Review structure

// Check if element exists
const exists = await evaluate_script(`
  () => !!document.querySelector('#my-element')
`);

// Wait for dynamic content
if (!exists) {
  await wait_for("Expected text", 5000);
  // Re-snapshot after load
  const newSnapshot = await take_snapshot();
}
```

### Pattern 2: Intermittent Failures
```javascript
// 1. Monitor console for timing issues
const messages = await list_console_messages();
const timeouts = messages.filter(m => 
  m.text.includes("timeout") || m.text.includes("race")
);

// 2. Check network timing
const requests = await list_network_requests();
const timings = requests.map(r => ({
  url: r.url,
  duration: r.timing?.duration,
  start: r.timing?.startTime
}));

// 3. Look for timing conflicts
console.log("Request timing analysis:", timings);
```

### Pattern 3: Memory Leaks
```javascript
// 1. Start with performance trace
await performance_start_trace({reload: false, autoStop: false});

// 2. Perform suspected leak operation multiple times
for (let i = 0; i < 10; i++) {
  await click("btn-create-widgets");
  await new Promise(resolve => setTimeout(resolve, 500));
}

// 3. Stop trace and analyze
await performance_stop_trace();

// 4. Check memory via script
const memoryInfo = await evaluate_script(`
  () => ({
    jsHeapSize: performance.memory?.usedJSHeapSize,
    totalHeapSize: performance.memory?.totalJSHeapSize,
    heapLimit: performance.memory?.jsHeapSizeLimit
  })
`);
```

### Pattern 4: CORS Issues
```javascript
// 1. Navigate and trigger cross-origin request
await navigate_page("https://app.com");
await click("btn-load-external-data");

// 2. Check console for CORS errors
const messages = await list_console_messages();
const corsErrors = messages.filter(m => 
  m.level === "error" && m.text.includes("CORS")
);

// 3. Check network request details
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});

for (const req of requests) {
  const details = await get_network_request({url: req.url});
  console.log(`Request: ${req.url}`);
  console.log(`Origin header: ${details.requestHeaders.origin}`);
  console.log(`CORS header: ${details.headers["access-control-allow-origin"]}`);
}
```

---

## Advanced Debugging Techniques

### Technique 1: Inject Debug Logger
```javascript
// Inject custom logging
await evaluate_script(`
  () => {
    window.debugLog = [];
    const originalLog = console.log;
    console.log = function(...args) {
      window.debugLog.push({
        time: Date.now(),
        args: args
      });
      originalLog.apply(console, args);
    };
  }
`);

// Perform actions...
await click("btn-action");

// Retrieve debug log
const debugLogs = await evaluate_script(`
  () => window.debugLog
`);
```

### Technique 2: Monitor Specific Events
```javascript
// Set up event monitoring
await evaluate_script(`
  () => {
    window.eventLog = [];
    ['click', 'change', 'submit', 'error'].forEach(eventType => {
      document.addEventListener(eventType, (e) => {
        window.eventLog.push({
          type: eventType,
          target: e.target.tagName + '#' + e.target.id,
          time: Date.now()
        });
      }, true);
    });
  }
`);

// Perform actions...

// Get event log
const events = await evaluate_script(`
  () => window.eventLog
`);
```

### Technique 3: Track API Call Stack
```javascript
// Override fetch/XHR to capture stack traces
await evaluate_script(`
  () => {
    window.apiCalls = [];
    const originalFetch = window.fetch;
    window.fetch = function(...args) {
      window.apiCalls.push({
        url: args[0],
        stack: new Error().stack,
        time: Date.now()
      });
      return originalFetch.apply(this, args);
    };
  }
`);

// Later retrieve call stack
const apiCalls = await evaluate_script(`
  () => window.apiCalls
`);
```

---

## Console Access Patterns

### Pattern 1: Real-time Console Monitoring
```javascript
// Continuous monitoring loop
async function monitorConsole(durationMs = 10000) {
  const startTime = Date.now();
  const allMessages = [];
  
  while (Date.now() - startTime < durationMs) {
    const messages = await list_console_messages();
    const newMessages = messages.filter(m => 
      !allMessages.find(existing => 
        existing.text === m.text && existing.timestamp === m.timestamp
      )
    );
    
    allMessages.push(...newMessages);
    
    // Report new errors immediately
    newMessages
      .filter(m => m.level === "error")
      .forEach(error => console.error("NEW ERROR:", error.text));
    
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  return allMessages;
}
```

### Pattern 2: Execute Console Commands
```javascript
// Run any JavaScript as if in console
const result = await evaluate_script(`
  () => {
    // Any console command here
    return Array.from(document.querySelectorAll('div'))
      .map(div => ({
        id: div.id,
        classes: div.className,
        text: div.textContent.substring(0, 50)
      }));
  }
`);
```

### Pattern 3: Debug Variable Inspection
```javascript
// Inspect global state
const appState = await evaluate_script(`
  () => ({
    // Common framework state objects
    reactState: window.__REACT_DEVTOOLS_GLOBAL_HOOK__ ? "detected" : "not found",
    vueState: window.__VUE_DEVTOOLS_GLOBAL_HOOK__ ? "detected" : "not found",
    angularState: window.ng ? "detected" : "not found",
    
    // Custom app state (adjust to your app)
    appData: window.app?.data,
    userState: window.currentUser,
    
    // General info
    location: window.location.href,
    timing: performance.timing,
    errors: window.errors || []
  })
`);
```

---

## Emulation for Testing Edge Cases

### Network Condition Testing
```json
// Test offline behavior
{"tool": "mcp_chrome-devtoo_emulate_network", "parameters": {"throttlingOption": "Offline"}}

// Test slow connection
{"tool": "mcp_chrome-devtoo_emulate_network", "parameters": {"throttlingOption": "Slow 3G"}}

// Reset to normal
{"tool": "mcp_chrome-devtoo_emulate_network", "parameters": {"throttlingOption": "No emulation"}}
```

### CPU Throttling for Performance Issues
```json
// Simulate slow device
{"tool": "mcp_chrome-devtoo_emulate_cpu", "parameters": {"throttlingRate": 4}}

// Reset
{"tool": "mcp_chrome-devtoo_emulate_cpu", "parameters": {"throttlingRate": 1}}
```

### Mobile Viewport Testing
```json
// iPhone 12 Pro
{"tool": "mcp_chrome-devtoo_resize_page", "parameters": {"width": 390, "height": 844}}

// iPad
{"tool": "mcp_chrome-devtoo_resize_page", "parameters": {"width": 768, "height": 1024}}

// Desktop
{"tool": "mcp_chrome-devtoo_resize_page", "parameters": {"width": 1920, "height": 1080}}
```

---

## Complete Debugging Session Example

```javascript
async function debugPageIssue(url) {
  console.log("=== Starting Debug Session ===");
  
  // 1. Navigate to page
  console.log("1. Navigating to page...");
  await navigate_page(url);
  
  // 2. Check console immediately
  console.log("2. Checking console messages...");
  const messages = await list_console_messages();
  const errors = messages.filter(m => m.level === "error");
  const warnings = messages.filter(m => m.level === "warn");
  
  console.log(`Found ${errors.length} errors, ${warnings.length} warnings`);
  errors.forEach(e => console.error(`  ERROR: ${e.text}`));
  
  // 3. Check network requests
  console.log("3. Checking network requests...");
  const requests = await list_network_requests();
  const failed = requests.filter(r => r.status >= 400);
  
  console.log(`Found ${failed.length} failed requests`);
  for (const req of failed) {
    console.error(`  FAILED: ${req.method} ${req.url} - ${req.status}`);
  }
  
  // 4. Performance analysis
  console.log("4. Running performance trace...");
  await performance_start_trace({reload: true, autoStop: true});
  await new Promise(resolve => setTimeout(resolve, 5000));
  const trace = await performance_stop_trace();
  
  console.log(`Performance metrics:`);
  console.log(`  LCP: ${trace.metrics?.LCP}ms`);
  console.log(`  FCP: ${trace.metrics?.FCP}ms`);
  console.log(`  CLS: ${trace.metrics?.CLS}`);
  
  // 5. Check page state
  console.log("5. Inspecting page state...");
  const pageState = await evaluate_script(`
    () => ({
      title: document.title,
      readyState: document.readyState,
      elementCount: document.querySelectorAll('*').length,
      scriptCount: document.scripts.length,
      hasErrors: !!window.lastError
    })
  `);
  
  console.log("Page state:", pageState);
  
  // 6. Take snapshot for inspection
  console.log("6. Taking snapshot...");
  const snapshot = await take_snapshot();
  
  // 7. Generate report
  return {
    url,
    timestamp: new Date().toISOString(),
    errors,
    warnings,
    failedRequests: failed,
    performance: trace.metrics,
    pageState,
    snapshot
  };
}

// Usage
const report = await debugPageIssue("https://app.com/problem-page");
console.log("Debug report:", JSON.stringify(report, null, 2));
```

---

## Quick Reference: Tool Names

### Console & Debugging
- `mcp_chrome-devtoo_list_console_messages` - Get all console output
- `mcp_chrome-devtoo_evaluate_script` - Execute JavaScript

### Network Tracing
- `mcp_chrome-devtoo_list_network_requests` - All requests
- `mcp_chrome-devtoo_get_network_request` - Specific request details

### Performance
- `mcp_chrome-devtoo_performance_start_trace` - Begin recording
- `mcp_chrome-devtoo_performance_stop_trace` - Stop and analyze
- `mcp_chrome-devtoo_performance_analyze_insight` - Detailed metrics

### Emulation
- `mcp_chrome-devtoo_emulate_network` - Network conditions
- `mcp_chrome-devtoo_emulate_cpu` - CPU throttling
- `mcp_chrome-devtoo_resize_page` - Viewport size

### Inspection
- `mcp_chrome-devtoo_take_snapshot` - Page structure
- `mcp_chrome-devtoo_take_screenshot` - Visual capture

---

## Best Practices for Debugging

1. **Check Console First** - Always start with `list_console_messages`
2. **Monitor Network** - Use `list_network_requests` to find API failures
3. **Use Performance Traces** - Identify slow operations with tracing
4. **Execute Diagnostic Scripts** - Use `evaluate_script` for deep inspection
5. **Emulate Conditions** - Test edge cases with throttling
6. **Save Evidence** - Take screenshots and snapshots for documentation

---

**Related Documentation**:
- [Chrome MCP Server Reference](../CHROME-MCP-SERVER-REFERENCE.md)
- [Chrome MCP Examples](../../examples/chrome-mcp-examples/)
- [Session Log](../sessions/2025-10-11-chrome-mcp-server-learning.md)
