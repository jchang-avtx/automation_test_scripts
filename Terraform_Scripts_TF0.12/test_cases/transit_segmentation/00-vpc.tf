resource aviatrix_vpc on_prem_vpc {
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-east-2"
  name = "segment-on-prem-vpc"
  cidr = "50.35.0.0/16"
}

resource aviatrix_vpc aws_segment_transit_vpc {
  cloud_type = 1
  account_name = "AWSAccess"
  region = "us-east-1"
  name = "segment-transit-vpc"
  cidr = "115.64.0.0/16"

  aviatrix_transit_vpc = true
}

resource aviatrix_vpc aws_segment_spoke_vpc {
  for_each = {
    "eu-central-1" = "120.14.0.0/16"
    "eu-west-1" = "82.103.0.0/16"
  }
  cloud_type = 1
  account_name = "AWSAccess"
  region = each.key
  name = "segment-spoke-vpc-${each.key}"
  cidr = each.value
}

resource aviatrix_vpc arm_segment_transit_vnet {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "East US"
  name = "arm-segment-transit-vnet"
  cidr = "46.84.0.0/16"
}

resource aviatrix_vpc arm_segment_spoke_vnet {
  count = var.enable_azure ? 1 : 0
  cloud_type = 8
  account_name = "AzureAccess"
  region = "East US 2"
  name = "arm-segment-spoke-vnet"
  cidr = "45.109.0.0/16"
}
