# Enter your controller's IP, username and password to login
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
       username = "${var.controller_username}"
       password = "${var.controller_password}"
}

# Create encrypteed peering between two aviatrix gateway
resource "aviatrix_aws_peer" "AWS_PEERING"{
           vpc_id1 = "${var.vpc_id1}"
           vpc_reg1 = "${var.vpc_reg1}"
           account_name1 = "${var.account_name1}"
           vpc_id2 = "${var.vpc_id2}"
           vpc_reg2 = "${var.vpc_reg2}"
           account_name2 = "${var.account_name2}"
}
