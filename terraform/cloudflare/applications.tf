
/*

  Infrastructure application

*/

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
        cloudflare_zero_trust_infrastructure_access_target.home_cluster_cluster_node_0.hostname,
        cloudflare_zero_trust_infrastructure_access_target.home_cluster_cluster_node_1.hostname
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

/*

  Self-hosted application

*/

resource "cloudflare_zero_trust_access_application" "home_cluster_self_hosted" {
  account_id                  = var.account_id
  allow_authenticate_via_warp = true
  type                        = "self_hosted"
  name                        = "Home cluster private K8s endpoints"
  session_duration            = "24h"
  auto_redirect_to_identity   = true
  domain                      = local.private_domain
}

resource "cloudflare_zero_trust_access_policy" "home_cluster_self_service_allow_service_token" {
  application_id = cloudflare_zero_trust_access_application.home_cluster_self_hosted.id
  account_id     = var.account_id
  name           = "Allow service token"
  decision       = "non_identity"
  precedence     = 2

  include {
    service_token = [local.google_sheets_service_token_id]
  }
}

resource "cloudflare_zero_trust_access_policy" "home_cluster_self_service_allow_emails" {
  application_id = cloudflare_zero_trust_access_application.home_cluster_self_hosted.id
  account_id     = var.account_id
  name           = "Allow emails"
  decision       = "allow"
  precedence     = 1

  include {
    email = var.allowed_emails
  }
}
