# Chrome MCP Example 4: Real-World Debugging Session

## Scenario
Troubleshoot a web application with intermittent failures and performance issues.

## Problem Statement
Users report:
- Occasional "Failed to load data" errors
- Slow page load times
- Form submissions that sometimes fail
- Console errors that don't always appear

## Step-by-Step Debugging Process

### Phase 1: Initial Assessment

#### Step 1: Navigate and Check Console
```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://problem-app.com"
  }
}
```

#### Step 2: Immediate Console Check
```json
{
  "tool": "mcp_chrome-devtoo_list_console_messages"
}
```

**What to look for:**
- JavaScript errors (level: "error")
- Deprecation warnings
- Failed resource loads
- Custom application errors

**Example Analysis:**
```javascript
const messages = /* console messages result */;

// Categorize issues
const errors = messages.filter(m => m.level === "error");
const warnings = messages.filter(m => m.level === "warn");

console.log(`Critical errors: ${errors.length}`);
console.log(`Warnings: ${warnings.length}`);

// Most common errors
const errorCounts = {};
errors.forEach(e => {
  const key = e.text.substring(0, 50);
  errorCounts[key] = (errorCounts[key] || 0) + 1;
});
```

### Phase 2: Network Investigation

#### Step 3: Check Network Requests
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests",
  "parameters": {
    "resourceTypes": ["xhr", "fetch", "document"]
  }
}
```

#### Step 4: Identify Failed Requests
```javascript
const requests = /* network requests result */;

// Find failures
const failures = requests.filter(r => r.status >= 400);

console.log(`Failed requests: ${failures.length}`);
failures.forEach(f => {
  console.log(`${f.method} ${f.url}: ${f.status} ${f.statusText}`);
});

// Find slow requests
const slow = requests.filter(r => r.timing?.duration > 2000);
console.log(`Slow requests (>2s): ${slow.length}`);
```

#### Step 5: Inspect Failed Request Details
```json
{
  "tool": "mcp_chrome-devtoo_get_network_request",
  "parameters": {
    "url": "https://api.problem-app.com/data"
  }
}
```

**Analyze the response:**
```javascript
const requestDetails = /* get_network_request result */;

console.log("Request headers:", requestDetails.requestHeaders);
console.log("Response headers:", requestDetails.headers);
console.log("Response body:", requestDetails.responseBody);
console.log("Timing:", requestDetails.timing);

// Check for common issues
if (!requestDetails.requestHeaders.authorization) {
  console.error("Missing authorization header!");
}

if (requestDetails.status === 401 || requestDetails.status === 403) {
  console.error("Authentication/Authorization issue");
}

if (requestDetails.status === 504 || requestDetails.status === 408) {
  console.error("Timeout issue");
}
```

### Phase 3: Reproduce the Issue

#### Step 6: Trigger the Problem Action
```json
{
  "tool": "mcp_chrome-devtoo_take_snapshot"
}
```

Get the button UID, then:

```json
{
  "tool": "mcp_chrome-devtoo_click",
  "parameters": {
    "uid": "btn-load-data"
  }
}
```

#### Step 7: Monitor During Action
Wait a moment, then:

```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests",
  "parameters": {
    "resourceTypes": ["xhr", "fetch"]
  }
}
```

```json
{
  "tool": "mcp_chrome-devtoo_list_console_messages"
}
```

### Phase 4: Performance Analysis

#### Step 8: Run Performance Trace
```json
{
  "tool": "mcp_chrome-devtoo_performance_start_trace",
  "parameters": {
    "reload": true,
    "autoStop": true
  }
}
```

Wait 5-10 seconds for auto-stop, then:

```json
{
  "tool": "mcp_chrome-devtoo_performance_stop_trace"
}
```

**Analyze Results:**
```javascript
const trace = /* performance trace result */;

console.log("Core Web Vitals:");
console.log(`  LCP: ${trace.metrics?.LCP}ms (target: <2500ms)`);
console.log(`  FCP: ${trace.metrics?.FCP}ms (target: <1800ms)`);
console.log(`  CLS: ${trace.metrics?.CLS} (target: <0.1)`);

