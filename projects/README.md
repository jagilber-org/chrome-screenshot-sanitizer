# Multi-Project Screenshot Sanitization

This directory contains subdirectories for different screenshot sanitization projects. Each project uses the **same .env file** for PII mapping but organizes outputs and configurations separately.

## Project Structure

```
projects/
├── azure-portal/          # Azure Portal screenshots
│   ├── config.json       # Project-specific settings
│   ├── outputs/          # Sanitized screenshots
│   └── README.md         # Project documentation
├── github/               # GitHub screenshots
│   ├── config.json
│   ├── outputs/
│   └── README.md
├── slack/                # Slack screenshots
│   ├── config.json
│   ├── outputs/
│   └── README.md
└── [project-name]/       # Add more as needed

```

## Shared PII Configuration

All projects use the **same .env file** at the repository root for PII sanitization patterns. This ensures consistency across all screenshots:

- `.env` - Contains your actual PII values (gitignored)
- `.env.example` - Template for all projects

## Creating a New Project

```powershell
# Create new project
.\New-SanitizationProject.ps1 -ProjectName "azure-devops"

# Take sanitized screenshot for project
.\Sanitize-Project.ps1 -Project "azure-devops" -Url "https://dev.azure.com/yourorg"
```

## Project Configuration

Each project has a `config.json` with project-specific settings:

```json
{
  "projectName": "azure-portal",
  "baseUrl": "https://portal.azure.com",
  "outputDir": "projects/azure-portal/outputs",
  "additionalPatterns": [
    // Project-specific regex patterns (optional)
  ],
  "chromeSettings": {
    "viewport": { "width": 1920, "height": 1080 },
    "waitTime": 2000
  }
}
```

## Workflow

1. **One-time setup**: Configure `.env` with your PII values
2. **Per project**: Create project directory and config
3. **Per screenshot**: Run sanitization script with project parameter
4. **Output**: Screenshots saved to `projects/{project-name}/outputs/`

## Benefits

- ✅ **Single PII config** - Maintain .env once, use across all projects
- ✅ **Organized outputs** - Each project has dedicated output directory
- ✅ **Project-specific settings** - Browser configs, URLs, additional patterns
- ✅ **Easy cleanup** - Delete entire project directory when done
- ✅ **Documentation** - Each project can have its own README with examples

## Example Projects

### Azure Portal
Screenshots for Azure troubleshooting guides (TSGs)

### GitHub
Screenshots for GitHub workflow documentation

### Slack
Screenshots for team communication guides

### Azure DevOps
Screenshots for ADO pipeline documentation
