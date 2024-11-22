resource "azurerm_linux_virtual_machine" "vm" {
  name                = "jenkins-vm"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  size                = "Standard_DS2_v2"
  admin_username      = var.vm_username

  admin_ssh_key {
    username   = var.vm_username
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

  filename = "${path.module}/provision/${var.pem_filename}"
  content  = azurerm_key_vault_secret.private_key.value

  file_permission = "0600" # Ensure the key file is secure
}

resource "random_password" "jenkins_admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*"
}

resource "azurerm_key_vault_secret" "jenkins_admin_password" {
  name         = "jenkins-admin-password"
  value        = random_password.jenkins_admin_password.result
  key_vault_id = var.key_vault_id
}

resource "terraform_data" "provision" {
  depends_on       = [azurerm_linux_virtual_machine.vm, local_file.private_key_file]

  provisioner "local-exec" {
    command     = <<EOT
      ansible-playbook -i '${azurerm_linux_virtual_machine.vm.public_ip_address},' \
                       -e 'ansible_user=${var.vm_username}' \
                       -e 'admin_password=${azurerm_key_vault_secret.jenkins_admin_password.value}' \
                       -e 'acr_sp_id=${var.acr_sp_id}' \
                       -e 'acr_sp_password=${var.acr_sp_password}' \
                       -e 'aks_sp_id=${var.aks_sp_id}' \
                       -e 'aks_sp_password=${var.aks_sp_password}' \
                       -e 'tenant_id=${var.tenant_id}' \
                       --private-key ./${var.pem_filename} \
                       jenkins.yml
    EOT
    working_dir = "${path.module}/provision"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}