resource "aviatrix_gateway" "fqdn_firenet_gw" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
  gw_name         = "fqdn-firenet-gw"
  vpc_id          = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.0.cidr

  single_az_ha    = true
  single_ip_snat  = false

  lifecycle {
    ignore_changes = [single_ip_snat]
  }
}

resource "aviatrix_fqdn" "fqdn_firenet_rules" {
  fqdn_tag      = "fqdn-firenet-rules"
  fqdn_enabled  = true
  fqdn_mode     = "black"

  gw_filter_tag_list {
    gw_name         = aviatrix_gateway.fqdn_firenet_gw.gw_name
    source_ip_list  = ["172.31.0.0/16"]
  }

  domain_names {
    fqdn   = "reddit.com"
    proto  = "tcp"
    port   = 443
    action = "Allow"
  }

  depends_on = [aviatrix_firenet.fqdn_firenet]
}
