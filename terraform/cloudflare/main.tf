terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.14.0"
}

provider "cloudflare" {
  ## token pulled from CLOUDFLARE_API_TOKEN environment variable
}

locals {
  home_cluster_cidr              = "170.0.0.0/24"
  google_sheets_service_token_id = "917547af-0bfa-4471-ab75-5d96fa4191d7"
  domain                         = "cristobalszk.dev"
  public_subdomain               = "public-k8s"
  private_subdomain              = "private-k8s"
  public_domain                  = "${local.public_subdomain}.${local.domain}"
  private_domain                 = "${local.private_subdomain}.${local.domain}"
  nginx_service_localhost_url    = "http://localhost:32415"
}


resource "cloudflare_zero_trust_tunnel_virtual_network" "home_cluster_vnet" {
  account_id = var.account_id
  name       = "Home cluster vnet"
  comment    = "Virtual network used for home cluster routing"
}
