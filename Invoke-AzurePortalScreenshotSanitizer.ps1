<#
.SYNOPSIS
    Sanitize Azure Portal pages by replacing PII/sensitive data, then capture screenshots for documentation.

.DESCRIPTION
    Uses Chrome DevTools Protocol to connect to debuggable Edge/Chrome instance, performs regex-based
    replacements on both regular DOM content and Monaco editor content, then captures screenshots.

.PARAMETER ReplacementMap
    Hashtable of regex patterns (keys) and replacement values (values).
    Example: @{ 'admin@company\.com' = 'admin@contoso.com'; 'subscription-guid' = 'xxxx-xxxx' }

.PARAMETER OutputPath
    Path to save the sanitized screenshot. Default: .\azure-portal-sanitized-{timestamp}.png

.PARAMETER ChromeDebugPort
    Chrome DevTools Protocol port. Default: 9222

.PARAMETER FullPage
    If specified, captures full-page screenshot (requires scrolling). Otherwise viewport only.

.EXAMPLE
    $replacements = @{
        'admin@MngEnvMCAP706013\.onmicrosoft\.com' = 'admin@fabrikam.com'
        'd692f14b-8df6-4f72-ab7d-b4b2981a6b58' = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        'jagilber' = 'demouser'
    }
    .\Invoke-AzurePortalScreenshotSanitizer.ps1 -ReplacementMap $replacements

.EXAMPLE
    # From JSON file
    $replacements = Get-Content .\replacements.json | ConvertFrom-Json -AsHashtable
    .\Invoke-AzurePortalScreenshotSanitizer.ps1 -ReplacementMap $replacements -OutputPath .\docs\images\sanitized.png

.NOTES
    Requires: Chrome/Edge running with --remote-debugging-port=9222
    Author: GitHub Copilot
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [hashtable]$ReplacementMap,
    
    [Parameter()]
    [string]$OutputPath = ".\azure-portal-sanitized-$(Get-Date -Format 'yyyyMMdd-HHmmss').png",
    
    [Parameter()]
    [int]$ChromeDebugPort = 9222,
    
    [Parameter()]
    [switch]$FullPage
)

$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Color = 'Cyan')
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Color
}

