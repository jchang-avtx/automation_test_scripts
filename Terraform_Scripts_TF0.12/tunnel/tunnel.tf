## Build encrypted peering between Aviatrix gateways in HA mode
## Creates 2 GWs and a peering tunnel

resource "aviatrix_gateway" "peeringGW1" {
  cloud_type          = 1
  account_name        = "AnthonyPrimaryAccess"
  gw_name             = "peeringGW1"
  vpc_id              = "vpc-0086065966b807866"
  vpc_reg             = "us-east-1"
  vpc_size            = "t2.micro"
  vpc_net             = "10.0.0.0/24"

  peering_ha_subnet   = "10.0.0.0/24"
  peering_ha_gw_size  = "t2.micro"
  peering_ha_eip      = "3.92.103.18"
}

resource "aviatrix_gateway" "peeringGW2" {
  cloud_type          = 1
  account_name        = "AnthonyPrimaryAccess"
  gw_name             = "peeringGW2"
  vpc_id              = "vpc-04ca29a568bf2b35f"
  vpc_reg             = "us-east-1"
  vpc_size            = "t2.micro"
  vpc_net             = "10.202.0.0/16"

  peering_ha_subnet   = "10.202.0.0/16"
  peering_ha_gw_size  = "t2.micro"
  peering_ha_eip      = "34.232.45.155"
}

# Create encrypted peering between two aviatrix gateway
resource "aviatrix_tunnel" "peeringTunnel"{
  vpc_name1     = aviatrix_gateway.peeringGW1.gw_name
  vpc_name2     = aviatrix_gateway.peeringGW2.gw_name
  enable_ha     = "yes"
  depends_on    = ["aviatrix_gateway.peeringGW1", "aviatrix_gateway.peeringGW2"]
}
