resource "azurerm_linux_virtual_machine" "vm" {
  name                = "jenkins-vm"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
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

resource "local_file" "private_key_file" {
  depends_on = [azurerm_key_vault_secret.private_key]

  filename = "${path.module}/provision/jenkins-server.pem"
  content  = azurerm_key_vault_secret.private_key.value

  file_permission = "0600" # Ensure the key file is secure
}

resource "terraform_data" "provision" {
  depends_on = [azurerm_linux_virtual_machine.vm,local_file.private_key_file]

  provisioner "local-exec" {
    command     = <<EOT
      ansible-playbook -i "${azurerm_linux_virtual_machine.vm.public_ip_address}," \
                       -e 'ansible_user=azureuser' \
                       --private-key ./jenkins-server.pem \
                       jenkins.yml
    EOT
    working_dir = "${path.module}/provision"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

output key_data {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}
