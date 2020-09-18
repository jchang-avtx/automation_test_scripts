## Create a new VPC
############################################################
# AWS
############################################################
resource aviatrix_vpc test_aws_vpc {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = "11.11.11.11/24"
  cloud_type            = 1
  name                  = "test-aws-vpc"
  region                = "us-west-1"
}

resource aviatrix_vpc test_aws_transit_vpc {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = "10.10.10.10/20"
  cloud_type            = 1
  name                  = "test-aws-transit-vpc"
  region                = "us-east-1"
}

resource aviatrix_vpc test_aws_firenet_vpc {
  account_name          = "AWSAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
  cidr                  = "13.13.13.13/24"
  cloud_type            = 1
  name                  = "test-aws-firenet-vpc"
  region                = "us-west-2"
}

# ############################################################
# # GCP
# ############################################################
resource aviatrix_vpc test_gcp_vpc {
  account_name          = "GCPAccess"
  cloud_type            = 4
  name                  = "test-gcp-vpc"
  subnets {
    name    = "us-east1-subnet"
    region  = "us-east1"
    cidr    = "172.17.0.0/16"
  }
  subnets {
    name    = "asia-east1-subnet"
    region  = "asia-east1"
    cidr    = "172.16.0.0/16"
  }
}

############################################################
# ARM
############################################################
resource aviatrix_vpc test_arm_vnet {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = "47.44.56.0/24"
  cloud_type            = 8
  name                  = "test-arm-vnet"
  region                = "Central US"
}

resource aviatrix_vpc test_arm_firenet_vnet {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
  cidr                  = "116.124.56.0/24"
  cloud_type            = 8
  name                  = "test-arm-firenet-vnet"
  region                = "Central US"
}

############################################################
## AWS GovCloud
############################################################
resource aviatrix_vpc test_aws_gov_vpc {
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = "29.11.72.0/24"
  cloud_type            = 256
  name                  = "test-aws-gov-vpc"
  region                = "us-gov-west-1"
}

resource aviatrix_vpc test_aws_gov_transit_vpc {
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = true
  aviatrix_firenet_vpc  = false
  cidr                  = "78.96.56.0/23"
  cloud_type            = 256
  name                  = "test-aws-gov-transit-vpc"
  region                = "us-gov-east-1"
}

resource aviatrix_vpc test_aws_gov_firenet_vpc {
  account_name          = "AWSGovRoot"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
  cidr                  = "125.47.115.0/24"
  cloud_type            = 256
  name                  = "test-aws-gov-firenet-vpc"
  region                = "us-gov-east-1"
}

############################################################
## OUTPUTS
############################################################

output test_aws_vpc_id {
  value = aviatrix_vpc.test_aws_vpc.id
}

output test_aws_transit_vpc_id {
  value = aviatrix_vpc.test_aws_transit_vpc.id
}

output test_aws_firenet_vpc_id {
  value = aviatrix_vpc.test_aws_firenet_vpc.id
}

output test_gcp_vpc_id {
  value = aviatrix_vpc.test_gcp_vpc.id
}

output test_arm_vnet_id {
  value = aviatrix_vpc.test_arm_vnet.id
}

output test_arm_firenet_vnet_id {
  value = aviatrix_vpc.test_arm_firenet_vnet.id
}

output test_aws_gov_vpc_id {
  value = aviatrix_vpc.test_aws_gov_vpc.id
}

output test_aws_gov_transit_vpc_id {
  value = aviatrix_vpc.test_aws_gov_transit_vpc.id
}

output test_aws_gov_firenet_vpc_id {
  value = aviatrix_vpc.test_aws_gov_firenet_vpc.id
}

############################################################
## DATA SOURCE
############################################################

data aviatrix_vpc d_test_aws_vpc{
  name = aviatrix_vpc.test_aws_vpc.name
}

data aviatrix_vpc_tracker d_aws_vpc_tracker {
  cloud_type = 1
  account_name = "AWSAccess"
}

output d_test_aws_vpc_id {
  value = data.aviatrix_vpc.d_test_aws_vpc.id
}

output d_aws_vpc_tracker_id {
  value = data.aviatrix_vpc_tracker.d_aws_vpc_tracker.id
}
