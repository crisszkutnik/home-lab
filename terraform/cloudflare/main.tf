terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.8.4"
}

provider "cloudflare" {
  ## token pulled from CLOUDFLARE_API_TOKEN environment variable
}

locals {
  home_cluster_cidr = "170.0.0.0/24"
}


resource "cloudflare_zero_trust_tunnel_virtual_network" "home_cluster_vnet" {
  account_id = var.account_id
  name       = "Home cluster vnet"
  comment    = "Virtual network used for home cluster routing"
}
