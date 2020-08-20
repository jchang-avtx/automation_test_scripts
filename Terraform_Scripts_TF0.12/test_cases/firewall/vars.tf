variable aviatrix_firewall_base_policy {
  default = "allow-all"
  description = "Base policy for the firewall: allow or deny"
}
variable aviatrix_firewall_packet_logging {
  default = true
  description = "Enable/ disable packet logging in the stateful firewall"
}

variable aviatrix_firewall_policy_source_ip {
  default = ["10.10.10.10/32",
             "12.12.12.12/32",
             "14.14.14.14/32",
             "16.16.16.16/32",
             "18.18.18.18/32",
             "20.20.20.20/32",
             "22.22.22.22/32",
             "24.24.24.24/32"]
  type = list(string)
}
variable aviatrix_firewall_policy_destination_ip {
  default = ["11.11.11.11/32",
             "13.13.13.13/32",
             "15.15.15.15/32",
             "17.17.17.17/32",
             "19.19.19.19/32",
             "21.21.21.21/32",
             "23.23.23.23/32",
             "25.25.25.25/32"]
  type = list(string)
}
variable aviatrix_firewall_policy_protocol {
  default = ["tcp",
             "udp",
             "sctp",
             "rdp",
             "dccp",
             "all",
             "tcp",
             "tcp"]
  type = list(string)
}
variable aviatrix_firewall_policy_port {
  default = [69,
             "0:65535",
             "25:420",
             420,
             65535,
             "",
             "0:100",
             443]
  type = list(string)
}
variable aviatrix_firewall_policy_action {
  default = ["allow", "deny", "force-drop"]
  description = "Policy action to take on session/connection"
  type = list(string)
}
variable aviatrix_firewall_policy_log_enable {
  default = [true, false]
  type = list(string)
}
variable aviatrix_firewall_policy_description {
  default = "icmp firewall rule #1"
  description = "Description of the policy"
}
