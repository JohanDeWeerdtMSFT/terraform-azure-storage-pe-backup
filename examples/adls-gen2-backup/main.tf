terraform {
  required_version = ">= 1.3.0"

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

provider "azurerm" {
  features {}
}

provider "azapi" {}

# Example resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-adls-backup"
  location = "East US"
}

# Example virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Example subnet for private endpoint
resource "azurerm_subnet" "example" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Azure Backup Vault
resource "azurerm_data_protection_backup_vault" "example" {
  name                = "bvault-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }
}

# Backup Policy
resource "azurerm_data_protection_backup_policy_blob_storage" "example" {
  name                            = "backup-policy-blob"
  vault_id                        = azurerm_data_protection_backup_vault.example.id
  operational_default_retention_duration = "P30D"
}

# Storage account module with ADLS Gen2 and backup
module "storage_account" {
  source = "../.."

  storage_account_name     = "stadls${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  subnet_id                = azurerm_subnet.example.id
  virtual_network_id       = azurerm_virtual_network.example.id
  account_replication_type = "LRS"

  # ADLS Gen2
  enable_hierarchical_namespace = true

  # Security settings
  enable_https_traffic_only     = true
  public_network_access_enabled = false
  min_tls_version               = "TLS1_2"

  # Blob recovery features
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  enable_versioning                    = true
  enable_point_in_time_restore         = true
  point_in_time_restore_days           = 6
  enable_change_feed                   = true

  # Azure Backup
  enable_backup_integration = true
  backup_vault_id           = azurerm_data_protection_backup_vault.example.id
  backup_policy_id          = azurerm_data_protection_backup_policy_blob_storage.example.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    DataLake    = "Enabled"
  }
}

# Grant backup vault access to storage account
resource "azurerm_role_assignment" "backup_operator" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.example.identity[0].principal_id
}

# Random suffix for unique storage account name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
