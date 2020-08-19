resource aviatrix_gateway fqdn_gw_1 {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "fqdn-gw-1"
  vpc_id        = aviatrix_vpc.fqdn_vpc_1.vpc_id
  vpc_reg       = aviatrix_vpc.fqdn_vpc_1.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.fqdn_vpc_1.public_subnets.0.cidr
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

resource aviatrix_gateway fqdn_gw_2 {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "fqdn-gw-2"
  vpc_id        = aviatrix_vpc.fqdn_vpc_1.vpc_id
  vpc_reg       = aviatrix_vpc.fqdn_vpc_1.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.fqdn_vpc_1.public_subnets.1.cidr
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

resource aviatrix_gateway fqdn_gw_3 {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "fqdn-gw-3"
  vpc_id        = aviatrix_vpc.fqdn_vpc_2.vpc_id
  vpc_reg       = aviatrix_vpc.fqdn_vpc_2.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.fqdn_vpc_2.public_subnets.0.cidr
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}
