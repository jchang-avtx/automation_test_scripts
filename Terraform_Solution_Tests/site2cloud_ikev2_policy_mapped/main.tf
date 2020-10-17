## Creates back-to-back IKEv2 Site2Cloud policy-based mapped connection between two Aviatrix gateways
## Test end-to-end traffic between instances and verify IKEv2 Site2Cloud connection
## Note that for policy-based mapped config, it needs to be symmetrical config such as "mapped" on both sides.

#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet and 1 VM in private subnet
# SiteVPC 10.0.0.0/16
# CloudVPC 20.0.0.0/16
module "aws-vpc" {
  source                 = "../../Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	             = 2
  resource_name_label	   = "site2cloud"
  pub_hostnum		         = 10
  pri_hostnum		         = 20
  vpc_cidr        	     = ["10.0.0.0/16","20.0.0.0/16"]
  pub_subnet1_cidr       = ["10.0.0.0/24","20.0.0.0/24"]
  pub_subnet2_cidr       = ["10.0.1.0/24","20.0.1.0/24"]
  pri_subnet_cidr        = ["10.0.2.0/24","20.0.2.0/24"]
  public_key      	     = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		         = "" # default empty will set to ubuntu 18.04 ami
}

#Create Aviatrix gateway in SiteVPC
resource "aviatrix_gateway" "site-gw" {
  cloud_type            = 1
  account_name          = var.aviatrix_aws_access_account
  gw_name               = "Site-GW"
  vpc_id                = module.aws-vpc.vpc_id[0]
  vpc_reg               = var.aws_region
  gw_size               = "t3.small"
  subnet                = module.aws-vpc.subnet_cidr[0]
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
  depends_on = [module.aws-vpc]
}

data "aviatrix_gateway" "site-gw-data" {
  gw_name    = aviatrix_gateway.site-gw.gw_name
  depends_on = [aviatrix_gateway.site-gw]
}

#Create Aviatrix gateway in CloudVPC
resource "aviatrix_gateway" "cloud-gw" {
  cloud_type            = 1
  account_name          = var.aviatrix_aws_access_account
  gw_name               = "Cloud-GW"
  vpc_id                = module.aws-vpc.vpc_id[1]
  vpc_reg               = var.aws_region
  gw_size               = "t3.small"
  subnet                = module.aws-vpc.subnet_cidr[1]
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
  depends_on = [module.aws-vpc]
}

data "aviatrix_gateway" "cloud-gw-data" {
  gw_name    = aviatrix_gateway.cloud-gw.gw_name
  depends_on = [aviatrix_gateway.site-gw]
}

#Create IKEv2 Site2Cloud connection tunnel
resource "aviatrix_site2cloud" "site2cloud" {
  vpc_id                        = aviatrix_gateway.site-gw.vpc_id
  connection_name               = "Site-to-Cloud"
  connection_type               = "mapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "policy"
  enable_ikev2                  = true
  ha_enabled                    = false
  primary_cloud_gateway_name    = aviatrix_gateway.site-gw.gw_name
  remote_gateway_ip             = data.aviatrix_gateway.cloud-gw-data.public_ip
  pre_shared_key                = var.pre_shared_key
  #backup_pre_shared_key        = var.pre_shared_key_backup
  custom_algorithms             = true
  phase_1_authentication        = var.phase_1_authentication
  phase_2_authentication        = var.phase_2_authentication
  phase_1_dh_groups             = var.phase_1_dh_groups
  phase_2_dh_groups             = var.phase_2_dh_groups
  phase_1_encryption            = var.phase_1_encryption
  phase_2_encryption            = var.phase_2_encryption
  remote_subnet_cidr            = "20.0.0.0/16"
  remote_subnet_virtual         = "192.168.0.0/16"
  local_subnet_cidr             = "10.0.0.0/16"
  local_subnet_virtual          = "172.16.0.0/16"
  enable_dead_peer_detection    = true # (Optional)
}

#Create IKEv2 Cloud2Site connection tunnel
resource "aviatrix_site2cloud" "cloud2site" {
  vpc_id                        = aviatrix_gateway.cloud-gw.vpc_id
  connection_name               = "Cloud-to-Site"
  connection_type               = "mapped"
  remote_gateway_type           = "generic"
  tunnel_type                   = "policy"
  enable_ikev2                  = true
  ha_enabled                    = false
  primary_cloud_gateway_name    = aviatrix_gateway.cloud-gw.gw_name
  remote_gateway_ip             = data.aviatrix_gateway.site-gw-data.public_ip
  pre_shared_key                = var.pre_shared_key
  #backup_pre_shared_key        = var.pre_shared_key_backup
  custom_algorithms             = true
  phase_1_authentication        = var.phase_1_authentication
  phase_2_authentication        = var.phase_2_authentication
  phase_1_dh_groups             = var.phase_1_dh_groups
  phase_2_dh_groups             = var.phase_2_dh_groups
  phase_1_encryption            = var.phase_1_encryption
  phase_2_encryption            = var.phase_2_encryption
  remote_subnet_cidr            = "10.0.0.0/16"
  remote_subnet_virtual         = "172.16.0.0/16"
  local_subnet_cidr             = "20.0.0.0/16"
  local_subnet_virtual          = "192.168.0.0/16"
  # ssl_server_pool             = "192.168.45.0/24" # (Optional) for 'tcp' tunnel type
  enable_dead_peer_detection    = true # (Optional)
}

# Test end-to-end traffic
# Ping VM from SiteVPC to VM in CloudVPC using virtual IP address 192.168.x.x
# Ping VM from CloudPC to VM in SiteVPC using virtual IP address 172.16.x.x
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_gateway.site-gw,
    aviatrix_gateway.cloud-gw,
    aviatrix_site2cloud.site2cloud,
    aviatrix_site2cloud.cloud2site,
]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null test_traffic.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[1]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/test_traffic.py --ping_list 192.168.0.10,192.168.2.20"
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

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/test_traffic.py --ping_list 172.16.0.10,172.16.2.20"
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = module.aws-vpc.ubuntu_public_ip[1]
      agent = false
    }
  }

  # Once test is done, copy log file and result file back to local
  provisioner "local-exec" {
    command = "ssh -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[1]} cat /tmp/log.txt >> log.txt"
  }
  provisioner "local-exec" {
    command = "ssh -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[1]} cat /tmp/result.txt >> result.txt"
  }
  provisioner "local-exec" {
    command = "if grep -q 'FAIL' result.txt ; then echo 'FAIL' > result.txt ; else echo 'PASS' > result.txt ; fi"
  }
}
