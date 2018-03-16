# -Sample Aviatrix terraform configuration to create datacenter extention gateways
 
# Create account with IAM roles
resource "aviatrix_account" "temp_account" {
  account_name = "${var.account_name}"
  account_password = "${var.account_password}"
  account_email = "${var.account_email}"
  cloud_type = 1
  aws_account_number = "${var.aws_account_number}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
}

# Create Datacenter Extension Gateway
resource "aviatrix_dc_extn" "dcx_gateway1" {
  cloud_type = 1
  account_name = "${aviatrix_account.temp_account.account_name}"
  gw_name = "OnPrem-GW"
  vpc_reg = "${var.region1}"
  gw_size = "${var.t2instance}"
  subnet_cidr = "192.168.16.128/26"
  public_subnet = "true"
  tunnel_type = "udp"
}
resource "aviatrix_dc_extn" "dcx_gateway2" {
  cloud_type = 1
  account_name = "${aviatrix_account.temp_account.account_name}"
  gw_name = "datacenter-GW2"
  vpc_reg = "${var.region1}"
  gw_size = "${var.t2instance}"
  subnet_cidr = "192.168.16.192/26"
  public_subnet = "true"
  tunnel_type = "udp"
}


