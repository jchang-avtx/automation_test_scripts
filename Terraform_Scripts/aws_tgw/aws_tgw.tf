## Manages the AWS TGW (Orchestrator)
# must first create an Aviatrix transitGW before attaching

## Test case: Updating from provider version without "manage_vpc_attachment", and hitting apply should not detect diff

# Manage Aviatrix Transit Network Gateways
resource "aviatrix_transit_vpc" "test_transit_gw" {
  cloud_type = 1
  account_name = "devops"
  gw_name = "avxtransitgw"
  vpc_id = "vpc-abcd1234" # ensure in different VPC than aws_tgw, or any other VPCs that will be connected to security domains
  vpc_reg = "us-east-1" # ensure same region as aws_tgw
  vpc_size = "t2.micro"
  subnet = "10.1.0.0/24"
  ha_subnet = "10.1.0.0/24"
  ha_gw_size = "t2.micro"
  tag_list = ["name:value", "name1:value1", "name2:value2"]
  enable_hybrid_connection = true # ensure this is true, otherwise cannot attach to aws_tgw
  connected_transit = "yes"
}

resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name = "${var.aviatrix_tgw_name}"
  account_name = "${var.aviatrix_cloud_account_name}"
  region = "${var.aviatrix_tgw_region}"
  aws_side_as_number = "${var.aws_bgp_asn}"
  attached_aviatrix_transit_gateway = ["avxtransitgw"] # be sure to have the transitGWs have "enable_hybrid_connection" set to true; otherwise must do Step5 in TGW GUI

  ## By default, there will be 3 domains ("Aviatrix_Edge_Domain", "Default_Domain", and "Shared_Service_Domain")
  security_domains = [
  {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains = "${var.connected_domains_list1}"
  },
  {
    security_domain_name = "Default_Domain"
    connected_domains = "${var.connected_domains_list2}"
    attached_vpc = []
  },
  {
    security_domain_name = "Shared_Service_Domain"
    connected_domains = "${var.connected_domains_list3}"
    attached_vpc = []
  },
  {
    security_domain_name = "${var.security_domain_name_list[0]}"
    connected_domains = "${var.connected_domains_list4}"
    attached_vpc = [
                    {
                      vpc_region = "${var.aws_region[0]}"
                      vpc_account_name = "${var.aviatrix_cloud_account_name_list[0]}"
                      vpc_id = "${var.aws_vpc_id[0]}"
                    },
                    {
                      vpc_region = "${var.aws_region[1]}"
                      vpc_account_name = "${var.aviatrix_cloud_account_name_list[1]}"
                      vpc_id = "${var.aws_vpc_id[1]}"
                    },
                    ]
  },
  {
    security_domain_name = "${var.security_domain_name_list[1]}"
    connected_domains = []
    # attached_vpc = [
    #                 {
    #                   vpc_region = "${var.aws_region[3]}"
    #                   vpc_account_name = "${var.aviatrix_cloud_account_name_list[3]}"
    #                   vpc_id = "${var.aws_vpc_id[3]}"
    #                 },
    #                 ]
  },
  ]
  manage_vpc_attachment = true # default is true; if set to false, must use aws_tgw_vpc_attachment resource, and must comment out 'attached_vpc' sections
  depends_on = ["aviatrix_transit_vpc.test_transit_gw"]
}
