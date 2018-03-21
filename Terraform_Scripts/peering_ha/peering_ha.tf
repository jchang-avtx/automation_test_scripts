# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
       username = "${var.controller_username}"
       password = "${var.controller_password}"
}

# Create encrypteed peering between two aviatrix gateway
resource "aviatrix_tunnel" "PEERING"{
           vpc_name1 = "${var.gateway_name1}"
           vpc_name2 = "${var.gateway_name2}"
           enable_ha = "${var.enable_ha}"
             cluster = "no"
    over_aws_peering = "no"
    peering_hastatus = "yes"
}
