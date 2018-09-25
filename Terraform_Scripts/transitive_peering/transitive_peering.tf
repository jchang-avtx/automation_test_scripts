# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.aviatrix_controller_ip}"
       username = "${var.aviatrix_controller_username}"
       password = "${var.aviatrix_controller_password}"
}

# Create encrypteed peering between two GWs
# A requirement for transitive peering feature
resource "aviatrix_tunnel" "encrypteed-peering"{
       vpc_name1 = "FQDN-NAT-enabled"
       vpc_name2 = "fqdn-nat-gw2"
}
# setup a transitive peering
resource "aviatrix_transpeer" "transitive-peering" {
  source         = "FQDN-NAT-enabled"
  nexthop        = "fqdn-nat-gw2"
  reachable_cidr = "10.152.0.0/16"
  depends_on     = ["aviatrix_tunnel.encrypteed-peering"]
}
