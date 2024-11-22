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

resource "azuread_application" "aks" {
  display_name = "kubernetes"
  owners       = [var.object_id]
}

resource "azuread_service_principal" "aks_sp" {
  client_id                    = azuread_application.aks.client_id
  app_role_assignment_required = false
  owners                       = [var.object_id]
}

resource "azuread_service_principal_password" "aks_sp_secret" {
  service_principal_id = azuread_service_principal.aks_sp.id
  end_date             = "2025-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "aks_sp_contributor" {
  principal_id         = azuread_service_principal.aks_sp.object_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = azurerm_kubernetes_cluster.k8s.id
}

resource "azurerm_key_vault_secret" "aks_client_secret" {
  name         = "aks-client-secret"
  value        = azuread_service_principal_password.aks_sp_secret.value
  key_vault_id = var.key_vault_id
}