// Performance classification
if (trace.metrics?.LCP > 4000) {
  console.error("CRITICAL: Poor LCP - page load is very slow");
} else if (trace.metrics?.LCP > 2500) {
  console.warn("WARNING: LCP needs improvement");
}
```

#### Step 9: Detailed Performance Insight
```json
{
  "tool": "mcp_chrome-devtoo_performance_analyze_insight",
  "parameters": {
    "insightName": "LCPBreakdown"
  }
}
```

### Phase 5: Deep Inspection

#### Step 10: Check Application State
```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "() => { return { appState: window.app?.state, userData: window.currentUser, config: window.config, errors: window.errorLog || [] }; }"
  }
}
```

#### Step 11: Inject Monitoring
```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "() => { window.debugTrace = []; const origFetch = window.fetch; window.fetch = function(...args) { window.debugTrace.push({ type: 'fetch', url: args[0], time: Date.now() }); return origFetch.apply(this, args); }; }"
  }
}
```

#### Step 12: Trigger Action Again
Click button again, wait, then:

```json
{
  "tool": "mcp_chrome-devtoo_evaluate_script",
  "parameters": {
    "function": "() => { return window.debugTrace; }"
  }
}
```

### Phase 6: Edge Case Testing

#### Step 13: Test Offline Behavior
```json
{
  "tool": "mcp_chrome-devtoo_emulate_network",
  "parameters": {
    "throttlingOption": "Offline"
  }
}
```

Click button, observe behavior:

```json
{
  "tool": "mcp_chrome-devtoo_list_console_messages"
}
```

Reset network:

```json
{
  "tool": "mcp_chrome-devtoo_emulate_network",
  "parameters": {
    "throttlingOption": "No emulation"
  }
}
```

#### Step 14: Test Slow Connection
```json
{
  "tool": "mcp_chrome-devtoo_emulate_network",
  "parameters": {
    "throttlingOption": "Slow 3G"
  }
}
```

Reload and observe:

```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://problem-app.com"
  }
}
```

Check timing:

```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests"
}
```

#### Step 15: Test CPU Throttling
```json
{
  "tool": "mcp_chrome-devtoo_emulate_cpu",
  "parameters": {
    "throttlingRate": 4
  }
}
```

Perform actions and observe performance.

### Phase 7: Documentation

#### Step 16: Take Evidence Screenshot
```json
{
  "tool": "mcp_chrome-devtoo_take_screenshot",
  "parameters": {
    "fullPage": true,
    "format": "png",
    "filePath": "c:\\github\\jagilber\\mcp-pr\\logs\\debug-evidence.png"
  }
}
```

#### Step 17: Capture Final State
```json
{
  "tool": "mcp_chrome-devtoo_take_snapshot"
}
```

## Complete Automated Debugging Script

```javascript
async function comprehensiveDebug(url) {
  const report = {
    url,
    timestamp: new Date().toISOString(),
    findings: []
  };
  
  // 1. Initial load
  console.log("Phase 1: Initial Assessment");
  await navigate_page(url);
  
  const messages = await list_console_messages();
  const errors = messages.filter(m => m.level === "error");
  const warnings = messages.filter(m => m.level === "warn");
  
  report.findings.push({
    phase: "Console Check",
    errors: errors.length,
    warnings: warnings.length,
    details: errors.slice(0, 5) // First 5 errors
  });
  
  // 2. Network check
  console.log("Phase 2: Network Investigation");
  const requests = await list_network_requests();
  const failed = requests.filter(r => r.status >= 400);
  const slow = requests.filter(r => r.timing?.duration > 2000);
  
  report.findings.push({
    phase: "Network Analysis",
    totalRequests: requests.length,
    failedRequests: failed.length,
    slowRequests: slow.length,
    failures: failed.map(f => ({
      url: f.url,
      status: f.status,
      method: f.method
    }))
  });
  
  // 3. Performance trace
  console.log("Phase 3: Performance Analysis");
  await performance_start_trace({reload: true, autoStop: true});
  await new Promise(resolve => setTimeout(resolve, 5000));
  const trace = await performance_stop_trace();
  
  report.findings.push({
    phase: "Performance",
    metrics: trace.metrics,
    verdict: trace.metrics?.LCP > 2500 ? "NEEDS IMPROVEMENT" : "GOOD"
  });
  
  // 4. Application state
  console.log("Phase 4: Application State");
  const appState = await evaluate_script(`
    () => ({
      ready: document.readyState,
      errors: window.errors || [],
      performance: {
        navigation: performance.navigation.type,
        timing: {
          loadComplete: performance.timing.loadEventEnd - performance.timing.navigationStart,
          domReady: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart
        }
      }
    })
  `);
  
  report.findings.push({
    phase: "Application State",
    state: appState
  });
  
  // 5. Offline test
  console.log("Phase 5: Edge Case Testing");
  await emulate_network({throttlingOption: "Offline"});
  
  // Try to click action button (will fail)
  try {
    const snapshot = await take_snapshot();
    // Assuming we know button UID
    await click("btn-action");
  } catch (e) {
    // Expected to fail
  }
  
  const offlineMessages = await list_console_messages();
  const offlineErrors = offlineMessages.filter(m => 
    m.level === "error" && m.timestamp > Date.now() - 5000
  );
  
  report.findings.push({
    phase: "Offline Behavior",
    newErrors: offlineErrors.length,
    hasErrorHandling: offlineErrors.some(e => 
      e.text.includes("network") || e.text.includes("offline")
    )
  });
  
  // Reset
  await emulate_network({throttlingOption: "No emulation"});
  
  // 6. Generate report
  console.log("=== DEBUG REPORT ===");
  console.log(JSON.stringify(report, null, 2));
  
  return report;
}

