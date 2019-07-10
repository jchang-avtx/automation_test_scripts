## Create Aviatrix transit gateway peering
## Must first create 2 Transit GWs before creating the peering of the two

resource "aviatrix_transit_vpc" "test_transit_gw1" {
  cloud_type        = 1
  account_name      = "AnthonyPrimaryAccess"
  gw_name           = "transitGW1"
  enable_nat        = "yes"
  vpc_id            = "vpc-0c32b9c3a144789ef"
  vpc_reg           = "us-east-1"
  vpc_size          = "t2.micro"
  subnet            = "10.0.1.32/28"

  enable_hybrid_connection = false
  connected_transit = "yes"
}

resource "aviatrix_transit_vpc" "test_transit_gw2" {
  cloud_type        = 1
  account_name      = "AnthonyPrimaryAccess"
  gw_name           = "transitGW2"
  enable_nat        = "yes"
  vpc_id            = "vpc-0cbdc7571b2fd28bf"
  vpc_reg           = "us-west-1"
  vpc_size          = "t2.micro"
  subnet            = "100.200.0.0/16"

  enable_hybrid_connection  = false
  connected_transit         = "yes"
}

resource "aviatrix_transit_gateway_peering" "test_transit_gw_peering" {
  transit_gateway_name1 = aviatrix_transit_vpc.test_transit_gw1.gw_name
  transit_gateway_name2 = aviatrix_transit_vpc.test_transit_gw2.gw_name
  depends_on            = ["aviatrix_transit_vpc.test_transit_gw1", "aviatrix_transit_vpc.test_transit_gw2"]
}
