variable gateway_cidrs {
  description = "Map for firewall_gateways' parameters"
  type = map
  default = {
    "firewall-gw1" = "172.31.0.0/20"
    "firewall-gw2" = "172.31.16.0/20"
    "firewall-gw3" = "172.31.0.0/20"
  }
}

resource aviatrix_gateway firewall_gateway {
  for_each = var.gateway_cidrs
  cloud_type    = 1
  account_name  = "AWSAccess"
  gw_name       = each.key
  vpc_id        = "vpc-ba3c12dd"
  vpc_reg       = "us-west-1"

  gw_size       = "t2.micro"
  subnet        = each.value
}
