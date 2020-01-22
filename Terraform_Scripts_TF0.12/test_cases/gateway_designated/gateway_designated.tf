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

resource "aviatrix_vpc" "design_vpc" {
  cloud_type              = 1
  account_name            = "AWSAccess"
  region                  = "us-east-2"
  name                    = "design-vpc"
  cidr                    = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

resource "aviatrix_vpc" "design_arm_vpc" {
  cloud_type              = 8
  account_name            = "AzureAccess"
  region                  = "Central US"
  name                    = "design-arm-vpc"
  cidr                    = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

data "aws_route_table" "design_rtb" {
  vpc_id      = aviatrix_vpc.design_vpc.vpc_id
  subnet_id   = aviatrix_vpc.design_vpc.subnets.3.subnet_id
}

resource "aviatrix_gateway" "design_gw" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "design-gw"
  vpc_id        = aviatrix_vpc.design_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.design_vpc.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.design_vpc.subnets.3.cidr

  enable_designated_gateway           = true
  additional_cidrs_designated_gateway = var.additional_cidrs

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
    exclude_rtb   = data.aws_route_table.design_rtb.id
  }
}

resource "aviatrix_gateway" "design_arm_gw" {
  cloud_type    = 8
  account_name  = "AzureAccess"
  gw_name       = "design-arm-gw"
  vpc_id        = aviatrix_vpc.design_arm_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.design_arm_vpc.region
  gw_size       = "Standard_B1s"
  subnet        = aviatrix_vpc.design_arm_vpc.subnets.0.cidr

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
    # exclude_rtb   = join(":", [data.azurerm_route_table.design_arm_gw_rtb.name, data.azurerm_route_table.design_arm_gw_rtb.resource_group_name])
  }
}


output "design_gw_id" {
  value = aviatrix_gateway.design_gw.id
}
output "design_arm_gw_id" {
  value = aviatrix_gateway.design_arm_gw.id
}
