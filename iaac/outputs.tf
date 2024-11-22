output "vm_public_ip" {
  value = module.jenkins.vm_ip
}

output "public_ssh" {
  value = module.jenkins.key_data
}

output "ingress_pip" {
  value = module.aks.ingress_pip
}

output "acr_client_id" {
  value = module.aks.acr_sp_client_id
}

output "aks_client_id" {
  value = module.aks.aks_sp_client_id
}

output "acr" {
  value = module.aks.acr
}