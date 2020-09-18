## For regression: Test case: test vpn gateway (okta)

resource random_integer gov_vpc1_cidr_int {
  count = var.enable_gov ? 3 : 0
  min = 1
  max = 126
}
resource aviatrix_vpc aws_gov_okta_vpc {
  count = var.enable_gov ? 1 : 0
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.gov_vpc1_cidr_int[0].result, random_integer.gov_vpc1_cidr_int[1].result, random_integer.gov_vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 256
  name                  = "aws-gov-okta-vpc"
  region                = "us-gov-west-1"
}

resource aviatrix_gateway aws_gov_okta_gw {
  count = var.enable_gov ? 1 : 0
  cloud_type              = 256
  account_name            = "AWSGovRoot"
  gw_name                 = "aws-gov-okta-gw"
  vpc_id                  = aviatrix_vpc.aws_gov_okta_vpc[0].vpc_id
  vpc_reg                 = aviatrix_vpc.aws_gov_okta_vpc[0].region
  gw_size                 = "t3.micro"
  subnet                  = aviatrix_vpc.aws_gov_okta_vpc[0].subnets.3.cidr

  vpn_access              = true
  max_vpn_conn            = 100
  vpn_cidr                = "192.168.43.0/24"
  enable_elb              = true
  elb_name                = "elb-aws-gov-okta-gw"

  split_tunnel            = true

  otp_mode                = 3
  okta_url                = var.aviatrix_vpn_okta_url
  okta_token              = var.aviatrix_vpn_okta_token
  okta_username_suffix    = var.aviatrix_vpn_okta_username_suffix

  allocate_new_eip        = true
}

output aws_gov_okta_gw_id {
  value = var.enable_gov ? aviatrix_gateway.aws_gov_okta_gw[0].id : null
}
