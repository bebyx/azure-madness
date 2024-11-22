output "ingress_pip" {
  value = azurerm_public_ip.nginx_ingress_static_ip.ip_address
}

output "acr_sp_client_id" {
  value = azuread_service_principal.acr_sp.client_id
}

output "acr_sp_password" {
  value = azuread_service_principal_password.acr_sp_secret.value
}

output "acr" {
  value = azurerm_container_registry.acr.name
}