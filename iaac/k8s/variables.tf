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

variable "node_username" {
  description = "AKS node username"
  type        = string
  default     = "azureuser"
}

variable "tenant_id" {
  type = string
}

variable "object_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "dns_zone_name" {
  type = string
}