resource "cloudflare_zero_trust_infrastructure_access_target" "home_cluster_cluster_master_0" {
  account_id = var.account_id
  hostname   = "cluster-master-0"
  ip = {
    ipv4 = {
      ip_addr            = var.tunnel_ipv4_ips["cluster-master-0"]
      virtual_network_id = cloudflare_zero_trust_tunnel_virtual_network.home_cluster_vnet.id
    }
  }
}

resource "cloudflare_zero_trust_infrastructure_access_target" "home_cluster_cluster_node_0" {
  account_id = var.account_id
  hostname   = "cluster-node-0"
  ip = {
    ipv4 = {
      ip_addr            = var.tunnel_ipv4_ips["cluster-node-0"]
      virtual_network_id = cloudflare_zero_trust_tunnel_virtual_network.home_cluster_vnet.id
    }
  }
}

resource "cloudflare_zero_trust_access_application" "home_cluster_infrastructure" {
  account_id                  = var.account_id
  allow_authenticate_via_warp = true
  type                        = "infrastructure"
  name                        = "Home cluster infrastructure"
  target_criteria {
    port     = 22
    protocol = "SSH"
    target_attributes {
      name = "hostname"
      values = [
        cloudflare_zero_trust_infrastructure_access_target.home_cluster_cluster_master_0.hostname,
        cloudflare_zero_trust_infrastructure_access_target.home_cluster_cluster_node_0.hostname
      ]
    }
  }
}

resource "cloudflare_zero_trust_access_policy" "allow_emails" {
  application_id = cloudflare_zero_trust_access_application.home_cluster_infrastructure.id
  account_id     = var.account_id
  name           = "Allow emails"
  decision       = "allow"
  precedence     = 1

  include {
    email = var.allowed_emails
  }

  connection_rules {
    ssh {
      usernames = var.ssh_usernames
    }
  }
}
