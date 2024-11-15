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

variable "key_vault_id" {
  description = "Common key vault ID to store secrets"
  type        = string
}