# Test order 4. change mode
# icmp type/code is expected as 0-39/0-19 or None or "ping" in the port field

##############################################

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = "enabled"
    aviatrix_fqdn_tag   = "user-fqdn-TAG"
aviatrix_gateway_list   = ["FQDN-GW", "FQDN-GW2"]

aviatrix_fqdn_source_ip_list  = ["172.31.0.0/16", "172.31.0.0/20"]
aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["444", "420", "ping", "all"]

# Note that terraform will detect in controller port "" as "ping", and whatever port for protocol "all" as "all"
# Nothing will actually change in behavior
