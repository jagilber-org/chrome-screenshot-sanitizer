# Multi-Project Structure Guide

## Overview

This repository supports **multiple screenshot sanitization projects** while using a **single shared .env file** for PII patterns. This approach ensures consistency while organizing outputs by project.

## Architecture

```
chrome-screenshot-sanitizer-pr/
├── .env                          # Shared PII configuration (gitignored)
├── .env.example                  # Template for all projects
├── Get-SanitizationMappings.ps1  # Pattern generator (used by all projects)
├── Sanitize-Project.ps1          # Multi-project sanitization script
├── New-SanitizationProject.ps1   # Project creation tool
│
└── projects/                     # Project-based organization
    ├── azure-portal/
    │   ├── config.json          # Project-specific settings
    │   ├── README.md            # Project documentation
    │   └── outputs/             # Sanitized screenshots
    ├── github/
    │   ├── config.json
    │   ├── README.md
    │   └── outputs/
    └── [project-name]/
        ├── config.json
        ├── README.md
        └── outputs/
```

## Key Concepts

### 1. Shared PII Configuration
**One .env file for all projects** containing your actual PII values:
- Email addresses
- Tenant names
- Subscription IDs
- Resource names
- Usernames

**Benefits**:
- ✅ Configure once, use everywhere
- ✅ Consistent sanitization across all screenshots
- ✅ Single source of truth for PII patterns
- ✅ Easy to update when values change

