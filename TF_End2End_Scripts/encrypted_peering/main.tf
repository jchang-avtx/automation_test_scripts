
# create the testing environment
data "aws_region" "current" {}

# this module creates a test environement, you can specify how many vpcs to create
# each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 2
  resource_name_label	= var.resource_name_label
  pub_hostnum		      = 10
  pri_hostnum		      = 50
  vpc_cidr        	  = ["30.10.0.0/16", "30.50.0.0/16"]
  pub_subnet1_cidr    = ["30.10.0.0/24", "30.50.0.0/24"]
  pub_subnet2_cidr    = ["30.10.5.0/24", "30.50.5.0/24"]
  pri_subnet_cidr     = ["30.10.10.0/24", "30.50.10.0/24"]
  public_key      	  = var.public_key
  termination_protection = false
}

# Create aviatrix access account for GWs
resource "aviatrix_account" "test_acc" {
  account_name        = var.access_account_name
  cloud_type          = 1
  aws_account_number  = var.aws_account_number
  aws_access_key      = var.aws_access_key
  aws_secret_key      = var.aws_secret_key
}

# Create aviatrix GWs to be peered
resource "aviatrix_gateway" "test_gateway1" {
  cloud_type      = 1
  account_name    = aviatrix_account.test_acc.account_name
  gw_name         = "${var.resource_name_label}-gw1"
  vpc_id          = module.aws-vpc.vpc_id[0]
  vpc_reg         = data.aws_region.current.name
  gw_size         = "t2.micro"
  subnet          = module.aws-vpc.subnet_cidr[0]
  enable_snat     = true
}

resource "aviatrix_gateway" "test_gateway2" {
  cloud_type      = 1
  account_name    = aviatrix_account.test_acc.account_name
  gw_name         = "${var.resource_name_label}-gw2"
  vpc_id          = module.aws-vpc.vpc_id[1]
  vpc_reg         = data.aws_region.current.name
  gw_size         = "t2.micro"
  subnet          = module.aws-vpc.subnet_cidr[1]
  enable_snat     = true
}

# Create encrypted peering between two GWs
resource "aviatrix_tunnel" "encrypted_peering"{
  gw_name1      = aviatrix_gateway.test_gateway1.gw_name
  gw_name2      = aviatrix_gateway.test_gateway2.gw_name
}

# Ping VMs
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_gateway.test_gateway1,
    aviatrix_gateway.test_gateway2,
    aviatrix_tunnel.encrypted_peering
  ]

  triggers = {
    key = "${uuid()}"
  }

  # SSH into remote host and ping other VMs
  provisioner "remote-exec" {
    inline = [
      "ping -w 3 ${module.aws-vpc.ubuntu_private_ip[0]} > /tmp/ping_output.txt",
      "echo '' >> /tmp/ping_output.txt",
      "echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> /tmp/ping_output.txt",
      "ping -w 3 ${module.aws-vpc.ubuntu_private_ip[1]} >> /tmp/ping_output.txt",
      "echo '' >> /tmp/ping_output.txt",
      "echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> /tmp/ping_output.txt",
      "ping -w 3 ${module.aws-vpc.ubuntu_private_ip[2]} >> /tmp/ping_output.txt",
      "echo '' >> /tmp/ping_output.txt",
      "echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> /tmp/ping_output.txt",
      "ping -w 3 ${module.aws-vpc.ubuntu_private_ip[3]} >> /tmp/ping_output.txt",
      "chmod 777 /tmp/ping_output.txt"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = var.private_key             # use either private key or ssh agent
      agent = var.ssh_agent                     # on Windows, only valid ssh agent is Pageant
      host = module.aws-vpc.ubuntu_public_ip[0]
    }
  }

  # Copy ping_output.txt from remote host to local machine
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/ping_output.txt ping_output.txt"
  }
}
