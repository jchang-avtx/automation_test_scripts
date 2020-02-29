##########################
# DATA SOURCE
##########################
# Note can only set data_source AFTER initial setup of firewall
# does not work for FQDN gateway
# data "aviatrix_firenet_vendor_integration" "firenet_vendor_info" {
#   vpc_id        = aviatrix_vpc.firenet_vpc["us-east-1"].id
#   instance_id   = aviatrix_firewall_instance.firenet_instance.instance_id
#   vendor_type   = "Palo Alto VM Series"
#   public_ip     = aviatrix_firewall_instance.firenet_instance.public_ip
#   username      = "admin"
#   password      = "1234"
#
#   firewall_name       = aviatrix_firewall_instance.firenet_instance.firewall_name
#   route_table         = ""
#   number_of_retries   = 5
#   retry_interval      = 180
#   save                = true
#   # synchronize = true
# }

##########################
# VPC
##########################
variable "vpc" {
  description = "Map for each VPC to create"
  default = {
    "us-east-1" = "84.19.0.0/16"
    "eu-west-1" = "85.20.0.0/16"
  }
}

resource "aviatrix_vpc" "firenet_vpc" {
  for_each = var.vpc
  cloud_type            = 1
  account_name          = "AWSAccess"
  region                = each.key
  name                  = join("-", ["firenetVPC", each.key])
  cidr                  = each.value
  aviatrix_transit_vpc  = false
  aviatrix_firenet_vpc  = true
}

##########################
# TGW
##########################
resource "aviatrix_aws_tgw" "firenet_tgw" {
  tgw_name            = "firenetTGW"
  account_name        = "AWSAccess"
  region              = aviatrix_vpc.firenet_vpc["us-east-1"].region
  aws_side_as_number  = "64512"
  manage_vpc_attachment = false
  # attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.firenet_transit_gateway.gw_name]
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
  }
  security_domains {
    security_domain_name = "FireNet_Domain"
    aviatrix_firewall = true
  }

}

## Step 6 of Firenet: (11330) support attach tgw vpc outside of tgw resource
resource "aviatrix_aws_tgw_vpc_attachment" "firenet_tgw_vpc_attach" {
  tgw_name              = aviatrix_aws_tgw.firenet_tgw.tgw_name
  region                = aviatrix_aws_tgw.firenet_tgw.region
  security_domain_name  = aviatrix_aws_tgw.firenet_tgw.security_domains.3.security_domain_name
  vpc_account_name      = aviatrix_vpc.firenet_vpc["us-east-1"].account_name
  vpc_id                = aviatrix_transit_gateway.firenet_transit_gateway.vpc_id
}

resource "aviatrix_aws_tgw" "firenet_tgw2" {
  tgw_name            = "firenetTGW2"
  account_name        = "AWSAccess"
  region              = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  aws_side_as_number  = "64512"
  manage_vpc_attachment = true
  # attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.firenet_transit_gateway.gw_name]
  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = ["Default_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Shared_Service_Domain"]
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = ["Aviatrix_Edge_Domain", "Default_Domain"]
  }
  security_domains {
    security_domain_name = "FireNet_Domain"
    aviatrix_firewall = true
    # STEP 6 of FIRENET
    attached_vpc {
      vpc_account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
      vpc_id              = aviatrix_transit_gateway.firenet_transit_gateway2.vpc_id
      vpc_region          = aviatrix_transit_gateway.firenet_transit_gateway2.vpc_reg
    }
  }

}

##########################
# Transit GW/ GW
##########################
resource "aviatrix_transit_gateway" "firenet_transit_gateway" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["us-east-1"].account_name
  gw_name         = "firenetTransitGW"
  vpc_id          = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["us-east-1"].region
  gw_size         = "c5.xlarge"
  subnet          = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.0.cidr
  ha_subnet       = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.2.cidr
  ha_gw_size      = "c5.xlarge"

  enable_hybrid_connection  = true
  enable_firenet            = true
  connected_transit         = false
  enable_active_mesh        = false
}

