## Initial creation
# Launch a spoke VPC, and join with transit VPC.
# Omit ha_subnet to launch spoke VPC without HA.
# ha_subnet can be later added or deleted to enable/disable HA in spoke VPC
# Omit transit_gw to launch spoke VPC without attaching with transit GW.
# transit_gw can be later added or deleted to attach/detach from spoke VPC

resource "aviatrix_spoke_vpc" "test_spoke_vpc" {
  cloud_type = "${var.aviatrix_cloud_type_aws}"
  account_name = "${var.aviatrix_cloud_account_name}"
  gw_name = "${var.aviatrix_gateway_name}"
  vpc_id = "${var.aws_vpc_id}"
  # vnet_and_resource_group_names = # (Optional) The string consisted of name of (Azure) VNet and name Resource-Group. Valid Value(s): Refer to Aviatrix controller GUI. (Required if cloud_type is "8")
  vpc_reg = "${var.aws_region}"
  vpc_size = "${var.aws_instance}"
  subnet = "${var.aws_vpc_public_cidr}"

  ha_subnet = "${var.aviatrix_ha_subnet}" # (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
  ha_gw_size = "${var.aviatrix_ha_gw_size}" # (optional) HA gw size. Mandatory if HA is enabled (ex. "t2.micro")
  enable_nat = "${var.aviatrix_enable_nat}" # Specify whether enabling NAT feature on the gateway or not. (Please disable AWS NAT instance before enabling this feature)
  # dns_server = # (optional) specify DNS IP, only required while using a custom private DNS for the VPC
  transit_gw = "${var.aviatrix_transit_gw}" # optional; comment out if want to test Update from no transitGW attachment to yes
  tag_list = "${var.tag_list}" # optional
}
