# Screenshot Update Plan for Managing Azure Resources Guide

**Document**: https://github.com/Azure/Service-Fabric-Troubleshooting-Guides/blob/master/Deployment/managing-azure-resources.md  
**Project**: azure-resource-explorer  
**Date**: December 10, 2025

## Executive Summary

The managing-azure-resources.md guide documents how to update ARM templates using Azure Portal's Resource Manager interface. The guide was last updated 2 months ago and currently shows a workflow using **ARM API Playground** as the primary method for modifying resources. Since then, **Resource Explorer has added GET/EDIT/PUT/PATCH buttons**, making it a complete solution without requiring API Playground for most scenarios.

## Current State Analysis

### Current Documentation Structure
1. **Azure Portal Section** (Primary focus):
   - Using Resource Explorer to **view** resources (read-only)
   - Using ARM API Playground to **modify** resources (GET → edit JSON → PUT)
   
2. **Alternative Methods**:
   - Azure PowerShell (Export-AzResourceGroup, New-AzResourceGroupDeployment)
   - Azure CLI (az resource update)

### Current Screenshots (7 total):
1. **azure-portal-fixed.png** - Resource Manager overview blade
2. **resource-explorer-obfuscated.png** - Resource Explorer hierarchical tree
3. **resource-vmss-nodetype0.png** - VMSS resource details expanded
4. **arm-api-put-workflow.png** - ARM API Playground overview
5. **arm-api-servicefabric-cluster.png** - GET request for Service Fabric cluster
6. **arm-api-put-vmss-nodetype0.png** - PUT request updating VMSS
7. **portal-resource-view.png** + **portal-json-view.png** - Resource JSON view (2 images)

### Current Workflow (Documented):
```
Resource Explorer (view only) 
    ↓
Copy resource path + API version
    ↓
ARM API Playground
    ↓
GET request → view JSON
    ↓
Copy JSON → modify in Request Body tab
    ↓
PUT request → submit changes
    ↓
Verify 200 OK + provisioningState
```

## New Resource Explorer Functionality

Based on your information, Resource Explorer now has:
- **GET button** - Retrieve current resource configuration
- **EDIT button** - Modify JSON directly in Resource Explorer
- **PUT button** - Submit complete resource update
- **PATCH button** - Submit partial resource update

### New Workflow (Should be Primary):
```
Resource Explorer
    ↓
Navigate to resource in tree
    ↓
Click GET button → view current JSON
    ↓
Click EDIT button → modify JSON inline
    ↓
Click PUT/PATCH button → submit changes
    ↓
Verify success
```

### API Playground Workflow (Edge Cases):
- Multiple resource operations (supports multiple tabs)
- URL modification and API version testing
- Advanced scenarios where Resource Explorer limitations exist
- Learning/troubleshooting ARM API directly

## Detailed Update Plan

### Phase 1: Resource Explorer - Primary Workflow (NEW)

#### Screenshot 1: Resource Manager Overview (UPDATE EXISTING)
- **Filename**: `resource-manager-overview-sanitized.png`
- **Replaces**: azure-portal-fixed.png
- **Content**: Resource Manager blade showing both Resource Explorer and ARM API Playground links
- **PII to sanitize**: Subscription names, tenant info
- **Navigation**: https://portal.azure.com/#view/Microsoft_Azure_Resources/ResourceManagerBlade/~/overview
- **Purpose**: Entry point showing unified interface

#### Screenshot 2: Resource Explorer Navigation (UPDATE EXISTING)
- **Filename**: `resource-explorer-navigation-sanitized.png`
- **Replaces**: resource-explorer-obfuscated.png
- **Content**: Hierarchical tree showing: Subscriptions → ResourceGroups → Resources
- **PII to sanitize**: Subscription names, resource group names, resource names
- **Navigation**: Expand tree to show structure
- **Purpose**: Show how to navigate to a resource

