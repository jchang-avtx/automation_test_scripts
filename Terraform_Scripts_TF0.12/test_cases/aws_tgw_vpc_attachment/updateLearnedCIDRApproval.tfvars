## Test case 3: disable learned_cidrs_approval

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.11.0.0/16"
disable_local_route_propagation = false

enable_learned_cidrs_approval = false
