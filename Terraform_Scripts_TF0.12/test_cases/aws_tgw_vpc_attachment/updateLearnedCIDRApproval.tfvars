## Test case 5: disable learned_cidrs_approval

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.12.0.0/16"
disable_local_route_propagation = true

prefix = "10.13.0.0/24"
enable_learned_cidrs_approval = false
