## Build encrypted peering between Aviatrix gateways in HA mode
## Creates 2 GWs and a peering tunnel

resource "aviatrix_gateway" "peeringGW1" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "peeringGW1"
  vpc_id              = "vpc-0086065966b807866"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "10.0.0.0/24"

  peering_ha_subnet   = "10.0.0.0/24"
  peering_ha_gw_size  = "t2.micro"
  peering_ha_eip      = "3.92.103.18"
}

resource "aviatrix_gateway" "peeringGW2" {
  cloud_type          = 1
  account_name        = "AWSAccess"
  gw_name             = "peeringGW2"
  vpc_id              = "vpc-04ca29a568bf2b35f"
  vpc_reg             = "us-east-1"
  gw_size             = "t2.micro"
  subnet              = "10.202.0.0/16"

  peering_ha_subnet   = "10.202.0.0/16"
  peering_ha_gw_size  = "t2.micro"
  peering_ha_eip      = "34.232.45.155"
}

# Create encrypted peering between two aviatrix gateway
resource "aviatrix_tunnel" "peeringTunnel" {
  gw_name1      = aviatrix_gateway.peeringGW1.gw_name
  gw_name2      = aviatrix_gateway.peeringGW2.gw_name
  enable_ha     = true
}

output "peeringTunnel_id" {
  value = aviatrix_tunnel.peeringTunnel.id
}
