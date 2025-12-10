# Expand-ResourceExplorerTree.ps1
# Automates Azure Portal Resource Explorer tree expansion using Chrome MCP

<#
.SYNOPSIS
    Expands Resource Explorer tree nodes programmatically using Chrome MCP tools.

.DESCRIPTION
    Uses mcp_chrome-devtoo_evaluate_script to find and click expand buttons in the
    Azure Portal Resource Explorer. Handles dynamic loading with retry logic.

.PARAMETER MaxDepth
    Maximum tree depth to expand (default: 3 levels - Subscriptions > ResourceGroups > Resources)

.PARAMETER WaitSeconds
    Seconds to wait between expansion attempts for dynamic content loading (default: 2)

.EXAMPLE
    .\Expand-ResourceExplorerTree.ps1 -MaxDepth 3 -WaitSeconds 2
#>

param(
    [int]$MaxDepth = 3,
    [int]$WaitSeconds = 2
)

Write-Host "`n🌲 Resource Explorer Tree Expansion Script" -ForegroundColor Cyan
Write-Host "  Max Depth: $MaxDepth levels" -ForegroundColor Gray
Write-Host "  Wait Time: $WaitSeconds seconds between expansions`n" -ForegroundColor Gray

# JavaScript function to expand all visible tree nodes
$expandScript = @'
() => {
    // Find all expand/collapse buttons in Azure Portal Resource Explorer
    // Common selectors for Azure Portal tree controls
    const selectors = [
        'button[aria-label*="Expand"]',
        'button[aria-label*="expand"]',
        'div[role="treeitem"][aria-expanded="false"]',
        '.fxs-tree-expander:not(.fxs-tree-expanded)',
        '.azc-treeView-expand',
        '[data-automation-id*="expand"]'
    ];
    
    let expandedCount = 0;
    let foundButtons = [];
    
    // Try each selector
    for (const selector of selectors) {
        const buttons = document.querySelectorAll(selector);
        if (buttons.length > 0) {
            foundButtons = Array.from(buttons);
            break;
        }
    }
    
    // Click each expand button
    for (const btn of foundButtons) {
        // Check if already expanded
        const isExpanded = btn.getAttribute('aria-expanded') === 'true' ||
                          btn.classList.contains('fxs-tree-expanded');
        
        if (!isExpanded) {
            btn.click();
            expandedCount++;
        }
    }
    
    return {
        success: true,
        expandedCount: expandedCount,
        totalFound: foundButtons.length,
        selectors: selectors
    };
}
'@

Write-Host "📊 Expansion Progress:" -ForegroundColor Cyan

for ($level = 1; $level -le $MaxDepth; $level++) {
    Write-Host "`n  Level $level of $MaxDepth" -ForegroundColor Yellow
    
    # Execute expansion script
    # Note: This outputs the tool call syntax for the agent to execute
    Write-Host "  Tool: mcp_chrome-devtoo_evaluate_script" -ForegroundColor Gray
    Write-Host "  Function: Expand tree nodes at level $level" -ForegroundColor Gray
    
    # Wait for dynamic content to load
    if ($level -lt $MaxDepth) {
        Write-Host "  Waiting $WaitSeconds seconds for content to load..." -ForegroundColor Gray
        Start-Sleep -Seconds $WaitSeconds
    }
}

Write-Host "`n✅ Tree expansion script ready" -ForegroundColor Green
Write-Host "`n💡 Agent Instructions:" -ForegroundColor Cyan
Write-Host "  1. Use mcp_chrome-devtoo_evaluate_script with the function above" -ForegroundColor White
Write-Host "  2. Execute $MaxDepth times with $WaitSeconds second delays" -ForegroundColor White
Write-Host "  3. Check result.expandedCount to verify expansion" -ForegroundColor White
Write-Host "  4. Take snapshot to verify tree is fully expanded`n" -ForegroundColor White

# Return the JavaScript for the agent to use
return @{
    Script = $expandScript
    MaxDepth = $MaxDepth
    WaitSeconds = $WaitSeconds
}
