## Update LDAP-related parameters for Update test

##############################################
## DO NOT MODIFY THESE
##############################################

aws_region = "us-east-1"
aws_vpc_id = "vpc-07eb417901c6b8382"
aws_instance = "t2.micro"
aws_vpc_public_cidr = "10.10.0.0/24"

aviatrix_cloud_account_name  = "Temp-AWS-AccessAccount"
aviatrix_gateway_name  = "VPN-ldap-duo-nat-GW"
aviatrix_cloud_type_aws = 1
aviatrix_enable_nat = "yes"

aviatrix_vpn_access = "yes"
aviatrix_vpn_cidr = "192.168.230.0/24"
aviatrix_vpn_elb = "yes"
aviatrix_vpn_split_tunnel = "yes"
aviatrix_vpn_otp_mode = "2"
aviatrix_vpn_duo_integration_key = "DDDDDDDDDDDDDDDDDDY6"
aviatrix_vpn_duo_secret_key = "QqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqXN2zwQ"
aviatrix_vpn_duo_api_hostname = "api-11111111.duosecurity.com"
aviatrix_vpn_duo_push_mode = "auto"

##############################################
## This is the section you are concerned about
##############################################
         aviatrix_vpn_ldap_enable = "no"
         aviatrix_vpn_ldap_server = "1.2.3.4:420"
        aviatrix_vpn_ldap_bind_dn = "TEST\\Admin"
       aviatrix_vpn_ldap_password = "short"
        aviatrix_vpn_ldap_base_dn = "DC=aviatrixTEST, DC=net"
aviatrix_vpn_ldap_username_attribute = "automatic"
