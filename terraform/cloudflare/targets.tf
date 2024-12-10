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

resource "cloudflare_zero_trust_infrastructure_access_target" "home_cluster_cluster_node_1" {
  account_id = var.account_id
  hostname   = "cluster-node-1"
  ip = {
    ipv4 = {
      ip_addr            = var.tunnel_ipv4_ips["cluster-node-1"]
      virtual_network_id = cloudflare_zero_trust_tunnel_virtual_network.home_cluster_vnet.id
    }
  }
}
