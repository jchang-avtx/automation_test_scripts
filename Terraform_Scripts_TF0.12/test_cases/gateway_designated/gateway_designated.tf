resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "random_integer" "vpc2_cidr_int" {
  count = 3
  min = 1
  max = 126
}

resource "aviatrix_vpc" "design_aws_vpc" {
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
  vpc_id      = aviatrix_vpc.design_aws_vpc.vpc_id
  subnet_id   = aviatrix_vpc.design_aws_vpc.subnets.3.subnet_id
}

resource "aviatrix_gateway" "design_aws_gw" {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "design-aws-gw"
  vpc_id        = aviatrix_vpc.design_aws_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.design_aws_vpc.region
  gw_size       = "t2.micro"
  subnet        = aviatrix_vpc.design_aws_vpc.subnets.3.cidr

  enable_designated_gateway           = true
  additional_cidrs_designated_gateway = var.additional_cidrs
}
resource "aviatrix_gateway_snat" "design_aws_snat" {
  gw_name = aviatrix_gateway.design_aws_gw.gw_name
  snat_policy {
    src_cidr      = "10.0.0.0/24"
    src_port      = ""
    dst_cidr      = "11.0.0.0/24"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    snat_ips      = "12.0.0.0"
    snat_port     = ""
    exclude_rtb   = ""
  }
}
resource "aviatrix_gateway_dnat" "design_aws_dnat" {
  gw_name = aviatrix_gateway.design_aws_gw.gw_name
  dnat_policy {
    src_cidr      = "16.0.0.0/24"
    src_port      = ""
    dst_cidr      = "17.0.0.0/24"
    dst_port      = ""
    protocol      = "icmp"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    dnat_ips      = "18.0.0.0"
    dnat_port     = ""
    exclude_rtb   = ""
  }
  dnat_policy {
    src_cidr      = var.aws_dnat_policy_src_cidr
    src_port      = var.aws_dnat_policy_src_port
    dst_cidr      = var.aws_dnat_policy_dst_cidr
    dst_port      = var.aws_dnat_policy_dst_port
    protocol      = var.aws_dnat_policy_protocol
    interface     = var.aws_dnat_policy_interface
    connection    = var.aws_dnat_policy_connection
    mark          = var.aws_dnat_policy_mark
    dnat_ips      = var.aws_dnat_policy_dnat_ips
    dnat_port     = var.aws_dnat_policy_dnat_port
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
}
resource "aviatrix_gateway_snat" "design_arm_snat" {
  gw_name = aviatrix_gateway.design_arm_gw.gw_name
  snat_policy {
    src_cidr      = "10.0.0.0/24"
    src_port      = ""
    dst_cidr      = "11.0.0.0/24"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    snat_ips      = "12.0.0.0"
    snat_port     = ""
    exclude_rtb   = ""
  }
}
resource "aviatrix_gateway_dnat" "design_arm_dnat" {
  gw_name = aviatrix_gateway.design_arm_gw.gw_name
  dnat_policy {
    src_cidr      = "16.0.0.0/24"
    src_port      = ""
    dst_cidr      = "17.0.0.0/24"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    dnat_ips      = "18.0.0.0"
    dnat_port     = ""
    exclude_rtb   = ""
  }
  dnat_policy {
    src_cidr      = var.arm_dnat_policy_src_cidr
    src_port      = var.arm_dnat_policy_src_port
    dst_cidr      = var.arm_dnat_policy_dst_cidr
    dst_port      = var.arm_dnat_policy_dst_port
    protocol      = var.arm_dnat_policy_protocol
    interface     = var.arm_dnat_policy_interface
    connection    = var.arm_dnat_policy_connection
    mark          = var.arm_dnat_policy_mark
    dnat_ips      = var.arm_dnat_policy_dnat_ips
    dnat_port     = var.arm_dnat_policy_dnat_port
    # exclude_rtb   = join(":", [data.azurerm_route_table.design_arm_gw_rtb.name, data.azurerm_route_table.design_arm_gw_rtb.resource_group_name])
  }
}

output "design_aws_dnat_id" {
  value = aviatrix_gateway_dnat.design_aws_dnat.id
}
output "design_arm_dnat_id" {
  value = aviatrix_gateway_dnat.design_arm_dnat.id
}