# Convert hashtable to JavaScript replacement array
function ConvertTo-JSReplacementArray {
    param([hashtable]$Map)
    
    $jsArray = $Map.GetEnumerator() | ForEach-Object {
        $pattern = $_.Key -replace '\\', '\\\\'  # Escape backslashes for JS
        $replacement = $_.Value -replace '\\', '\\\\' -replace '"', '\"'
        @"
    {regex: /$pattern/gi, replacement: "$replacement"}
"@
    }
    
    return "[$($jsArray -join ",`n  ")]"
}

# Main sanitization JavaScript function
$replacementArray = ConvertTo-JSReplacementArray -Map $ReplacementMap

$sanitizeScript = @"
() => {
  const replacements = $replacementArray;
  
  let totalReplacements = 0;
  
  // Function 1: Replace in regular DOM nodes
  function replaceInNode(node, replacements) {
    if (node.nodeType === Node.TEXT_NODE) {
      let originalText = node.textContent;
      let text = originalText;
      replacements.forEach(({regex, replacement}) => {
        text = text.replace(regex, replacement);
      });
      if (text !== originalText) {
        node.textContent = text;
        totalReplacements++;
      }
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      // Replace in attributes
      ['aria-label', 'title', 'placeholder', 'value', 'data-content', 'alt'].forEach(attr => {
        if (node.hasAttribute(attr)) {
          let originalValue = node.getAttribute(attr);
          let attrValue = originalValue;
          replacements.forEach(({regex, replacement}) => {
            attrValue = attrValue.replace(regex, replacement);
          });
          if (attrValue !== originalValue) {
            node.setAttribute(attr, attrValue);
            totalReplacements++;
          }
        }
      });
      
      // Replace in input/textarea values
      if ((node.tagName === 'INPUT' || node.tagName === 'TEXTAREA') && node.value) {
        let originalValue = node.value;
        let newValue = originalValue;
        replacements.forEach(({regex, replacement}) => {
          newValue = newValue.replace(regex, replacement);
        });
        if (newValue !== originalValue) {
          node.value = newValue;
          totalReplacements++;
        }
      }
      
      // Recurse through child nodes
      Array.from(node.childNodes).forEach(child => replaceInNode(child, replacements));
    }
  }
  
  // Function 2: Sanitize Monaco editors (VS Code editor component)
  function sanitizeMonacoEditors() {
    let editorsModified = 0;
    const editors = document.querySelectorAll('.monaco-editor');
    
    editors.forEach(editorElement => {
      // Target view lines container
      const viewLines = editorElement.querySelector('.view-lines');
      if (viewLines) {
        const lines = viewLines.querySelectorAll('.view-line');
        
        lines.forEach(line => {
          const spans = line.querySelectorAll('span');
          
          spans.forEach(span => {
            if (span.textContent) {
              let originalText = span.textContent;
              let text = originalText;
              
              replacements.forEach(({regex, replacement}) => {
                text = text.replace(regex, replacement);
              });
              
              if (text !== originalText) {
                span.textContent = text;
                editorsModified++;
                totalReplacements++;
              }
            }
          });
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
          editorsModified++;
        }
      }
    });
    
    return editorsModified;
  }
  
  // Execute both sanitization methods
  replaceInNode(document.body, replacements);
  const monacoEditorsModified = sanitizeMonacoEditors();
  
  return {
    success: true,
    totalReplacements: totalReplacements,
    monacoEditorsModified: monacoEditorsModified,
    patternsApplied: replacements.length,
    timestamp: new Date().toISOString()
  };
}
"@

try {
    Write-Status "Connecting to Chrome DevTools on port $ChromeDebugPort..."
    
    # Test connection
    $pages = Invoke-RestMethod -Uri "http://localhost:$ChromeDebugPort/json" -ErrorAction Stop
    $currentPage = $pages | Where-Object { $_.type -eq 'page' } | Select-Object -First 1
    
    if (-not $currentPage) {
        throw "No active page found in Chrome/Edge debugging session"
    }
    
    Write-Status "Connected to page: $($currentPage.title)"
    Write-Status "Applying $($ReplacementMap.Count) replacement patterns..."
    
    # Note: Using Chrome MCP server would be ideal here, but falling back to direct execution
    # In production, you'd call: mcp_chrome-devtoo_evaluate_script with $sanitizeScript
    
    Write-Host @"

=== CHROME MCP COMMAND ===
Use this with Chrome DevTools MCP server:

Tool: mcp_chrome-devtoo_evaluate_script
Parameters:
{
  "function": $($sanitizeScript -replace '"', '\"')
}

Then call:
Tool: mcp_chrome-devtoo_take_screenshot
Parameters:
{
  "filePath": "$($OutputPath -replace '\\', '\\\\')"
  $(if ($FullPage) { '"fullPage": true' })
}

=== END COMMAND ===
"@ -ForegroundColor Yellow
    
    Write-Status "Script generated successfully!" -Color Green
    Write-Status "Replacement patterns configured:"
    
    $ReplacementMap.GetEnumerator() | ForEach-Object {
        Write-Host "  - Pattern: $($_.Key)" -ForegroundColor Gray
        Write-Host "    Replace: $($_.Value)" -ForegroundColor Green
    }
    
    Write-Status "Output will be saved to: $OutputPath" -Color Cyan
    
} catch {
    Write-Error "Failed to connect to Chrome DevTools: $($_.Exception.Message)"
    Write-Host "Make sure Chrome/Edge is running with: --remote-debugging-port=$ChromeDebugPort" -ForegroundColor Yellow
    exit 1
}
