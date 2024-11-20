resource "azurerm_key_vault" "cluster_kv" {
  name                        = "bebyx-k8s-kv"
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "aks_access" {
  key_vault_id               = azurerm_key_vault.cluster_kv.id
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  object_id                  = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
  secret_permissions         = ["Get", "List"]
}


resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.3.0"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "time_sleep" "wait" {
  create_duration = "60s"

  depends_on = [helm_release.csi_secrets_store]
}

resource "kubectl_manifest" "azure_key_vault_secrets" {
  yaml_body = <<YAML
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: azure-keyvault-secrets
    spec:
      provider: azure
      parameters:
        usePodIdentity: "false"
        useVMManagedIdentity: "true"  # Use this for managed identity
        keyvaultName: ${azurerm_key_vault.cluster_kv.name}
        cloudName: ""
        tenantId: "${var.tenant_id}"
        objects: |
          array:
            - |
              objectName: sample-secret
              objectType: secret
        resourceGroup: ${var.resource_group_name}
        subscriptionId: "${var.subscription_id}"
  YAML

  depends_on = [time_sleep.wait]
}