resource "cloudflare_zero_trust_device_profiles" "default_warp_policy" {
  account_id           = var.account_id
  name                 = "Default"
  description          = "Default WARP policy. Configured via Terraform"
  default              = true
  enabled              = true
  service_mode_v2_mode = "warp"
}

resource "cloudflare_zero_trust_split_tunnel" "default_warp_policy_split_tunnel" {
  account_id = var.account_id
  policy_id  = cloudflare_zero_trust_device_profiles.default_warp_policy.id
  mode       = "include"
  tunnels {
    address     = local.home_cluster_cidr
    description = "Home cluster private VNET address space"
  }
  tunnels {
    host        = "*.cristobalszk.dev"
    description = "My domain"
  }
  tunnels {
    host        = "edge.browser.run"
    description = "Required for include tunnel to work correctly"
  }
  tunnels {
    host        = "cristobalszk.cloudflareaccess.com"
    description = "Required for include tunnel to work correctly"
  }
}
