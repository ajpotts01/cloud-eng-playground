output "arm_client_id" {
  value = azurerm_user_assigned_identity.sa_github.client_id
}

output "arm_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "arm_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg_state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa_state.name
}

output "container_name" {
  value = azurerm_storage_container.storage_container_state.name
}