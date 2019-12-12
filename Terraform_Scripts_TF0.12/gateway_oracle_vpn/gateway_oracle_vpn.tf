resource "aviatrix_gateway" "oci_vpn_gateway" {
  cloud_type          = 16
  account_name        = "OCIAccess"
  gw_name             = "oci-vpn-gw"
  vpc_id              = "OCI-VCN-phoenix"
  vpc_reg              = "us-phoenix-1"
  gw_size             = "VM.Standard2.2"
  subnet              = "169.69.0.0/16"

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
