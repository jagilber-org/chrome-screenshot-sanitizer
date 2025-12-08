# Quick wrapper to sanitize current Azure Portal page and screenshot
# Usage: .\Sanitize-AzurePortal.ps1

$replacementsFile = "$PSScriptRoot\replacements-azure-portal.json"

if (!(Test-Path $replacementsFile)) {
    Write-Error "Replacements file not found: $replacementsFile"
    exit 1
}

# Load replacements
$config = Get-Content $replacementsFile | ConvertFrom-Json
$replacementMap = @{}
$config.replacements.PSObject.Properties | ForEach-Object {
    $replacementMap[$_.Name] = $_.Value
}

Write-Host "Loaded $($replacementMap.Count) replacement patterns from $replacementsFile" -ForegroundColor Green

# Build the combined JavaScript function
$replacementArray = ($replacementMap.GetEnumerator() | ForEach-Object {
    $pattern = $_.Key -replace '\\', '\\\\'
    $replacement = $_.Value -replace '\\', '\\\\' -replace '"', '\"'
    "    {regex: /$pattern/gi, replacement: `"$replacement`"}"
}) -join ",`n"

$jsFunction = @"
() => {
  const replacements = [
$replacementArray
  ];
  
  let totalReplacements = 0;
  
  // Replace in regular DOM
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
      Array.from(node.childNodes).forEach(child => replaceInNode(child, replacements));
    }
  }
  
  // Sanitize Monaco editors
  function sanitizeMonacoEditors() {
    let editorsModified = 0;
    const editors = document.querySelectorAll('.monaco-editor');
    editors.forEach(editorElement => {
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
  
  replaceInNode(document.body, replacements);
  const monacoEditorsModified = sanitizeMonacoEditors();
  
  return {
    success: true,
    totalReplacements: totalReplacements,
    monacoEditorsModified: monacoEditorsModified,
    patternsApplied: replacements.length
  };
}
"@

Write-Host "`nExecuting sanitization on current page..." -ForegroundColor Cyan

# Save to temp file for easy copying
$tempFile = "$env:TEMP\azure-portal-sanitize.js"
$jsFunction | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline

Write-Host "`n✓ JavaScript function saved to: $tempFile" -ForegroundColor Green
Write-Host "`n=== EXECUTE THIS IN COPILOT CHAT ===" -ForegroundColor Yellow
Write-Host @"

@chrome-devtools Use evaluate_script with this function, then take_screenshot:

``````javascript
$jsFunction
``````

"@ -ForegroundColor White

Write-Host "`n=== OR USE THESE COMMANDS ===" -ForegroundColor Yellow
Write-Host "1. Copy the JavaScript function above" -ForegroundColor Gray
Write-Host "2. Tell Copilot: 'Execute this JavaScript in the current page'" -ForegroundColor Gray  
Write-Host "3. Then: 'Take a screenshot and save to ./docs/images/sanitized-{timestamp}.png'" -ForegroundColor Gray

return @{
    ReplacementCount = $replacementMap.Count
    JavaScriptFunction = $jsFunction
    TempFile = $tempFile
}
