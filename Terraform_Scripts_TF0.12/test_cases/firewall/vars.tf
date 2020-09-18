variable "aviatrix_firewall_base_policy" {}
variable "aviatrix_firewall_packet_logging" {}

variable "aviatrix_firewall_policy_source_ip" {
  type = list(string)
}
variable "aviatrix_firewall_policy_destination_ip" {
  type = list(string)
}
variable "aviatrix_firewall_policy_protocol" {
  type = list(string)
}
variable "aviatrix_firewall_policy_port" {
  type = list(string)
}
variable "aviatrix_firewall_policy_action" {
  type = list(string)
}
variable "aviatrix_firewall_policy_log_enable" {
  type = list(string)
}
variable "aviatrix_firewall_policy_description" {}
