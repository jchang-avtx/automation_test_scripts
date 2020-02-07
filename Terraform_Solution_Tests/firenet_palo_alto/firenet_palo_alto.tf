## Creates Spoke VPC1 in Dev Domain and VPC2 in Shared Service Domain, TransitVPC in Edge Domain, and OnPrem VPC also.
## Both public and private ubuntu instances are created along with VPC creations.
## Set up Aviatrix Transit GW in TransitVPC and makes connection to On-Prem via VGW
## Creates AWS TGW and attaches with Aviatrix Transit GW.
## Add/modify domain connection policies so that Dev is connected to Shared Service and Security domains.
## Creates Security VPC in Firewall Security Domain and deploy Aviatrix FireNet GW.
## Attaches Aviatrix FireNet GW to TGW Firewall Domain. Also, launch and associate with Palo Alto VM-series Firewall instance.
## Test end-to-end traffic flows and verify E-W, N-S, and Egress traffic flows are inspected by Firewall instance.


# Create key_pair for firewall instance and launch Palo Alto Networks VM-Series instance
resource "random_id" "key_id" {
  byte_length = 4
}
resource "aws_key_pair" "key_pair" {
  key_name      = "testbed_ubuntu_key-${random_id.key_id.dec}"
  public_key    = file(var.public_key)
}
resource "aviatrix_firewall_instance" "firenet_instance" {
  vpc_id                = aviatrix_vpc.security-vpc.vpc_id
  firenet_gw_name       = aviatrix_transit_gateway.AVX-FireNet-GW.gw_name
  firewall_name         = "avx_firewall_instance"
  firewall_image        = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_size         = "m5.xlarge"
  management_subnet     = aviatrix_vpc.security-vpc.subnets[0].cidr
  egress_subnet         = aviatrix_vpc.security-vpc.subnets[1].cidr
  key_name              = aws_key_pair.key_pair.key_name
  iam_role              = var.bootstrap_role  # ensure that role is for EC2
  bootstrap_bucket_name = var.bootstrap_bucket
}

#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# VPC1 (Dev Domain) 10.0.0.0/16
# VPC2 (Shared Service Domain) 20.0.0.0/16
# Transit VPC (Edge Domain) 192.168.0.0/16
# OnPrem VPC 99.0.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 3   # VPC1, VPC2, OnPremVPC
  resource_name_label	= "firenet"
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
  vpc_reg                  = aviatrix_vpc.transit-vpc.region
  gw_size                  = "t2.micro"
  subnet                   = aviatrix_vpc.transit-vpc.subnets[4].cidr
  single_ip_snat           = false
  enable_hybrid_connection = true
  connected_transit        = false
  #ha_subnet                = aviatrix_vpc.transit-vpc.subnets[6].cidr
  #ha_gw_size               = "t2.micro"
  enable_active_mesh       = true
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
  depends_on  = [aviatrix_transit_gateway.AVX-Transit-GW]
}
data "aws_route_table" "onprem_public" {
  subnet_id   = data.aws_subnet.onprem_public.id
  depends_on  = [aviatrix_transit_gateway.AVX-Transit-GW]
}
resource "aws_route" "onprem_public" {
  route_table_id          = data.aws_route_table.onprem_public.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway.id
}

# #Add SpokeVPC dst cidr 10.0.0.0/16 route to OnPremVPC private subnet route table; Use VGW as gateway
data "aws_subnet" "onprem_private" {
  cidr_block = module.aws-vpc.subnet_cidr[8]
  depends_on  = [aviatrix_transit_gateway.AVX-Transit-GW]
}
data "aws_route_table" "onprem_private" {
  subnet_id   = data.aws_subnet.onprem_private.id
  depends_on  = [aviatrix_transit_gateway.AVX-Transit-GW]
}
resource "aws_route" "onprem_private" {
  route_table_id          = data.aws_route_table.onprem_private.id
  destination_cidr_block  = "10.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway.id
}

#Create Security VPC for FireNet
resource "aviatrix_vpc" "security-vpc" {
  cloud_type           = 1
  account_name         = var.aviatrix_aws_access_account
  region               = var.aws_region
  name                 = "SecurityVPC"
  cidr                 = "172.16.0.0/16"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = true
}

