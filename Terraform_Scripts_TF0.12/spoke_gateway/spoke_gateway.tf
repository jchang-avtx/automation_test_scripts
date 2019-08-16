# Launch a spoke VPC, and join with transit VPC.

resource "aviatrix_transit_gateway" "test_transit_gw1" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "transitGW1forSpoke"
  vpc_id          = "vpc-0c32b9c3a144789ef"
  vpc_reg         = "us-east-1"
  gw_size         = "t2.micro"
  subnet          = "10.0.1.32/28"

  ha_subnet       = "10.0.1.32/28"
  ha_gw_size      = "t2.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
}

## Create a 2nd transitGW to test "updateTransitGW.tfvars test case"
resource "aviatrix_transit_gateway" "test_transit_gw2" {
  cloud_type      = 1
  account_name    = "AWSAccess"
  gw_name         = "transitGW2forSpoke"
  vpc_id          = "vpc-0cbdc7571b2fd28bf"
  vpc_reg         = "us-west-1"
  gw_size         = "t2.micro"
  subnet          = "100.200.0.0/16"

  ha_subnet       = "100.200.0.0/16"
  ha_gw_size      = "t2.micro"

  enable_hybrid_connection  = false
  connected_transit         = true
}

resource "aviatrix_spoke_gateway" "test_spoke_gateway" {
  cloud_type        = 1
  account_name      = "AWSAccess"
  gw_name           = "spoke-gw-01"
  vpc_id            = "vpc-06b5b670e792e3462"
  vpc_reg           = "us-east-1"
  gw_size           = var.gw_size

  # insane_mode       = true
  # insane_mode_az    = "us-east-1a"
  # subnet            = "172.0.2.0/26"
  subnet            = "172.0.0.0/24" # non-insane

  # ha_insane_mode_az = "us-east-1b"
  # ha_subnet         = "172.0.2.64/26"
  ha_subnet         = "172.0.1.0/24" # non-insane
  ha_gw_size        = var.aviatrix_ha_gw_size
  enable_snat       = false

  allocate_new_eip  = false
  eip               = "34.239.41.40"
  ha_eip            = "3.213.178.197"

  transit_gw        = var.aviatrix_transit_gw
  tag_list          = ["k1:v1", "k2:v2"]
  depends_on        = ["aviatrix_transit_gateway.test_transit_gw1", "aviatrix_transit_gateway.test_transit_gw2"]
}
