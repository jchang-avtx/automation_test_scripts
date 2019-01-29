# empty creation

## Use variations of commenting out the top and bottom portion of this file to test individual/ combinations of empty/invalid + valid input
## Please see Mantis id =

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################
## Only modify the account-specific ones such as aws_region, vpc or aviatrix_account_name
                       aws_region = "us-east-1"
                       aws_vpc_id = "vpc-abc123"
                     aws_instance = "t2.micro"
              aws_vpc_public_cidr = "10.0.0.0/24"

     aviatrix_cloud_account_name  = "Temp-AWS-AccessAccount"
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

#             aviatrix_vpn_otp_mode = "2"
#  aviatrix_vpn_duo_integration_key = "DDDDDDDDDDDDDDDDDDY6"
#       aviatrix_vpn_duo_secret_key = "QqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqXN2zwQ"
#     aviatrix_vpn_duo_api_hostname = "api-11111111.duosecurity.com"
#        aviatrix_vpn_duo_push_mode = "auto"
#
#          aviatrix_vpn_ldap_enable = "yes"
#          aviatrix_vpn_ldap_server = "1.2.3.4:389"
#         aviatrix_vpn_ldap_bind_dn = "TTTTTTTTTEST\\Administrator"
#        aviatrix_vpn_ldap_password = "myLDAPpassword123"
#         aviatrix_vpn_ldap_base_dn = "DC=aviatrixtest, DC=com"
# aviatrix_vpn_ldap_username_attribute = "auto"

##############################################
## INVALID/ EMPTY INPUT
##############################################

aviatrix_vpn_otp_mode = ""
aviatrix_vpn_duo_integration_key = ""
aviatrix_vpn_duo_secret_key = ""
aviatrix_vpn_duo_api_hostname = ""
aviatrix_vpn_duo_push_mode = ""

aviatrix_vpn_ldap_enable = ""
aviatrix_vpn_ldap_server = ""
aviatrix_vpn_ldap_bind_dn = ""
aviatrix_vpn_ldap_password = ""
aviatrix_vpn_ldap_base_dn = ","
aviatrix_vpn_ldap_username_attribute = ""
