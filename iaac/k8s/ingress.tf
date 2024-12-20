# Needed because public IP is not in cluster resource group
resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.resource_group_id
}

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

module "nginx-ingress" {
  source  = "terraform-iaac/nginx-controller/helm"

  namespace  = kubernetes_namespace.nginx_ingress.metadata[0].name
  ip_address = azurerm_public_ip.nginx_ingress_static_ip.ip_address

  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
      value = var.resource_group_name
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
      value = "/healthz"
      type  = "string"
    }
  ]
}

resource "azurerm_public_ip" "nginx_ingress_static_ip" {
  name                = "nginx-ingress-static-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_dns_a_record" "nginx_ingress_a_record" {
  name                = "*"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.nginx_ingress_static_ip.ip_address]
}