variable aviatrix_fqdn_mode {
  default = "white"
}
variable aviatrix_fqdn_status {
  default = true
}
variable aviatrix_fqdn_gateway {
  default = "fqdn-gw-1"
}

variable aviatrix_fqdn_source_ip_list {
  default = ["172.31.0.0/16", "172.31.0.0/20"]
  type = list(string)
}
variable aviatrix_fqdn_domain {
  default = ["facebook.com", "google.com", "twitter.com", "cnn.com"]
  type = list(string)
}
variable aviatrix_fqdn_protocol {
  default = ["tcp", "udp", "udp", "udp"]
  type = list(string)
}
variable aviatrix_fqdn_port {
  default = [443, 480, 480, 480]
  type = list(string)
}
variable aviatrix_fqdn_action {
  default = ["Deny", "Base Policy", "Base Policy", "Base Policy"]
  type = list(string)
}

variable pass_thru_list {
  description = "List of CIDRs allowed to ignore/pass thru FQDN tag"
  default = [
    "125.93.201.144/28",
    "15.123.9.0/24"
  ]
  type = list(string)
}
