output "ingress_pip" {
  value = azurerm_public_ip.nginx_ingress_static_ip.ip_address
}

output "acr_sp_client_id" {
  value = azuread_service_principal.acr_sp.client_id
}

output "acr_sp_password" {
  value = azuread_service_principal_password.acr_sp_secret.value
}

output "aks_sp_client_id" {
  value = azuread_service_principal.aks_sp.client_id
}

output "aks_sp_password" {
  value = azuread_service_principal_password.aks_sp_secret.value
}

output "acr" {
  value = azurerm_container_registry.acr.name
}