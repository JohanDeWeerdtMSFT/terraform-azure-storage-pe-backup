# Azure Storage Account with Private Endpoints and Backup

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)

A Terraform module to deploy an Azure Storage Account (GPv2) with private endpoints, private DNS zones, and comprehensive security hardening. Includes optional ADLS Gen2 support, blob recovery features (soft delete, versioning, point-in-time restore), and Azure Backup integration via AzAPI.

## Features

### Security Hardening
- ✅ **HTTPS-only traffic** enforcement
- ✅ **No public network access** (default)
- ✅ **TLS 1.2** minimum version (configurable)
- ✅ **Private endpoints** for blob and DFS (ADLS Gen2)
- ✅ **Private DNS zones** with automatic VNet linking
- ✅ **Network rules** with default deny policy

### Blob Recovery Features
- ✅ **Soft delete** for blobs and containers (configurable retention)
- ✅ **Blob versioning** to track changes
- ✅ **Point-in-time restore** for container recovery
- ✅ **Change feed** support (required for point-in-time restore)

### Optional Features
- ✅ **ADLS Gen2** (hierarchical namespace)
- ✅ **Azure Backup integration** via AzAPI provider
- ✅ **Flexible DNS zone management** (bring your own or create new)
- ✅ **Customizable replication** (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)

## Prerequisites

- Terraform >= 1.3.0
- Azure subscription with appropriate permissions
- Existing virtual network with subnet for private endpoints
- Azure CLI or Service Principal configured for authentication

## Required Providers

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.10.0"
    }
  }
}
```

## Usage

### Basic Example

```hcl
module "storage_account" {
  source = "github.com/JohanDeWeerdtMSFT/terraform-azure-storage-pe-backup"

  storage_account_name     = "mystorageaccount"
  resource_group_name      = "my-resource-group"
  location                 = "East US"
  subnet_id                = azurerm_subnet.private_endpoints.id
  virtual_network_id       = azurerm_virtual_network.main.id
  account_replication_type = "LRS"

  # Blob recovery features
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  enable_versioning                    = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Advanced Example with ADLS Gen2 and Backup

```hcl
module "storage_account_adls" {
  source = "github.com/JohanDeWeerdtMSFT/terraform-azure-storage-pe-backup"

  storage_account_name     = "myadlsstorage"
  resource_group_name      = "my-resource-group"
  location                 = "East US"
  subnet_id                = azurerm_subnet.private_endpoints.id
  virtual_network_id       = azurerm_virtual_network.main.id
  account_replication_type = "GRS"

  # Enable ADLS Gen2
  enable_hierarchical_namespace = true

  # Advanced blob recovery
  blob_soft_delete_retention_days      = 14
  container_soft_delete_retention_days = 14
  enable_versioning                    = true
  enable_point_in_time_restore         = true
  point_in_time_restore_days           = 7
  enable_change_feed                   = true

  # Azure Backup integration
  enable_backup_integration = true
  backup_vault_id           = azurerm_data_protection_backup_vault.main.id
  backup_policy_id          = azurerm_data_protection_backup_policy_blob_storage.main.id

  tags = {
    Environment = "Production"
    DataLake    = "Enabled"
  }
}
```

## Examples

See the [examples](./examples) directory for complete working examples:

- [Basic](./examples/basic) - Basic storage account with private endpoint
- [ADLS Gen2 with Backup](./examples/adls-gen2-backup) - Advanced example with ADLS Gen2, point-in-time restore, and backup integration

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| storage_account_name | Name of the storage account (must be globally unique, 3-24 chars, lowercase and numbers only) | `string` | n/a | yes |
| resource_group_name | Name of the resource group where resources will be created | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| subnet_id | Subnet ID for private endpoint | `string` | n/a | yes |
| account_tier | Storage account tier (Standard or Premium) | `string` | `"Standard"` | no |
| account_replication_type | Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS) | `string` | `"LRS"` | no |
| enable_https_traffic_only | Enable HTTPS traffic only | `bool` | `true` | no |
| min_tls_version | Minimum TLS version | `string` | `"TLS1_2"` | no |
| public_network_access_enabled | Enable public network access to storage account | `bool` | `false` | no |
| enable_hierarchical_namespace | Enable ADLS Gen2 hierarchical namespace | `bool` | `false` | no |
| blob_soft_delete_retention_days | Number of days to retain deleted blobs (0 to disable) | `number` | `7` | no |
| container_soft_delete_retention_days | Number of days to retain deleted containers (0 to disable) | `number` | `7` | no |
| enable_versioning | Enable blob versioning | `bool` | `true` | no |
| enable_point_in_time_restore | Enable point-in-time restore for containers | `bool` | `false` | no |
| point_in_time_restore_days | Number of days for point-in-time restore (requires versioning and blob soft delete) | `number` | `6` | no |
| enable_change_feed | Enable change feed (required for point-in-time restore) | `bool` | `false` | no |
| private_dns_zone_blob_id | Resource ID of the private DNS zone for blob storage. If not provided, module will create one. | `string` | `""` | no |
| private_dns_zone_dfs_id | Resource ID of the private DNS zone for DFS storage. If not provided and ADLS Gen2 is enabled, module will create one. | `string` | `""` | no |
| virtual_network_id | Virtual Network ID to link private DNS zones (required if creating DNS zones) | `string` | `""` | no |
| enable_backup_integration | Enable Azure Backup integration via AzAPI | `bool` | `false` | no |
| backup_vault_id | Resource ID of the Azure Backup vault (required if enable_backup_integration is true) | `string` | `""` | no |
| backup_policy_id | Resource ID of the backup policy (required if enable_backup_integration is true) | `string` | `""` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the storage account |
| storage_account_name | The name of the storage account |
| storage_account_primary_blob_endpoint | The primary blob endpoint of the storage account |
| storage_account_primary_dfs_endpoint | The primary DFS endpoint of the storage account (ADLS Gen2) |
| storage_account_primary_access_key | The primary access key for the storage account (sensitive) |
| storage_account_primary_connection_string | The primary connection string for the storage account (sensitive) |
| blob_private_endpoint_id | The ID of the blob private endpoint |
| blob_private_endpoint_ip | The private IP address of the blob private endpoint |
| dfs_private_endpoint_id | The ID of the DFS private endpoint (if ADLS Gen2 is enabled) |
| dfs_private_endpoint_ip | The private IP address of the DFS private endpoint (if ADLS Gen2 is enabled) |
| blob_private_dns_zone_id | The ID of the blob private DNS zone |
| dfs_private_dns_zone_id | The ID of the DFS private DNS zone (if ADLS Gen2 is enabled) |
| backup_instance_id | The ID of the backup instance (if backup integration is enabled) |

