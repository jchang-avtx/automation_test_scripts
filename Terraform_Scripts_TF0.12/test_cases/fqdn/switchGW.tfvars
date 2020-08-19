# Test order 7. change gw; you can also try to add more than one

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = false
aviatrix_fqdn_gateway   = "fqdn-gw-2"

aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = [443, 420, "ping", "all"]
aviatrix_fqdn_action          = ["Allow", "Base Policy", "Base Policy", "Base Policy"]
