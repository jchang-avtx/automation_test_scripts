resource "aviatrix_spoke_vpc" "azure_spoke" {
    account_name = "${var.account_name}"
    cloud_type = 8
    gw_name = "spoke-azure"
    vnet_and_resource_group_names = "av-group1-vnet:av-group1"
    vpc_reg = "West US"
    vpc_size = "Standard_B1s"
    subnet = "10.0.1.0/24"
    ha_subnet = "10.0.1.0/24"
    transit_gw = "${var.transit_gw}"
}

# Create encrypteed peering between shared to spoke gateway
resource "aviatrix_tunnel" "shared-to-spoke"{
  count = "1"
  vpc_name1 = "${aviatrix_spoke_vpc.azure_spoke.gw_name}"
  vpc_name2 = "canada-shared"
  cluster   = "no"
  enable_ha = "yes"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  depends_on = ["aviatrix_spoke_vpc.azure_spoke"]
}
