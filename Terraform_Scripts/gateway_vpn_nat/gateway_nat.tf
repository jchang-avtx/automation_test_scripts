# Create Aviatrix gateway in AWS public cloud

resource "aviatrix_gateway" "aws_gateway" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name}"
     enable_nat = "${var.aviatrix_enable_nat}"
         vpc_id = "${var.aws_vpc_id}"
        vpc_reg = "${var.aws_region}"
       vpc_size = "${var.aws_instance}"
        vpc_net = "${var.aws_vpc_public_cidr}"
     vpn_access = "${var.aviatrix_vpn_access}"
       vpn_cidr = "${var.aviatrix_vpn_cidr}"
   split_tunnel = "${var.aviatrix_vpn_split_tunnel}"
     enable_elb = "${var.aviatrix_vpn_elb}"
}

## ONLY enable ELB if split_tunnel is NOT configured
##     enable_elb = "${var.aviatrix_vpn_elb}"

## enable both if split_tunnel is configured
##   split_tunnel = "${var.aviatrix_vpn_split_tunnel}"
##     enable_elb = "${var.aviatrix_vpn_elb}"
