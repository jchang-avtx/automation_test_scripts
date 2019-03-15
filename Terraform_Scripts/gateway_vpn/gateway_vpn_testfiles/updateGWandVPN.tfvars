## Test case: update GW name and VPN access option;; run this after initial creation
## Should fail

## Additional test cases to consider:
## - When users set "enable_elb" = "yes", but "vpn_access" = "no"
## - Setting empty "elb_name" with "split_tunnel" enabled
## - Updating gw_name and vpn_access should be blocked <<--- we are testing this one with this .tfvars

## These credentials must be filled to test
aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################

                  aws_region = "us-east-1"
                  aws_vpc_id = "vpc-abc123"
                aws_instance = "t2.micro"
         aws_vpc_public_cidr = "10.0.0.0/24"

aviatrix_cloud_account_name  = "PrimaryAccessAccount"
      # aviatrix_gateway_name  = "testGW-VPN" # comment out to test Additional#3
     aviatrix_cloud_type_aws = 1

##############################################
## VALID INPUT
##############################################
       aviatrix_gateway_name = "updatedGWName" # uncomment to test Additional#3

## VPN gateway parameters (sample#1 Split_Tunnel enabled)
         aviatrix_vpn_access = "no" # turn off vpn access to check other vpn features are still working (they shouldnt)
           aviatrix_vpn_saml = "yes"
           aviatrix_vpn_cidr = "192.168.43.0/24"
            aviatrix_vpn_elb = "yes"
   aviatrix_vpn_split_tunnel = "yes"
