## Test case 2: Add custom routes to vpc attachment

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.12.0.0/16"
disable_local_route_propagation = false

adv_subnets = "subnet-05827995c52de2d76"
adv_rtb     = "rtb-024a3b4ff2b9cf333"
adv_custom_route_advertisement = "10.60.0.0/24"
