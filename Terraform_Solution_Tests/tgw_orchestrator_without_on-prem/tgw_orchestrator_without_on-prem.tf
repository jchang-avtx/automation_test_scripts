## Creates Spoke VPC1 and VPC2 in Dev Domain, and Spoke VPC3 in Prod Domain.
## Creates VPC4 in Shared Service Domain.
## Both public and private ubuntu instances are created along with VPC creations.
## Creates AWS TGW and add/modify domain connection policies so that Dev and Prod are segregated, but both can access Shared Service.
## Test end-to-end traffic and verify traffic flows are in accordance with domain policies


#this module creates a test environement, you can specify how many vpcs to create
#each vpc has 1 VM in public subnet 1 and 1 VM in private subnet
# VPC1 (Dev Domain) 10.0.0.0/16
# VPC2 (Dev Domain) 20.0.0.0/16
# VPC3 (Prod Domain) 30.0.0.0/16
# VPC4 (Shared Service Domain) 40.0.0.0/16
module "aws-vpc" {
  source              = "github.com/AviatrixSystems/automation_test_scripts/Regression_Testbed_TF_Module/modules/testbed-vpc-aws"
  vpc_count	        	= 4   # VPC1, VPC2, VPC3, VPC4
  resource_name_label	= "tgw_orchesterator"
  pub_hostnum		      = 10
  pri_hostnum		      = 20
  vpc_cidr        	  = ["10.0.0.0/16","20.0.0.0/16","30.0.0.0/16","40.0.0.0/16"]
  pub_subnet1_cidr    = ["10.0.0.0/24","20.0.0.0/24","30.0.0.0/24","40.0.0.0/24"]
  pub_subnet2_cidr    = ["10.0.1.0/24","20.0.1.0/24","30.0.1.0/24","40.0.1.0/24"]
  pri_subnet_cidr     = ["10.0.2.0/24","20.0.2.0/24","30.0.2.0/24","40.0.2.0/24"]
  public_key      	  = "${file(var.public_key)}"
  termination_protection = false
  ubuntu_ami		      = "" # default empty will set to ubuntu 18.04 ami
}

# Create an Aviatrix AWS TGW
resource "aviatrix_aws_tgw" "test_aws_tgw" {
  tgw_name                          = "test-aws-tgw"
  account_name                      = var.aviatrix_aws_access_account
  region                            = var.aws_region
  aws_side_as_number                = "64512"

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = var.edge_domain_connected_list
  }
  security_domains {
    security_domain_name = "Default_Domain"
  }
  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains    = var.shared_service_domain_connected_list
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[3]   #VPC4
      vpc_region         = var.aws_region
    }
  }
  security_domains {
    security_domain_name = "Dev_Domain"
    connected_domains    = var.dev_domain_connected_list
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[0]   #Spoke VPC1
      vpc_region         = var.aws_region
    }
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[1]   #Spoke VPC2
      vpc_region         = var.aws_region
    }
  }
  security_domains {
    security_domain_name = "Prod_Domain"
    connected_domains    = var.prod_domain_connected_list
    attached_vpc {
      vpc_account_name   = var.aviatrix_aws_access_account
      vpc_id             = module.aws-vpc.vpc_id[2]   #Spoke VPC3
      vpc_region         = var.aws_region
    }
  }
}

########## Test to make sure following end-to-end traffic works ##########
# Test intra Dev Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.0.10 (public instance in SpokeVPC2)
# Test Dev-ShareService Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 40.0.0.10 (public instance in SpokeVPC4)
# Test intra Dev Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 20.0.2.20 (private instance in SpokeVPC2)
# Test Dev-ShareService Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 40.0.2.20 (private instance in SpokeVPC4)

########## Test to make sure following end-to-end traffic flows got blocked ##########
# Test Dev-Prod Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 30.0.0.10 (public instance in SpokeVPC3)
# Test Dev-Prod Domain policy - Ping from 10.0.0.10 (public instance in SpokeVPC1) to 30.0.2.20 (private instance in SpokeVPC3)
resource "null_resource" "ping" {
  depends_on = [
    module.aws-vpc.ubuntu_public_ip,
    aviatrix_aws_tgw.test_aws_tgw
  ]

  triggers = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null tgw_orchestrator_without_on-prem.py ${var.ssh_user}@${module.aws-vpc.ubuntu_public_ip[0]}:/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 /tmp/tgw_orchestrator_without_on-prem.py --ping_work_list ${join(",",[for i in [1,3,5,7]: module.aws-vpc.ubuntu_private_ip[i]])} --ping_block_list ${join(",",[for i in [2,6]: module.aws-vpc.ubuntu_private_ip[i]])}"
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
