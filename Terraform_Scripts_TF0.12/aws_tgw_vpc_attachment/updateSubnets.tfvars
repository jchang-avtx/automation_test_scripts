## Test case 4: update custom subnets to attach to VPC. by default a subnet will be selected representing each AZ for the VPC attachment

## vpc-attachment-related
tgw_sec_domain            = "SDN2"

customized_routes = "10.10.0.0/16,10.12.0.0/16"
disable_local_route_propagation = true

adv_subnets = "subnet-0f45ddd6547d91dec"
adv_rtb     = "rtb-024a3b4ff2b9cf333"
adv_custom_route_advertisement = "10.60.0.0/24"
