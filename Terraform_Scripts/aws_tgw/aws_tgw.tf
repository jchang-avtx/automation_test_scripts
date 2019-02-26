## Manages the AWS TGW (Orchestrator)

resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name = "${var.aviatrix_tgw_name}"
  account_name = "${var.aviatrix_cloud_account_name}"
  region = "${var.aviatrix_tgw_region}"
  aws_side_as_number = "${var.aws_bgp_asn}"
  # attached_aviatrix_transit_gateway = ["avxtransitgw", "avxtransitgw2"]

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
                    {
                      vpc_region = "${var.aws_region[2]}"
                      vpc_account_name = "${var.aviatrix_cloud_account_name_list[2]}"
                      vpc_id = "${var.aws_vpc_id[2]}"
                    },
                    ]
  },
  {
    security_domain_name = "${var.security_domain_name_list[1]}"
    connected_domains = []
    attached_vpc = [
                    {
                      vpc_region = "${var.aws_region[3]}"
                      vpc_account_name = "${var.aviatrix_cloud_account_name_list[3]}"
                      vpc_id = "${var.aws_vpc_id[3]}"
                    },
                    ]
  },
  ]
}
