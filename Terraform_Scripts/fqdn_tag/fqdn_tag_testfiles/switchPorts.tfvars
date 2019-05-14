# Test order 2. change ports

##############################################

   aviatrix_fqdn_mode   = "white"
 aviatrix_fqdn_status   = "enabled"
    aviatrix_fqdn_tag   = "user-fqdn-TAG"
aviatrix_gateway_list   = ["FQDN-GW", "FQDN-GW2"]

aviatrix_fqdn_source_ip_list  = ["172.31.0.0/16", "172.31.0.0/20"]
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "udp", "udp"]
aviatrix_fqdn_port            = ["444", "420", "4200", "43"]
