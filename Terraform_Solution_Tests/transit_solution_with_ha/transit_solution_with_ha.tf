## Creates Transit VPC and Aviatrix Transit GW with HA and ActiveMesh configs
## Connects Aviatrix Transit GW to on-prem through AWS VGW
## Creates a couple of Spoke VPCs and Aviatrix GWs with HA and ActiveMesh configs
## Attaches Spoke VPC to Transit VPC
## Test end-to-end traffic and verify Spoke-Spoke and Spoke-OnPrem are working


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# Spoke VPC1 10.0.0.0/16
# Spoke VPC2 20.0.0.0/16
# Transit VPC 192.168.0.0/16
# OnPrem VPC 99.0.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 3
  resource_name_label	= "transit_solution"
  pub_hostnum		      = 10
  pri_hostnum		      = 20
  vpc_cidr        	  = ["10.0.0.0/16","20.0.0.0/16","99.0.0.0/16"]
  pub_subnet1_cidr    = ["10.0.0.0/24","20.0.0.0/24","99.0.0.0/24"]
  pub_subnet2_cidr    = ["10.0.1.0/24","20.0.1.0/24","99.0.1.0/24"]
  pri_subnet_cidr     = ["10.0.2.0/24","20.0.2.0/24","99.0.2.0/24"]
  public_key      	  = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		      = "" # default empty will set to ubuntu 18.04 ami
}

#Create AWS Transit VPC
resource "aviatrix_vpc" "transit-vpc" {
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_region
  name                 = "TransitVPC"
  cidr                 = "192.168.0.0/16"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}

#Create an Aviatrix AWS Transit Network Gateway
resource "aviatrix_transit_gateway" "AVX-Transit-GW" {
  cloud_type               = 1
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "AVX-Transit-GW"
  vpc_id                   = aviatrix_vpc.transit-vpc.vpc_id
  vpc_reg                  = var.aws_region
  gw_size                  = "t2.micro"
  subnet                   = aviatrix_vpc.transit-vpc.subnets[4].cidr
  enable_snat              = false
  connected_transit        = true
  ha_subnet                = aviatrix_vpc.transit-vpc.subnets[5].cidr
  ha_gw_size               = "t2.micro"
  enable_active_mesh       = true
}

#Create an Aviatrix AWS Spoke Gateway-A in Spoke VPC1
resource "aviatrix_spoke_gateway" "AVX-Spoke-GW-A" {
  cloud_type   = 1
  account_name = var.aviatrix_aws_access_account
  gw_name      = "AVX-Spoke-GW-A"
  vpc_id       = module.aws-vpc.vpc_id[0]
  vpc_reg      = var.aws_region
  gw_size      = "t2.micro"
  subnet       = module.aws-vpc.subnet_cidr[0]
  transit_gw   = aviatrix_transit_gateway.AVX-Transit-GW.gw_name
  ha_subnet    = module.aws-vpc.subnet_cidr[3]
  ha_gw_size   = "t2.micro"
  enable_active_mesh = true
}

#Create an Aviatrix AWS Spoke Gateway-B in Spoke VPC2
resource "aviatrix_spoke_gateway" "AVX-Spoke-GW-B" {
  cloud_type   = 1
  account_name = var.aviatrix_aws_access_account
  gw_name      = "AVX-Spoke-GW-B"
  vpc_id       = module.aws-vpc.vpc_id[1]
  vpc_reg      = var.aws_region
  gw_size      = "t2.micro"
  subnet       = module.aws-vpc.subnet_cidr[1]
  transit_gw   = aviatrix_transit_gateway.AVX-Transit-GW.gw_name
  ha_subnet    = module.aws-vpc.subnet_cidr[4]
  ha_gw_size   = "t2.micro"
  enable_active_mesh = true
}

#Create AWS VGW and attach to OnPrem VPC
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = module.aws-vpc.vpc_id[2]
}

# Create an Aviatrix VGW Connection
resource "aviatrix_vgw_conn" "test_vgw_conn" {
  conn_name        = "test-connection-vgw-to-tgw"
  gw_name          = aviatrix_transit_gateway.AVX-Transit-GW.gw_name
  vpc_id           = aviatrix_vpc.transit-vpc.vpc_id
  bgp_vgw_id       = aws_vpn_gateway.vpn_gateway.id
  bgp_vgw_account  = var.aviatrix_aws_access_account
  bgp_vgw_region   = var.aws_region
  bgp_local_as_num = "65001"
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC public subnet route table; Use VGW as gateway
data "aws_subnet" "onprem_public" {
  cidr_block = module.aws-vpc.subnet_cidr[2]
}
data "aws_route_table" "onprem_public" {
  subnet_id   = data.aws_subnet.onprem_public.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
resource "aws_route" "onprem_public" {
  route_table_id          = data.aws_route_table.onprem_public.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway.id
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC private subnet route table; Use VGW as gateway
data "aws_subnet" "onprem_private" {
  cidr_block = module.aws-vpc.subnet_cidr[8]
}
data "aws_route_table" "onprem_private" {
  subnet_id   = data.aws_subnet.onprem_private.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
resource "aws_route" "onprem_private" {
  route_table_id          = data.aws_route_table.onprem_private.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway.id
}

# Test end-to-end traffic
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.0.10 (public instance in SpokeVPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.0.0.10 (public instance in OnPrem VPC)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.2.20 (private instance in SpokeVPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.0.2.20 (private instance in OnPrem VPC)
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_transit_gateway.AVX-Transit-GW,
    aviatrix_spoke_gateway.AVX-Spoke-GW-A,
    aviatrix_spoke_gateway.AVX-Spoke-GW-B,
    aviatrix_vgw_conn.test_vgw_conn
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null transit_solution_with_ha.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/transit_solution_with_ha.py --ping_list ${join(",",[for i in [1,2,4,5]: module.aws-vpc.ubuntu_private_ip[i]])}"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      #private_key = file("~/Downloads/Aviatrix-key")
      host = module.aws-vpc.ubuntu_public_ip[0]
      agent = true
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}

variable "ssh_user" {
  default = "ubuntu"
}
