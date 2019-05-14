## Test case: enable elb in creation, but no vpn_access

## Additional test cases to consider:
## - When users set "enable_elb" = "yes", but "vpn_access" = "no" <<--- we are testing this one with this .tfvars
## - Setting empty "elb_name" with "split_tunnel" enabled
## - Updating gw_name and vpn_access should be blocked

##############################################

                  aws_region = "us-east-1"
                  aws_vpc_id = "vpc-abc123"
                aws_instance = "t2.micro"
         aws_vpc_public_cidr = "10.0.0.0/24"

aviatrix_cloud_account_name  = "PrimaryAccessAccount"
      aviatrix_gateway_name  = "testGW-VPN"
     aviatrix_cloud_type_aws = 1

##############################################
## VALID INPUT
##############################################

## VPN gateway parameters (sample#1 Split_Tunnel enabled)
         aviatrix_vpn_access = "no" # turn off vpn access to check other vpn features are still working (they shouldnt)
           aviatrix_vpn_saml = "yes"
           aviatrix_vpn_cidr = "192.168.43.0/24"
            aviatrix_vpn_elb = "yes"
   aviatrix_vpn_split_tunnel = "yes"
