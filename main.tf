# Storage Account with GPv2, hardened for security
resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  public_network_access_enabled   = var.public_network_access_enabled
  is_hns_enabled                  = var.enable_hierarchical_namespace
  nfsv3_enabled                   = var.enable_nfs_v3
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.blob_soft_delete_retention_days > 0 ? [1] : []
      content {
        days = var.blob_soft_delete_retention_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.container_soft_delete_retention_days > 0 ? [1] : []
      content {
        days = var.container_soft_delete_retention_days
      }
    }

    versioning_enabled = var.enable_versioning

    dynamic "restore_policy" {
      for_each = var.enable_point_in_time_restore ? [1] : []
      content {
        days = var.point_in_time_restore_days
      }
    }

    change_feed_enabled           = var.enable_change_feed || var.enable_point_in_time_restore
    change_feed_retention_in_days = var.enable_point_in_time_restore ? var.point_in_time_restore_days + 1 : null
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  count               = var.private_dns_zone_blob_id == "" ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  count                 = var.private_dns_zone_blob_id == "" && var.virtual_network_id != "" ? 1 : 0
  name                  = "${var.storage_account_name}-blob-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = var.virtual_network_id
  tags                  = var.tags
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_blob_id != "" ? var.private_dns_zone_blob_id : azurerm_private_dns_zone.blob[0].id]
  }

  tags = var.tags
}

# Private DNS Zone for DFS (ADLS Gen2)
resource "azurerm_private_dns_zone" "dfs" {
  count               = var.enable_hierarchical_namespace && var.private_dns_zone_dfs_id == "" ? 1 : 0
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  count                 = var.enable_hierarchical_namespace && var.private_dns_zone_dfs_id == "" && var.virtual_network_id != "" ? 1 : 0
  name                  = "${var.storage_account_name}-dfs-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dfs[0].name
  virtual_network_id    = var.virtual_network_id
  tags                  = var.tags
}

# Private Endpoint for DFS (ADLS Gen2)
resource "azurerm_private_endpoint" "dfs" {
  count               = var.enable_hierarchical_namespace ? 1 : 0
  name                = "${var.storage_account_name}-dfs-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-dfs-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name = "dfs-dns-zone-group"
    private_dns_zone_ids = [
      var.enable_hierarchical_namespace && var.private_dns_zone_dfs_id != "" ? var.private_dns_zone_dfs_id : azurerm_private_dns_zone.dfs[0].id
    ]
  }

  tags = var.tags
}

# Azure Backup Integration via AzAPI
resource "azapi_resource" "backup_instance" {
  count     = var.enable_backup_integration ? 1 : 0
  type      = "Microsoft.DataProtection/backupVaults/backupInstances@2023-05-01"
  name      = "${var.storage_account_name}-backup-instance"
  parent_id = var.backup_vault_id

  body = jsonencode({
    properties = {
      dataSourceInfo = {
        datasourceType   = "Microsoft.Storage/storageAccounts/blobServices"
        objectType       = "Datasource"
        resourceID       = azurerm_storage_account.this.id
        resourceName     = azurerm_storage_account.this.name
        resourceType     = "Microsoft.Storage/storageAccounts"
        resourceUri      = azurerm_storage_account.this.id
        resourceLocation = var.location
      }
      policyInfo = {
        policyId = var.backup_policy_id
      }
      objectType = "BackupInstance"
    }
  })

  depends_on = [
    azurerm_storage_account.this
  ]
}
