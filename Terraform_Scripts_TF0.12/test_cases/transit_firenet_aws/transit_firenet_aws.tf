# AWS Transit FireNet solution
# (13061) Add Terraform support for Transit FireNet

#################################################
# Infrastructure
#################################################
# Transit
resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "aws_transit_firenet_vpc" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-west-1"
  name                  = "transit-firenet-vpc"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
}
resource "aviatrix_transit_gateway" "aws_transit_firenet_gateway" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "aws-transit-firenet-gateway"
  vpc_id        = aviatrix_vpc.aws_transit_firenet_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.aws_transit_firenet_vpc.region
  gw_size       = "c5.xlarge"
  subnet        = aviatrix_vpc.aws_transit_firenet_vpc.subnets.0.cidr

  # enable_firenet            = true # cannot set this if setting transit firenet
  enable_transit_firenet    = true # pull (298)
  enable_hybrid_connection  = true # must be enabled if enable_transit_firenet is
  connected_transit         = true # must be enabled for Encrypted Transit Network
  enable_active_mesh        = true # must be enabled for AWS deployment
}

# Spoke 1
resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "transit_firenet_spoke_vpc_1" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "transit-firenet-spoke-vpc-1"
  cidr                  = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}
resource "aviatrix_spoke_gateway" "transit_firenet_spoke_gateway_1" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "transit-firenet-spoke-gateway-1"
  vpc_id        = aviatrix_vpc.transit_firenet_spoke_vpc_1.vpc_id
  vpc_reg       = aviatrix_vpc.transit_firenet_spoke_vpc_1.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.transit_firenet_spoke_vpc_1.subnets.6.cidr

  enable_active_mesh  = true
  transit_gw          = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
}

# Spoke 2
resource "random_integer" "vpc3_cidr_int" {
  count = 3
  min = 1
  max = 126
}
resource "aviatrix_vpc" "transit_firenet_spoke_vpc_2" {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "eu-central-1"
  name                  = "transit-firenet-spoke-vpc-2"
  cidr                  = join(".", [random_integer.vpc3_cidr_int[0].result, random_integer.vpc3_cidr_int[1].result, random_integer.vpc3_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}
resource "aviatrix_spoke_gateway" "transit_firenet_spoke_gateway_2" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "transit-firenet-spoke-gateway-2"
  vpc_id        = aviatrix_vpc.transit_firenet_spoke_vpc_2.vpc_id
  vpc_reg       = aviatrix_vpc.transit_firenet_spoke_vpc_2.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.transit_firenet_spoke_vpc_2.subnets.3.cidr

  enable_active_mesh  = true
  transit_gw          = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
}

# Site2cloud from transit to spoke1
resource "aviatrix_site2cloud" "transit_firenet_s2c_spoke1_transit" {
  vpc_id                = aviatrix_vpc.aws_transit_firenet_vpc.vpc_id
  connection_name       = "transit-firenet-s2c-spoke1-transit"
  remote_gateway_type   = "generic"
  connection_type       = "unmapped"
  tunnel_type           = "udp"
  primary_cloud_gateway_name  = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
  local_subnet_cidr           = aviatrix_transit_gateway.aws_transit_firenet_gateway.subnet
  remote_gateway_ip           = aviatrix_spoke_gateway.transit_firenet_spoke_gateway_1.eip
  remote_subnet_cidr          = aviatrix_spoke_gateway.transit_firenet_spoke_gateway_1.subnet

  lifecycle {
    ignore_changes = [local_subnet_cidr]
  }
}

#################################################
# FireNet
#################################################
resource "aviatrix_firewall_instance" "firenet_instance" {
  vpc_id                  = aviatrix_vpc.aws_transit_firenet_vpc.vpc_id
  firenet_gw_name         = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
  firewall_name           = "transit-firenet-instance"
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version  = "9.1.0-h3"
  firewall_size           = "m5.xlarge"
  management_subnet       = aviatrix_vpc.aws_transit_firenet_vpc.subnets.0.cidr
  egress_subnet           = aviatrix_vpc.aws_transit_firenet_vpc.subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  iam_role                = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name   = "bootstrap-bucket-firenet"
}
resource "aviatrix_firenet" "firenet" {
  vpc_id              = aviatrix_vpc.aws_transit_firenet_vpc.vpc_id
  inspection_enabled  = true # default true (reversed if FQDN use case)
  egress_enabled      = true # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.firenet_instance.firewall_name
    instance_id           = aviatrix_firewall_instance.firenet_instance.instance_id
    lan_interface         = aviatrix_firewall_instance.firenet_instance.lan_interface
    management_interface  = aviatrix_firewall_instance.firenet_instance.management_interface
    egress_interface      = aviatrix_firewall_instance.firenet_instance.egress_interface
    attached              = true # updateable
  }
}

#################################################
# Transit FireNet
#################################################
resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_1" {
  transit_firenet_gateway_name  = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.transit_firenet_spoke_gateway_1.gw_name])
}
resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_2" {
  transit_firenet_gateway_name  = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
  inspected_resource_name       = join(":", ["SPOKE", aviatrix_spoke_gateway.transit_firenet_spoke_gateway_2.gw_name])
}
# Only one resource may be used for Firewall Management Access at a time
resource "aviatrix_firewall_management_access" "transit_firenet_firewall_management_1" {
  transit_firenet_gateway_name      = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
  management_access_resource_name   = join(":", ["SITE2CLOUD", aviatrix_site2cloud.transit_firenet_s2c_spoke1_transit.connection_name])
}
# resource "aviatrix_firewall_management_access" "transit_firenet_firewall_management_2" {
#   transit_firenet_gateway_name      = aviatrix_transit_gateway.aws_transit_firenet_gateway.gw_name
#   management_access_resource_name   = join(":", ["SPOKE", aviatrix_spoke_gateway.transit_firenet_spoke_gateway_2.gw_name])
# }

#################################################
# Outputs
#################################################
output "aws_transit_firenet_gateway_id" {
  value = aviatrix_transit_gateway.aws_transit_firenet_gateway.id
}
output "transit_firenet_policy_1_id" {
  value = aviatrix_transit_firenet_policy.transit_firenet_policy_1.id
}
output "transit_firenet_policy_2_id" {
  value = aviatrix_transit_firenet_policy.transit_firenet_policy_2.id
}
output "transit_firenet_firewall_management_1_id" {
  value = aviatrix_firewall_management_access.transit_firenet_firewall_management_1.id
}
