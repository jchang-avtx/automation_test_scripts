## Test case 1. Changes Duo-related parameter values
## Please see Mantis id =

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"
##############################################

                       aws_region = "us-east-1"
                       aws_vpc_id = "vpc-abc123"
                     aws_instance = "t2.micro"
              aws_vpc_public_cidr = "10.0.0.0/24"

     aviatrix_cloud_account_name  = "Temp-AWS-AccessAccount"
           aviatrix_gateway_name  = "myAviatrix-gateway-VPN-ldap-duo"
          aviatrix_cloud_type_aws = 1

              aviatrix_vpn_access = "yes"
                aviatrix_vpn_cidr = "192.168.230.0/24"
                 aviatrix_vpn_elb = "yes"
        aviatrix_vpn_split_tunnel = "yes"
            aviatrix_vpn_otp_mode = "2"
##############################################
## This is the section you're concerned with
 aviatrix_vpn_duo_integration_key = "UPDATED_DUO_INTEGRATION_KEY"
      aviatrix_vpn_duo_secret_key = "UPDATED_DUO_SECRET_KEY"
    aviatrix_vpn_duo_api_hostname = "api-22222222.duosecurity.com"
       aviatrix_vpn_duo_push_mode = "selective"
       # aviatrix_vpn_duo_push_mode = "token" #If you are interested in testing another push_mode config
##############################################

         aviatrix_vpn_ldap_enable = "yes"
         aviatrix_vpn_ldap_server = "1.2.3.4:389"
        aviatrix_vpn_ldap_bind_dn = "TTTTTTTTTEST\\Administrator"
       aviatrix_vpn_ldap_password = "myLDAPpassword123"
        aviatrix_vpn_ldap_base_dn = "DC=aviatrixtest, DC=com"
aviatrix_vpn_ldap_username_attribute = "auto"
