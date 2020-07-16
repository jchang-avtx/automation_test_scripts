resource random_integer csr_transit_vpc_int {
  count = 2
  min = 1
  max = 126
}

resource aviatrix_vpc csr_transit_vpc {
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-east-2"
  name = "csr-transit-vpc"
  cidr = join(".", [random_integer.csr_transit_vpc_int[0].result, random_integer.csr_transit_vpc_int[1].result, "0.0/16"])
}

resource aviatrix_transit_gateway csr_transit_gw {
  count = var.avx_transit_att_status || var.aws_tgw_att_status ? 1 : 0

  cloud_type = 1
  account_name = "AWSAccess"
  gw_name = "csr-transit-gw"
  vpc_id = aviatrix_vpc.csr_transit_vpc.vpc_id
  vpc_reg = aviatrix_vpc.csr_transit_vpc.region
  gw_size = "t2.micro"
  subnet = aviatrix_vpc.csr_transit_vpc.subnets.4.cidr

  # ha_gw_size = "t2.micro"
  # ha_subnet = aviatrix_vpc.csr_transit_vpc.subnets.5.cidr
  enable_hybrid_connection = true
}

resource aviatrix_aws_tgw csr_aws_tgw {
  count = var.aws_tgw_att_status ? 1 : 0

  tgw_name = "csr-aws-tgw"
  account_name = "AWSAccess"
  region = "us-east-2"
  aws_side_as_number = 65000

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
  }

  manage_vpc_attachment = true
  manage_transit_gateway_attachment = true
  attached_aviatrix_transit_gateway = [
    aviatrix_transit_gateway.csr_transit_gw[0].gw_name
  ]
}
