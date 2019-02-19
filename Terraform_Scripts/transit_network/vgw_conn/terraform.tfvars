# intial creation of the Aviatrix TGW to VGW Connection

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

tgw_vgw_conn_name         = "test_connection_tgw_vgw" # Connection name
aviatrix_gateway_name     = "testtransitGW1" # existing transitGW name
aws_vpc_id                = "vpc-abc123" # VPC ID fo the transitGW (transitVPC resource)
aws_vgw_id                = "vgw-123456" # VGW ID
bgp_local_as              = 100
