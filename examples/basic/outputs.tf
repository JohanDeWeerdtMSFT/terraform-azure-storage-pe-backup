output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account.storage_account_id
}

output "blob_private_endpoint_id" {
  description = "ID of the blob private endpoint"
  value       = module.storage_account.blob_private_endpoint_id
}

output "blob_private_endpoint_ip" {
  description = "Private IP address of the blob private endpoint"
  value       = module.storage_account.blob_private_endpoint_ip
}
