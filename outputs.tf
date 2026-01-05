output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "storage_account_primary_dfs_endpoint" {
  description = "The primary DFS endpoint of the storage account (ADLS Gen2)"
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "blob_private_endpoint_id" {
  description = "The ID of the blob private endpoint"
  value       = azurerm_private_endpoint.blob.id
}

output "blob_private_endpoint_ip" {
  description = "The private IP address of the blob private endpoint"
  value       = azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
}

output "dfs_private_endpoint_id" {
  description = "The ID of the DFS private endpoint (if ADLS Gen2 is enabled)"
  value       = var.enable_hierarchical_namespace ? azurerm_private_endpoint.dfs[0].id : null
}

output "dfs_private_endpoint_ip" {
  description = "The private IP address of the DFS private endpoint (if ADLS Gen2 is enabled)"
  value       = var.enable_hierarchical_namespace ? azurerm_private_endpoint.dfs[0].private_service_connection[0].private_ip_address : null
}

output "blob_private_dns_zone_id" {
  description = "The ID of the blob private DNS zone"
  value       = var.private_dns_zone_blob_id != "" ? var.private_dns_zone_blob_id : try(azurerm_private_dns_zone.blob[0].id, null)
}

output "dfs_private_dns_zone_id" {
  description = "The ID of the DFS private DNS zone (if ADLS Gen2 is enabled)"
  value       = var.enable_hierarchical_namespace ? (var.private_dns_zone_dfs_id != "" ? var.private_dns_zone_dfs_id : try(azurerm_private_dns_zone.dfs[0].id, null)) : null
}

output "backup_instance_id" {
  description = "The ID of the backup instance (if backup integration is enabled)"
  value       = var.enable_backup_integration ? azapi_resource.backup_instance[0].id : null
}
