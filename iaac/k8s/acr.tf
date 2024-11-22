resource "azurerm_container_registry" "acr" {
  name                = "bebyxRegistry"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  admin_enabled       = false

}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}


resource "azuread_application" "acr" {
  display_name = "registry"
  owners       = [var.object_id]
}

resource "azuread_service_principal" "acr_sp" {
  client_id                    = azuread_application.acr.client_id
  app_role_assignment_required = false
  owners                       = [var.object_id]
}

resource "azuread_service_principal_password" "acr_sp_secret" {
  service_principal_id = azuread_service_principal.acr_sp.id
  end_date             = "2099-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "acr_sp_role" {
  principal_id         = azuread_service_principal.acr_sp.object_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_key_vault_secret" "acr_client_secret" {
  name         = "acr-client-secret"
  value        = azuread_service_principal_password.acr_sp_secret.value
  key_vault_id = var.key_vault_id
}
