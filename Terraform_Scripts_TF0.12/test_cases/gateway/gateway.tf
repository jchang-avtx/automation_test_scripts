## Test case: test regular gateway

#######################
## INFRASTRUCTURE
#######################
resource random_integer vpc1_cidr_int {
  count = 3
  min = 1
  max = 126
}
resource random_integer vpc2_cidr_int {
  count = 3
  min = 1
  max = 126
}

resource aviatrix_vpc aws_gw_vpc_1 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-gw-vpc-1"
  region                = "us-east-1"
}
resource aviatrix_vpc aws_gw_vpc_2 {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  cloud_type            = 1
  name                  = "aws-gw-vpc-1"
  region                = "us-east-2"
}

resource aws_eip eip_aws_gw_test_1 {
  lifecycle {
    ignore_changes = [tags]
  }
}
resource aws_eip eip_aws_gw_test_1_ha {
  lifecycle {
    ignore_changes = [tags]
  }
}

#######################
## GATEWAYS
#######################
resource aviatrix_gateway aws_gw_test_1 {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "aws-gw-test-1"
  vpc_id              = aviatrix_vpc.aws_gw_vpc_1.vpc_id
  vpc_reg             = aviatrix_vpc.aws_gw_vpc_1.region
  gw_size             = var.aws_instance_size
  subnet              = aviatrix_vpc.aws_gw_vpc_1.subnets.6.cidr

  tag_list            = var.aws_gateway_tag_list
  single_ip_snat      = var.single_ip_snat

  allocate_new_eip    = false
  eip                 = aws_eip.eip_aws_gw_test_1.public_ip

  peering_ha_subnet   = aviatrix_vpc.aws_gw_vpc_1.subnets.7.cidr
  peering_ha_gw_size  = var.aws_ha_gw_size
  peering_ha_eip      = aws_eip.eip_aws_gw_test_1_ha.public_ip

  enable_vpc_dns_server = var.enable_vpc_dns_server
}

resource aviatrix_gateway aws_gw_test_2 {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "aws-gw-test-2"
  vpc_id              = aviatrix_vpc.aws_gw_vpc_2.vpc_id
  vpc_reg             = aviatrix_vpc.aws_gw_vpc_2.region
  gw_size             = "t2.micro"
  subnet              = aviatrix_vpc.aws_gw_vpc_2.subnets.6.cidr

  tag_list            = var.aws_gateway_tag_list
  single_ip_snat      = var.single_ip_snat

  allocate_new_eip    = true

  peering_ha_subnet   = aviatrix_vpc.aws_gw_vpc_2.subnets.7.cidr
  peering_ha_gw_size  = var.aws_ha_gw_size

  enable_vpc_dns_server = var.enable_vpc_dns_server
}

resource aviatrix_site2cloud ping_tunnel_to_dest {
  vpc_id                = aviatrix_gateway.aws_gw_test_1.vpc_id
  connection_name       = "ping-tunnel-to-dest"
  connection_type       = "unmapped"
  remote_gateway_type   = "avx"
  tunnel_type           = "policy"

  primary_cloud_gateway_name    = aviatrix_gateway.aws_gw_test_1.gw_name
  remote_gateway_ip             = aviatrix_gateway.aws_gw_test_2.eip

  remote_subnet_cidr    = aviatrix_gateway.aws_gw_test_2.subnet
  local_subnet_cidr     = aviatrix_gateway.aws_gw_test_1.subnet

  pre_shared_key = "key123a"

  lifecycle {
    ignore_changes = [pre_shared_key]
  }
}

resource aviatrix_site2cloud ping_tunnel_to_gw {
  vpc_id                  = aviatrix_gateway.aws_gw_test_2.vpc_id
  connection_name         = "ping-tunnel-to-gw"
  connection_type         = "unmapped"
  remote_gateway_type     = "avx"
  tunnel_type             = "policy"

  primary_cloud_gateway_name    = aviatrix_gateway.aws_gw_test_2.gw_name
  remote_gateway_ip             = aviatrix_gateway.aws_gw_test_1.eip

  remote_subnet_cidr    = aviatrix_gateway.aws_gw_test_1.subnet
  local_subnet_cidr     = aviatrix_gateway.aws_gw_test_2.subnet

  pre_shared_key = "key123a"

  lifecycle {
    ignore_changes = [pre_shared_key]
  }
}

# available in R2.16
resource aviatrix_periodic_ping ping_test {
  gw_name       = aviatrix_gateway.aws_gw_test_1.gw_name
  interval      = var.ping_interval
  ip_address    = aviatrix_gateway.aws_gw_test_2.eip

  depends_on = [aviatrix_site2cloud.ping_tunnel_to_dest, aviatrix_site2cloud.ping_tunnel_to_gw]
}

#######################
## OUTPUTS
#######################
output aws_gw_test_1_id {
  value = aviatrix_gateway.aws_gw_test_1.id
}
