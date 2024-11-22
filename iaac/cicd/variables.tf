variable "resource_group_name" {
  type    = string
  default = "Artem-Candidate"
}

variable "resource_group_location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_id" {
  type = string
}

variable "vnetwork_name" {
  type = string
}

variable "key_vault_id" {
  description = "Common key vault ID to store secrets"
  type        = string
}

variable "vm_username" {
  description = "Virtual Machine username"
  type        = string
  default     = "azureuser"
}

variable "pem_filename" {
  description = "File name for Jenkins server private SSH key"
  type        = string
  default     = "jenkins-server.pem"
}

variable "dns_zone_name" {
  type = string
}

variable "acr_sp_id" {
  type = string
}

variable "acr_sp_password" {
  type = string
}