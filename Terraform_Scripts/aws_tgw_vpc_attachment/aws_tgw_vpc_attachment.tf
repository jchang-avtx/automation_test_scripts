## initial creation

# Manage attaching or detaching VPCs to aws tgw
resource "aviatrix_aws_tgw_vpc_attachment" "tgw_vpc_attach_test" {
  tgw_name = "testAWSTGW"
  # tgw_account_name = "devops" # removed
  region = "eu-central-1"
  security_domain_name = "${var.tgw_sec_domain}"
  vpc_account_name = "devops"
  vpc_id = "vpc-abc123" # TGWVPC1

}
