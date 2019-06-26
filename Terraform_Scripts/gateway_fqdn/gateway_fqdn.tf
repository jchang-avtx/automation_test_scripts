resource "aviatrix_vpc" "fqdn-vpc" {
  cloud_type       = 1
  account_name     = "EdselAWS"
  region           = "us-east-2"
  name             = "fqdn-vpc1"
  cidr             = "10.1.0.0/24"
}

resource "aviatrix_gateway" "gateway1" {
     cloud_type = 1
   account_name = "EdselAWS"
        gw_name = "gateway1"
         vpc_id = "${aviatrix_vpc.fqdn-vpc.vpc_id}"
        vpc_reg = "us-east-2"
       vpc_size = "t2.micro"
        vpc_net = "${aviatrix_vpc.fqdn-vpc.subnets.3.cidr}"
     vpn_access = "yes"
       vpn_cidr = "192.168.101.0/24"
     enable_elb = "yes"
     enable_nat = "yes"
   split_tunnel = "yes"
     depends_on = ["aviatrix_vpc.fqdn-vpc"]
}

resource "aviatrix_gateway" "gateway2" {
     cloud_type = 1
   account_name = "EdselAWS"
        gw_name = "gateway2"
         vpc_id = "${aviatrix_vpc.fqdn-vpc.vpc_id}"
        vpc_reg = "us-east-2"
       vpc_size = "t2.micro"
        vpc_net = "${aviatrix_vpc.fqdn-vpc.subnets.4.cidr}"
     vpn_access = "yes"
       vpn_cidr = "192.168.200.0/24"
     enable_elb = "yes"
     enable_nat = "yes"
   split_tunnel = "yes"
     depends_on = ["aviatrix_vpc.fqdn-vpc"]
}


resource "aviatrix_fqdn" "TAG1" {
       fqdn_tag = "social-media"
    fqdn_status = "enabled"
      fqdn_mode = "white"
   gw_filter_tag_list = [{
                           gw_name = "${aviatrix_gateway.gateway1.gw_name}"
                           source_ip_list = ["${aviatrix_vpc.fqdn-vpc.subnets.3.cidr}"]
                        }]
         domain_names = [{
                           fqdn  = "facebook.com"
                           proto = "tcp"
                           port  = "443"
                         },
                         {
                           fqdn  = "*.google.com"
                           proto = "tcp"
                           port  = "80"
                         }]
     depends_on = ["aviatrix_vpc.fqdn-vpc","aviatrix_gateway.gateway1"]
}
resource "aviatrix_fqdn" "TAG2" {
       fqdn_tag = "news-sports"
    fqdn_status = "enabled"
      fqdn_mode = "white"
   gw_filter_tag_list = [{
                           gw_name = "${aviatrix_gateway.gateway1.gw_name}"
                           source_ip_list = ["${aviatrix_vpc.fqdn-vpc.subnets.3.cidr}"]
                        }]
         domain_names = [{
                           fqdn  = "*.reddit.com"
                           proto = "tcp"
                           port  = "443"
                         },
                         {
                           fqdn  = "*.nba.com"
                           proto = "tcp"
                           port  = "80"
                         },
                         {
                           fqdn  = "*.foxnews.com"
                           proto = "tcp"
                           port  = "80"
                         }]
     depends_on = ["aviatrix_vpc.fqdn-vpc","aviatrix_gateway.aws_gateway"]
}

resource "aviatrix_fqdn" "TAG3" {
       fqdn_tag = "restrict"
    fqdn_status = "enabled"
      fqdn_mode = "black"
   gw_filter_tag_list = [{
                           gw_name = "${aviatrix_gateway.gateway2.gw_name}"
                           source_ip_list = ["${aviatrix_vpc.fqdn-vpc.subnets.4.cidr}"]
                        }]
         domain_names = [{
                           fqdn  = "*.meetup.com"
                           proto = "tcp"
                           port  = "443"
                         },
                         {
                           fqdn  = "*.myspace.com"
                           proto = "tcp"
                           port  = "80"
                         }]
     depends_on = ["aviatrix_vpc.fqdn-vpc","aviatrix_gateway.aws_gateway"]
}