#### Screenshot 3: Resource Explorer with GET/EDIT/PUT/PATCH Buttons (NEW - CRITICAL)
- **Filename**: `resource-explorer-new-buttons-sanitized.png`
- **Replaces**: None (new screenshot)
- **Content**: Resource selected in tree, showing the new GET/EDIT/PUT/PATCH buttons in UI
- **PII to sanitize**: Resource names, subscription info, any JSON content visible
- **Navigation**: Select a resource (VMSS or Service Fabric cluster)
- **Purpose**: Highlight the new functionality that makes this workflow possible
- **Note**: This is the KEY screenshot showing what changed

#### Screenshot 4: Resource Explorer GET Request (NEW)
- **Filename**: `resource-explorer-get-request-sanitized.png`
- **Replaces**: Conceptually replaces arm-api-servicefabric-cluster.png
- **Content**: After clicking GET button, showing current resource JSON in Resource Explorer
- **PII to sanitize**: Resource IDs, subscription IDs, location names, any sensitive config
- **Navigation**: Click GET button on selected resource
- **Purpose**: Show how to retrieve current configuration

#### Screenshot 5: Resource Explorer EDIT Mode (NEW)
- **Filename**: `resource-explorer-edit-mode-sanitized.png`
- **Replaces**: Conceptually similar to arm-api-put-vmss-nodetype0.png Request Body tab
- **Content**: EDIT button clicked, JSON now editable, showing modified properties highlighted
- **PII to sanitize**: Resource configuration values, IDs, names
- **Navigation**: Click EDIT button, make a sample modification
- **Purpose**: Show inline editing capability

#### Screenshot 6: Resource Explorer PUT/PATCH Execution (NEW)
- **Filename**: `resource-explorer-put-execution-sanitized.png`
- **Replaces**: Conceptually replaces arm-api-put-vmss-nodetype0.png Response section
- **Content**: After clicking PUT/PATCH, showing success response with provisioningState
- **PII to sanitize**: Resource IDs, provisioning details
- **Navigation**: Click PUT or PATCH button
- **Purpose**: Show successful update confirmation

### Phase 2: ARM API Playground - Edge Cases Workflow (KEEP BUT REPOSITION)

#### Screenshot 7: ARM API Playground Workflow (UPDATE EXISTING)
- **Filename**: `arm-api-playground-workflow-sanitized.png`
- **Replaces**: arm-api-put-workflow.png
- **Content**: ARM API Playground interface showing URL field, HTTP method dropdown, Execute button
- **PII to sanitize**: Any resource URIs in examples
- **Navigation**: https://portal.azure.com/#view/Microsoft_Azure_Resources/ResourceManagerBlade/~/armapiplayground
- **Purpose**: Show alternative interface for edge cases

#### Screenshot 8: ARM API GET Request (KEEP)
- **Filename**: `arm-api-get-request-sanitized.png`
- **Replaces**: arm-api-servicefabric-cluster.png
- **Content**: GET request executed in ARM API Playground
- **PII to sanitize**: Resource URIs, subscription IDs, response JSON
- **Purpose**: Edge case documentation

#### Screenshot 9: ARM API PUT Request (KEEP)
- **Filename**: `arm-api-put-request-sanitized.png`
- **Replaces**: arm-api-put-vmss-nodetype0.png
- **Content**: PUT request with modified JSON in Request Body tab
- **PII to sanitize**: Resource URIs, JSON configuration
- **Purpose**: Edge case documentation

### Phase 3: Supporting Screenshots (MINOR UPDATES)

#### Screenshot 10: Portal Resource JSON View (KEEP)
- **Filename**: `portal-resource-json-view-sanitized.png`
- **Replaces**: portal-resource-view.png + portal-json-view.png (combine if possible)
- **Content**: Resource blade with JSON View showing Resource ID and API versions
- **PII to sanitize**: Resource IDs, subscription IDs
- **Purpose**: Show how to get resource URI from any resource blade

## Screenshot Inventory Summary

