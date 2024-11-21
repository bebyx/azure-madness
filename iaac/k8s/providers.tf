terraform {
  required_version = ">=1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.10"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

data "azurerm_client_config" "current" {}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}