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

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "custom_rg" {
  name = "Artem-Candidate"
}

locals {
  //location = data.azurerm_resource_group.custom_rg.location
  location = "northeurope"
}

resource "azurerm_key_vault" "key_vault" {
  name                = "bebyx-common-kv"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.custom_rg.name

  sku_name = "standard"

  tenant_id = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "Purge",
      "List"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "common-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = data.azurerm_resource_group.custom_rg.name
}

resource "azurerm_dns_zone" "common" {
  name                = "artem-bebik.com"
  resource_group_name = data.azurerm_resource_group.custom_rg.name
}

module "jenkins" {
  source = "./cicd"

  resource_group_id       = data.azurerm_resource_group.custom_rg.id
  key_vault_id            = azurerm_key_vault.key_vault.id
  vnetwork_name           = azurerm_virtual_network.vnet.name
  resource_group_location = local.location
  dns_zone_name           = azurerm_dns_zone.common.name
  acr_sp_id               = module.aks.acr_sp_client_id
  acr_sp_password         = module.aks.acr_sp_password
  aks_sp_id               = module.aks.aks_sp_client_id
  aks_sp_password         = module.aks.aks_sp_password
  tenant_id               = data.azurerm_client_config.current.tenant_id
}

module "aks" {
  source = "./k8s"

  resource_group_id       = data.azurerm_resource_group.custom_rg.id
  key_vault_id            = azurerm_key_vault.key_vault.id
  vnetwork_name           = azurerm_virtual_network.vnet.name
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  subscription_id         = data.azurerm_client_config.current.subscription_id
  resource_group_location = local.location
  dns_zone_id             = azurerm_dns_zone.common.id
  dns_zone_name           = azurerm_dns_zone.common.name
}