// Usage
const report = await comprehensiveDebug("https://problem-app.com");

// Analyze report
if (report.findings.some(f => f.errors > 0 || f.failedRequests > 0)) {
  console.error("ISSUES FOUND - Review report");
} else {
  console.log("No critical issues detected");
}
```

## Common Issues and Solutions

### Issue 1: Intermittent API Failures
**Symptoms:**
- Status 500/502/503 errors
- Timeouts
- Inconsistent response times

**Debug Steps:**
1. Check network request timing variation
2. Monitor console for race conditions
3. Test with slow connection emulation
4. Check for retry logic in code

**Solution Pattern:**
```javascript
// Check if retries are happening
const apiRequests = requests.filter(r => r.url.includes("/api/"));
const duplicateUrls = apiRequests.filter((r, i, arr) => 
  arr.findIndex(x => x.url === r.url) !== i
);

if (duplicateUrls.length > 0) {
  console.log("Detected retry attempts");
}
```

### Issue 2: Performance Degradation
**Symptoms:**
- Slow page loads (LCP > 4000ms)
- High CLS (> 0.25)
- Unresponsive UI

**Debug Steps:**
1. Run performance trace
2. Check for large resources
3. Test with CPU throttling
4. Monitor memory usage

**Solution Pattern:**
```javascript
// Find performance bottlenecks
const trace = await performance_stop_trace();
const insight = await performance_analyze_insight({
  insightName: "LCPBreakdown"
});

// Check for blocking resources
const requests = await list_network_requests();
const largeResources = requests.filter(r => 
  r.resourceType === "script" && r.timing?.duration > 1000
);
```

### Issue 3: Authentication Failures
**Symptoms:**
- 401/403 errors
- Lost sessions
- Redirect loops

**Debug Steps:**
1. Check localStorage/sessionStorage
2. Monitor auth-related network requests
3. Verify token refresh logic
4. Check cookie settings

**Solution Pattern:**
```javascript
// Check auth state before/after
const authState = await evaluate_script(`
  () => ({
    localStorage: localStorage.getItem("token"),
    cookies: document.cookie,
    sessionStorage: sessionStorage.getItem("session")
  })
`);

// Monitor auth requests
const authRequests = requests.filter(r => 
  r.url.includes("/auth") || r.url.includes("/token")
);
```

## Debugging Checklist

- [ ] Check console for JavaScript errors
- [ ] Monitor network requests for failures
- [ ] Run performance trace
- [ ] Test with slow network conditions
- [ ] Test with CPU throttling
- [ ] Test offline behavior
- [ ] Check application state
- [ ] Monitor memory usage
- [ ] Verify authentication flow
- [ ] Take screenshots for evidence
- [ ] Document findings

## Next Steps

After debugging:
1. Document root cause
2. Create bug report with evidence
3. Test fix with same workflow
4. Verify performance improvements
5. Add monitoring for future detection

---

**Related Examples:**
- [01-basic-navigation-snapshot.md](01-basic-navigation-snapshot.md)
- [02-form-interaction.md](02-form-interaction.md)
- [03-network-monitoring.md](03-network-monitoring.md)
- [Chrome MCP Debugging Quick Reference](../docs/quick-reference/CHROME-MCP-DEBUGGING-QUICK-REFERENCE.md)
