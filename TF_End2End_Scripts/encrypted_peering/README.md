## Aviatrix Terraform Module - Encrypted Peering Test

### Description

This Terraform configuration creates an AWS VPC testbed environment with ubuntu instances, sets up Aviatrix access accounts, launched 2 aviatrix gateways, and creates an encrypted peering between the aviatrix gateways. The peering is tested by ssh into a remote host, pinging the other VM's, then copying the ping output from the remote host into the local machine.

### Usage
```
provider "aws" {
  region     = ""
  access_key = local.access_key
  secret_key = local.secret_key
}

provider "aviatrix" {
	controller_ip	= ""
	username			= "admin"
	password			= ""
}

module "encrypted-peering" {
  source = "./encrypted_peering"
  aws_account_number = ""
  aws_access_key     = local.access_key
  aws_secret_key     = local.secret_key
  public_key         = file("<<filepath to public key>>")
  #private_key       = file("<<filepath to private key>>")
  ssh_agent          = true                   #default is true
}

locals {
  access_key     = ""
  secret_key     = ""
}
```

### Variables

- **aws_account_number**

AWS account number for creating aviatrix account. Required.

- **aws_access_key**

AWS access key for creating aviatrix account. Required.

- **aws_secret_key**

AWS secret key for creating aviatrix account. Required.

- **public_key**

Public key to be used for creating key pairs for aws instances. Required.

- **private_key**

Private key to be used for ssh into aws instances. Optional, by default uses ssh-agent instead.

- **ssh_agent**

Whether or not to authenticate using ssh-agent. On Windows, only Pageant is supported. Default is true. Can specify to use private key authentication instead.

- **resource_name_label**

Name of label for AWS resources created. Default is "encrypted-peering".

- **ssh_user**

Name of user when ssh into aws instance. Default is "ubuntu".

- **access_account_name**

Aviatrix access account name. Default is "test-aws-acc".
