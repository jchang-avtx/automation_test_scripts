# Test order 7. change tag name
# icmp type/code is expected as 0-39/0-19 or None or "ping" in the port field

## Cannot update tag name? Is it bug or intended behavior. Detects as an update-in-place but when apply,
## ends up being "newname does not exist" as if it wants to target changes to the new name instead?

aviatrix_controller_ip  = "1.2.3.4"
aviatrix_account_username  = "admin"
aviatrix_account_password  = "password"
##############################################

   aviatrix_fqdn_mode   = "black"
 aviatrix_fqdn_status   = "disabled"
    aviatrix_fqdn_tag   = "changedName-fqdn-TAG3.4"
aviatrix_gateway_list   = ["FQDN-GW", "FirewallGW"]

aviatrix_fqdn_domain          = ["reddit.com", "amazon.com", "instagram.com", "nytimes.com"]
aviatrix_fqdn_protocol        = ["tcp", "udp", "icmp", "all"]
aviatrix_fqdn_port            = ["444", "420", "", "43"]

# Note that terraform will detect in controller port "" as "ping", and whatever port for protocol "all" as "all"
# Nothing will actually change in behavior
