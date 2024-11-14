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

locals {
  resource_group_name     = "Artem-Candidate"
  resource_group_location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "common-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "jenkins-nic"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "jenkins-vm"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/azure-vm.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "jenkins_pip" {
  name                = "jenkins-public-ip"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

output "vm_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}
