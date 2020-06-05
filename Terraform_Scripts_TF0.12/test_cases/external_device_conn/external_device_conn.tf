# to simulate this:
# 1. transit VPC + gw
# 2. VPC + gw (simulate external dev/ router)
# 3. enable HA for both
# 4. spoke VPC + gw
# 5. attach spoke to transit
###########################################################################
## Transit VPC & GW HA
resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 126
}
resource "aviatrix_vpc" "ext_conn_transit_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "ext-conn-transit-vpc"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
}

resource "aviatrix_transit_gateway" "ext_conn_transit_gw" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "ext-conn-transit-gw"

  vpc_id              = aviatrix_vpc.ext_conn_transit_vpc.vpc_id
  vpc_reg             = aviatrix_vpc.ext_conn_transit_vpc.region
  gw_size             = "t2.micro"
  subnet              = aviatrix_vpc.ext_conn_transit_vpc.subnets.4.cidr

  ha_subnet           = aviatrix_vpc.ext_conn_transit_vpc.subnets.5.cidr
  ha_gw_size          = "t2.micro"

  connected_transit         = false
  enable_active_mesh        = true # active mesh required for BGP. technically allowed, but cannot have more than 1 connection. dead usecase
}

resource "aws_vpn_gateway" "ext_conn_transit_vgw" {
  tags = {
    Name = "ext-conn-transit-vgw"
  }
  amazon_side_asn = 64513
  vpc_id = aviatrix_vpc.ext_conn_transit_vpc.vpc_id
}

###########################################################################
## On-prem simulation + router
resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "ext_conn_on_prem_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "ext-conn-on-prem-vpc"
  region                = "us-east-1"
}

resource "aviatrix_gateway" "ext_conn_on_prem_router" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "ext-conn-on-prem-router"
  vpc_id              = aviatrix_vpc.ext_conn_on_prem_vpc.vpc_id
  vpc_reg             = aviatrix_vpc.ext_conn_on_prem_vpc.region
  gw_size             = "t2.micro"
  subnet              = aviatrix_vpc.ext_conn_on_prem_vpc.subnets.6.cidr

  peering_ha_subnet   = aviatrix_vpc.ext_conn_on_prem_vpc.subnets.7.cidr
  peering_ha_gw_size  = "t2.micro"
}

###########################################################################
resource "aviatrix_aws_peer" "transit_router_vpc_peering" {
  account_name1 = aviatrix_vpc.ext_conn_transit_vpc.account_name
  account_name2 = aviatrix_vpc.ext_conn_on_prem_vpc.account_name
  vpc_id1       = aviatrix_vpc.ext_conn_transit_vpc.vpc_id
  vpc_id2       = aviatrix_vpc.ext_conn_on_prem_vpc.vpc_id
  vpc_reg1      = aviatrix_vpc.ext_conn_transit_vpc.region
  vpc_reg2      = aviatrix_vpc.ext_conn_on_prem_vpc.region
}

## External device conn
resource "aviatrix_transit_external_device_conn" "ext_conn" {
  connection_type = var.conn_type

  connection_name     = "ext-conn"
  vpc_id              = aviatrix_vpc.ext_conn_transit_vpc.vpc_id
  gw_name             = aviatrix_transit_gateway.ext_conn_transit_gw.gw_name
  bgp_local_as_num    = var.conn_type == "bgp" ? 65000 : null

  remote_gateway_ip     = var.dxc_status == true ? aviatrix_gateway.ext_conn_on_prem_router.private_ip : aviatrix_gateway.ext_conn_on_prem_router.eip
  bgp_remote_as_num     = var.conn_type == "bgp" ? 65001 : null

  remote_subnet         = var.conn_type == "static" ? aviatrix_gateway.ext_conn_on_prem_router.subnet : null
  direct_connect        = var.dxc_status # if true, must specify private IP for router/ remote IP
  pre_shared_key        = "abc-123"
  local_tunnel_cidr     = "172.17.11.2/30,172.17.11.6/30" # tunnel inside IP addr of tranist gw
  remote_tunnel_cidr    = "172.17.11.1/30,172.17.11.5/30" # tunnel inside IP addr of external dev

  custom_algorithms = true
  phase_1_authentication        = "SHA-512"
  phase_1_dh_groups             = "1"
  phase_1_encryption            = "AES-192-CBC"
  phase_2_authentication        = "HMAC-SHA-512"
  phase_2_dh_groups             = "1"
  phase_2_encryption            = "AES-192-CBC"

  ha_enabled = true
  backup_direct_connect       = var.dxc_status == true ? true : false
  backup_remote_gateway_ip    = var.dxc_status == true ? aviatrix_gateway.ext_conn_on_prem_router.peering_ha_private_ip : aviatrix_gateway.ext_conn_on_prem_router.peering_ha_eip
  backup_bgp_remote_as_num    = var.conn_type == "bgp" ? 65001 : null # must match primary remote ASN , only for bgp
  backup_pre_shared_key       = "abc-123"
  backup_local_tunnel_cidr    = "172.17.12.2/30,172.17.12.6/30"
  backup_remote_tunnel_cidr   = "172.17.12.1/30,172.17.12.5/30"

  enable_edge_segmentation = true # only supported for ActiveMesh gateway

  lifecycle {
    ignore_changes = [pre_shared_key, backup_pre_shared_key]
  }
}

output "ext_conn_id" {
  value = aviatrix_transit_external_device_conn.ext_conn.id
}
###########################################################################
## Spoke
resource "random_integer" "vpc3_cidr_int" {
  count = 2
  min = 1
  max = 126
}
resource "aviatrix_vpc" "ext_conn_spoke_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "ext-conn-spoke-vpc"
  region                = "us-east-1"
}

resource "aviatrix_spoke_gateway" "ext_conn_spoke_gw" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "ext-conn-spoke-gw"
  vpc_id            = aviatrix_vpc.ext_conn_spoke_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.ext_conn_spoke_vpc.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.ext_conn_spoke_vpc.subnets.6.cidr

  ha_subnet         = aviatrix_vpc.ext_conn_spoke_vpc.subnets.7.cidr
  ha_gw_size        = "t2.micro"

  enable_active_mesh = true

  transit_gw        = aviatrix_transit_gateway.ext_conn_transit_gw.gw_name
  # depends_on = [aviatrix_transit_external_device_conn.ext_conn]
}
