## Create Aviatrix transit gateway peering
## Must first create 2 Transit GWs before creating the peering of the two

resource "aviatrix_transit_vpc" "test_transit_gw1" {
  cloud_type        = 1
  account_name      = "PrimaryAccessAccount"
  gw_name           = "transitGW1"
  enable_nat        = "yes"
  vpc_id            = "vpc-1234"
  vpc_reg           = "us-east-1"
  vpc_size          = "t2.micro"
  subnet            = "10.0.0.0/24"
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC
  # HA-related parameters are removed for sake of testing speed
  enable_hybrid_connection = false # (optional) sign of readiness for TGW connection (ex. false)
  connected_transit = "yes" # (optional) specify connected transit status (yes or no)
}

resource "aviatrix_transit_vpc" "test_transit_gw2" {
  cloud_type        = 1
  account_name      = "PrimaryAccessAccount"
  gw_name           = "transitGW2"
  enable_nat        = "yes"
  vpc_id            = "vpc-5678"
  vpc_reg           = "us-west-1"
  vpc_size          = "t2.micro"
  subnet            = "11.0.0.0/24"
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC
  # HA-related parameters are removed for sake of testing speed
  enable_hybrid_connection = false # (optional) sign of readiness for TGW connection (ex. false)
  connected_transit = "yes" # (optional) specify connected transit status (yes or no)
}

resource "aviatrix_transit_gateway_peering" "test_transit_gw_peering" {
  transit_gateway_name1 = "transitGW1"
  transit_gateway_name2 = "transitGW2"
  depends_on            = ["aviatrix_transit_vpc.test_transit_gw1", "aviatrix_transit_vpc.test_transit_gw2"]
}
