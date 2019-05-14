## Test case 0. Change otp mode and/or change enable_ldap
## Please see Mantis id = 8142

##############################################

                       aws_region = "us-east-1"
                       aws_vpc_id = "vpc-abc123"
                     aws_instance = "t2.micro"
              aws_vpc_public_cidr = "10.0.0.0/24"

     aviatrix_cloud_account_name  = "PrimaryAccessAccount"
           aviatrix_gateway_name  = "myAviatrix-gateway-VPN-okta"
          aviatrix_cloud_type_aws = 1

              aviatrix_vpn_access = "yes"
                aviatrix_vpn_cidr = "192.168.230.0/24"
                 aviatrix_vpn_elb = "yes"
        aviatrix_vpn_split_tunnel = "yes"
##############################################
## OTP Mode edit here:
            aviatrix_vpn_otp_mode = "1" # random invalid input
            # aviatrix_vpn_otp_mode = "2" # Duo (which would make Okta parameters invalid and Duo parameters required)
##############################################
          aviatrix_vpn_okta_token = "OOOOOOOOoooooooTTTTTTTTTTTTTTTTTTTTTTTTken"
            aviatrix_vpn_okta_url = "https://api-1234.okta.com"
aviatrix_vpn_okta_username_suffix = "okta-suffiXXXXXXXXXXXXXXX"
