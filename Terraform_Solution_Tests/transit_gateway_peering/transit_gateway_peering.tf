## Creates Transit VPCs and Aviatrix Transit GWs
## Connects Aviatrix Transit GW-1 to on-prem-1 through AWS VGW
## Connects Aviatrix Transit GW-2 to on-prem-2 through AWS VGW
## Creates a couple of Spoke VPCs and Aviatrix GWs
## Attaches Spoke VPC1 to Transit VPC1 and Spoke VPC2 to Transit VPC2
## Test end-to-end traffic and verify Spoke-Spoke and Spoke-OnPrem are working along with Transit Peering config


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# Spoke VPC1 10.0.0.0/16
# Spoke VPC2 20.0.0.0/16
# OnPrem VPC1 99.0.0.0/16
# OnPrem VPC2 99.1.0.0/16
module "aws-vpc" {
  source                  = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count               = 4
  resource_name_label     = "transit_gateway_peering"
  pub_hostnum             = 10
  pri_hostnum             = 20
  vpc_cidr                = ["10.0.0.0/16","20.0.0.0/16","99.0.0.0/16","99.1.0.0/16"]
  pub_subnet1_cidr        = ["10.0.0.0/24","20.0.0.0/24","99.0.0.0/24","99.1.0.0/24"]
  pub_subnet2_cidr        = ["10.0.1.0/24","20.0.1.0/24","99.0.1.0/24","99.1.1.0/24"]
  pri_subnet_cidr         = ["10.0.2.0/24","20.0.2.0/24","99.0.2.0/24","99.1.2.0/24"]
  public_key              = "${file(var.public_key)}"
  termination_protection  = false
  ubuntu_ami              = "" # default empty will set to ubuntu 18.04 ami
}

#Create AWS Transit VPCs
# Transit VPC1 172.16.0.0/16
# Transit VPC2 192.168.0.0/16
resource "aviatrix_vpc" "transit-vpc-1" {
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_region
  name                 = "TransitVPC1"
  cidr                 = "172.16.0.0/16"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}
resource "aviatrix_vpc" "transit-vpc-2" {
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_region
  name                 = "TransitVPC2"
  cidr                 = "192.168.0.0/16"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}

#Create an Aviatrix AWS Transit Network Gateway
resource "aviatrix_transit_gateway" "AVX-Transit-GW-1" {
  cloud_type               = 1
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "AVX-Transit-GW-1"
  vpc_id                   = aviatrix_vpc.transit-vpc-1.vpc_id
  vpc_reg                  = var.aws_region
  gw_size                  = "t2.micro"
  subnet                   = aviatrix_vpc.transit-vpc-1.subnets[4].cidr
  single_ip_snat           = false
  connected_transit        = true
}
resource "aviatrix_transit_gateway" "AVX-Transit-GW-2" {
  cloud_type               = 1
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "AVX-Transit-GW-2"
  vpc_id                   = aviatrix_vpc.transit-vpc-2.vpc_id
  vpc_reg                  = var.aws_region
  gw_size                  = "t2.micro"
  subnet                   = aviatrix_vpc.transit-vpc-2.subnets[4].cidr
  single_ip_snat           = false
  connected_transit        = true
  depends_on  = [aviatrix_transit_gateway.AVX-Transit-GW-1]
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
  transit_gw   = aviatrix_transit_gateway.AVX-Transit-GW-1.gw_name
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
  transit_gw   = aviatrix_transit_gateway.AVX-Transit-GW-2.gw_name
}

#Create AWS VGW and attach to OnPrem VPC
resource "aws_vpn_gateway" "vpn_gateway-1" {
  vpc_id = module.aws-vpc.vpc_id[2]
}
resource "aws_vpn_gateway" "vpn_gateway-2" {
  vpc_id = module.aws-vpc.vpc_id[3]
}