## Point-in-Time Restore Requirements

To enable point-in-time restore, the following must be configured:

1. **Blob versioning** must be enabled (`enable_versioning = true`)
2. **Blob soft delete** must be enabled with retention days > restore days
3. **Change feed** must be enabled (`enable_change_feed = true` or `enable_point_in_time_restore = true`)
4. **Point-in-time restore days** must be less than blob soft delete retention days

Example configuration:
```hcl
blob_soft_delete_retention_days = 7
enable_versioning               = true
enable_point_in_time_restore    = true
point_in_time_restore_days      = 6
enable_change_feed              = true
```

## Azure Backup Integration

This module supports Azure Backup integration for blob storage using the AzAPI provider. To enable backup:

1. Create an Azure Backup Vault and Backup Policy (see [examples/adls-gen2-backup](./examples/adls-gen2-backup))
2. Set `enable_backup_integration = true`
3. Provide `backup_vault_id` and `backup_policy_id`
4. Grant the backup vault the "Storage Account Backup Contributor" role on the storage account

```hcl
resource "azurerm_role_assignment" "backup" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}
```

## Private DNS Zones

The module can either create new private DNS zones or use existing ones:

### Option 1: Module Creates DNS Zones (Default)
```hcl
module "storage_account" {
  # ... other settings ...
  virtual_network_id = azurerm_virtual_network.main.id
}
```

### Option 2: Use Existing DNS Zones
```hcl
module "storage_account" {
  # ... other settings ...
  private_dns_zone_blob_id = azurerm_private_dns_zone.blob.id
  private_dns_zone_dfs_id  = azurerm_private_dns_zone.dfs.id  # Only if ADLS Gen2
}
```

## Security Considerations

- **Network Access**: By default, the storage account denies all public network access and only allows access through private endpoints
- **TLS Version**: Minimum TLS 1.2 is enforced by default
- **Shared Access Keys**: Enabled by default but can be disabled if using Azure AD authentication only
- **Public Blob Access**: Disabled by default (`allow_nested_items_to_be_public = false`)
- **Service Bypass**: Azure services can bypass network rules (useful for backup and monitoring)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This module is licensed under the MIT License.

## Authors

- [Johan De Weerdt](https://github.com/JohanDeWeerdtMSFT)

## Resources Created

This module creates the following resources:

- `azurerm_storage_account` - Storage Account (GPv2)
- `azurerm_private_endpoint` - Private endpoint for blob storage
- `azurerm_private_endpoint` - Private endpoint for DFS (if ADLS Gen2 enabled)
- `azurerm_private_dns_zone` - Private DNS zone for blob (if not provided)
- `azurerm_private_dns_zone` - Private DNS zone for DFS (if ADLS Gen2 and not provided)
- `azurerm_private_dns_zone_virtual_network_link` - VNet links for DNS zones
- `azapi_resource` - Backup instance (if backup integration enabled)