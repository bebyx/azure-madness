output "ingress_pip" {
  value = azurerm_public_ip.nginx_ingress_static_ip.ip_address
}