# Launch a spoke VPC, and join with transit VPC.

#################################################
# Infrastructure
#################################################
resource random_integer vpc1_cidr_int {
  count = 2
  min = 1
  max = 126
}
resource random_integer vpc2_cidr_int {
  count = 2
  min = 1
  max = 126
}
resource random_integer vpc3_cidr_int {
  count = 2
  min = 1
  max = 126
}

resource aws_eip eip_aws_spoke_gateway {
  lifecycle {
    ignore_changes = [tags]
  }
}
resource aws_eip eip_aws_spoke_gateway_ha {
  lifecycle {
    ignore_changes = [tags]
  }
}

resource aviatrix_vpc aws_transit_vpc_1 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "aws-transit-vpc-1"
  region                = "us-east-1"
}
resource aviatrix_vpc aws_transit_vpc_2 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "aws-transit-vpc-2"
  region                = "us-west-1"
}
resource aviatrix_vpc aws_spoke_vpc_1 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "aws-spoke-vpc-1"
  region                = "us-east-1"
}

#################################################
# Transit Network
#################################################
resource aviatrix_transit_gateway spoke_transit_gateway_1 {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "spoke-transit-gateway-1"
  vpc_id          = aviatrix_vpc.aws_transit_vpc_1.vpc_id
  vpc_reg         = aviatrix_vpc.aws_transit_vpc_1.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.aws_transit_vpc_1.subnets.4.cidr

  ha_subnet       = aviatrix_vpc.aws_transit_vpc_1.subnets.5.cidr
  ha_gw_size      = "t2.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
  enable_active_mesh        = true
}

## Create a 2nd transitGW to test "updateTransitGW.tfvars test case"
resource aviatrix_transit_gateway spoke_transit_gateway_2 {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "spoke-transit-gateway-2"
  vpc_id          = aviatrix_vpc.aws_transit_vpc_2.vpc_id
  vpc_reg         = aviatrix_vpc.aws_transit_vpc_2.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.aws_transit_vpc_2.subnets.4.cidr

  ha_subnet       = aviatrix_vpc.aws_transit_vpc_2.subnets.5.cidr
  ha_gw_size      = "t2.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
  enable_active_mesh        = true
}

resource aviatrix_spoke_gateway aws_spoke_gateway {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "aws-spoke-gateway"
  vpc_id            = aviatrix_vpc.aws_spoke_vpc_1.vpc_id
  vpc_reg           = aviatrix_vpc.aws_spoke_vpc_1.region
  gw_size           = var.gw_size

  insane_mode       = true
  insane_mode_az    = "us-east-1a"
  subnet            = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, "192.0/26"])
  # subnet            = "172.0.0.0/24" # non-insane

  ha_insane_mode_az = "us-east-1b"
  ha_subnet         = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, "192.64/26"])
  # ha_subnet         = "172.0.1.0/24" # non-insane
  ha_gw_size        = var.aviatrix_ha_gw_size
  single_ip_snat    = false
  enable_active_mesh= var.active_mesh

  allocate_new_eip  = false
  eip               = aws_eip.eip_aws_spoke_gateway.public_ip
  ha_eip            = aws_eip.eip_aws_spoke_gateway_ha.public_ip

  transit_gw        = var.aviatrix_transit_gw
  tag_list          = ["k1:v1", "k2:v2"]
  enable_vpc_dns_server = var.enable_vpc_dns_server
  depends_on        = [aviatrix_transit_gateway.spoke_transit_gateway_1, aviatrix_transit_gateway.spoke_transit_gateway_2]
}

#################################################
# Output
#################################################
output aws_spoke_gateway_id {
  value = aviatrix_spoke_gateway.aws_spoke_gateway.id
}
