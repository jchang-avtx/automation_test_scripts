# Create Aviatrix gateway in AWS public cloud

resource "aviatrix_gateway" "aws_gateway" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name}"

         vpc_id = "${var.aws_vpc_id}"
        vpc_reg = "${var.aws_region}"
       vpc_size = "${var.aws_instance}"
        vpc_net = "${var.aws_vpc_public_cidr}"

     vpn_access = "${var.aviatrix_vpn_access}"
   saml_enabled = "${var.aviatrix_vpn_saml}"
       vpn_cidr = "${var.aviatrix_vpn_cidr}"
   split_tunnel = "${var.aviatrix_vpn_split_tunnel}"
     enable_elb = "${var.aviatrix_vpn_elb}"
       elb_name = "test-elb-name"
}

## enable both if split_tunnel is configured
##   split_tunnel = "${var.aviatrix_vpn_split_tunnel}"
##     enable_elb = "${var.aviatrix_vpn_elb}"

## if split_tunnel is NOT configured, ONLY enable ELB
##     enable_elb = "${var.aviatrix_vpn_elb}"

## Note that ELB Name is optional; but you have the option to name the ELB
