resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "jenkins-public-key"
  location  = var.resource_group_location
  parent_id = var.resource_group_id
}

resource "azurerm_key_vault_secret" "private_key" {
  name         = "jenkins-private-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.privateKey
  key_vault_id = var.key_vault_id
}