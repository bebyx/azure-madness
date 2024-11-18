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

resource "azurerm_key_vault" "key_vault" {
  name                = "bebyx-secrets"
  location            = data.azurerm_resource_group.custom_rg.location
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
  location            = data.azurerm_resource_group.custom_rg.location
  resource_group_name = data.azurerm_resource_group.custom_rg.name
}

module "jenkins" {
  source = "./cicd"

  resource_group_id = data.azurerm_resource_group.custom_rg.id
  key_vault_id      = azurerm_key_vault.key_vault.id
  vnetwork_name     = azurerm_virtual_network.vnet.name
}

module "aks" {
  source = "./k8s"

  resource_group_id = data.azurerm_resource_group.custom_rg.id
  key_vault_id      = azurerm_key_vault.key_vault.id
  vnetwork_name     = azurerm_virtual_network.vnet.name
  tenant_id   = data.azurerm_client_config.current.tenant_id
  subscription_id = data.azurerm_client_config.current.subscription_id
}

output "vm_public_ip_from_module" {
  value = module.jenkins.vm_ip
}

output "public_ssh" {
  value = module.jenkins.key_data
}

output "dns_zone_id" {
  value = module.aks.dns_zone_id
}