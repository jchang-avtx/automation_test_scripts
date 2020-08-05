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
# Firewall Instance
##########################
resource "aviatrix_firewall_instance" "firenet_instance" {
  vpc_id                = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.firenet_transit.gw_name
  firewall_name         = "firenet_Instance_Name"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]"
  firewall_image_version= "9.1.0-h3"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.0.cidr
  egress_subnet         = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.1.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource "aviatrix_firewall_instance" "firenet_instance_2" {
  vpc_id                = aviatrix_vpc.firenet_vpc["us-east-1"].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.firenet_transit.ha_gw_name
  firewall_name         = "firenet-instance-2"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]"
  firewall_image_version= "9.0.3.xfr"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.2.cidr
  egress_subnet         = aviatrix_vpc.firenet_vpc["us-east-1"].subnets.3.cidr
  # key_name              = "randomKeyName.pem"
  iam_role              = "bootstrap-VM-S3-role" # ensure that role is for EC2
  bootstrap_bucket_name = "bootstrap-bucket-firenet"
}

resource "aviatrix_firewall_instance" "fqdn_firenet_instance" {
  vpc_id                = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.fqdn_firenet_transit.gw_name
  firewall_name         = "fqdn-firenet-instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]"
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
    firenet_gw_name       = aviatrix_transit_gateway.firenet_transit.gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.firenet_instance.firewall_name
    instance_id           = aviatrix_firewall_instance.firenet_instance.instance_id
    lan_interface         = aviatrix_firewall_instance.firenet_instance.lan_interface
    management_interface  = aviatrix_firewall_instance.firenet_instance.management_interface
    egress_interface      = aviatrix_firewall_instance.firenet_instance.egress_interface
    attached              = true # updateable
  }

  firewall_instance_association {
    firenet_gw_name       = aviatrix_transit_gateway.firenet_transit.ha_gw_name
    vendor_type           = "Generic"
    firewall_name         = aviatrix_firewall_instance.firenet_instance_2.firewall_name
    instance_id           = aviatrix_firewall_instance.firenet_instance_2.instance_id
    lan_interface         = aviatrix_firewall_instance.firenet_instance_2.lan_interface
    management_interface  = aviatrix_firewall_instance.firenet_instance_2.management_interface
    egress_interface      = aviatrix_firewall_instance.firenet_instance_2.egress_interface
    attached              = true # updateable
  }
}

resource "aviatrix_firenet" "fqdn_firenet" {
  vpc_id              = aviatrix_vpc.firenet_vpc["eu-west-1"].vpc_id
  inspection_enabled  = false # default true (reversed if FQDN use case)
  egress_enabled      = true # default false (reversed if FQDN use case)

  firewall_instance_association {
    firenet_gw_name   = aviatrix_transit_gateway.fqdn_firenet_transit.gw_name
    vendor_type       = "fqdn_gateway"
    instance_id       = aviatrix_gateway.fqdn_firenet_gw.gw_name
    attached          = true
  }
}
