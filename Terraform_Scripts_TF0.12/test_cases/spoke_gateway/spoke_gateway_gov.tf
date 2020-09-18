# Launch a spoke VPC, and join with transit VPC.

#################################################
# Infrastructure
#################################################
resource random_integer gov_vpc1_cidr_int {
  count = var.enable_gov ? 2 : 0
  min = 1
  max = 126
}
resource random_integer gov_vpc2_cidr_int {
  count = var.enable_gov ? 2 : 0
  min = 1
  max = 126
}
resource random_integer gov_vpc3_cidr_int {
  count = var.enable_gov ? 2 : 0
  min = 1
  max = 126
}

resource aws_eip gov_eip_aws_spoke_gateway {
  count = var.enable_gov ? 1 : 0
  lifecycle {
    ignore_changes = [tags]
  }
}
resource aws_eip gov_eip_aws_spoke_gateway_ha {
  count = var.enable_gov ? 1 : 0
  lifecycle {
    ignore_changes = [tags]
  }
}

resource aviatrix_vpc aws_gov_transit_vpc_1 {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 256
  name                  = "aws-gov-transit-vpc-1"
  region                = "us-gov-east-1"
}
resource aviatrix_vpc aws_gov_transit_vpc_2 {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc2_cidr_int[0].result, random_integer.gov_vpc2_cidr_int[1].result, "0.0/16"])
  cloud_type            = 256
  name                  = "aws-gov-transit-vpc-2"
  region                = "us-gov-west-1"
}
resource aviatrix_vpc aws_gov_spoke_vpc_1 {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc3_cidr_int[0].result, random_integer.gov_vpc3_cidr_int[1].result, "0.0/16"])
  cloud_type            = 256
  name                  = "aws-gov-spoke-vpc-1"
  region                = "us-gov-east-1"
}

#################################################
# Transit Network
#################################################
resource aviatrix_transit_gateway gov_spoke_transit_gateway_1 {
  count = var.enable_gov ? 1 : 0
  cloud_type      = 256
  account_name    = "AWSGovRoot"
  gw_name         = "gov-spoke-transit-gateway-1"
  vpc_id          = aviatrix_vpc.aws_gov_transit_vpc_1[0].vpc_id
  vpc_reg         = aviatrix_vpc.aws_gov_transit_vpc_1[0].region
  gw_size         = "t3.micro"
  subnet          = aviatrix_vpc.aws_gov_transit_vpc_1[0].subnets.4.cidr

  ha_subnet       = aviatrix_vpc.aws_gov_transit_vpc_1[0].subnets.5.cidr
  ha_gw_size      = "t3.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
  enable_active_mesh        = true
}

## Create a 2nd transitGW to test "updateTransitGW.tfvars test case"
resource aviatrix_transit_gateway gov_spoke_transit_gateway_2 {
  count = var.enable_gov ? 1 : 0
  cloud_type      = 256
  account_name    = "AWSGovRoot"
  gw_name         = "gov-spoke-transit-gateway-2"
  vpc_id          = aviatrix_vpc.aws_gov_transit_vpc_2[0].vpc_id
  vpc_reg         = aviatrix_vpc.aws_gov_transit_vpc_2[0].region
  gw_size         = "t3.micro"
  subnet          = aviatrix_vpc.aws_gov_transit_vpc_2[0].subnets.4.cidr

  ha_subnet       = aviatrix_vpc.aws_gov_transit_vpc_2[0].subnets.5.cidr
  ha_gw_size      = "t3.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
  enable_active_mesh        = true
}

resource aviatrix_spoke_gateway aws_gov_spoke_gateway {
  count = var.enable_gov ? 1 : 0
  cloud_type        = 256
  account_name      = "AWSGovRoot"
  gw_name           = "aws-gov-spoke-gateway"
  vpc_id            = aviatrix_vpc.aws_gov_spoke_vpc_1[0].vpc_id
  vpc_reg           = aviatrix_vpc.aws_gov_spoke_vpc_1[0].region
  gw_size           = var.gw_size

  insane_mode       = true
  insane_mode_az    = "us-gov-east-1a"
  subnet            = join(".", [random_integer.gov_vpc3_cidr_int[0].result, random_integer.gov_vpc3_cidr_int[1].result, "192.0/26"])
  # subnet            = "172.0.0.0/24" # non-insane

  ha_insane_mode_az = "us-gov-east-1b"
  ha_subnet         = join(".", [random_integer.gov_vpc3_cidr_int[0].result, random_integer.gov_vpc3_cidr_int[1].result, "192.64/26"])
  # ha_subnet         = "172.0.1.0/24" # non-insane
  ha_gw_size        = var.aviatrix_ha_gw_size
  single_ip_snat    = false
  enable_active_mesh= var.active_mesh

  allocate_new_eip  = false
  eip               = aws_eip.gov_eip_aws_spoke_gateway[0].public_ip
  ha_eip            = aws_eip.gov_eip_aws_spoke_gateway_ha[0].public_ip

  transit_gw        = var.gov_attach_transit_gw
  tag_list          = ["k1:v1", "k2:v2"]
  enable_vpc_dns_server = var.enable_vpc_dns_server
  depends_on        = [aviatrix_transit_gateway.gov_spoke_transit_gateway_1, aviatrix_transit_gateway.gov_spoke_transit_gateway_2]
}

#################################################
# Output
#################################################
output aws_gov_spoke_gateway_id {
  value = var.enable_gov ? aviatrix_spoke_gateway.aws_gov_spoke_gateway[0].id : null
}
