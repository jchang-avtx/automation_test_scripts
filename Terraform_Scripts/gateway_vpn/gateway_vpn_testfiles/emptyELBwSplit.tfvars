## Test case: setting empty "elb_name" with "split_tunnel" enabled
## Run this in conjunction with emptyELBwSplit.tf

## Additional test cases to consider:
## - When users set "enable_elb" = "yes", but "vpn_access" = "no"
## - Setting empty "elb_name" with "split_tunnel" enabled <<----- we are testing this one with this .tfvars
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
         aviatrix_vpn_access = "yes"
           aviatrix_vpn_saml = "yes"
           aviatrix_vpn_cidr = "192.168.43.0/24"
            aviatrix_vpn_elb = "yes"
   aviatrix_vpn_split_tunnel = "yes"
