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

# Example resource group (or use existing)
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-example"
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

# Storage account module
module "storage_account" {
  source = "../.."

  storage_account_name     = "stexample${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  subnet_id                = azurerm_subnet.example.id
  virtual_network_id       = azurerm_virtual_network.example.id
  account_replication_type = "LRS"

  # Security settings
  enable_https_traffic_only     = true
  public_network_access_enabled = false
  min_tls_version               = "TLS1_2"

  # Blob recovery features
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  enable_versioning                    = true

  tags = {
    Environment = "Example"
    ManagedBy   = "Terraform"
  }
}

# Random suffix for unique storage account name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
