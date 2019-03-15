variable "aviatrix_controller_ip" {}
variable "aviatrix_controller_username" {}
variable "aviatrix_controller_password" {}

variable "aviatrix_firewall_tag_name" {}
variable "cidr_list_tag_name" {
  type = "list"
}
variable "cidr_list_cidr" {
  type = "list"
}
