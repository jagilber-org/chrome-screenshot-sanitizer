# Chrome MCP Example 3: Network Request Monitoring and API Testing

## Objective
Monitor network requests, inspect API calls, and validate responses using Chrome MCP Server.

## Use Cases
- API endpoint testing
- Performance analysis
- Debugging AJAX calls
- Validating data payloads

## Basic Network Monitoring

### Step 1: Navigate to Page
```json
{
  "tool": "mcp_chrome-devtoo_navigate_page",
  "parameters": {
    "url": "https://api-demo.example.com"
  }
}
```

### Step 2: Trigger Actions That Generate Requests
```json
{
  "tool": "mcp_chrome-devtoo_click",
  "parameters": {
    "uid": "btn-load-data"
  }
}
```

### Step 3: List All Network Requests
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests"
}
```

**Example Output:**
```json
{
  "requests": [
    {
      "url": "https://api.example.com/users",
      "method": "GET",
      "status": 200,
      "resourceType": "xhr",
      "timing": { "duration": 145 }
    },
    {
      "url": "https://api.example.com/data",
      "method": "POST",
      "status": 201,
      "resourceType": "fetch"
    }
  ]
}
```

## Filtering Network Requests

### Filter by Resource Type
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests",
  "parameters": {
    "resourceTypes": ["xhr", "fetch"]
  }
}
```

### Paginate Large Result Sets
```json
{
  "tool": "mcp_chrome-devtoo_list_network_requests",
  "parameters": {
    "pageSize": 10,
    "pageIdx": 0,
    "resourceTypes": ["document", "xhr", "fetch"]
  }
}
```

## Inspecting Specific Requests

### Get Request Details by URL
```json
{
  "tool": "mcp_chrome-devtoo_get_network_request",
  "parameters": {
    "url": "https://api.example.com/users"
  }
}
```

**Detailed Response:**
```json
{
  "url": "https://api.example.com/users",
  "method": "GET",
  "status": 200,
  "statusText": "OK",
  "headers": {
    "content-type": "application/json",
    "cache-control": "no-cache"
  },
  "requestHeaders": {
    "authorization": "Bearer token123"
  },
  "responseBody": "[{\"id\":1,\"name\":\"John\"}]",
  "timing": {
    "startTime": 1234567890,
    "duration": 145,
    "responseTime": 120
  }
}
```

## API Testing Workflows

### Test 1: Verify API Endpoint Called
```javascript
// 1. Navigate to app
await navigate_page("https://myapp.com");

// 2. Trigger action
await click("btn-fetch-users");

// 3. Verify request made
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});

// 4. Find specific request
const userRequest = requests.find(r => 
  r.url.includes("/api/users")
);

// 5. Assert request was made
console.assert(userRequest !== undefined, "User API not called");
```

### Test 2: Validate Response Status
```javascript
// Get request details
const request = await get_network_request({
  url: "https://api.example.com/data"
});

// Validate status
console.assert(request.status === 200, "Expected 200 OK");
console.assert(request.method === "POST", "Expected POST method");
```

### Test 3: Inspect Response Payload
```javascript
// Get request
const request = await get_network_request({
  url: "https://api.example.com/users"
});

// Parse response
const data = JSON.parse(request.responseBody);

// Validate structure
console.assert(Array.isArray(data), "Expected array response");
console.assert(data.length > 0, "Expected non-empty results");
console.assert(data[0].hasOwnProperty("id"), "Expected id field");
```

### Test 4: Check Request Headers
```javascript
const request = await get_network_request({
  url: "https://api.example.com/protected"
});

// Verify auth header sent
const hasAuth = request.requestHeaders.hasOwnProperty("authorization");
console.assert(hasAuth, "Auth header missing");

// Verify content type
console.assert(
  request.headers["content-type"] === "application/json",
  "Unexpected content type"
);
```

## Performance Analysis

### Analyze Request Timing
```javascript
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});

// Find slow requests
const slowRequests = requests.filter(r => r.timing.duration > 500);

console.log(`Found ${slowRequests.length} slow requests:`);
slowRequests.forEach(r => {
  console.log(`${r.url}: ${r.timing.duration}ms`);
});
```

### Calculate Total Load Time
```javascript
const requests = await list_network_requests();

const totalTime = requests.reduce((sum, r) => {
  return sum + (r.timing?.duration || 0);
}, 0);

console.log(`Total request time: ${totalTime}ms`);
```

## Advanced Patterns

