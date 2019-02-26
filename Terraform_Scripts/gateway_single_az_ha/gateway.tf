# Create Aviatrix gateway in AWS cloud provider (with single_az_enabled)

resource "aviatrix_gateway" "aws_gateway" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name}"

         vpc_id = "${var.aws_vpc_id}"
        vpc_reg = "${var.aws_region}"
       vpc_size = "${var.aws_instance}"
        vpc_net = "${var.aws_vpc_public_cidr}"

   single_az_ha = "${var.aviatrix_single_az_ha}" # comment out if testing Additional#1
       tag_list = "${var.aws_gateway_tag_list}"
}
