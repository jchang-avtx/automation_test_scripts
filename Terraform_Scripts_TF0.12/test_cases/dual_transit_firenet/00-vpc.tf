resource aviatrix_vpc on_prem_vpc {
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-east-2"
  name = "dual-on-prem-vpc"
  cidr = "45.99.0.0/16"
}

resource aviatrix_vpc transit_firenet_vpc {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-east-1"
  name = "transit-firenet-vpc"
  cidr = "15.67.0.0/16"

  aviatrix_firenet_vpc = true
}

resource aviatrix_vpc egress_firenet_vpc {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-west-1"
  name = "egress-transit-vpc"
  cidr = "15.68.0.0/16"

  aviatrix_firenet_vpc = true
}

resource aviatrix_vpc dual_firenet_spoke_vpc_1 {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  region = "eu-central-1"
  name = "dual-firenet-spoke-vpc-1"
  cidr = "82.84.0.0/16"
}

resource aviatrix_vpc dual_firenet_spoke_vpc_2 {
  count = var.enable_aws ? 1 : 0
  cloud_type = 1
  account_name = "AWSAccess"
  region = "eu-west-1"
  name = "dual-firenet-spoke-vpc-2"
  cidr = "82.85.0.0/16"
}
