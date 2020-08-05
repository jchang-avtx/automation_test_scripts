variable aviatrix_fqdn_mode {}
variable aviatrix_fqdn_status {}
variable aviatrix_fqdn_tag {}
variable aviatrix_fqdn_gateway {}

variable aviatrix_fqdn_source_ip_list {
  type = list(string)
}
variable aviatrix_fqdn_domain {
  type = list(string)
}
variable aviatrix_fqdn_protocol {
  type = list(string)
}
variable aviatrix_fqdn_port {
  type = list(string)
}
variable aviatrix_fqdn_action {
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
