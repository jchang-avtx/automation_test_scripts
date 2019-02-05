# Create Aviatrix gateway in AWS cloud provider

##############################################
## Case 1. Testing one or two gateways
## Be sure to comment out specific parts;
## ex. if you want to only test one gw, comment out "testGW2" below
## Case 1.5 Create gateway with "tags"
##############################################
resource "aviatrix_gateway" "testGW1" {
     cloud_type = "${var.aviatrix_cloud_type_aws}"
   account_name = "${var.aviatrix_cloud_account_name}"
        gw_name = "${var.aviatrix_gateway_name[0]}"
         vpc_id = "${var.aws_vpc_id[0]}"
        vpc_reg = "${var.aws_region[0]}"
       vpc_size = "${var.aws_instance[0]}"
        vpc_net = "${var.aws_vpc_public_cidr[0]}"
       tag_list = "${var.aws_gateway_tag_list}" # optional. can comment out if do not want
}

# resource "aviatrix_gateway" "testGW2" {
#      cloud_type = "${var.aviatrix_cloud_type_aws}"
#    account_name = "${var.aviatrix_cloud_account_name}"
#         gw_name = "${var.aviatrix_gateway_name[1]}"
#          vpc_id = "${var.aws_vpc_id[1]}"
#         vpc_reg = "${var.aws_region[1]}"
#        vpc_size = "${var.aws_instance[1]}"
#         vpc_net = "${var.aws_vpc_public_cidr[1]}"
#        tag_list = "${var.aws_gateway_tag_list}" # optional. can comment out if do not want
# }

##############################################
## Case 2. Testing a gateway with EIP turned off
## Be sure to comment out specific parts,if you want to test valid/invalid eip value;
## Otherwise, be sure to fill out the EIP field as one specified in your pool in AWS
##############################################
# resource "aviatrix_gateway" "testGW1" {
#      cloud_type = "${var.aviatrix_cloud_type_aws}"
#    account_name = "${var.aviatrix_cloud_account_name}"
#         gw_name = "${var.aviatrix_gateway_name[0]}"
#          vpc_id = "${var.aws_vpc_id[0]}"
#         vpc_reg = "${var.aws_region[0]}"
#        vpc_size = "${var.aws_instance[0]}"
#         vpc_net = "${var.aws_vpc_public_cidr[0]}"
#         allocate_new_eip = "on"
#         # eip = "1.23.456.789" # input correct EIP here
#         # eip = "54" # invalid IP format
#         # eip = "" # empty value
# }
