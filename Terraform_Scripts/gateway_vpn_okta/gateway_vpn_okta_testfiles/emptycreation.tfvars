# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis id = 8142

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################
## Only modify the account-specific ones such as aws_region, vpc or aviatrix_account_name
                       aws_region = "us-east-1"
                       aws_vpc_id = "vpc-abc123"
                     aws_instance = "t2.micro"
              aws_vpc_public_cidr = "10.0.0.0/24"

     aviatrix_cloud_account_name  = "PrimaryAccessAccount"
           aviatrix_gateway_name  = "myAviatrix-gateway-VPN-ldap-duo"
          ## DO NOT MODIFY VALUES BELOW THIS COMMENT
          aviatrix_cloud_type_aws = 1

              aviatrix_vpn_access = "yes"
                aviatrix_vpn_cidr = "192.168.230.0/24"
                 aviatrix_vpn_elb = "yes"
        aviatrix_vpn_split_tunnel = "yes"
##############################################
## VALID INPUT
##############################################

            aviatrix_vpn_otp_mode = "3"
          # aviatrix_vpn_okta_token = "OOOOOOOOoooooooTTTTTTTTTTTTTTTTTTTTTTTTken"
            # aviatrix_vpn_okta_url = "https://api-1234.okta.com"
# aviatrix_vpn_okta_username_suffix = "okta-suffiXXXXXXXXXXXXXXX"

##############################################
## INVALID/ EMPTY INPUT
##############################################

# aviatrix_vpn_otp_mode = "4" # invalid. 2 for DUO, 3 for OKTA (ERROR)
aviatrix_vpn_okta_token = ""
aviatrix_vpn_okta_url = ""
aviatrix_vpn_okta_username_suffix = "" # optional
