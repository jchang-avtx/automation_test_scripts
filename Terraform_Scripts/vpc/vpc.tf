provider "aviatrix"  {
  controller_ip = "1.2.3.4"
  username = "admin"
  password = "password"
}

# Create a new VPC
resource "aviatrix_vpc" "test_vpc" {
  cloud_type = 1
  account_name = "PrimaryAccessAccount"
  region = "us-west-1"
  name = "createVPCTest"
  cidr = "11.11.11.11/24"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

resource "aviatrix_vpc" "test_vpc2" {
  cloud_type = 1
  account_name = "PrimaryAccessAccount"
  region = "us-east-1"
  name = "createVPCTest2"
  cidr = "10.10.10.10/20"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}

resource "aviatrix_vpc" "test_vpc3" {
  cloud_type = 1
  account_name = "PrimaryAccessAccount"
  region = "us-west-2"
  name = "createVPCTest3"
  cidr = "13.13.13.13/24"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = true
}
