## Creates Transit VPC and Aviatrix Transit GW
## Creates a couple of Spoke VPCs and Aviatrix GWs
## Attaches Spoke VPCs to Transit VPC
## Test end-to-end traffic between Spoke VPCs


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# Spoke VPC1 10.0.0.0/16
# Spoke VPC2 20.0.0.0/16
# Transit VPC 192.168.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 2
  resource_name_label	= "transit_solution_spoke_to_spoke"
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
}

# Test end-to-end traffic
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.0.10 (public instance in SpokeVPC2)
# Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.2.20 (private instance in SpokeVPC2)
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_transit_gateway.AVX-Transit-GW,
    aviatrix_spoke_gateway.AVX-Spoke-GW-A,
    aviatrix_spoke_gateway.AVX-Spoke-GW-B
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null transit_sol_spoke_to_spoke.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/transit_sol_spoke_to_spoke.py --ping_list ${join(",",[for i in range(1,4,2): module.aws-vpc.ubuntu_private_ip[i]])}"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-vpc.ubuntu_public_ip[0]
      agent = true
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/*.txt ."
  }
}
