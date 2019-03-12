## Test case: Update Source and NextHop gw

## Expectation: fail (not allow update), and ask to delete and create new
## Reality: correct

aviatrix_controller_ip = "1.2.3.4"
aviatrix_controller_username = "admin"
aviatrix_controller_password = "password"
##############################################

avx_tunnel_vpc1 = "NAT-gw1"
avx_tunnel_vpc2 = "NAT-gw2"

transpeer_source = "NAT-gw1"
transpeer_nexthop = "NAT-gw2"
transpeer_reachable_cidr = "55.55.55.0/24" # new CIDR
