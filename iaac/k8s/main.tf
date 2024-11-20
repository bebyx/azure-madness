terraform {
  required_version = ">=1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }
}

# Datasource to get Latest Azure AKS latest Version
data azurerm_kubernetes_service_versions current {
  location        = var.resource_group_location
  include_preview = false
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnetwork_name
  address_prefixes     = ["10.0.2.0/24"]
}

resource azurerm_kubernetes_cluster k8s {
  name                      = "aks"
  location                  = var.resource_group_location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "aks-dns"
  kubernetes_version        = data.azurerm_kubernetes_service_versions.current.latest_version
  sku_tier                  = "Standard"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "pool"
    type                = "VirtualMachineScaleSets"
    vm_size             = "Standard_A2_v2"
    os_disk_size_gb     = 50
    node_count          = 1

    vnet_subnet_id = azurerm_subnet.aks_subnet.id

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  linux_profile {
    admin_username = var.node_username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"

    service_cidr      = "10.2.0.0/16"
    dns_service_ip    = "10.2.0.10"
  }
}

resource "azurerm_dns_zone" "aks_dns" {
  name                = "artem-bebik.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "dns_role_assignment" {
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
  role_definition_name = "DNS Zone Contributor"
  scope                = azurerm_dns_zone.aks_dns.id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.resource_group_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  create_namespace = true
  version          = "4.11.3"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = var.resource_group_name
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.nginx_static_ip.ip_address
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = "k8s"
  }
}

resource "azurerm_public_ip" "nginx_static_ip" {
  name                = "nginx-ingress-static-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_dns_a_record" "nginx_ingress_a_record" {
  name                = "k8s"
  zone_name           = azurerm_dns_zone.aks_dns.name
  resource_group_name = azurerm_dns_zone.aks_dns.resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.nginx_static_ip.ip_address]
}

output "dns_zone_id" {
  value = azurerm_dns_zone.aks_dns.id
}