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

module "jenkins" {
  source = "./cicd"

  resource_group_id = data.azurerm_resource_group.custom_rg.id
  key_vault_id      = azurerm_key_vault.key_vault.id
}

output "vm_public_ip_from_module" {
  value = module.jenkins.vm_ip
}

output "public_ssh" {
  value = module.jenkins.key_data
}