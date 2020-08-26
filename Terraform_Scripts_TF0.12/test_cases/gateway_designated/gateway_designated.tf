#################################################
# AWS
#################################################
resource random_integer vpc2_cidr_int {
  count = 3
  min = 1
  max = 126
}

resource aviatrix_vpc design_aws_vpc {
  cloud_type              = 1
  account_name            = "AWSAccess"
  region                  = "us-east-2"
  name                    = "design-vpc"
  cidr                    = "10.3.0.0/16"
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

# Mantis 13505 : DNAT resource creation fails due to existing SNAT policy (incorrect arg reference)
resource aws_subnet design_vpc_subnet_13505 {
  availability_zone     = join("", [aviatrix_vpc.design_aws_vpc.region, "a"])
  cidr_block            = "10.3.96.0/24" # avoid overlap in AZs
  vpc_id                = aviatrix_vpc.design_aws_vpc.vpc_id
}

data aws_route_table design_rtb {
  vpc_id      = aviatrix_vpc.design_aws_vpc.vpc_id
  subnet_id   = aviatrix_vpc.design_aws_vpc.public_subnets.0.subnet_id
}

data aws_route_table design_rtb_13505 {
  vpc_id      = aviatrix_vpc.design_aws_vpc.vpc_id
  subnet_id   = aviatrix_vpc.design_aws_vpc.public_subnets.1.subnet_id
}

resource aws_route_table_association design_rtb_assoc_13505 {
  route_table_id    = data.aws_route_table.design_rtb_13505.route_table_id
  subnet_id         = aws_subnet.design_vpc_subnet_13505.id
}

resource aviatrix_gateway design_aws_gw {
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = "design-aws-gw"
  vpc_id        = aviatrix_vpc.design_aws_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.design_aws_vpc.region
  gw_size       = "t2.micro"
  subnet        = aws_subnet.design_vpc_subnet_13505.cidr_block

  enable_designated_gateway           = true
  additional_cidrs_designated_gateway = var.additional_cidrs

  depends_on    = [aws_route_table_association.design_rtb_assoc_13505]
}

#################################################
# Azure
#################################################
resource aviatrix_vpc design_arm_vpc {
  cloud_type              = 8
  account_name            = "AzureAccess"
  region                  = "Central US"
  name                    = "design-arm-vpc"
  cidr                    = join(".", [random_integer.vpc2_cidr_int[0].result, random_integer.vpc2_cidr_int[1].result, random_integer.vpc2_cidr_int[2].result, "0/24"])
  aviatrix_transit_vpc    = false
  aviatrix_firenet_vpc    = false
}

resource aviatrix_gateway design_arm_gw {
  cloud_type    = 8
  account_name  = "AzureAccess"
  gw_name       = "design-arm-gw"
  vpc_id        = aviatrix_vpc.design_arm_vpc.vpc_id
  vpc_reg       = aviatrix_vpc.design_arm_vpc.region
  gw_size       = "Standard_B1ms"
  subnet        = aviatrix_vpc.design_arm_vpc.subnets.0.cidr

  peering_ha_gw_size = "Standard_B1ms"
  peering_ha_subnet = aviatrix_vpc.design_arm_vpc.subnets.1.cidr
}

#################################################
# AWS S/DNAT
#################################################
resource aviatrix_gateway_snat design_aws_snat {
  gw_name = aviatrix_gateway.design_aws_gw.gw_name
  sync_to_ha = null

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

resource aviatrix_gateway_dnat design_aws_dnat {
  gw_name = aviatrix_gateway.design_aws_gw.gw_name
  sync_to_ha = null

  dnat_policy {
    src_cidr      = "10.9.5.0/24"
    src_port      = ""
    dst_cidr      = "10.4.4.100/32"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    dnat_ips      = "10.3.3.100" # IP within VPC subnet
    dnat_port     = "" #
    exclude_rtb   = ""
  }
  dnat_policy {
    src_cidr      = "10.106.4.0/24" # note near dupe policy rule; if diff resource, will fail
    src_port      = ""
    dst_cidr      = "10.4.4.100/32"
    dst_port      = ""
    protocol      = "all"
    interface     = "eth0"
    connection    = "None"
    mark          = ""
    dnat_ips      = "10.3.3.100" # IP within VPC subnet
    dnat_port     = "" #
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

#################################################
# Azure S/DNAT
#################################################
resource aviatrix_gateway_snat design_arm_snat {
  gw_name = aviatrix_gateway.design_arm_gw.gw_name
  sync_to_ha = true

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

resource aviatrix_gateway_dnat design_arm_dnat {
  gw_name = aviatrix_gateway.design_arm_gw.gw_name
  sync_to_ha = true

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

#################################################
# Outputs
#################################################
output design_aws_dnat_id {
  value = aviatrix_gateway_dnat.design_aws_dnat.id
}
output design_arm_dnat_id {
  value = aviatrix_gateway_dnat.design_arm_dnat.id
}
