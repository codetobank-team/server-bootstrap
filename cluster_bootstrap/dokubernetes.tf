resource "kubernetes_namespace" "ether-client-prod" {
  metadata {
    name = "etherbank-client-prod"
  }
}

resource "kubernetes_namespace" "ether-api-prod" {
  metadata {
    name = "etherbank-api-prod"
  }
}

resource "kubernetes_namespace" "argo-namespace" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "ingress-resource" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_secret" "atlasname" {
   metadata {
     name = "ether-prod-secrets"
     namespace = "etherbank-api-prod"
   }
   
   type = "Opaque"
   data = {
     "atlas_db_name" = var.atlas_db_name
     "atlas_password" = var.atlas_password
     "jwtsecret" = var.jwtsecret
   }
}

resource "kubernetes_secret" "atlasname" {
   metadata {
     name = "ether-prod-secrets"
     namespace = "etherbank-api-prod"
   }
   
   type = "Opaque"
   data = {
     "atlas_db_name" = var.atlas_db_name
     "atlas_password" = var.atlas_password
     "jwtsecret" = var.jwtsecret
   }
}



