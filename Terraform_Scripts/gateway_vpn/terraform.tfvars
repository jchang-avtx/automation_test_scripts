                  aws_region = "us-east-1"
                  aws_vpc_id = "vpc-07eb417901c6b8382"
                aws_instance = "t2.micro"
         aws_vpc_public_cidr = "10.10.0.0/24"

aviatrix_cloud_account_name  = "Temp-AWS-CloudAccount"
      aviatrix_gateway_name  = "tr-gateway-vpn"
     aviatrix_cloud_type_aws = 1

# VPN gateway parameters (sample#1 Split_Tunnel enabled)
         aviatrix_vpn_access = "yes"
           aviatrix_vpn_cidr = "192.168.43.0/24"
            aviatrix_vpn_elb = "yes"
   aviatrix_vpn_split_tunnel = "yes"



