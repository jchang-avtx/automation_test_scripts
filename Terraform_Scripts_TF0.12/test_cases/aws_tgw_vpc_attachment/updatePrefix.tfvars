## Test case 4: (case 1 for TGW DxC) update allowed_prefix

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.12.0.0/16"
disable_local_route_propagation = true

## tgw-directconnect-related
prefix = "10.13.0.0/24"
