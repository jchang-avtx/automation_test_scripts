# Test order 6. change gw; you can also try to add more than one

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = false
    aviatrix_fqdn_tag   = "anthony-fqdn-TAG"
aviatrix_fqdn_gateway   = "FQDN-GW2"

aviatrix_fqdn_source_ip_list  = ["172.31.0.0/16", "172.31.0.0/20"]
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["444", "420", "ping", "all"]
