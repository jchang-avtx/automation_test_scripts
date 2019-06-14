## Manages the vpn_connection of the Aviatrix TGW resource
## dependent on aws_tgw_testing case

## Dynamic connection
resource "aviatrix_aws_tgw_vpn_conn" "test_aws_tgw_vpn_conn1" {
  tgw_name = "testAWSTGW"
  route_domain_name = "Default_Domain"
  connection_name = "tgw_vpn_conn1"
  public_ip = "69.0.0.0"
  remote_as_number = "1234"
}

## Static connection
# resource "aviatrix_aws_tgw_vpn_conn" "test_aws_tgw_vpn_conn2" {
#   tgw_name = "testAWSTGW"
#   route_domain_name = "Default_Domain"
#   connection_name = "tgw_vpn_conn2"
#   public_ip = "70.0.0.0"
#   remote_cidr = "10.0.0.0/16,10.1.0.0/16"
# }
