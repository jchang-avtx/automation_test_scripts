##########################
# VPC
##########################
resource "aviatrix_vpc" "firenet_vpc" {
  for_each = var.vpc
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = each.key
  name                  = join("-", ["firenet-vpc", each.key])
  cidr                  = each.value
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
}
