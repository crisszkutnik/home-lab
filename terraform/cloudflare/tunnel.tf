resource "cloudflare_zero_trust_tunnel_cloudflared" "home_cluster" {
  account_id = var.account_id
  name       = "Home cluster"
  secret     = var.home_cluster_tunnel_secret
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_cluster_config" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_cluster.id

  config {
    warp_routing {
      enabled = true
    }

    ingress_rule {
      hostname = local.public_domain
      service  = local.nginx_service_localhost_url
    }

    ingress_rule {
      hostname = local.private_domain
      service  = local.nginx_service_localhost_url
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_route" "home_cluster_route" {
  account_id         = var.account_id
  tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared.home_cluster.id
  network            = local.home_cluster_cidr
  comment            = "Route used in the local home cluster"
  virtual_network_id = cloudflare_zero_trust_tunnel_virtual_network.home_cluster_vnet.id
}
