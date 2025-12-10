# Azure Portal Screenshot Project

**Purpose**: Sanitized Azure Portal screenshots for public TSGs and documentation

## Quick Start

```powershell
# 1. Start browser with remote debugging
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:TEMP\edge-remote-debug"

# 2. Navigate to Azure Portal page you want to capture

# 3. Run sanitization and capture
.\Sanitize-Project.ps1 -Project "azure-portal"
```

## Common Pages

- **Home**: Portal home with subscription list
- **Resource Groups**: List and detail views
- **Virtual Machines**: VM overview and monitoring
- **Service Fabric**: Cluster health and metrics
- **Key Vault**: Secrets and access policies
- **Storage Accounts**: Containers and configuration

## Output Organization

```
outputs/
├── home-sanitized-20251210-1015.png
├── resource-group-list-sanitized-20251210-1020.png
├── service-fabric-cluster-sanitized-20251210-1025.png
└── [descriptive-name]-sanitized-[timestamp].png
```

## Examples

See `outputs/` directory for sanitized screenshot examples demonstrating PII removal across different Azure Portal pages.