resource "aviatrix_transit_gateway" "firenet_transit_gateway2" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
  gw_name         = "firenetTransitGW2"
  vpc_id          = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  gw_size         = "c5.xlarge"
  subnet          = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.0.cidr
  # ha_subnet       = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.2.cidr
  # ha_gw_size      = "c5.xlarge"

  enable_hybrid_connection  = true
  enable_firenet            = true
  connected_transit         = false
  enable_active_mesh        = false
}


resource "aviatrix_gateway" "fqdn_gateway" {
  cloud_type      = 1
  account_name    = aviatrix_vpc.firenet_vpc["eu-west-1"].account_name
  gw_name         = "fqdnGW"
  vpc_id          = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  vpc_reg         = aviatrix_vpc.firenet_vpc["eu-west-1"].region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.0.cidr
  single_az_ha    = true
}

##########################
# Firewall Instance
##########################
resource "aviatrix_firewall_instance" "firenet_instance" {
  vpc_id                = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.firenet_transit_gateway.gw_name
  firewall_name         = "firenet_Instance_Name"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version= "9.1.0-h3"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource "aviatrix_firewall_instance" "firenet_instance2" {
  vpc_id                = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  firenet_gw_name       = join("-", [aviatrix_transit_gateway.firenet_transit_gateway.gw_name, "hagw"])
  firewall_name         = "firenetInstanceName2"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version= "9.0.3.xfr"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.2.cidr
  egress_subnet         = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.3.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource "aviatrix_firewall_instance" "firenet_instance3" {
  vpc_id                = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.firenet_transit_gateway2.gw_name
  firewall_name         = "firenet_Instance_Name3"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.firenet_vpc["eu-west-1"].subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  # iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  # bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

##########################
# FireNet
##########################
resource "aviatrix_firenet" "firenet" {
  vpc_id              = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  inspection_enabled  = true # default true (reversed if FQDN use case)
  egress_enabled      = true # default false (reversed if FQDN use case)

  ## can test updating by creating another firewall instance and attaching
  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.firenet_transit_gateway.gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.firenet_instance.firewall_name
    instance_id           = aviatrix_firewall_instance.firenet_instance.instance_id
    lan_interface         = aviatrix_firewall_instance.firenet_instance.lan_interface
    management_interface  = aviatrix_firewall_instance.firenet_instance.management_interface
    egress_interface      = aviatrix_firewall_instance.firenet_instance.egress_interface
    attached              = true # updateable
  }

  firewall_instance_association {
    firenet_gw_name       = join("-", [aviatrix_transit_gateway.firenet_transit_gateway.gw_name, "hagw"])
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.firenet_instance2.firewall_name
    instance_id           = aviatrix_firewall_instance.firenet_instance2.instance_id
    lan_interface         = aviatrix_firewall_instance.firenet_instance2.lan_interface
    management_interface  = aviatrix_firewall_instance.firenet_instance2.management_interface
    egress_interface      = aviatrix_firewall_instance.firenet_instance2.egress_interface
    attached              = true # updateable
  }
}

resource "aviatrix_firenet" "fqdn_firenet" {
  vpc_id              = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  inspection_enabled  = false # default true (reversed if FQDN use case)
  egress_enabled      = true # default false (reversed if FQDN use case)

  firewall_instance_association {
    firenet_gw_name   = aviatrix_transit_gateway.firenet_transit_gateway2.gw_name
    vendor_type       = "fqdn_gateway"
    instance_id       = aviatrix_gateway.fqdn_gateway.gw_name
    attached          = true
  }
}

##########################
# Outputs
##########################
output "firenet_id" {
  value = aviatrix_firenet.firenet.id
}
output "fqdn_firenet_id" {
  value = aviatrix_firenet.fqdn_firenet.id
}
output "firenet_instance_id" {
  value = aviatrix_firewall_instance.firenet_instance.id
}
output "firenet_instance3_id" {
  value = aviatrix_firewall_instance.firenet_instance3.id
}