### 2. Project-Specific Organization
Each project has its own:
- **config.json**: Project settings (URLs, viewport, screenshot format)
- **outputs/**: Sanitized screenshots for that project
- **README.md**: Project-specific documentation

**Benefits**:
- ✅ Organized by use case (Azure Portal, GitHub, Slack, etc.)
- ✅ Project-specific documentation
- ✅ Easy to share/archive individual projects
- ✅ Custom settings per project without affecting others

### 3. Project Configuration (config.json)

```json
{
  "projectName": "azure-portal",
  "description": "Azure Portal screenshots for TSGs",
  "baseUrl": "https://portal.azure.com",
  "outputDir": "projects/azure-portal/outputs",
  "chromeSettings": {
    "debugPort": 9222,
    "browserType": "msedge",
    "viewport": { "width": 1920, "height": 1080 },
    "waitBeforeScreenshot": 2000
  },
  "screenshotDefaults": {
    "format": "png",
    "quality": 95,
    "fullPage": false
  },
  "additionalPatterns": []
}
```

**What you can customize per project**:
- Base URL for quick navigation
- Browser viewport size
- Screenshot format/quality
- Wait times before capture
- Additional regex patterns (beyond .env)

## Workflows

### Initial Setup (One-time)

1. **Configure shared PII** (all projects use this):
   ```powershell
   # Copy template and fill in your values
   Copy-Item .env.example .env
   # Edit .env with your actual PII values
   code .env
   ```

2. **Verify pattern generation**:
   ```powershell
   .\Get-SanitizationMappings.ps1 -ShowMappings
   ```

### Creating a New Project

```powershell
# Create project structure
.\New-SanitizationProject.ps1 `
  -ProjectName "azure-devops" `
  -Description "Azure DevOps pipeline screenshots" `
  -BaseUrl "https://dev.azure.com"

# Creates:
# - projects/azure-devops/
# - projects/azure-devops/config.json
# - projects/azure-devops/outputs/
# - projects/azure-devops/README.md
```

### Capturing Screenshots

```powershell
# 1. Start browser with debugging
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:TEMP\edge-remote-debug"

# 2. Navigate to page you want to capture

# 3. Sanitize and capture (uses shared .env)
.\Sanitize-Project.ps1 -Project "azure-portal"

# With custom filename
.\Sanitize-Project.ps1 `
  -Project "azure-portal" `
  -OutputFileName "resource-group-list"

# Full page screenshot
.\Sanitize-Project.ps1 `
  -Project "azure-portal" `
  -OutputFileName "service-fabric-cluster" `
  -FullPage
```

### Output Organization

Screenshots automatically saved to project-specific directories:

```
projects/
├── azure-portal/outputs/
│   ├── resource-group-list-sanitized.png
│   ├── service-fabric-cluster-sanitized.png
│   └── storage-account-sanitized.png
├── github/outputs/
│   ├── workflow-overview-sanitized.png
│   └── pull-request-sanitized.png
└── slack/outputs/
    └── channel-messages-sanitized.png
```

## Example Projects

### Azure Portal
**Use case**: Azure troubleshooting guides (TSGs)  
**Common pages**: Resource groups, VMs, Service Fabric, Storage, Key Vault

```powershell
.\New-SanitizationProject.ps1 `
  -ProjectName "azure-portal" `
  -Description "Azure Portal screenshots for TSGs" `
  -BaseUrl "https://portal.azure.com"
```

### GitHub
**Use case**: GitHub workflow documentation  
**Common pages**: Repositories, Actions, Pull Requests, Issues

```powershell
.\New-SanitizationProject.ps1 `
  -ProjectName "github" `
  -Description "GitHub workflow documentation" `
  -BaseUrl "https://github.com/yourorg"
```

### Azure DevOps
**Use case**: Pipeline and release documentation  
**Common pages**: Pipelines, Repos, Boards, Test Plans

```powershell
.\New-SanitizationProject.ps1 `
  -ProjectName "azure-devops" `
  -Description "Azure DevOps pipeline documentation" `
  -BaseUrl "https://dev.azure.com/yourorg"
```

### Slack
**Use case**: Team communication guides  
**Common pages**: Channels, DMs, App integrations

```powershell
.\New-SanitizationProject.ps1 `
  -ProjectName "slack" `
  -Description "Slack communication guides" `
  -BaseUrl "https://yourworkspace.slack.com"
```

## Benefits of Multi-Project Approach

### Organizational Benefits
- ✅ **Separation of concerns**: Each project isolated
- ✅ **Easy cleanup**: Delete entire project when done
- ✅ **Project-specific docs**: README per project
- ✅ **Searchable**: Find screenshots by project name

### Technical Benefits
- ✅ **Shared PII config**: Maintain .env once, use everywhere
- ✅ **Consistent sanitization**: Same patterns across all projects
- ✅ **Custom settings**: Project-specific viewport, format, quality
- ✅ **Version control**: Git-friendly structure (outputs gitignored)

### Workflow Benefits
- ✅ **Quick context switching**: Switch between projects easily
- ✅ **Batch processing**: Capture multiple screenshots per project
- ✅ **Documentation**: Each project documents its own examples
- ✅ **Collaboration**: Share individual projects with teammates

## Migration from Single-Project

If you have existing screenshots in `images/examples/`:

```powershell
# 1. Create azure-portal project
.\New-SanitizationProject.ps1 -ProjectName "azure-portal" -BaseUrl "https://portal.azure.com"

# 2. Move existing screenshots
Move-Item images/examples/*-sanitized.png projects/azure-portal/outputs/

# 3. Continue using new structure
.\Sanitize-Project.ps1 -Project "azure-portal"
```

## Advanced: Project-Specific Patterns

While most patterns come from shared `.env`, you can add project-specific patterns in `config.json`:

```json
{
  "additionalPatterns": [
    {
      "description": "Azure DevOps organization-specific IDs",
      "find": "yourorg-specific-pattern",
      "replace": "demo-pattern"
    }
  ]
}
```

## Troubleshooting

### Issue: Project not found
**Error**: `Project 'xyz' not found`  
**Solution**: Create project first with `New-SanitizationProject.ps1`

### Issue: No patterns generated
**Error**: Failed to generate sanitization patterns  
**Solution**: Verify `.env` exists and contains required fields

### Issue: Screenshots missing PII replacement
**Problem**: Some PII not being sanitized  
**Solution**: 
1. Check `.env` contains the PII value
2. Run `Get-SanitizationMappings.ps1 -ShowMappings` to verify pattern
3. Add missing value to `.env`

## Best Practices

1. **One .env for all projects** - Don't create per-project .env files
2. **Descriptive project names** - Use kebab-case (azure-portal, not AzurePortal)
3. **Meaningful filenames** - Describe what's in screenshot (resource-group-list, not screenshot1)
4. **Document examples** - Update project README with screenshot descriptions
5. **Clean up regularly** - Delete old projects when no longer needed
6. **Version control** - Commit project structure, not outputs (outputs are gitignored)

## Security

- ✅ `.env` is gitignored (contains real PII)
- ✅ Project `config.json` can be committed (no secrets)
- ✅ Sanitized screenshots can be committed (PII removed)
- ✅ Project structure can be shared safely