### Pattern 1: Wait and Verify Request
```javascript
// Navigate
await navigate_page("https://myapp.com");

// Trigger action
await click("btn-load");

// Wait for content to appear
await wait_for("Data loaded", 3000);

// Verify API was called
const requests = await list_network_requests({
  resourceTypes: ["fetch"]
});

const apiCalled = requests.some(r => r.url.includes("/api/data"));
console.assert(apiCalled, "Expected API call");
```

### Pattern 2: Sequence Validation
```javascript
// Get all XHR/Fetch requests
const requests = await list_network_requests({
  resourceTypes: ["xhr", "fetch"]
});

// Sort by start time
const sorted = requests.sort((a, b) => 
  a.timing.startTime - b.timing.startTime
);

// Verify sequence
console.assert(
  sorted[0].url.includes("/auth"),
  "First request should be auth"
);
console.assert(
  sorted[1].url.includes("/data"),
  "Second request should be data"
);
```

### Pattern 3: Error Detection
```javascript
const requests = await list_network_requests();

// Find failed requests
const failures = requests.filter(r => 
  r.status >= 400 && r.status < 600
);

if (failures.length > 0) {
  console.error("Failed requests detected:");
  failures.forEach(r => {
    console.error(`${r.method} ${r.url}: ${r.status} ${r.statusText}`);
  });
}
```

## Integration with Console Monitoring

### Correlate Network and Console Errors
```javascript
// Get network failures
const requests = await list_network_requests();
const failures = requests.filter(r => r.status >= 400);

// Get console errors
const messages = await list_console_messages();
const errors = messages.filter(m => m.level === "error");

// Report correlation
console.log(`Network failures: ${failures.length}`);
console.log(`Console errors: ${errors.length}`);
```

## Common Network Testing Scenarios

### Scenario 1: Login Flow Validation
```javascript
// 1. Navigate to login
await navigate_page("https://app.com/login");

// 2. Fill and submit
await fill_form([
  {uid: "email", value: "test@example.com"},
  {uid: "password", value: "password"}
]);
await click("btn-submit");

// 3. Verify auth request
const requests = await list_network_requests({resourceTypes: ["xhr"]});
const authRequest = requests.find(r => r.url.includes("/auth/login"));

console.assert(authRequest.status === 200, "Login failed");
console.assert(
  authRequest.responseBody.includes("token"),
  "No token in response"
);
```

### Scenario 2: Data Submission Verification
```javascript
// Submit form
await fill_form([{uid: "name", value: "Test User"}]);
await click("btn-save");

// Wait for success
await wait_for("Saved successfully");

// Verify POST request
const requests = await list_network_requests({resourceTypes: ["fetch"]});
const postRequest = requests.find(r => 
  r.method === "POST" && r.url.includes("/api/save")
);

console.assert(postRequest !== undefined, "Save request not found");
console.assert(postRequest.status === 201, "Save failed");
```

### Scenario 3: Polling Detection
```javascript
// Trigger polling
await click("btn-start-updates");

// Wait a few seconds
await new Promise(resolve => setTimeout(resolve, 5000));

// Check for repeated requests
const requests = await list_network_requests({resourceTypes: ["xhr"]});
const pollingRequests = requests.filter(r => r.url.includes("/status"));

console.log(`Detected ${pollingRequests.length} polling requests`);
console.assert(pollingRequests.length >= 3, "Polling not working");
```

## Troubleshooting

**Issue**: Request list is empty
- **Cause**: Network logs cleared on navigation
- **Solution**: List requests before navigating away

**Issue**: Can't find specific request
- **Cause**: Request completed before monitoring started
- **Solution**: Start monitoring before triggering action

**Issue**: Response body is empty
- **Cause**: Some responses are not captured
- **Solution**: Use `evaluate_script` to access response via JavaScript

**Issue**: Too many requests returned
- **Cause**: Page makes many resource requests
- **Solution**: Filter by `resourceTypes` (xhr, fetch only)

## Performance Tips

1. **Filter Early**: Use `resourceTypes` to reduce result size
2. **Paginate**: Use pagination for pages with many requests
3. **Targeted URLs**: Search for specific URL patterns
4. **Clear Pattern**: Navigate → Action → Monitor → Extract

## Next Steps
- Combine with performance tracing for full analysis
- Test error handling scenarios
- Validate request/response headers
- Monitor WebSocket connections

---

**Related Examples:**
- [01-basic-navigation-snapshot.md](01-basic-navigation-snapshot.md)
- [02-form-interaction.md](02-form-interaction.md)
- [04-performance-testing.md](04-performance-testing.md)
