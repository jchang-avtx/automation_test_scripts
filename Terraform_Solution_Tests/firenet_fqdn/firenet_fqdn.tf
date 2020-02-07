## Creates Spoke VPC in Dev Domain, and both public and private ubuntu instances are created as well.
## Creates Security VPC in FireNet Domain and deploys Aviatrix FireNet GW and FQDN GW.
## Creates AWS TGW and attaches all VPCs and domains.
## Add/modify domain connection policies so that Dev domain is connected to FireNet domain for traffic inspection.
## Test Egress (Internet-bound) traffic flows from private instance and verify traffic flows are inspected by FQDN as expected.


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# Spoke VPC (Dev Domain) 10.0.0.0/16
module "aws-vpc" {
  source                 = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	         = 1
  resource_name_label    = "firenet-spoke"
  pub_hostnum	         = 10
  pri_hostnum	         = 20
  vpc_cidr               = ["10.0.0.0/16"]
  pub_subnet1_cidr       = ["10.0.0.0/24"]
  pub_subnet2_cidr       = ["10.0.1.0/24"]
  pri_subnet_cidr        = ["10.0.2.0/24"]
  public_key             = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		 = "" # default empty will set to ubuntu 18.04 ami
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

#Create an Aviatrix FQDN GW instance
resource "aviatrix_gateway" "AVX-FQDN-GW" {
  cloud_type      = 1
  account_name    = var.aviatrix_aws_access_account
  gw_name         = "AVX-FQDN-GW"
  vpc_id          = aviatrix_vpc.security-vpc.vpc_id
  vpc_reg         = aviatrix_vpc.security-vpc.region
  gw_size         = "t2.micro"
  subnet          = aviatrix_vpc.security-vpc.subnets[0].cidr
  single_az_ha    = true
  single_ip_snat  = false
}
resource "aviatrix_fqdn" "FQDN-allow" {
  fqdn_tag      = "test-fqdn-allow"
  fqdn_enabled  = true
  fqdn_mode     = "white"
  depends_on    = [aviatrix_firenet.fqdn_firenet]

  gw_filter_tag_list {
    gw_name         = aviatrix_gateway.AVX-FQDN-GW.gw_name
  }

  dynamic domain_names {
    for_each = toset(var.ping_allow_list)

    content {
    fqdn   = domain_names.value
    proto  = "icmp"
    port   = "ping"
    }
  }
}

# Create an Aviatrix AWS TGW
resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name                          = "test-aws-tgw"
  account_name                      = var.aviatrix_aws_access_account
  region                            = var.aws_region
  aws_side_as_number                = "64512"
  manage_vpc_attachment             = false

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Dev_Domain"
    connected_domains    = var.dev_domain_connected_list
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.shared_service_domain_connected_list
  }
  security_domains {
    security_domain_name = "FireNet_Domain"
    connected_domains    = var.firenet_domain_connected_list
    aviatrix_firewall    = true
  }
}

## Attach Spoke VPC to TGW
resource "aviatrix_aws_tgw_vpc_attachment" "vpc1_tgw_attach" {
  tgw_name              = aviatrix_aws_tgw.test_aws_tgw.tgw_name
  region                = aviatrix_aws_tgw.test_aws_tgw.region
  security_domain_name  = aviatrix_aws_tgw.test_aws_tgw.security_domains[2].security_domain_name
  vpc_account_name      = var.aviatrix_aws_access_account
  vpc_id                = module.aws-vpc.vpc_id[0]   #Spoke VPC
}

## Step 6 FireNet Setup: Attach Aviatrix FireNet Gateway to TGW Firewall Domain.
resource "aviatrix_aws_tgw_vpc_attachment" "firenet_tgw_vpc_attach" {
  tgw_name              = aviatrix_aws_tgw.test_aws_tgw.tgw_name
  region                = aviatrix_aws_tgw.test_aws_tgw.region
  security_domain_name  = aviatrix_aws_tgw.test_aws_tgw.security_domains[4].security_domain_name
  vpc_account_name      = var.aviatrix_aws_access_account
  vpc_id                = aviatrix_transit_gateway.AVX-FireNet-GW.vpc_id
}

## Step 7c Deploy Firewall Network; Associate with Aviatrix FQDN GW firewall instance
resource "aviatrix_firenet" "fqdn_firenet" {
  vpc_id                   = aviatrix_vpc.security-vpc.vpc_id
  inspection_enabled       = false  // FQDN doesn't inspect E-W, N-S traffic flows
  egress_enabled           = true
  firewall_instance_association {
    firenet_gw_name        = aviatrix_transit_gateway.AVX-FireNet-GW.gw_name
    vendor_type            = "fqdn_gateway"
    instance_id            = aviatrix_gateway.AVX-FQDN-GW.gw_name
    attached               = true
  }
}

########## Test Egress traffic flows for FQDN Firewall inspection ##########
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_aws_tgw.test_aws_tgw,
    aviatrix_firenet.fqdn_firenet,
    aviatrix_fqdn.FQDN-allow
  ]

  triggers = {
    key = "${uuid()}"
  }

  # This provisioner will copy python script to public VM instance
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null firenet_fqdn.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
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
  # Python script will test internet-bound egress traffic flows on private instance
  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/firenet_fqdn.py --ping_allow_list ${join(",",var.ping_allow_list)} --ping_deny_list ${join(",",var.ping_deny_list)} --instance ${module.aws-vpc.ubuntu_private_ip[1]}"
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
