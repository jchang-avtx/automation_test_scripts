# Test order 2. change ports

   aviatrix_fqdn_mode   = "white"
 aviatrix_fqdn_status   = true
    aviatrix_fqdn_tag   = "fqdn-tag-1"
aviatrix_fqdn_gateway   = "fqdn-gw-1"

aviatrix_fqdn_source_ip_list  = ["172.31.0.0/16", "172.31.0.0/20"]
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "udp", "udp"]
aviatrix_fqdn_port            = ["444", "420", "4200", "43"]
aviatrix_fqdn_action          = ["Base Policy", "Base Policy", "Base Policy", "Base Policy"]
