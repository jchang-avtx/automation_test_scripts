resource "aviatrix_spoke_vpc" "azure_spoke" {
    account_name = "${var.account_name}"
    cloud_type = 8
    gw_name = "spoke-azure"
    vnet_and_resource_group_names = "${var.vpc_id}"
    vpc_reg = "${var.region}"
    vpc_size = "Standard_B1s"
    subnet = "${var.subnet}"
    ha_subnet = "${var.subnet}"
    transit_gw = "${var.transit_gateway}"
}

# Create encrypteed peering between shared to spoke gateway
resource "aviatrix_tunnel" "shared-to-spoke"{
  count = "1"
  vpc_name1 = "${aviatrix_spoke_vpc.azure_spoke.gw_name}"
  vpc_name2 = "${var.shared}"
  cluster   = "no"
  enable_ha = "yes"
  over_aws_peering = "no"
  peering_hastatus = "yes"
  depends_on = ["aviatrix_spoke_vpc.azure_spoke"]
}
