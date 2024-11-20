resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

resource "helm_release" "redis" {
  name       = "redis"
  namespace  = kubernetes_namespace.redis.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "17.11.1"

  set {
    name  = "architecture"
    value = "replication"
  }

  set {
    name  = "sentinel.enabled"
    value = "true"
  }

  set {
    name  = "replica.replicaCount"
    value = "2"
  }

  set {
    name  = "auth.enabled"
    value = "false"
  }
}