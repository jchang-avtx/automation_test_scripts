## initial creation

aviatrix_fqdn_mode   = "white"
aviatrix_fqdn_status   = true
aviatrix_fqdn_tag   = "test-fqdn-TAG"
aviatrix_fqdn_gateway   = "FQDN-GW"

aviatrix_fqdn_source_ip_list  = ["10.10.2.0/24"]
aviatrix_fqdn_domain          = ["*.facebook.com", "*.google.com", "www.aviatrix.com", "www.apple.com"]
aviatrix_fqdn_protocol        = ["tcp", "tcp", "https", "icmp"]
aviatrix_fqdn_port            = ["443", "80", "443", "ping"]
