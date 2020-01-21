resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "sdnat_spoke_aws_vpc" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  region                  = "us-east-2"
  name                    = "sdnat-spoke-aws-vpc"
  cidr                    = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

resource "aviatrix_vpc" "sdnat_spoke_arm_vpc" {
  cloud_type              = 8
  account_name            = "AzureAccess"
  region                  = "Central US"
  name                    = "sdnat-spoke-arm-vpc"
  cidr                    = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

data "aws_route_table" "sdnat_spoke_aws_rtb" {
  vpc_id      = aviatrix_vpc.sdnat_spoke_aws_vpc.vpc_id
  subnet_id   = aviatrix_vpc.sdnat_spoke_aws_vpc.subnets.3.subnet_id
}

data "azurerm_route_table" "sdnat_spoke_arm_rtb" {
  name                  = "rtb-user"
  resource_group_name   = element(split(":", aviatrix_vpc.sdnat_spoke_arm_vpc.vpc_id),1)
}

resource "aviatrix_transit_gateway" "random_transit" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "random-transit"
  vpc_id              = "vpc-0c32b9c3a144789ef"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "10.0.1.32/28"
  enable_active_mesh  = false
}

resource "aviatrix_spoke_gateway" "sdnat_spoke_aws_gw" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "sdnat-spoke-aws-gw"
  vpc_id            = aviatrix_vpc.sdnat_spoke_aws_vpc.vpc_id
  vpc_reg           = aviatrix_vpc.sdnat_spoke_aws_vpc.region
  gw_size           = "t2.micro"
  subnet            = aviatrix_vpc.sdnat_spoke_aws_vpc.subnets.3.cidr

  enable_active_mesh  = false # activemesh does not support DNAT
  transit_gw          = aviatrix_transit_gateway.random_transit.gw_name

  enable_snat       = true # disable AWS NAT instance before enabling; not supported w insane mode
  snat_mode         = "custom"
  snat_policy {
    src_ip        = "10.0.0.0/24"
    src_port      = ""
    dst_ip        = "11.0.0.0/24"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    new_src_ip    = "12.0.0.0"
    new_src_port  = ""
    exclude_rtb   = ""
  }
  snat_policy {
    src_ip        = var.aws_snat_policy_src_ip
    src_port      = var.aws_snat_policy_src_port
    dst_ip        = var.aws_snat_policy_dst_ip
    dst_port      = var.aws_snat_policy_dst_port
    protocol      = var.aws_snat_policy_protocol
    interface     = var.aws_snat_policy_interface
    connection    = var.aws_snat_policy_connection
    mark          = var.aws_snat_policy_mark
    new_src_ip    = var.aws_snat_policy_new_src_ip
    new_src_port  = var.aws_snat_policy_new_src_port
    exclude_rtb   = data.aws_route_table.sdnat_spoke_aws_rtb.id
  }

  dnat_policy {
    src_ip        = "16.0.0.0/24"
    src_port      = ""
    dst_ip        = "17.0.0.0/24"
    dst_port      = ""
    protocol      = "icmp"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    new_src_ip    = "18.0.0.0"
    new_src_port  = ""
    exclude_rtb   = ""
  }
  dnat_policy {
    src_ip        = var.aws_dnat_policy_src_ip
    src_port      = var.aws_dnat_policy_src_port
    dst_ip        = var.aws_dnat_policy_dst_ip
    dst_port      = var.aws_dnat_policy_dst_port
    protocol      = var.aws_dnat_policy_protocol
    interface     = var.aws_dnat_policy_interface
    connection    = var.aws_dnat_policy_connection
    mark          = var.aws_dnat_policy_mark
    new_src_ip    = var.aws_dnat_policy_new_src_ip
    new_src_port  = var.aws_dnat_policy_new_src_port
    exclude_rtb   = data.aws_route_table.sdnat_spoke_aws_rtb.id
  }
}

resource "aviatrix_spoke_gateway" "sdnat_spoke_arm_gw" {
  cloud_type      = 8
  account_name    = "AzureAccess"
  gw_name         = "sdnat-spoke-arm-gw"
  vpc_id          = aviatrix_vpc.sdnat_spoke_arm_vpc.vpc_id
  vpc_reg         = aviatrix_vpc.sdnat_spoke_arm_vpc.region
  gw_size         = "Standard_B1s"
  subnet          = aviatrix_vpc.sdnat_spoke_arm_vpc.subnets.0.cidr

  enable_snat     = true
  snat_mode       = "custom"
  snat_policy {
    src_ip        = "10.0.0.0/24"
    src_port      = ""
    dst_ip        = "11.0.0.0/24"
    dst_port      = ""
    protocol      = "icmp"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    new_src_ip    = "12.0.0.0"
    new_src_port  = ""
    exclude_rtb   = ""
  }
  snat_policy {
    src_ip        = var.arm_snat_policy_src_ip
    src_port      = var.arm_snat_policy_src_port
    dst_ip        = var.arm_snat_policy_dst_ip
    dst_port      = var.arm_snat_policy_dst_port
    protocol      = var.arm_snat_policy_protocol
    interface     = var.arm_snat_policy_interface
    connection    = var.arm_snat_policy_connection
    mark          = var.arm_snat_policy_mark
    new_src_ip    = var.arm_snat_policy_new_src_ip
    new_src_port  = var.arm_snat_policy_new_src_port
    exclude_rtb   = join(":", [data.azurerm_route_table.sdnat_spoke_arm_rtb.name, data.azurerm_route_table.sdnat_spoke_arm_rtb.resource_group_name])
  }

  dnat_policy {
    src_ip        = "16.0.0.0/24"
    src_port      = ""
    dst_ip        = "17.0.0.0/24"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    new_src_ip    = "18.0.0.0"
    new_src_port  = ""
    exclude_rtb   = ""
  }
  dnat_policy {
    src_ip        = var.arm_dnat_policy_src_ip
    src_port      = var.arm_dnat_policy_src_port
    dst_ip        = var.arm_dnat_policy_dst_ip
    dst_port      = var.arm_dnat_policy_dst_port
    protocol      = var.arm_dnat_policy_protocol
    interface     = var.arm_dnat_policy_interface
    connection    = var.arm_dnat_policy_connection
    mark          = var.arm_dnat_policy_mark
    new_src_ip    = var.arm_dnat_policy_new_src_ip
    new_src_port  = var.arm_dnat_policy_new_src_port
    exclude_rtb   = join(":", [data.azurerm_route_table.sdnat_spoke_arm_rtb.name, data.azurerm_route_table.sdnat_spoke_arm_rtb.resource_group_name])
  }
}

output "sdnat_spoke_aws_gw_id" {
  value = aviatrix_spoke_gateway.sdnat_spoke_aws_gw.id
}
output "sdnat_spoke_arm_gw_id" {
  value = aviatrix_spoke_gateway.sdnat_spoke_arm_gw.id
}
