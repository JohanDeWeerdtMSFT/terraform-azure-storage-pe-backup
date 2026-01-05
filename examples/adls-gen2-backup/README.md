# Advanced Example - ADLS Gen2 with Point-in-Time Restore and Backup

This example creates a storage account with ADLS Gen2 enabled, point-in-time restore, and Azure Backup integration.

## Features

- ADLS Gen2 (Hierarchical Namespace)
- Private Endpoints for both blob and DFS
- Point-in-Time Restore
- Blob Versioning
- Soft Delete for blobs and containers
- Azure Backup Integration

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- Storage Account (GPv2) with ADLS Gen2
- Private Endpoints for blob and DFS
- Private DNS Zones
- Azure Backup Vault
- Backup Policy
- Backup Instance

## Prerequisites

- Azure subscription
- Resource group
- Virtual network with subnet
