######################################################################
# INFRASTRUCTURE | MANTIS 11363
######################################################################
resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "vpn_manage_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "vpn-manage-vpc"
  region                = "us-east-2"
}
data "aviatrix_vpc" "vpn_manage_vpc_data" {
  name = aviatrix_vpc.vpn_manage_vpc.name
}
resource "aviatrix_gateway" "vpn_manage_gw" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "vpn-manage-gw"

  vpc_id            = aviatrix_vpc.vpn_manage_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.vpn_manage_vpc.region
  gw_size           = "t2.micro"
  subnet            = data.aviatrix_vpc.vpn_manage_vpc_data.public_subnets.0.cidr

  vpn_access        = true
  saml_enabled      = false # if true, must specify SAML endpoint in vpn user
  max_vpn_conn      = 100
  vpn_cidr          = "192.168.45.0/24"
  split_tunnel      = true
  enable_elb        = true
  elb_name          = "vpn-manage-gw-elb"
  single_ip_snat    = false
  allocate_new_eip  = true
}

######################################################################
# USERS
######################################################################
resource "aviatrix_vpn_user" "vpn_manage_user_1" {
  vpc_id            = aviatrix_gateway.vpn_manage_gw.vpc_id
  gw_name           = aviatrix_gateway.vpn_manage_gw.elb_name
  user_name         = "vpn-manage-user-1"
  # user_email        = var.vpn_user_email[0]
  # saml_endpoint     = "saml_test_endpoint"

  manage_user_attachment = true # default false
  profiles = [
    aviatrix_vpn_profile.vpn_manage_profile_1.name,
    aviatrix_vpn_profile.vpn_manage_profile_3.name
  ]
}
resource "aviatrix_vpn_user" "vpn_manage_user_2" {
  vpc_id            = aviatrix_gateway.vpn_manage_gw.vpc_id
  gw_name           = aviatrix_gateway.vpn_manage_gw.elb_name
  user_name         = "vpn-manage-user-2"
  # user_email        = var.vpn_user_email[0]
  # saml_endpoint     = "saml_test_endpoint"

  manage_user_attachment = false
  # profiles = []
}

######################################################################
# PROFILES
######################################################################
resource "aviatrix_vpn_profile" "vpn_manage_profile_1" {
  name            = "vpn-manage-profile-1"
  base_rule       = "deny_all"

  manage_user_attachment    = false # default true

  policy {
    action    = "allow"
    proto     = "all"
    port      = "0:65535"
    target    = "10.0.0.0/32"
  }
  policy {
    action    = "allow"
    proto     = "tcp"
    port      = 5555
    target    = "11.0.0.0/32"
  }
  policy {
    action    = "allow"
    proto     = "udp"
    port      = 5566
    target    = "12.0.0.0/32"
  }
  policy {
    action    = "allow"
    proto     = "icmp"
    port      = "0:65535"
    target    = "13.0.0.0/32"
  }
}
resource "aviatrix_vpn_profile" "vpn_manage_profile_2" {
  name            = "vpn-manage-profile-2"
  base_rule       = "allow_all"

  manage_user_attachment    = true # default true
  users                     = [aviatrix_vpn_user.vpn_manage_user_2.user_name]

  policy {
    action    = "deny"
    proto     = "sctp"
    port      = 5588
    target    = "14.0.0.0/32"
  }
  policy {
    action    = "deny"
    proto     = "rdp"
    port      = 5599
    target    = "15.0.0.0/32"
  }
  policy {
    action    = "deny"
    proto     = "dccp"
    port      = 5600
    target    = "16.0.0.0/32"
  }
}
resource "aviatrix_vpn_profile" "vpn_manage_profile_3" {
  name            = "vpn-manage-profile-3"
  base_rule       = "deny_all"

  manage_user_attachment    = false
}

######################################################################
# OUTPUTS
######################################################################
output "vpn_manage_user_1_id" {
  value = aviatrix_vpn_user.vpn_manage_user_1.id
}
output "vpn_manage_user_2_id" {
  value = aviatrix_vpn_user.vpn_manage_user_2.id
}
output "vpn_manage_profile_1_id" {
  value = aviatrix_vpn_profile.vpn_manage_profile_1.id
}
output "vpn_manage_profile_2_id" {
  value = aviatrix_vpn_profile.vpn_manage_profile_2.id
}
output "vpn_manage_profile_3_id" {
  value = aviatrix_vpn_profile.vpn_manage_profile_3.id
}