| # | Filename | Type | Replaces | Priority | Workflow |
|---|----------|------|----------|----------|----------|
| 1 | resource-manager-overview-sanitized.png | Update | azure-portal-fixed.png | P0 | Both |
| 2 | resource-explorer-navigation-sanitized.png | Update | resource-explorer-obfuscated.png | P0 | Primary |
| 3 | **resource-explorer-new-buttons-sanitized.png** | **NEW** | None | **P0** | **Primary** |
| 4 | resource-explorer-get-request-sanitized.png | NEW | Conceptual | P0 | Primary |
| 5 | resource-explorer-edit-mode-sanitized.png | NEW | Conceptual | P0 | Primary |
| 6 | resource-explorer-put-execution-sanitized.png | NEW | Conceptual | P0 | Primary |
| 7 | arm-api-playground-workflow-sanitized.png | Update | arm-api-put-workflow.png | P1 | Edge Case |
| 8 | arm-api-get-request-sanitized.png | Update | arm-api-servicefabric-cluster.png | P1 | Edge Case |
| 9 | arm-api-put-request-sanitized.png | Update | arm-api-put-vmss-nodetype0.png | P1 | Edge Case |
| 10 | portal-resource-json-view-sanitized.png | Update | portal-resource-view.png + portal-json-view.png | P2 | Supporting |

**Total**: 10 screenshots (3 NEW for Resource Explorer, 7 UPDATED)

## PII Sanitization Strategy

### Environment Variables Needed in .env:

**Current .env.example has**:
- USER_EMAIL, USER_TENANT_NAME, USER_TENANT_DOMAIN, USERNAME ✓
- SUBSCRIPTION_NAME, SUBSCRIPTION_ID, TENANT_ID ✓
- RESOURCE_GROUP_1, STORAGE_ACCOUNT_1/2, KEY_VAULT_1, SERVICE_FABRIC_CLUSTER_1 ✓

**Additional variables needed for Resource Explorer**:
- VMSS_NAME (Virtual Machine Scale Set for examples)
- VMSS_NODE_TYPE (e.g., NT0, NT1)
- SERVICE_FABRIC_CLUSTER_NAME (already have SERVICE_FABRIC_CLUSTER_1)
- API_VERSION (e.g., 2023-11-01-preview)
- LOCATION (e.g., eastus, westus2)

**ARM Template specific** (values that appear in JSON):
- CERT_THUMBPRINT (certificate thumbprints)
- VMSS_SKU (e.g., Standard_D2_v2)
- VMSS_CAPACITY (instance counts)

### Pattern Generation:
The existing Get-SanitizationMappings.ps1 will handle most patterns automatically through the indexed variable system. We'll need to add these to .env:

```
# VMSS Resources
VMSS_NAME_1=your-vmss-name
VMSS_NODE_TYPE_1=NT0

# Demo values
DEMO_VMSS_NAME_1=demo-vmss-01
DEMO_VMSS_NODE_TYPE_1=NodeType0

# ARM Template Values
CERT_THUMBPRINT_1=your-cert-thumbprint
DEMO_CERT_THUMBPRINT_1=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

LOCATION=eastus
DEMO_LOCATION=demo-region
```

## Documentation Structure Changes

### Current Section Order:
1. Azure Portal
   - Using Resource Explorer to **view** (read-only)
   - Using ARM API Playground to **update** (primary method)
2. Azure PowerShell
3. Azure CLI
4. Additional Information

### Proposed New Section Order:
1. Azure Portal
   - **Using Resource Explorer to view AND update** (primary method - NEW)
     - Navigation
     - GET button usage
     - EDIT button usage
     - PUT/PATCH button usage
     - Success verification
   - **Using ARM API Playground** (alternative/edge case method)
     - When to use (edge cases documented)
     - GET → modify → PUT workflow
   - **Resource JSON View** (supporting information)
2. Azure PowerShell (no changes)
3. Azure CLI (no changes)
4. Additional Information (no changes)

## Key Documentation Changes

### Section: "Using Azure Portal to update resources"

**Current text**:
> "To use ARM API Playground to modify resource configuration, the resource URI with API version must be provided..."

**Proposed text**:
> "Azure Portal provides two methods for modifying resource configuration:
> 1. **Resource Explorer** (Recommended): Navigate to resource and use built-in GET/EDIT/PUT/PATCH buttons
> 2. **ARM API Playground** (Edge cases): For complex scenarios or when Resource Explorer has limitations"

