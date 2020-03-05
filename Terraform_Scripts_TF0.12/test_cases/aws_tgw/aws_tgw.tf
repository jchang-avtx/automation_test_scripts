## Manages the AWS TGW (Orchestrator)

resource "random_integer" "vpc1_cidr_int" {
  count = 2
  min = 1
  max = 126
}

resource "aviatrix_vpc" "aws_transit_gw_vpc" {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  cloud_type            = 1
  name                  = "awsTransitGWVPC"
  region                = "eu-central-1"
}

resource "aviatrix_transit_gateway" "tgw_transit_gw" {
  cloud_type                  = 1
  account_name                = "AWSAccess"
  gw_name                     = "tgw-transit-gw"
  vpc_id                      = aviatrix_vpc.aws_transit_gw_vpc.vpc_id
  vpc_reg                     = aviatrix_vpc.aws_transit_gw_vpc.region
  gw_size                     = "t2.micro"
  subnet                      = aviatrix_vpc.aws_transit_gw_vpc.subnets.4.cidr

  enable_hybrid_connection    = true
  connected_transit           = false
  enable_active_mesh          = false
}

resource "aws_vpn_gateway" "eu_tgw_vgw" {
  tags = {
    Name = "eu-tgw-vgw"
  }
  amazon_side_asn = 64512
}

resource "aviatrix_vgw_conn" "tgw_vgw_conn" {
  conn_name             = "tgw-vgw-conn"
  gw_name               = aviatrix_transit_gateway.tgw_transit_gw.gw_name
  vpc_id                = aviatrix_transit_gateway.tgw_transit_gw.vpc_id
  bgp_vgw_id            = aws_vpn_gateway.eu_tgw_vgw.id
  bgp_vgw_account       = aviatrix_transit_gateway.tgw_transit_gw.account_name
  bgp_vgw_region        = aviatrix_transit_gateway.tgw_transit_gw.vpc_reg
  bgp_local_as_num      = 65001
}

resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name                          = "test-aws-tgw"
  account_name                      = aviatrix_transit_gateway.tgw_transit_gw.account_name
  region                            = aviatrix_transit_gateway.tgw_transit_gw.vpc_reg
  aws_side_as_number                = 65412
  attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.tgw_transit_gw.gw_name]

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = var.connected_domains_list1
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = var.connected_domains_list2
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.connected_domains_list3
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[0]
    connected_domains    = var.connected_domains_list4
    attached_vpc {
      vpc_account_name   = aviatrix_transit_gateway.tgw_transit_gw.account_name
      vpc_id             = var.aws_vpc_id[0]
      vpc_region         = aviatrix_transit_gateway.tgw_transit_gw.vpc_reg
    }
    attached_vpc {
      vpc_account_name   = aviatrix_transit_gateway.tgw_transit_gw.account_name
      vpc_id             = var.aws_vpc_id[1]
      vpc_region         = aviatrix_transit_gateway.tgw_transit_gw.vpc_reg
    }
  }
  security_domains {
    security_domain_name = var.security_domain_name_list[1]
    aviatrix_firewall    = false
    native_egress        = false
    native_firewall      = false
    attached_vpc {
      vpc_account_name    = aviatrix_transit_gateway.tgw_transit_gw.account_name
      vpc_id              = var.aws_vpc_id[2]
      vpc_region          = aviatrix_transit_gateway.tgw_transit_gw.vpc_reg

      customized_routes               = var.custom_routes_list
      disable_local_route_propagation = var.disable_local_route_propagation
    }
  }

  manage_vpc_attachment = true
  depends_on            = ["aviatrix_vgw_conn.tgw_vgw_conn"]
}

## AWS_TGW_VPN_CONN
# Dynamic connection
resource "aviatrix_aws_tgw_vpn_conn" "test_aws_tgw_vpn_conn1" {
  tgw_name             = aviatrix_aws_tgw.test_aws_tgw.tgw_name
  route_domain_name    = "Default_Domain"
  connection_name      = "tgw_vpn_conn1"
  connection_type      = "dynamic"
  public_ip            = "69.0.0.0"
  remote_as_number     = "1234"

  # optional custom tunnel options
  inside_ip_cidr_tun_1 = "169.254.69.69/30" # A /30 CIDR in 169.254.0.0/16
  pre_shared_key_tun_1 = "abc_123.def" # A 8-64 character string with alphanumeric, underscore(_) and dot(.). It cannot start with 0.
  inside_ip_cidr_tun_2 = "169.254.70.70/30"
  pre_shared_key_tun_2 = "def_456.ghi"

  lifecycle {
    ignore_changes = [pre_shared_key_tun_1, pre_shared_key_tun_2]
  }
}

# Static connection
resource "aviatrix_aws_tgw_vpn_conn" "test_aws_tgw_vpn_conn2" {
  tgw_name             = aviatrix_aws_tgw.test_aws_tgw.tgw_name
  route_domain_name    = "Default_Domain"
  connection_name      = "tgw_vpn_conn2"
  connection_type      = "static" 
  public_ip            = "70.0.0.0"
  remote_cidr          = "10.0.0.0/16,10.1.0.0/16"
}

## OUTPUTS
output "test_aws_tgw_id" {
  value = aviatrix_aws_tgw.test_aws_tgw.id
}

output "test_aws_tgw_vpn_conn1_id" {
  value = aviatrix_aws_tgw_vpn_conn.test_aws_tgw_vpn_conn1.id
}

output "test_aws_tgw_vpn_conn2_id" {
  value = aviatrix_aws_tgw_vpn_conn.test_aws_tgw_vpn_conn2.id
}
