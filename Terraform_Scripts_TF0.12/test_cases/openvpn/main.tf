# this module creates a test environement, you can specify how many vpcs to create
# each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
module "aws_vpc_testbed" {
  source = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count               = 2
  resource_name_label     = "splunk-open-vpn"
  pub_hostnum             = 10
  pri_hostnum             = 20
  vpc_cidr                = ["13.10.0.0/16","14.10.0.0/16"]
  pub_subnet1_cidr        = ["13.10.0.0/24","14.10.0.0/24"]
  pub_subnet2_cidr        = ["13.10.1.0/24","14.10.1.0/24"]
  pri_subnet_cidr         = ["13.10.2.0/24","14.10.2.0/24"]
  public_key              = "${file(var.public_key)}"
  termination_protection  = false
  ubuntu_ami              = "" # default empty will set to ubuntu 18.04 ami
}

resource "aviatrix_gateway" "splunk_avx_vpn_gw" {
  cloud_type        = 1
  account_name      = var.avx_aws_access_account_name
  gw_name           = "splunk-avx-vpn-gw"
  vpc_id            = module.aws_vpc_testbed.vpc_id[0]
  vpc_reg           = var.aws_region
  gw_size           = "t2.micro"
  subnet            = module.aws_vpc_testbed.subnet_cidr[0]

  allocate_new_eip  = true

  vpn_access        = true
  vpn_cidr          = var.avx_vpn_cidr
  vpn_protocol      = "TCP" # default: TCP
  enable_elb        = true
  enable_vpn_nat    = true # default: true
  elb_name          = "elb-splunk-avx-vpn-gw"
  max_vpn_conn      = 100

  split_tunnel      = true # default true
  search_domains    = null
  additional_cidrs  = null
  name_servers      = null
}

# WIP provisioners + .py
resource "null_resource" "ping" {
  depends_on = [
    module.aws_vpc_testbed.instance_state,
    aviatrix_gateway.splunk_avx_vpn_gw
  ]

  triggers = {
    key = uuid()
  }

  # copy private key to public VM instance [1] in VPC [1]
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.private_key} ${var.ssh_user}@${module.aws_vpc_testbed.ubuntu_public_ip[1]}:~/.ssh/id_rsa"
  }

  # copy .py to public VM instance [1] in VPC [1]
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null openvpn.py ${var.ssh_user}@${module.aws_vpc_testbed.ubuntu_public_ip[1]}:/tmp/openvpn.py"
  }
}
