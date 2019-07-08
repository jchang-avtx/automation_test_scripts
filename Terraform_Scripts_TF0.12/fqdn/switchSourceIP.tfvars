# Test order 7. change source IPs

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = "disabled"
    aviatrix_fqdn_tag   = "anthony-fqdn-TAG"
aviatrix_fqdn_gateway   = "FQDN-GW2"

aviatrix_fqdn_source_ip_list  = ["173.31.0.0/16", "174.31.0.0/20"] ## updated source IP list
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["444", "420", "ping", "all"]
