# azure-resource-explorer Screenshot Project

**Purpose**: Azure Resource Explorer screenshots for resource management documentation

## Quick Start

```powershell
# 1. Start browser with remote debugging
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:TEMP\edge-remote-debug"

# 2. Navigate to the page you want to capture
# Base URL: https://resources.azure.com

# 3. Run sanitization and capture
.\Sanitize-Project.ps1 -Project "azure-resource-explorer"
```

## Configuration

See [config.json](config.json) for project-specific settings:
- Chrome/Edge settings
- Screenshot defaults (format, quality)
- Additional sanitization patterns (optional)

## PII Sanitization

This project uses the shared .env file at the repository root for PII patterns.
All sanitization happens automatically based on your configured values.

## Output Organization

Screenshots are saved to outputs/ with naming pattern:
```
[description]-sanitized-[timestamp].png
```

## Examples

Add sanitized screenshot examples to the outputs/ directory demonstrating:
- Different pages/views
- Various PII types being sanitized
- Before/after comparisons (in documentation only)
