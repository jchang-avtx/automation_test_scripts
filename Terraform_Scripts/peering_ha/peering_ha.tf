## Build encrypted peering between Aviatrix gateways in HA mode
## Creates 2 GWs and a peering tunnel

resource "aviatrix_gateway" "GW" {
            count = "${length(var.aws_vpc_id)}"
       cloud_type = "${var.aviatrix_cloud_type_aws}"
     account_name = "${var.aviatrix_cloud_account_name}"
          gw_name = "${element(var.gateway_names,count.index)}"
           vpc_id = "${element(var.aws_vpc_id,count.index)}"
          vpc_reg = "${var.aws_region}"
         vpc_size = "${var.aws_instance}"
          vpc_net = "${element(var.aws_vpc_public_cidr,count.index)}"
peering_ha_subnet = "${element(var.aws_vpc_public_cidr,count.index)}"
   peering_ha_eip = "${element(var.avx_peering_eip,count.index)}"
}

# Create encrypteed peering between two aviatrix gateway
resource "aviatrix_tunnel" "peeringTunnel"{
           vpc_name1 = "${var.gateway_names[0]}"
           vpc_name2 = "${var.gateway_names[1]}"
           enable_ha = "${var.enable_ha}" # (optional)
          depends_on = ["aviatrix_gateway.GW"]
          cluster = "${var.enable_cluster}" # (optional) whether to enable cluster peering
 # over_aws_peering = "no" # (deprecated) Use aws_peer resource instead
}
