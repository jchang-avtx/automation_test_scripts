resource random_integer vpc1_cidr_int {
  count = 2
  min = 1
  max = 126
}
resource random_integer vnet1_cidr_int {
  count = 3
  min = 1
  max = 126
}
resource random_integer vnet2_cidr_int {
  count = 3
  min = 1
  max = 126
}

##############################################################################
## VPC
##############################################################################
resource aviatrix_vpc aws_custom_routes_vpc {
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = "us-east-1"
  name                  = "aws-custom-routes-vpc"
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "0.0/16"])
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
}
resource aviatrix_vpc arm_custom_routes_vnet {
  account_name          = "AzureAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet1_cidr_int[0].result, random_integer.vnet1_cidr_int[1].result, random_integer.vnet1_cidr_int[2].result, "0/24"])
  cloud_type            = 8
  name                  = "arm-custom-routes-vnet"
  region                = "Central US"
}
resource aviatrix_vpc gcp_custom_routes_vpc {
  account_name          = "GCPAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cloud_type            = 4
  name                  = "gcp-custom-routes-vpc"
  subnets {
    name    = "asia-east1-subnet"
    region  = "asia-east1"
    cidr    = "172.20.0.0/16"
  }
}
resource aviatrix_vpc oci_custom_routes_vnet {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vnet2_cidr_int[0].result, random_integer.vnet2_cidr_int[1].result, random_integer.vnet2_cidr_int[2].result, "0/24"])
  cloud_type            = 16
  name                  = "oci-custom-routes-vnet"
  region                = "us-ashburn-1"
}

##############################################################################
## GATEWAY
##############################################################################

resource aviatrix_spoke_gateway aws_custom_routes_spoke {
  cloud_type   = 1
  account_name = "AWSAccess"
  gw_name      = "aws-custom-routes-spoke"
  vpc_id       = aviatrix_vpc.aws_custom_routes_vpc.vpc_id
  vpc_reg      = aviatrix_vpc.aws_custom_routes_vpc.region
  # gw_size      = "t2.micro"
  # subnet       = aviatrix_vpc.aws_custom_routes_vpc.subnets.6.cidr
  gw_size      = "c5.large"

  insane_mode  = true
  insane_mode_az = "us-east-1a"
  subnet       = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "192.0/26"])
  ha_insane_mode_az = "us-east-1b"
  ha_subnet    = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, "192.64/26"])
  ha_gw_size   = "c5.large"

  # ha_subnet    = aviatrix_vpc.aws_custom_routes_vpc.subnets.7.cidr
  # ha_gw_size   = "t2.micro"
  single_ip_snat  = false
  # tag_list     = [
  #   "k1:v1",
  #   "k2:v2",
  # ]
  transit_gw   = null

  customized_spoke_vpc_routes = var.custom_spoke_vpc_routes
  filtered_spoke_vpc_routes = var.filter_spoke_vpc_routes
  included_advertised_spoke_routes = var.include_advertise_spoke_routes
}

resource aviatrix_spoke_gateway arm_custom_routes_spoke {
  cloud_type        = 8
  account_name      = "AzureAccess"
  gw_name           = "arm-custom-routes-spoke"
  vpc_id            = aviatrix_vpc.arm_custom_routes_vnet.vpc_id
  vpc_reg           = aviatrix_vpc.arm_custom_routes_vnet.region
  gw_size           = "Standard_B1ms"

  # insane_mode       = true
  subnet            = aviatrix_vpc.arm_custom_routes_vnet.subnets.0.cidr
  # subnet            = "10.3.0.0/24" # non-insane

  ha_subnet         = aviatrix_vpc.arm_custom_routes_vnet.subnets.1.cidr
  ha_gw_size        = "Standard_B1ms"

  single_ip_snat    = false # insane mode does not support SNAT
  single_az_ha      = true
  transit_gw        = null
  enable_active_mesh= false

  customized_spoke_vpc_routes = var.custom_spoke_vpc_routes
  filtered_spoke_vpc_routes = var.filter_spoke_vpc_routes
  included_advertised_spoke_routes = var.include_advertise_spoke_routes
}

resource aviatrix_spoke_gateway gcp_custom_routes_spoke {
  cloud_type      = 4
  account_name    = "GCPAccess"
  gw_name         = "gcp-custom-routes-spoke"
  vpc_id          = aviatrix_vpc.gcp_custom_routes_vpc.vpc_id
  vpc_reg         = join("-", [aviatrix_vpc.gcp_custom_routes_vpc.subnets.0.region, "a"])
  gw_size         = "n1-standard-1"
  subnet          = aviatrix_vpc.gcp_custom_routes_vpc.subnets.0.cidr

  ha_zone         = join("-", [aviatrix_vpc.gcp_custom_routes_vpc.subnets.0.region, "b"])
  ha_gw_size      = "n1-standard-1"
  ha_subnet       = aviatrix_vpc.gcp_custom_routes_vpc.subnets.0.cidr

  single_ip_snat  = false # cannot have SNAT enabled if you have HA-enabled
  # single_az_ha = "enabled" # used if not have HA-gw; not supported for Gcloud
  transit_gw      = null
  # tag_list = ["k1:v1"] # only supported in AWS
  enable_active_mesh = false

  customized_spoke_vpc_routes = var.custom_spoke_vpc_routes
  filtered_spoke_vpc_routes = var.filter_spoke_vpc_routes
  included_advertised_spoke_routes = var.include_advertise_spoke_routes
}

resource aviatrix_spoke_gateway oci_custom_routes_spoke {
  cloud_type        = 16
  account_name      = "OCIAccess"
  gw_name           = "oci-custom-routes-spoke"
  vpc_id            = aviatrix_vpc.oci_custom_routes_vnet.name
  vpc_reg           = aviatrix_vpc.oci_custom_routes_vnet.region
  gw_size           = "VM.Standard2.2"

  subnet            = aviatrix_vpc.oci_custom_routes_vnet.subnets.0.cidr
  single_az_ha      = true

  ha_subnet         = aviatrix_vpc.oci_custom_routes_vnet.subnets.0.cidr
  ha_gw_size        = "VM.Standard2.2"
  single_ip_snat    = false
  enable_active_mesh= false

  transit_gw        = null

  customized_spoke_vpc_routes = var.custom_spoke_vpc_routes
  filtered_spoke_vpc_routes = var.filter_spoke_vpc_routes
  included_advertised_spoke_routes = var.include_advertise_spoke_routes
}

##############################################################################
## OUTPUT
##############################################################################
output aws_custom_routes_spoke_id {
  value = aviatrix_spoke_gateway.aws_custom_routes_spoke.id
}

output arm_custom_routes_spoke_id {
  value = aviatrix_spoke_gateway.arm_custom_routes_spoke.id
}

output gcp_custom_routes_spoke_id {
  value = aviatrix_spoke_gateway.gcp_custom_routes_spoke.id
}

output oci_custom_routes_spoke_id {
  value = aviatrix_spoke_gateway.oci_custom_routes_spoke.id
}
