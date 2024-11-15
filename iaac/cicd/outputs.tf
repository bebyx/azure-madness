output key_data {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

output "vm_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}