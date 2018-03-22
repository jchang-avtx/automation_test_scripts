# Create Aviatrix gateway in AWS public cloud 

resource "aviatrix_gateway" "aws_gateway" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name}"
         vpc_id = "${var.aws_vpc_id}"
        vpc_reg = "${var.aws_region}"
       vpc_size = "${var.aws_instance}"
        vpc_net = "${var.aws_vpc_public_cidr}"
}

# if need to enable NAT, add this line to resource  
# and include variable "aviatrix_enable_nat" to vars.tf file
#
#     enable_nat = "${var.aviatrix_enable_nat}"


