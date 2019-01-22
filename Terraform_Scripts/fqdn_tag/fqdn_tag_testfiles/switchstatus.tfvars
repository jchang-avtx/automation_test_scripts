# Test order 5. change status
# icmp type/code is expected as 0-39/0-19 or None or "ping" in the port field

aviatrix_controller_ip  = "1.2.3.4"
aviatrix_account_username  = "admin"
aviatrix_account_password  = "password"

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = "disabled"
    aviatrix_fqdn_tag   = "user-fqdn-TAG3.4"
aviatrix_gateway_list   = ["FQDN-GW"]

aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["444", "420", "", "43"]

# Note that terraform will detect in controller port "" as "ping", and whatever port for protocol "all" as "all"
# Nothing will actually change in behavior
