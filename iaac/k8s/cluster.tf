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
