# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## There will be bugs with corrupt Terraform state;
## Note: Can also just use this file and make minor edits to test any combination of changes that involve:
## 1. vpn_access
## 2. elb_enable (elb_name can be found on the main gateway_vpn.tf)
## 3. split_tunnel

## Additional test cases to consider:
## - When users set "enable_elb" = "yes", but "vpn_access" = "no"
## - Setting empty "elb_name" with "split_tunnel" enabled

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
      aviatrix_gateway_name  = "testGW-VPN"
     aviatrix_cloud_type_aws = 1

##############################################
## VALID INPUT
##############################################
# VPN gateway parameters (sample#1 Split_Tunnel enabled)
         aviatrix_vpn_access = "yes"
   #       # aviatrix_vpn_access = "no" # turn off vpn access to check other vpn features are still working (they shouldnt)
   #         aviatrix_vpn_saml = "yes"
           aviatrix_vpn_cidr = "192.168.43.0/24"
            aviatrix_vpn_elb = "yes"
   # aviatrix_vpn_split_tunnel = "yes"

##############################################
## INVALID INPUT
##############################################
        # aviatrix_vpn_access = "" # for empty input
        # aviatrix_vpn_access = "invalid input" # invalid
          aviatrix_vpn_saml = "invalid input" # invalid
          # aviatrix_vpn_cidr = "" # empty/ invalid
           # aviatrix_vpn_elb = ""
           # aviatrix_vpn_elb = "no"
  aviatrix_vpn_split_tunnel = "no"
