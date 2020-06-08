# Test order 8. change source IPs

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = false
    aviatrix_fqdn_tag   = "fqdn-tag-1"
aviatrix_fqdn_gateway   = "fqdn-gw-2"

aviatrix_fqdn_source_ip_list  = ["173.31.0.0/16", "174.31.0.0/20"] ## updated source IP list
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["https", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["443", "420", "ping", "all"]
aviatrix_fqdn_action          = ["Allow", "Base Policy", "Base Policy", "Base Policy"]
