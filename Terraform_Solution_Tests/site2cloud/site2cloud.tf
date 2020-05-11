## Creates and manages a Site2Cloud connection between Aviatrix gateway and VGW
## Test end-to-end traffic between instances and verify Site2Cloud connection


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# SiteVPC 10.0.0.0/16
# CloudVPC 20.0.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 2
  resource_name_label	= "site2cloud"
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

#Create Aviatrix gateway in CloudVPC
resource "aviatrix_gateway" "AVX-GW" {
  cloud_type    = 1
  account_name  = var.aviatrix_aws_access_account
  gw_name       = "AVX-GW"
  vpc_id        = module.aws-vpc.vpc_id[1]
  vpc_reg       = var.aws_region
  gw_size       = "t2.micro"
  subnet        = module.aws-vpc.subnet_cidr[1]
  single_ip_snat   = true
  enable_vpc_dns_server = false

  lifecycle {
    ignore_changes = [enable_vpc_dns_server]
  }
}
    
data "aviatrix_gateway" "ag_data" {
  gw_name = "AVX-GW"
  depends_on = [aviatrix_gateway.AVX-GW]
}
    
#Create AWS VGW and attach to Site VPC
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = module.aws-vpc.vpc_id[0]
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = data.aviatrix_gateway.ag_data.public_ip
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id        = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id   = aws_customer_gateway.customer_gateway.id
  type                  = "ipsec.1"
  static_routes_only    = true
  tunnel1_preshared_key = var.pre_shared_key
  tunnel2_preshared_key = var.pre_shared_key
}

# Add static route under AWS VPN Connection in order to connect to CloudVPC
resource "aws_vpn_connection_route" "to_cloud" {
  destination_cidr_block = "20.0.0.0/16"
  vpn_connection_id      = aws_vpn_connection.main.id
}

#Add cloud VPC cidr route to VGW route table
data "aws_subnet" "selected" {
  cidr_block = module.aws-vpc.subnet_cidr[0]
}
data "aws_route_table" "selected" {
  subnet_id   = data.aws_subnet.selected.id
  depends_on  = [aviatrix_gateway.AVX-GW]
}
resource "aws_route" "route" {
  route_table_id          = data.aws_route_table.selected.id
  destination_cidr_block  = "20.0.0.0/16"
  gateway_id              = aws_vpn_gateway.vpn_gateway.id
}

#Create Site2Cloud connection tunnel
resource "aviatrix_site2cloud" "s2c_test" {
  vpc_id                        = aviatrix_gateway.AVX-GW.vpc_id
  connection_name               = "s2c_test_conn_name"
  connection_type               = "unmapped"
  remote_gateway_type           = "aws"
  tunnel_type                   = "udp"
  ha_enabled                    = false
  primary_cloud_gateway_name    = aviatrix_gateway.AVX-GW.gw_name
  remote_gateway_ip             = aws_vpn_connection.main.tunnel1_address
  pre_shared_key                = var.pre_shared_key
  #backup_pre_shared_key        = var.pre_shared_key_backup
  custom_algorithms             = true
  phase_1_authentication        = "SHA-1"
  phase_2_authentication        = "HMAC-SHA-1"
  phase_1_dh_groups             = "2"
  phase_2_dh_groups             = "2"
  phase_1_encryption            = "AES-128-CBC"
  phase_2_encryption            = "AES-128-CBC"

  remote_subnet_cidr            = "10.0.0.0/16"
  local_subnet_cidr             = "20.0.0.0/16"

  # ssl_server_pool             = "192.168.45.0/24" # (Optional) for 'tcp' tunnel type
  enable_dead_peer_detection    = true # (Optional)
}

# Test end-to-end traffic
# Ping VM from SiteVPC to other public and private VMs in CloudVPC
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_gateway.AVX-GW,
    aviatrix_site2cloud.s2c_test,
    aws_vpn_connection_route.to_cloud,
    aws_route.route
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null site2cloud.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/site2cloud.py --ping_list ${join(",",[for i in range(1,4,2): module.aws-vpc.ubuntu_private_ip[i]])}"
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
