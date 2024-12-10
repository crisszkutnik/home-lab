variable "account_id" {
  type = string
}

variable "home_cluster_tunnel_secret" {
  type = string
}

variable "allowed_emails" {
  type = list(string)
}

variable "ssh_usernames" {
  type = list(string)
}

variable "tunnel_ipv4_ips" {
  type = map(string)
}
