## Creates SrcVPC, TransitiveVPC, and DstVPC
## Creates Aviatrix gateways A,B and C in each VPC respectively.
## Creates Aviatrix encrypted tunnels A-B and B-C
## Creates Transitive peering A-C with next hop of B.
## Test traffic between SrcVPC and DstVPC by passing through TransitiveVPC.


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# SrcVPC 10.0.0.0/16
# DstVPC 20.0.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 2
  resource_name_label	= "peering"
  pub_hostnum		      = 10
  pri_hostnum		      = 20
  vpc_cidr        	  = ["10.0.0.0/16","20.0.0.0/16"]
  pub_subnet1_cidr    = ["10.0.0.0/24","20.0.0.0/24"]
  pub_subnet2_cidr    = ["10.0.1.0/24","20.0.1.0/24"]
  pri_subnet_cidr     = ["10.0.2.0/24","20.0.2.0/24"]
  public_key      	  = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		      = "" # default empty will set to ubuntu 18.04 ami
}

# Create TransitiveVPC 15.0.0.0/16
resource "aws_vpc" "TransitiveVPC" {
  cidr_block     = "15.0.0.0/16"
  tags = {
    Name = "TransitiveVPC"
  }
}
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.TransitiveVPC.id
  cidr_block = "15.0.0.0/24"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.TransitiveVPC.id
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.TransitiveVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
      ignore_changes = all
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

#Create Aviatrix gateway-A in SrcVPC
resource "aviatrix_gateway" "AVX-GW-A" {
  cloud_type    = 1
  account_name  = var.aviatrix_aws_access_account
  gw_name       = "AVX-GW-A"
  vpc_id        = module.aws-vpc.vpc_id[0]
  vpc_reg       = var.aws_region
  gw_size       = "t2.micro"
  subnet        = module.aws-vpc.subnet_cidr[0]
  enable_snat   = false
  enable_vpc_dns_server = false
  #depends_on    = [module.aws-vpc]

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

#Create Aviatrix gateway-B in TransitiveVPC
resource "aviatrix_gateway" "AVX-GW-B" {
  cloud_type    = 1
  account_name  = var.aviatrix_aws_access_account
  gw_name       = "AVX-GW-B"
  vpc_id        = aws_vpc.TransitiveVPC.id
  vpc_reg       = var.aws_region
  gw_size       = "t2.micro"
  subnet        = aws_subnet.main.cidr_block
  enable_snat   = true
  enable_vpc_dns_server = false
  #depends_on    = [aws_subnet.main]

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

#Create Aviatrix gateway-C in DstVPC
resource "aviatrix_gateway" "AVX-GW-C" {
  cloud_type    = 1
  account_name  = var.aviatrix_aws_access_account
  gw_name       = "AVX-GW-C"
  vpc_id        = module.aws-vpc.vpc_id[1]
  vpc_reg       = var.aws_region
  gw_size       = "t2.micro"
  subnet        = module.aws-vpc.subnet_cidr[1]
  enable_snat   = false
  enable_vpc_dns_server = false
  #depends_on    = [module.aws-vpc]

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

# Create Aviatrix Encrypted Tunnel between AVX-GW-A and AVX-GW-B
resource "aviatrix_tunnel" "A-B" {
  gw_name1 = aviatrix_gateway.AVX-GW-A.gw_name
  gw_name2 = aviatrix_gateway.AVX-GW-B.gw_name
}
# Create Aviatrix Encrypted Tunnel between AVX-GW-B and AVX-GW-C
resource "aviatrix_tunnel" "B-C" {
  gw_name1 = aviatrix_gateway.AVX-GW-B.gw_name
  gw_name2 = aviatrix_gateway.AVX-GW-C.gw_name
}

# Create an Aviatrix AWS Transitive Peering
resource "aviatrix_trans_peer" "test_trans_peer" {
  source         = aviatrix_gateway.AVX-GW-A.gw_name
  nexthop        = aviatrix_gateway.AVX-GW-B.gw_name
  reachable_cidr = "20.0.0.0/16"
  depends_on = [aviatrix_tunnel.A-B,aviatrix_tunnel.B-C]
}

# Test end-to-end traffic
resource "null_resource" "ping" {
  depends_on = [
    aviatrix_trans_peer.test_trans_peer,
    module.aws-vpc.ubuntu_public_ip
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null transitive_peering.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "/tmp/transitive_peering.py --ping_list ${join(",",[module.aws-vpc.ubuntu_private_ip[1],module.aws-vpc.ubuntu_private_ip[3]])}"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      #private_key = file("~/Downloads/sshkey")
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
