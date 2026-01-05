variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, 3-24 chars, lowercase and numbers only)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters, lowercase letters and numbers only."
  }
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "enable_https_traffic_only" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Enable public network access to storage account"
  type        = bool
  default     = false
}

variable "enable_hierarchical_namespace" {
  description = "Enable ADLS Gen2 hierarchical namespace"
  type        = bool
  default     = false
}

variable "enable_nfs_v3" {
  description = "Enable NFS v3 protocol"
  type        = bool
  default     = false
}

variable "blob_soft_delete_retention_days" {
  description = "Number of days to retain deleted blobs (0 to disable)"
  type        = number
  default     = 7
  validation {
    condition     = var.blob_soft_delete_retention_days >= 0 && var.blob_soft_delete_retention_days <= 365
    error_message = "Retention days must be between 0 and 365."
  }
}

variable "container_soft_delete_retention_days" {
  description = "Number of days to retain deleted containers (0 to disable)"
  type        = number
  default     = 7
  validation {
    condition     = var.container_soft_delete_retention_days >= 0 && var.container_soft_delete_retention_days <= 365
    error_message = "Retention days must be between 0 and 365."
  }
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "enable_point_in_time_restore" {
  description = "Enable point-in-time restore for containers"
  type        = bool
  default     = false
}

variable "point_in_time_restore_days" {
  description = "Number of days for point-in-time restore (requires versioning and blob soft delete)"
  type        = number
  default     = 6
  validation {
    condition     = var.point_in_time_restore_days >= 1 && var.point_in_time_restore_days <= 365
    error_message = "Point-in-time restore days must be between 1 and 365."
  }
}

variable "enable_change_feed" {
  description = "Enable change feed (required for point-in-time restore)"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_blob_id" {
  description = "Resource ID of the private DNS zone for blob storage (privatelink.blob.core.windows.net). If not provided, module will create one."
  type        = string
  default     = ""
}

variable "private_dns_zone_dfs_id" {
  description = "Resource ID of the private DNS zone for DFS storage (privatelink.dfs.core.windows.net). If not provided and ADLS Gen2 is enabled, module will create one."
  type        = string
  default     = ""
}

variable "virtual_network_id" {
  description = "Virtual Network ID to link private DNS zones (required if creating DNS zones)"
  type        = string
  default     = ""
}

variable "enable_backup_integration" {
  description = "Enable Azure Backup integration via AzAPI"
  type        = bool
  default     = false
}

variable "backup_vault_id" {
  description = "Resource ID of the Azure Backup vault (required if enable_backup_integration is true)"
  type        = string
  default     = ""
}

variable "backup_policy_id" {
  description = "Resource ID of the backup policy (required if enable_backup_integration is true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
