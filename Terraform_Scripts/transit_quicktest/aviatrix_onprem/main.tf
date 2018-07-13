## Create Aviatrix OnPrem gateway
## -----------------------------------
## if doing peering HA do enable public_subnet
##       public_subnet = "${var.subnet}"
##
resource "aviatrix_gateway" "OnPrem-GW" {
    cloud_type = 1
    account_name = "${var.account_name}"
    gw_name = "${var.onprem_gw_name}"
    vpc_id = "${var.vpc_id}"
    vpc_reg = "${var.region}"
    vpc_size = "${var.onprem_gw_size}"
    vpc_net = "${var.subnet}"
    zone = "no"
}
## END -------------------------------

## Create AWS customer gateway & VGW towards aviatrix OnPrem Gateway
## -----------------------------------------------------------------
resource "aws_customer_gateway" "customer_gateway" {
    bgp_asn    = 6592
    ip_address = "${aviatrix_gateway.OnPrem-GW.public_ip}"
    type       = "ipsec.1"
    tags {
       Name = "onprem-gateway"
    }
}
resource "aws_vpn_connection" "onprem" {
    vpn_gateway_id      = "${var.vgw_id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
    type                = "ipsec.1"
    static_routes_only  = true
    tags {
       Name = "s2c-to-vgw"
    }
    depends_on = ["aviatrix_gateway.OnPrem-GW"]
}
    #vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
# original onprem CIDR block
resource "aws_vpn_connection_route" "onprem1" {
    destination_cidr_block = "172.16.0.0/16"
    vpn_connection_id = "${aws_vpn_connection.onprem.id}"
}
# 2nd static route from onprem
resource "aws_vpn_connection_route" "onprem2" {
    destination_cidr_block = "100.100.100.0/24"
    vpn_connection_id = "${aws_vpn_connection.onprem.id}"
}
## END -------------------------------

# Aviatrix site2cloud connection facing AWS VGW
## END -------------------------------
resource "aviatrix_site2cloud" "onprem-vgw" {
    vpc_id = "${var.vpc_id}"
    connection_name = "s2c_to_vgw"
    connection_type = "unmapped"
    tunnel_type = "udp"
    remote_gateway_type = "aws"
    remote_subnet_cidr = "${var.remote_subnet}"
    primary_cloud_gateway_name = "${aviatrix_gateway.OnPrem-GW.gw_name}"
    remote_gateway_ip = "${aws_vpn_connection.onprem.tunnel1_address}"
    pre_shared_key = "${aws_vpn_connection.onprem.tunnel1_preshared_key}"
    depends_on = ["aviatrix_gateway.OnPrem-GW"]
}

## HA
#resource "aviatrix_site2cloud" "onprem-vgw" {
#    vpc_id = "${var.vpc_id}"
#    connection_name = "s2c_to_vgw"
#    connection_type = "unmapped"
#    tunnel_type = "udp"
#    remote_gateway_type = "aws"
#    remote_subnet_cidr = "${var.remote_subnet}"
#    primary_cloud_gateway_name = "${aviatrix_gateway.OnPrem-GW.gw_name}"
#    backup_gateway_name = "${aviatrix_gateway.OnPrem-GW.gw_name}-hagw"
#    remote_gateway_ip = "${aws_vpn_connection.onprem.tunnel1_address}"
#    backup_remote_gateway_ip = "${aws_vpn_connection.onprem.tunnel2_address}"
#    pre_shared_key = "${aws_vpn_connection.onprem.tunnel1_preshared_key}"
#    backup_pre_shared_key = "${aws_vpn_connection.onprem.tunnel2_preshared_key}"
#    ha_enabled = "yes"
#    depends_on = ["aviatrix_gateway.OnPrem-GW"]
#}

## HA
## END -------------------------------