# Create an Aviatrix VGW Connection
resource "aviatrix_vgw_conn" "test_vgw_conn-1" {
  conn_name        = "test-connection-vgw-to-tgw-1"
  gw_name          = aviatrix_transit_gateway.AVX-Transit-GW-1.gw_name
  vpc_id           = aviatrix_vpc.transit-vpc-1.vpc_id
  bgp_vgw_id       = aws_vpn_gateway.vpn_gateway-1.id
  bgp_vgw_account  = var.aviatrix_aws_access_account
  bgp_vgw_region   = var.aws_region
  bgp_local_as_num = "65001"
}
resource "aviatrix_vgw_conn" "test_vgw_conn-2" {
  conn_name        = "test-connection-vgw-to-tgw-2"
  gw_name          = aviatrix_transit_gateway.AVX-Transit-GW-2.gw_name
  vpc_id           = aviatrix_vpc.transit-vpc-2.vpc_id
  bgp_vgw_id       = aws_vpn_gateway.vpn_gateway-2.id
  bgp_vgw_account  = var.aviatrix_aws_access_account
  bgp_vgw_region   = var.aws_region
  bgp_local_as_num = "65002"
}

# Create an Aviatrix Transit Gateway Peering
resource "aviatrix_transit_gateway_peering" "test_transit_gateway_peering" {
  transit_gateway_name1 = aviatrix_transit_gateway.AVX-Transit-GW-1.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.AVX-Transit-GW-2.gw_name
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC1 public subnet route table; Use VGW as gateway
data "aws_subnet" "onprem1_public" {
  cidr_block = module.aws-vpc.subnet_cidr[2]
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
data "aws_route_table" "onprem1_public" {
  subnet_id   = data.aws_subnet.onprem1_public.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
resource "aws_route" "onprem1_public" {
  route_table_id          = data.aws_route_table.onprem1_public.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway-1.id
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC1 private subnet route table; Use VGW as gateway
data "aws_subnet" "onprem1_private" {
  cidr_block = module.aws-vpc.subnet_cidr[10]
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
data "aws_route_table" "onprem1_private" {
  subnet_id   = data.aws_subnet.onprem1_private.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-A]
}
resource "aws_route" "onprem1_private" {
  route_table_id          = data.aws_route_table.onprem1_private.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway-1.id
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC2 public subnet route table; Use VGW as gateway
data "aws_subnet" "onprem2_public" {
  cidr_block = module.aws-vpc.subnet_cidr[3]
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-B]
}
data "aws_route_table" "onprem2_public" {
  subnet_id   = data.aws_subnet.onprem2_public.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-B]
}
resource "aws_route" "onprem2_public" {
  route_table_id          = data.aws_route_table.onprem2_public.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway-2.id
}

#Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC2 private subnet route table; Use VGW as gateway
data "aws_subnet" "onprem2_private" {
  cidr_block = module.aws-vpc.subnet_cidr[11]
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-B]
}
data "aws_route_table" "onprem2_private" {
  subnet_id   = data.aws_subnet.onprem2_private.id
  depends_on  = [aviatrix_spoke_gateway.AVX-Spoke-GW-B]
}
resource "aws_route" "onprem2_private" {
  route_table_id          = data.aws_route_table.onprem2_private.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway-2.id
}

# Test end-to-end traffic
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.0.10 (public instance in SpokeVPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.0.0.10 (public instance in OnPrem VPC1)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.1.0.10 (public instance in OnPrem VPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.2.20 (private instance in SpokeVPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.0.2.20 (private instance in OnPrem VPC1)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 99.1.2.20 (private instance in OnPrem VPC2)
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_transit_gateway.AVX-Transit-GW-1,
    aviatrix_transit_gateway.AVX-Transit-GW-2,
    aviatrix_spoke_gateway.AVX-Spoke-GW-A,
    aviatrix_spoke_gateway.AVX-Spoke-GW-B,
    aviatrix_vgw_conn.test_vgw_conn-1,
    aviatrix_vgw_conn.test_vgw_conn-2,
    aviatrix_transit_gateway_peering.test_transit_gateway_peering
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null transit_gateway_peering.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/transit_gateway_peering.py --ping_list ${join(",",[for i in [1,2,3,5,6,7]: module.aws-vpc.ubuntu_private_ip[i]])}"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-vpc.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}
