variable "do_token" {}


variable "atlas_db_name" {}

variable "atlas_password" {}

variable "jwtsecret" {}

variable "contract_address" {}

variable "contract_private_key" {}

variable "infura_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "dokub3" {
  name    = "dokub3"
  region  = "ams3"
  version = "1.18.3-do.0"
  tags    = ["test"]

  node_pool {
    name       = "test-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }
}

provider "kubernetes" {
  host = digitalocean_kubernetes_cluster.dokub3.endpoint

  client_certificate     = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_certificate)
  client_key             = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.cluster_ca_certificate)
}