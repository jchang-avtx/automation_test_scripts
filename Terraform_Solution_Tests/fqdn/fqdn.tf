## Creates and manages FQDN filters for Aviatrix gateway
## Test end-to-end traffic to make sure FQDN filters are working


# this module creates a test environement, you can specify how many vpcs to create
# each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 1
  resource_name_label	= "fqdn"
  pub_hostnum		      = 10
  pri_hostnum		      = 20
  vpc_cidr        	  = ["10.10.0.0/16"]
  pub_subnet1_cidr    = ["10.10.0.0/24"]
  pub_subnet2_cidr    = ["10.10.1.0/24"]
  pri_subnet_cidr     = ["10.10.2.0/24"]
  public_key      	  = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		      = "" # default empty will set to ubuntu 18.04 ami
}

resource "aviatrix_gateway" "FQDN-GW" {
  cloud_type    = 1
  account_name  = var.aviatrix_aws_access_account
  gw_name       = "FQDN-GW"
  vpc_id        = module.aws-vpc.vpc_id[0]
  vpc_reg       = var.aws_region
  gw_size       = "t2.micro"
  subnet        = module.aws-vpc.subnet_cidr[0]
  enable_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}

resource "aviatrix_fqdn" "FQDN-tag1" {
  fqdn_tag      = var.aviatrix_fqdn_tag
  fqdn_enabled  = var.aviatrix_fqdn_status
  fqdn_mode     = var.aviatrix_fqdn_mode

  gw_filter_tag_list {
    gw_name         = var.aviatrix_fqdn_gateway
    source_ip_list  = var.aviatrix_fqdn_source_ip_list
  }

  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[0]
    proto  = var.aviatrix_fqdn_protocol[0]
    port   = var.aviatrix_fqdn_port[0]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[1]
    proto  = var.aviatrix_fqdn_protocol[1]
    port   = var.aviatrix_fqdn_port[1]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[2]
    proto  = var.aviatrix_fqdn_protocol[2]
    port   = var.aviatrix_fqdn_port[2]
  }
  domain_names {
    fqdn   = var.aviatrix_fqdn_domain[3]
    proto  = var.aviatrix_fqdn_protocol[3]
    port   = var.aviatrix_fqdn_port[3]
  }

  depends_on = [aviatrix_gateway.FQDN-GW]
}

# Test end-to-end traffic
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_fqdn.FQDN-tag1
  ]

  triggers = {
    key = "${uuid()}"
  }

  # This provisioner will copy fqdn.py to public VM instance
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null fqdn.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/fqdn.py"
  }

  # Copy private key to public instance in order to ssh to private instance
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${local.private_key} ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:~/.ssh/id_rsa"
  }

  # Install python3 modules as necessary to run python script
  # This provisioner can be removed if we use ubuntu_ami with customized modules
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "echo 'Y' | sudo apt-get install python3-pexpect"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      #private_key = file("~/Downloads/sshkey")
      host = module.aws-vpc.ubuntu_public_ip[0]
      agent = true
    }
  }

  # Run python script on public instance
  # Python script will test end-to-end traffic on private instance
  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/fqdn.py --domain ${join(",", var.aviatrix_fqdn_domain)} --proto ${join(",", var.aviatrix_fqdn_protocol)} --port ${join(",", var.aviatrix_fqdn_port)} --mode ${var.aviatrix_fqdn_mode} --instance ${module.aws-vpc.ubuntu_private_ip[1]}"
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

locals {
  private_key     = "/home/ubuntu/.ssh/id_rsa"
}
