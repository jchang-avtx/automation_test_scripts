resource "random_integer" "vpc1_cidr_int" {
  count = 3
  min = 1
  max = 223
}

resource "aviatrix_vpc" "oci_vpn_gw_vnet_1" {
  account_name          = "OCIAccess"
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = false
  cidr                  = join(".", [random_integer.vpc1_cidr_int[0].result, random_integer.vpc1_cidr_int[1].result, random_integer.vpc1_cidr_int[2].result, "0/24"])
  cloud_type            = 16
  name                  = "oci-vpn-gw-vnet-1"
  region                = "us-phoenix-1"
}

resource "aviatrix_gateway" "oci_vpn_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-vpn-gw"
  vpc_id              = aviatrix_vpc.oci_vpn_gw_vnet_1.name
  vpc_reg             = aviatrix_vpc.oci_vpn_gw_vnet_1.region
  gw_size             = "VM.Standard2.2"
  subnet              = aviatrix_vpc.oci_vpn_gw_vnet_1.subnets.0.cidr

  enable_snat         = true
  single_az_ha        = var.aviatrix_single_az_ha

  vpn_access          = true
  vpn_cidr            = var.aviatrix_vpn_cidr
  # enable_elb          = true ## not supported by OCI
  # elb_name            = "elb-oci-vpn-gw"
  max_vpn_conn        = var.aviatrix_vpn_max_conn
  enable_vpn_nat      = var.aviatrix_vpn_nat

  split_tunnel        = var.aviatrix_vpn_split_tunnel
  search_domains      = var.aviatrix_vpn_split_tunnel_search_domain_list
  additional_cidrs    = var.aviatrix_vpn_split_tunnel_additional_cidrs_list
  name_servers        = var.aviatrix_vpn_split_tunnel_name_servers_list

  saml_enabled        = true
}

output "oci_vpn_gateway_id" {
  value = aviatrix_gateway.oci_vpn_gateway.id
}
