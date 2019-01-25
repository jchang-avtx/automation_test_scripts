# Create Aviatrix gateway in AWS cloud provider

##############################################
## Case 1. Testing one or two gateways
## Be sure to comment out specific parts;
## ex. if you want to only test one gw, comment out "testGW2" below
##############################################
resource "aviatrix_gateway" "testGW1" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name[0]}"
         vpc_id = "${var.aws_vpc_id[0]}"
        vpc_reg = "${var.aws_region[0]}"
       vpc_size = "${var.aws_instance[0]}"
        vpc_net = "${var.aws_vpc_public_cidr[0]}"
}

# resource "aviatrix_gateway" "testGW2" {
#      cloud_type = "${var.aviatrix_cloud_type_aws}"
#    account_name = "${var.aviatrix_cloud_account_name}"
#         gw_name = "${var.aviatrix_gateway_name[1]}"
#          vpc_id = "${var.aws_vpc_id[1]}"
#         vpc_reg = "${var.aws_region[1]}"
#        vpc_size = "${var.aws_instance[1]}"
#         vpc_net = "${var.aws_vpc_public_cidr[1]}"
# }
