variable "do_token" {}


variable "atlas_db_name" {}

variable "atlas_password" {}

variable "jwtsecret" {}

provider "digitalocean" {
  token = var.do_token
}