resource "azuread_application" "external_dns" {
  display_name = "aks-external-dns"
  owners       = [var.object_id]
}

resource "azuread_service_principal" "external_dns" {
  client_id                    = azuread_application.external_dns.client_id
  app_role_assignment_required = false
  owners                       = [var.object_id]
}

resource "azuread_service_principal_password" "external_dns_sp_secret" {
  service_principal_id = azuread_service_principal.external_dns.id
  end_date             = "2099-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "external_dns_contributor" {
  principal_id         = azuread_service_principal.external_dns.object_id
  role_definition_name = "DNS Zone Contributor"
  scope                = azurerm_dns_zone.aks_dns.id
}

resource "azurerm_role_assignment" "external_dns_reader" {
  principal_id         = azuread_service_principal.external_dns.object_id
  role_definition_name = "Reader"
  scope                = azurerm_dns_zone.aks_dns.id
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.6.0"

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.tenantId"
    value = var.tenant_id
  }

  set {
    name  = "azure.subscriptionId"
    value = var.subscription_id
  }

  set {
    name  = "azure.resourceGroup"
    value = var.resource_group_name
  }

  set {
    name  = "azure.aadClientId"
    value = azuread_service_principal.external_dns.id
  }

  set {
    name  = "azure.aadClientSecret"
    value = azuread_service_principal_password.external_dns_sp_secret.value
  }

  set {
    name  = "azure.cloud"
    value = "AzurePublicCloud"
  }

  set {
    name  = "policy"
    value = "sync"
  }
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}

module "cert_manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = "artem.bebyk@gmail.com"
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
}