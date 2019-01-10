variable "mod_tgw_per_region" { type="map" }

#locals {
#    name_prefix = "${var.name_prefix != "" ? "${var.name_prefix}-" : ""}"
#    regions = {
#        us-east-1 = "5"
#        us-east-2 = "5"
#        us-west-1 = "2"
#        us-west-2 = "1"
#        ca-central-1 = "0"
#        eu-central-1 = "0"
#        eu-west-1 = "0"
#        eu-west-2 = "0"
#        eu-west-3 = "0"
#        ap-southeast-1 = "0"
#        ap-southeast-2 = "0"
#        ap-northeast-1 = "0"
#        ap-northeast-2 = "0"
#        ap-south-1 = "0"
#        sa-east-1 = "0"
#    }
#    images_byol = {
#        us-east-1 = "ami-db9bb9a1"
#        us-east-2 = "ami-b40228d1"
#        us-west-1 = "ami-2a7e7c4a"
#        us-west-2 = "ami-fd48f885"
#        ca-central-1 = "ami-de4bceba"
#        eu-central-1 = "ami-a025b9cf"
#        eu-west-1 = "ami-830d93fa"
#        eu-west-2 = "ami-bc253ed8"
#        eu-west-3 = "ami-f8e35585"
#        ap-southeast-1 = "ami-0484f878"
#        ap-southeast-2 = "ami-34728e56"
#        ap-northeast-2 = "ami-d902a2b7"
#        ap-northeast-1 = "ami-2a43244c"
#        ap-south-1 = "ami-e7560088"
#        sa-east-1 = "ami-404c012c"
#        us-gov-west-1 = "ami-30890051"
#    }
#    ami_id = "${var.type == "metered" ? local.regions[data.aws_region.current.name] : local.images_byol[data.aws_region.current.name]}"
#}
