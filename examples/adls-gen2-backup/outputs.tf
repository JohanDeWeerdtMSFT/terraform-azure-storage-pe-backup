output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account.storage_account_id
}

output "storage_account_primary_dfs_endpoint" {
  description = "Primary DFS endpoint for ADLS Gen2"
  value       = module.storage_account.storage_account_primary_dfs_endpoint
}

output "blob_private_endpoint_id" {
  description = "ID of the blob private endpoint"
  value       = module.storage_account.blob_private_endpoint_id
}

output "dfs_private_endpoint_id" {
  description = "ID of the DFS private endpoint"
  value       = module.storage_account.dfs_private_endpoint_id
}

output "backup_instance_id" {
  description = "ID of the backup instance"
  value       = module.storage_account.backup_instance_id
}

output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = azurerm_data_protection_backup_vault.example.id
}