#Create an Aviatrix FireNet Gateway
resource "aviatrix_transit_gateway" "AVX-FireNet-GW" {
  cloud_type               = 1
  account_name             = var.aviatrix_aws_access_account
  gw_name                  = "AVX-FireNet-GW"
  vpc_id                   = aviatrix_vpc.security-vpc.vpc_id
  vpc_reg                  = aviatrix_vpc.security-vpc.region
  gw_size                  = "c5.xlarge"
  subnet                   = aviatrix_vpc.security-vpc.subnets[0].cidr
  single_ip_snat           = false
  enable_hybrid_connection = true
  enable_firenet           = true
  connected_transit        = false
  #ha_subnet                = aviatrix_vpc.security-vpc.subnets[2].cidr
  #ha_gw_size               = "c5.xlarge"
  enable_active_mesh       = false
}

# Create an Aviatrix AWS TGW
resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name                          = "test-aws-tgw"
  account_name                      = var.aviatrix_aws_access_account
  region                            = var.aws_region
  aws_side_as_number                = "64512"
  attached_aviatrix_transit_gateway = [aviatrix_transit_gateway.AVX-Transit-GW.gw_name]
  manage_vpc_attachment             = true
  depends_on                        = [aviatrix_vgw_conn.test_vgw_conn]

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = var.edge_domain_connected_list
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Dev_Domain"
    connected_domains    = var.dev_domain_connected_list
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[0]   #Spoke VPC1
      vpc_region         = var.aws_region
    }
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.shared_service_domain_connected_list
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[1]   #VPC2
      vpc_region         = var.aws_region
    }
  }
  security_domains {
    security_domain_name = "Security_Domain"
    connected_domains    = var.security_domain_connected_list
    aviatrix_firewall    = true
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = aviatrix_vpc.security-vpc.vpc_id
      vpc_region         = var.aws_region
    }
  }
}

# Deploy Firewall Network; Associate VM-Series firewall instance
resource "aviatrix_firenet" "palo_alto_firenet" {
  vpc_id                   = aviatrix_vpc.security-vpc.vpc_id
  inspection_enabled       = true
  egress_enabled           = true
  firewall_instance_association {
    firenet_gw_name        = aviatrix_transit_gateway.AVX-FireNet-GW.gw_name
    vendor_type            = "Generic"   // Mantis Bug ID 12822
    firewall_name          = aviatrix_firewall_instance.firenet_instance.firewall_name
    instance_id            = aviatrix_firewall_instance.firenet_instance.instance_id
    lan_interface          = aviatrix_firewall_instance.firenet_instance.lan_interface
    management_interface   = aviatrix_firewall_instance.firenet_instance.management_interface
    egress_interface       = aviatrix_firewall_instance.firenet_instance.egress_interface
    attached               = true
  }
}

########## Test following end-to-end traffic flows for firewall inspection ##########
# Test East-West traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to 20.0.0.10 (public instance in SpokeVPC2)
# Test East-West traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to 20.0.2.20 (private instance in SpokeVPC2)
# Test North-South traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to 99.0.0.10 (public instance in OnPrem VPC)
# Test North-South traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to 99.0.2.20 (private instance in OnPrem VPC)
# Test Egress (internet) traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to www.aviatrix.com (35.223.111.68)
# Test Egress (internet) traffic flow - Ping from 10.0.2.20 (private instance in SpokeVPC1) to Google Public DNS (8.8.8.8)
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_transit_gateway.AVX-Transit-GW,
    aviatrix_aws_tgw.test_aws_tgw,
    aviatrix_firenet.palo_alto_firenet
  ]

  triggers = {
    key = "${uuid()}"
  }

  # This provisioner will copy python script to public VM instance
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null firenet_palo_alto.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  # Copy private key to public instance in order to ssh to private instance
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.private_key} ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:~/.ssh/id_rsa"
  }

  # Install python3 modules as necessary to run python script
  # This provisioner can be removed if we use ubuntu_ami with customized pre-installed modules
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "echo 'Y' | sudo apt-get install python3-pexpect"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-vpc.ubuntu_public_ip[0]
      agent = false
    }
  }

  # Run python script on public instance
  # Python script will test end-to-end traffic on private instance
  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/firenet_palo_alto.py --ping_list ${join(",",[for i in [1,2,4,5]: module.aws-vpc.ubuntu_private_ip[i]])},35.223.111.68,8.8.8.8 --instance ${module.aws-vpc.ubuntu_private_ip[3]} --firewall_ip ${aviatrix_firewall_instance.firenet_instance.public_ip}"
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
