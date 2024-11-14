terraform {
  required_version = ">=1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "jenkins" {
  source = "./cicd"
}

output "vm_public_ip_from_module" {
  value = module.jenkins.vm_ip
}