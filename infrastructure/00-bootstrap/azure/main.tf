# Makes sure to grab all the relevant subscription etc. info
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg_state" {
  name     = "rg-${var.project_name}-tf-state"
  location = var.region
}

resource "azurerm_storage_account" "sa_state" {
  name                     = "${replace(var.project_name, "-", "")}tfstate" # Azure storage accounts can't have spaces in their names
  location                 = var.region
  resource_group_name      = azurerm_resource_group.rg_state.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false
  account_kind             = "StorageV2"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "storage_container_state" {
  name                  = "${var.project_name}-tf-state"
  storage_account_id    = azurerm_storage_account.sa_state.id
  container_access_type = "private"
}

# Required for Terraform to run in bootstrap mode against my identity
resource "azurerm_role_assignment" "self_blob_owner" {
  scope                = azurerm_storage_account.sa_state.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_user_assigned_identity" "sa_github" {
  location            = azurerm_resource_group.rg_state.location
  name                = "sa-${var.project_name}-infra-cicd"
  resource_group_name = azurerm_resource_group.rg_state.name
}

resource "azurerm_role_assignment" "sa_github_blob_contributor" {
  scope                = azurerm_storage_account.sa_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.sa_github.principal_id
}

resource "azurerm_role_assignment" "sa_github_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.sa_github.principal_id
}

# Test comment
resource "azurerm_role_assignment" "sa_github_rbac" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azurerm_user_assigned_identity.sa_github.principal_id
}

resource "azurerm_federated_identity_credential" "sa_github_identity" {
  name                      = "cicd-${var.project_name}-github"
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_repo_owner_id}/${var.github_repo_id}:ref:refs/heads/main"
  audience                  = ["api://AzureADTokenExchange"]
  user_assigned_identity_id = azurerm_user_assigned_identity.sa_github.id
}