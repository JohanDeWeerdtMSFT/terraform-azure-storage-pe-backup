# Basic Example - Storage Account with Private Endpoint

This example creates a basic storage account with private endpoint for blob storage.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- Storage Account (GPv2) with HTTPS-only access
- Private Endpoint for blob storage
- Private DNS Zone for blob storage
- VNet link for DNS resolution

## Prerequisites

- Azure subscription
- Resource group
- Virtual network with subnet
