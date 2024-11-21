output "ingress_pip" {
  value = azurerm_public_ip.nginx_ingress_static_ip.ip_address
}

output "acr_client_id" {
  value = azuread_service_principal.acr_sp.client_id
}

output "acr" {
  value = azurerm_container_registry.acr.name
}