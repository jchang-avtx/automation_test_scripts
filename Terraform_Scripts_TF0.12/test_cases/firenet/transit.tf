##########################
# TGW
##########################
resource "aviatrix_aws_tgw" "firenet_tgw" {
  tgw_name            = "firenet-tgw"
  account_name        = "AWSAccess"
  region              = aviatrix_vpc.firenet_vpc["us-east-1"].region
  aws_side_as_number  = "64512"
  manage_vpc_attachment = false
  # attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.firenet_transit.gw_name]
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
  }
  security_domains {
    security_domain_name = "FireNet_Domain"
    aviatrix_firewall = true
  }

}

## Step 6 of Firenet: (11330) support attach tgw vpc outside of tgw resource
resource "aviatrix_aws_tgw_vpc_attachment" "firenet_tgw_vpc_attach" {
  tgw_name              = aviatrix_aws_tgw.firenet_tgw.tgw_name
  region                = aviatrix_aws_tgw.firenet_tgw.region
  security_domain_name  = aviatrix_aws_tgw.firenet_tgw.security_domains.3.security_domain_name
  vpc_account_name      = aviatrix_vpc.firenet_vpc["us-east-1"].account_name
  vpc_id                = aviatrix_transit_gateway.firenet_transit.vpc_id
}

resource "aviatrix_aws_tgw" "fqdn_firenet_tgw" {
  tgw_name            = "fqdn-firenet-tgw"
  account_name        = "AWSAccess"
  region              = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  aws_side_as_number  = "64512"
  manage_vpc_attachment = true
  # attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.firenet_transit.gw_name]
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
  }
  security_domains {
    security_domain_name = "FireNet_Domain"
    aviatrix_firewall = true
    # STEP 6 of FIRENET
    attached_vpc {
      vpc_account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
      vpc_id              = aviatrix_transit_gateway.fqdn_firenet_transit.vpc_id
      vpc_region          = aviatrix_transit_gateway.fqdn_firenet_transit.vpc_reg
    }
  }

}

##########################
# Transit GW/ GW
##########################
resource "aviatrix_transit_gateway" "firenet_transit" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["us-east-1"].account_name
  gw_name         = "firenet-transit"
  vpc_id          = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["us-east-1"].region
  gw_size         = "c5.xlarge"
  subnet          = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.0.cidr
  ha_subnet       = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.2.cidr
  ha_gw_size      = "c5.xlarge"

  enable_hybrid_connection  = true
  enable_firenet            = true
  connected_transit         = false
  enable_active_mesh        = false
}

resource "aviatrix_transit_gateway" "fqdn_firenet_transit" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
  gw_name         = "fqdn-firenet-transit"
  vpc_id          = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  gw_size         = "c5.xlarge"
  subnet          = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.0.cidr
  # ha_subnet       = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.2.cidr
  # ha_gw_size      = "c5.xlarge"

  enable_hybrid_connection  = true
  enable_firenet            = true
  connected_transit         = false
  enable_active_mesh        = false
}