### New Subsection: "Using Resource Explorer to update resources"

**Content**:
1. Navigate to resource in Resource Explorer
2. Click GET button to retrieve current configuration
3. Click EDIT button to modify JSON inline
4. Click PUT (complete update) or PATCH (partial update) button
5. Verify provisioningState is Updating or Succeeded

### Updated Subsection: "Using ARM API Playground"

**Prefix with**:
> "ARM API Playground provides an alternative interface for scenarios where:
> - Working with multiple resources simultaneously (multiple tabs supported)
> - Testing different API versions or URL modifications
> - Resource Explorer has limitations for specific resource types
> - Direct ARM API interaction is needed for troubleshooting"

## Quality Assurance Checklist

Before finalizing screenshots:
- [ ] All PII sanitized (subscription IDs, resource names, tenant info, emails)
- [ ] Screenshots at 1920x1080 resolution
- [ ] Browser zoom at 100%
- [ ] GET/EDIT/PUT/PATCH buttons clearly visible in Resource Explorer screenshots
- [ ] JSON content readable but sanitized
- [ ] Success responses show provisioningState clearly
- [ ] File naming convention followed: [description]-sanitized.png
- [ ] All screenshots saved to projects/azure-resource-explorer/outputs/
- [ ] Descriptive filenames that indicate workflow step

## Implementation Steps

### Step 1: Configure .env (Task 5)
Add VMSS, certificate, and ARM template variables to .env

### Step 2: Capture Primary Workflow Screenshots (Task 6)
Priority order:
1. Screenshot 3 (new buttons) - CRITICAL
2. Screenshot 4 (GET request)
3. Screenshot 5 (EDIT mode)
4. Screenshot 6 (PUT execution)
5. Screenshot 1 (overview)
6. Screenshot 2 (navigation)

### Step 3: Capture Edge Case Screenshots (Task 7)
ARM API Playground workflow (screenshots 7-9)

### Step 4: Validate Quality (Task 8)
Review all screenshots for PII, clarity, resolution

### Step 5: Document Mapping (Task 9)
Create detailed table of old→new with exact line numbers in MD file

### Step 6: Present for Approval (Task 10)
Show complete screenshot inventory and proposed documentation changes

## Risk Mitigation

### Potential Issues:
1. **Resource Explorer UI may vary by resource type**
   - Solution: Capture screenshots using VMSS (common example in current doc)
   
2. **GET/EDIT/PUT/PATCH buttons may not be visible for all resources**
   - Solution: Test with multiple resource types, document any limitations
   
3. **ARM template JSON may contain sensitive configuration**
   - Solution: Use .env variables for all sensitive values, sanitize inline

4. **Screenshot count increased from 7 to 10**
   - Solution: This is acceptable - better documentation with new workflow

5. **Source file is local clone, not remote GitHub**
   - Solution: Working with C:\github\jagilber\Service-Fabric-Troubleshooting-Guides\Deployment\managing-azure-resources.md
   - Can directly reference line numbers and make precise updates

## Success Criteria

- [ ] All 10 screenshots captured and sanitized
- [ ] Resource Explorer primary workflow clearly documented with new buttons
- [ ] ARM API Playground repositioned as edge case alternative
- [ ] No PII in any screenshot
- [ ] Documentation structure improved (primary → edge case → alternatives)
- [ ] User approves plan before implementation
- [ ] Quality over speed maintained throughout

## Next Steps

1. **User Review**: Review this plan and confirm understanding is correct
2. **Configuration**: Add necessary variables to .env
3. **Capture**: Execute screenshot capture in priority order
4. **Validation**: Review each screenshot for quality and PII
5. **Documentation**: Map screenshots to exact locations in MD file
6. **Approval**: Present final work for user approval before any commits

---

**Key Insight**: The new GET/EDIT/PUT/PATCH buttons in Resource Explorer fundamentally change the recommended workflow from "Resource Explorer (view) + ARM API Playground (modify)" to "Resource Explorer (view AND modify)" with ARM API Playground as a fallback for edge cases. This is a significant improvement in user experience and should be reflected as the primary documented method.
