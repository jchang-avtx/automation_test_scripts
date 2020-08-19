# Test order 6. change status

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = false

aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = [443, 420, "ping", "all"]
aviatrix_fqdn_action          = ["Allow", "Base Policy", "Base Policy", "Base Policy"]
